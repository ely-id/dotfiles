#!/usr/bin/env python3
"""Hook PreToolUse dos subagentes do ciclo: apagar arquivo só em lugar seguro.

O hook so-no-repositorio.py vigia as ferramentas de edição, mas um rm rodado
no terminal passava direto. Na S21 um rm mal escrito num script de teste do
dev-shell apagou um papel de parede do repositório; o git devolveu, mas o
mesmo erro com um caminho na minha pasta pessoal não teria volta.

Leio o comando de terminal que o subagente vai rodar, acho cada rm, rmdir,
unlink, shred e find -delete, e confiro os caminhos. Passa o que fica dentro
do repositório ou numa pasta temporária (/tmp, $TMPDIR, $XDG_RUNTIME_DIR e o
cache da bancada). Caminho que eu não consigo resolver (com variável, crase ou
glob fora de lugar seguro) é recusado: o subagente reescreve com o caminho
explícito.

Limite conhecido: apagar por dentro de um script Python (os.remove,
shutil.rmtree) não passa por aqui. A instrução dos subagentes cobre esse caso.

Saída 2 recusa, com o motivo em stderr; saída 0 deixa passar.
"""

import json
import os
import re
import shlex
import sys
from pathlib import Path

repo = Path(os.environ.get("CLAUDE_PROJECT_DIR") or Path(__file__).resolve().parents[2]).resolve()
home = Path.home()
seguros = [repo, Path("/tmp"), Path("/var/tmp"), home / ".cache" / "dotfiles-bancada"]
for var in ("TMPDIR", "XDG_RUNTIME_DIR"):
    if os.environ.get(var):
        seguros.append(Path(os.environ[var]))
seguros = [Path(os.path.realpath(p)) for p in seguros]

APAGAM = {"rm", "rmdir", "unlink", "shred"}

try:
    entrada = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

comando = (entrada.get("tool_input") or {}).get("command") or ""
cwd_inicial = Path(entrada.get("cwd") or repo)
# A pasta corrente acompanha os cd do próprio comando; None quando não sei onde estou.
estado = {"cwd": cwd_inicial}


def resolver(caminho: str, base):
    if re.search(r"[$`]", caminho):
        return None
    alvo = Path(os.path.expanduser(caminho))
    if not alvo.is_absolute():
        if base is None:
            return None
        alvo = base / alvo
    return alvo


def seguro(caminho: str) -> bool:
    alvo = resolver(caminho, estado["cwd"])
    if alvo is None:
        return False
    # Um glob é julgado pela pasta que ele varre.
    partes = []
    for parte in alvo.parts:
        if re.search(r"[*?\[]", parte):
            break
        partes.append(parte)
    base = Path(*partes) if partes else Path("/")
    real = Path(os.path.realpath(base))
    if real in (Path("/"), home, Path(os.path.realpath(home))):
        return False
    return any(real == s or real.is_relative_to(s) for s in seguros)


def analisar(texto: str, problemas: list) -> None:
    for trecho in re.split(r"&&|\|\||;|\||\n", texto):
        try:
            tokens = shlex.split(trecho, comments=True)
        except ValueError:
            tokens = trecho.split()
        # Comando dentro de comando (bash -c "...", sudo, xargs) é olhado também.
        for tok in tokens:
            if " " in tok and re.search(r"\b(rm|rmdir|unlink|shred|find)\b", tok):
                analisar(tok, problemas)
        if tokens and tokens[0] in {"cd", "pushd"}:
            destino = tokens[1] if len(tokens) > 1 else "~"
            novo = resolver(destino, estado["cwd"])
            estado["cwd"] = Path(os.path.realpath(novo)) if novo is not None else None
            continue
        for i, tok in enumerate(tokens):
            nome = os.path.basename(tok)
            if nome in APAGAM:
                args = [t for t in tokens[i + 1:] if not t.startswith("-")]
                fim = next((k for k, t in enumerate(args) if t in {"&", ">", ">>", "2>"}), len(args))
                for caminho in args[:fim]:
                    if not seguro(caminho):
                        problemas.append(f"{nome} {caminho}")
            elif nome == "find" and "-delete" in tokens[i + 1:]:
                raizes = []
                for t in tokens[i + 1:]:
                    if t.startswith("-") or t in {"(", "!"}:
                        break
                    raizes.append(t)
                for caminho in raizes or ["."]:
                    if not seguro(caminho):
                        problemas.append(f"find {caminho} -delete")


problemas: list = []
analisar(comando, problemas)
if problemas:
    print(
        "Comando recusado: ele apagaria fora do repositório ou de uma pasta temporária, "
        f"ou com um caminho que não consigo resolver: {', '.join(problemas)}. "
        f"No ciclo, os subagentes só apagam dentro de {repo} ou em /tmp, $TMPDIR e no cache da bancada, "
        "com o caminho escrito por extenso.",
        file=sys.stderr,
    )
    sys.exit(2)
sys.exit(0)
