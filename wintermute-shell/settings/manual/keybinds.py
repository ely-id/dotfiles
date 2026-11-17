#!/usr/bin/env python3
"""Gera as binds do Niri a partir do shortcuts.json, a lista única de atalhos da Wintermute Shell.

Uso:
  keybinds.py check    [--list ARQUIVO]
  keybinds.py generate [--list ARQUIVO] [--shell CAMINHO] [--output ARQUIVO [--apply]]

O shortcuts.json diz, para cada atalho, a tecla do Niri, a descrição e a ação. O Manual da shell
(State.qml) tira dele as teclas que mostra, e este script tira dele o bloco `binds { }` do Niri. Os dois
saem da mesma lista, então os dois não divergem. Só uso a biblioteca padrão.
"""

import argparse
import datetime
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

AQUI = Path(__file__).resolve().parent
LISTA_PADRAO = AQUI / "shortcuts.json"
# settings/manual/ -> settings/ -> wintermute-shell/
SHELL_PADRAO = AQUI.parents[1]

ACOES = ("niri", "spawn", "sh", "ipc")
MODIFICADORES = ("Mod", "Super", "Ctrl", "Shift", "Alt")

# Campos que cada tipo de item aceita. Qualquer outro é erro: um campo escrito errado some em silêncio
# no Niri (a bind sai sem a propriedade), então prefiro recusar.
CAMPOS_SECAO = {"section"}
CAMPOS_SIMPLES = {"bind", "label", "options", "manual", "waits", "keys", "overlay", *ACOES}
CAMPOS_VARIAS = {"keys", "label", "binds"}
CAMPOS_SUB = {"bind", "options", *ACOES}

RE_BIND = re.compile(r"^(?:(?:%s)\+)*[A-Za-z0-9_]+$" % "|".join(MODIFICADORES))
RE_OPCOES = re.compile(r"^[a-z][a-z0-9-]*=[^\s\"]+(?: [a-z][a-z0-9-]*=[^\s\"]+)*$")

# Largura mínima da coluna da tecla, a mesma do meu keybinds.kdl, para o arquivo gerado ter a cara dele.
COLUNA_MINIMA = 36


class Erro(Exception):
    pass


# ───────────────────────────── leitura e conferência ─────────────────────────────

def carregar(caminho):
    try:
        with open(caminho, encoding="utf-8") as f:
            dados = json.load(f)
    except OSError as e:
        raise Erro("não consegui abrir %s: %s" % (caminho, e.strerror))
    except json.JSONDecodeError as e:
        raise Erro("%s não é um JSON válido (linha %d, coluna %d): %s" % (caminho, e.lineno, e.colno, e.msg))
    if not isinstance(dados, list):
        raise Erro("%s tem de ser uma lista de itens" % caminho)
    return dados


def _texto(valor):
    return isinstance(valor, str) and valor.strip() != ""


def _normalizada(bind):
    """Forma para comparar binds: o Niri não liga para maiúsculas nem para a ordem dos modificadores."""
    partes = bind.lower().split("+")
    return (tuple(sorted(set(partes[:-1]))), partes[-1])


def _conferir_acao(d, onde, erros, com_waits=False):
    """Confere que há uma ação só (ou `waits`, no lugar dela) e que o texto dela é válido."""
    presentes = [a for a in ACOES if a in d]
    for a in presentes:
        if not _texto(d[a]):
            erros.append("%s: `%s` tem de ser um texto não vazio" % (onde, a))
    if len(presentes) > 1:
        erros.append("%s: mais de uma ação (%s); deixo só uma" % (onde, ", ".join(presentes)))
    if com_waits and "waits" in d:
        if not _texto(d["waits"]):
            erros.append("%s: `waits` tem de ser a fase em que a ação passa a existir, ex. \"F5\"" % onde)
        if presentes:
            erros.append("%s: tem `waits` e ação ao mesmo tempo; `waits` é só para o atalho cuja ação ainda não existe" % onde)
    elif not presentes:
        erros.append("%s: sem ação (use `niri`, `spawn`, `sh` ou `ipc`%s)" % (onde, ", ou `waits` se a ação ainda não existe" if com_waits else ""))
    if "options" in d and not (isinstance(d["options"], str) and RE_OPCOES.match(d["options"])):
        erros.append("%s: `options` tem de ser texto no formato `nome=valor`, ex. \"cooldown-ms=150\"" % onde)


def _conferir_bind(d, onde, vistas, erros):
    bind = d.get("bind")
    if not _texto(bind):
        erros.append("%s: falta `bind`" % onde)
        return
    if not RE_BIND.match(bind):
        erros.append("%s: `bind` \"%s\" não está no formato do Niri, ex. \"Mod+Shift+A\" (modificadores: %s)" % (onde, bind, ", ".join(MODIFICADORES)))
        return
    chave = _normalizada(bind)
    if chave in vistas:
        erros.append("%s: bind repetida: %s já é usada em %s" % (onde, bind, vistas[chave]))
    else:
        vistas[chave] = onde


def _conferir_keys(d, onde, erros, obrigatoria):
    if "keys" not in d:
        if obrigatoria:
            erros.append("%s: falta `keys`, as teclas que o Manual mostra" % onde)
        return
    if not (isinstance(d["keys"], list) and d["keys"] and all(_texto(k) for k in d["keys"])):
        erros.append("%s: `keys` tem de ser uma lista de textos, ex. [\"Super\", \"Q\"]" % onde)


def conferir(itens):
    """Devolve a lista de erros (vazia quando a lista está certa)."""
    erros = []
    vistas = {}
    for n, item in enumerate(itens, 1):
        nome = (item.get("section") or item.get("bind") or item.get("label")) if isinstance(item, dict) else None
        onde = "item %d%s" % (n, " (%s)" % nome if nome else "")
        if not isinstance(item, dict):
            erros.append("%s: tem de ser um objeto { ... }" % onde)
            continue

        if "section" in item:
            if not _texto(item["section"]):
                erros.append("%s: `section` tem de ser um texto não vazio" % onde)
            extras = sorted(set(item) - CAMPOS_SECAO)
            if extras:
                erros.append("%s: campo desconhecido numa seção: %s" % (onde, ", ".join(extras)))
            continue

        if "binds" in item:
            extras = sorted(set(item) - CAMPOS_VARIAS)
            if extras:
                erros.append("%s: campo desconhecido: %s (uma linha com várias binds aceita só %s)" % (onde, ", ".join(extras), ", ".join(sorted(CAMPOS_VARIAS))))
            _conferir_keys(item, onde, erros, obrigatoria=True)
            if not _texto(item.get("label")):
                erros.append("%s: falta `label`" % onde)
            subs = item["binds"]
            if not (isinstance(subs, list) and subs):
                erros.append("%s: `binds` tem de ser uma lista com pelo menos uma bind" % onde)
                continue
            for k, sub in enumerate(subs, 1):
                onde_sub = "%s, bind %d%s" % (onde, k, " (%s)" % sub["bind"] if isinstance(sub, dict) and _texto(sub.get("bind")) else "")
                if not isinstance(sub, dict):
                    erros.append("%s: tem de ser um objeto { ... }" % onde_sub)
                    continue
                extras = sorted(set(sub) - CAMPOS_SUB)
                if extras:
                    erros.append("%s: campo desconhecido: %s" % (onde_sub, ", ".join(extras)))
                _conferir_bind(sub, onde_sub, vistas, erros)
                _conferir_acao(sub, onde_sub, erros)
            continue

        extras = sorted(set(item) - CAMPOS_SIMPLES)
        if extras:
            erros.append("%s: campo desconhecido: %s" % (onde, ", ".join(extras)))
        if "manual" in item and not isinstance(item["manual"], bool):
            erros.append("%s: `manual` tem de ser true ou false" % onde)
        if "overlay" in item:
            if not isinstance(item["overlay"], bool):
                erros.append("%s: `overlay` tem de ser true ou false" % onde)
            elif item["overlay"] and item.get("manual") is False:
                erros.append("%s: `overlay: true` com `manual: false`: o título vem do `label` do Manual, e este atalho não aparece lá" % onde)
        _conferir_keys(item, onde, erros, obrigatoria=False)
        if item.get("manual") is not False and not _texto(item.get("label")):
            erros.append("%s: falta `label`, o texto que o Manual mostra" % onde)
        elif "label" in item and not _texto(item["label"]):
            erros.append("%s: `label` tem de ser um texto não vazio" % onde)
        _conferir_bind(item, onde, vistas, erros)
        _conferir_acao(item, onde, erros, com_waits=True)
    return erros


def linhas_no_manual(itens):
    return sum(1 for i in itens if "section" not in i and i.get("manual") is not False)


# ───────────────────────────── geração do KDL ─────────────────────────────

def kdl_texto(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def caminho_da_shell(opcao):
    """A pasta da shell como vai no comando de IPC. Sem a opção, uso a pasta onde este script mora, com o
    começo igual a $HOME trocado por ~, para nenhum caminho pessoal ficar escrito no repositório."""
    if opcao is not None:
        return opcao
    p = str(SHELL_PADRAO)
    casa = str(Path.home())
    if p == casa or p.startswith(casa + os.sep):
        p = "~" + p[len(casa):]
    return p


def para_o_sh(caminho):
    """O caminho escrito para o `sh -c` do Niri. O `~` do começo tem de ficar sem aspas para o shell expandir."""
    if caminho == "~":
        return caminho
    if caminho.startswith("~/"):
        return "~/" + shlex.quote(caminho[2:])
    return shlex.quote(caminho)


def acao_kdl(d, pasta_da_shell):
    if "niri" in d:
        return d["niri"]
    if "spawn" in d:
        return "spawn " + kdl_texto(d["spawn"])
    if "sh" in d:
        return "spawn-sh " + kdl_texto(d["sh"])
    comando = "qs -p %s ipc call %s" % (para_o_sh(pasta_da_shell), d["ipc"])
    return "spawn-sh " + kdl_texto(comando)


def entradas(itens, pasta_da_shell):
    """Separa a lista em seções. Cada entrada é um dicionário com bind, props, ação e (se espera) a fase."""
    secoes = [{"nome": None, "entradas": []}]
    for item in itens:
        if "section" in item:
            secoes.append({"nome": item["section"], "entradas": []})
            continue
        # O `hotkey-overlay-title` só entra no atalho simples com `"overlay": true`. Título em toda bind
        # encheria o overlay do Niri; sem ele, o Niri usa a descrição dele. As linhas com várias binds não
        # aceitam o campo.
        simples = "binds" not in item
        com_titulo = simples and item.get("overlay") is True
        for sub in (item["binds"] if not simples else [item]):
            props = []
            if sub.get("options"):
                props.append(sub["options"])
            if com_titulo:
                props.append("hotkey-overlay-title=" + kdl_texto(item["label"]))
            if "waits" in sub:
                secoes[-1]["entradas"].append({"bind": sub["bind"], "props": props, "espera": sub["waits"]})
            else:
                secoes[-1]["entradas"].append({"bind": sub["bind"], "props": props, "acao": acao_kdl(sub, pasta_da_shell)})
    return secoes


def gerar(itens, pasta_da_shell):
    secoes = entradas(itens, pasta_da_shell)
    todas = [e for s in secoes for e in s["entradas"]]
    largura = max(COLUNA_MINIMA, max(len(e["bind"]) for e in todas) + 2)

    saida = [
        "// [wintermute] Gerado por wintermute-shell/settings/manual/keybinds.py a partir de",
        "// wintermute-shell/settings/manual/shortcuts.json. Não edito este arquivo à mão: edito o",
        "// shortcuts.json e gero de novo.",
        "// https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings",
        "binds {",
    ]
    for secao in secoes:
        if not secao["entradas"]:
            continue
        saida.append("")
        if secao["nome"]:
            saida.append("    // ─── %s ───" % secao["nome"])
        # Alinho também a coluna das ações dentro da seção, para a leitura descer reta.
        textos = [" ".join(e["props"]) for e in secao["entradas"]]
        largura_props = max(len(t) for t in textos)
        for e, props in zip(secao["entradas"], textos):
            if "espera" in e:
                # Comentada: a ação só existe numa fase futura e eu não invento o alvo de IPC dela.
                prefixo = "// [%s] " % e["espera"]
                linha = "    " + prefixo + e["bind"].ljust(max(largura - len(prefixo), len(e["bind"]) + 2)) + props
                saida.append("%s  (a ação entra na %s)" % (linha.rstrip(), e["espera"]))
            else:
                coluna_props = (props.ljust(largura_props) + " ") if largura_props else ""
                saida.append("    " + e["bind"].ljust(largura) + coluna_props + "{ " + e["acao"] + "; }")
    saida.append("}")
    return "\n".join(saida) + "\n"


# ───────────────────────────── escrita ─────────────────────────────

def dentro_de_config(caminho):
    """Verdadeiro se o caminho cai dentro de ~/.config (ou de $XDG_CONFIG_HOME), seguindo links simbólicos."""
    alvo = Path(caminho).expanduser().resolve()
    raizes = {(Path.home() / ".config").resolve()}
    if os.environ.get("XDG_CONFIG_HOME"):
        raizes.add(Path(os.environ["XDG_CONFIG_HOME"]).expanduser().resolve())
    return any(alvo == r or r in alvo.parents for r in raizes)


def validar_no_niri(texto):
    """Passa o texto pelo `niri validate` antes de aplicar. Sem o niri instalado, só aviso."""
    if shutil.which("niri") is None:
        print("aviso: `niri` não está no PATH; não validei a saída antes de aplicar", file=sys.stderr)
        return
    with tempfile.TemporaryDirectory() as pasta:
        arquivo = Path(pasta) / "config.kdl"
        arquivo.write_text(texto, encoding="utf-8")
        r = subprocess.run(["niri", "validate", "-c", str(arquivo)], capture_output=True, text=True)
    if r.returncode != 0:
        raise Erro("o `niri validate` recusou o arquivo gerado, então não apliquei nada:\n%s" % (r.stdout + r.stderr).strip())


def escrever(texto, destino, aplicar):
    destino = Path(destino).expanduser()
    if dentro_de_config(destino) and not aplicar:
        raise Erro("%s fica dentro de ~/.config. Recuso escrever lá sem --apply, que guarda uma cópia antes." % destino)
    if aplicar:
        validar_no_niri(texto)
        if destino.exists():
            copia = destino.with_name("%s.bak-%s" % (destino.name, datetime.datetime.now().strftime("%Y%m%d-%H%M%S")))
            shutil.copy2(destino, copia)
            print("cópia guardada em %s" % copia, file=sys.stderr)
    destino.parent.mkdir(parents=True, exist_ok=True)
    # Escrevo num arquivo ao lado e troco de nome, para o Niri nunca ler um arquivo pela metade.
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=destino.parent, prefix=destino.name + ".", suffix=".tmp", delete=False) as f:
        f.write(texto)
        provisorio = f.name
    os.replace(provisorio, destino)


# ───────────────────────────── linha de comando ─────────────────────────────

def comando_check(args):
    itens = carregar(args.list)
    erros = conferir(itens)
    if erros:
        raise Erro("%d erro(s) em %s:\n  - %s" % (len(erros), args.list, "\n  - ".join(erros)))
    binds = sum(len(i["binds"]) if "binds" in i else 1 for i in itens if "section" not in i)
    esperando = sum(1 for i in itens if "waits" in i)
    print("ok: %d binds (%d esperando a ação), %d linhas no Manual" % (binds, esperando, linhas_no_manual(itens)))


def comando_generate(args):
    itens = carregar(args.list)
    erros = conferir(itens)
    if erros:
        raise Erro("não gerei nada: %d erro(s) em %s:\n  - %s" % (len(erros), args.list, "\n  - ".join(erros)))
    texto = gerar(itens, caminho_da_shell(args.shell))
    if args.apply and not args.output:
        raise Erro("--apply precisa de --output")
    if args.output:
        escrever(texto, args.output, args.apply)
    else:
        sys.stdout.write(texto)


def main(argv=None):
    p = argparse.ArgumentParser(description="Confere e gera as binds do Niri a partir do shortcuts.json.")
    sub = p.add_subparsers(dest="comando", required=True)

    c = sub.add_parser("check", help="confere o shortcuts.json")
    c.add_argument("--list", default=str(LISTA_PADRAO), metavar="ARQUIVO", help="outro shortcuts.json (padrão: o da shell)")
    c.set_defaults(funcao=comando_check)

    g = sub.add_parser("generate", help="escreve o bloco `binds { }` do Niri")
    g.add_argument("--list", default=str(LISTA_PADRAO), metavar="ARQUIVO", help="outro shortcuts.json (padrão: o da shell)")
    g.add_argument("--shell", metavar="CAMINHO", help="pasta da shell no comando de IPC (padrão: a pasta desta shell, com ~)")
    g.add_argument("--output", metavar="ARQUIVO", help="onde escrever (padrão: a saída padrão)")
    g.add_argument("--apply", action="store_true", help="permite escrever dentro de ~/.config, guardando antes uma cópia .bak-AAAAMMDD-HHMMSS")
    g.set_defaults(funcao=comando_generate)

    args = p.parse_args(argv)
    try:
        args.funcao(args)
    except Erro as e:
        print("erro: %s" % e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
