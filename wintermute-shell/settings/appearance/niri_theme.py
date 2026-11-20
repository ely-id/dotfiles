#!/usr/bin/env python3
"""Escreve o arquivo da shell na configuração do Niri: o anel de foco no acento da variação, o recuo das bordas e o raio das janelas.

Uso:
  niri_theme.py check    --accent "#RRGGBB" [--output ARQUIVO]
  niri_theme.py generate --accent "#RRGGBB" [--output ARQUIVO]

A shell chama o `generate` quando começa e toda vez que a variação (Chiba, Freeside, Sprawl) muda. O arquivo é só
dela: `~/.config/niri/cfg/wintermute.kdl` (ou o que `XDG_CONFIG_HOME` apontar). Por isso, ao contrário do
keybinds.py, aqui não existe --apply. Em troca, eu nunca escrevo por cima de um arquivo que já existe sem o marcador
`[wintermute]` na primeira linha, para jamais passar por cima de um arquivo meu. `check` só mostra o que escreveria.
Se o destino é um link simbólico, escrevo no alvo e o link continua link. Um link quebrado vira arquivo novo no alvo.
Um laço de links simbólicos no caminho é erro, e nada é escrito.
Só uso a biblioteca padrão.
"""

import argparse
import errno
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

MARCADOR = "[wintermute]"
# Uso fullmatch, não match com `$`: no `re` do Python o `$` casa antes de uma quebra de linha final, e um "#52C2F6\n"
# passaria e quebraria a string do KDL em duas linhas.
RE_COR = re.compile(r"#[0-9A-Fa-f]{6}")

# Largura do anel (ficha 19, estado 1: anel de acento de 2 px) e raio das janelas (ficha 19, "raios (12)"; ficha 17, o
# anel de 14 da captura em volta de uma janela de 12).
LARGURA_DO_ANEL = 2
RAIO_DAS_JANELAS = 12
# Recuo das bordas (ficha 19, "Folga das janelas", P-88). No board dos desktops as janelas ficam a 12 da zona da barra, do
# topo, da base e da direita, e a 16 uma da outra. O Niri só tem um `gaps`, que vale para os dois, então o `gaps 16` do meu
# layout.kdl dá os 16 entre colunas e um strut negativo tira das bordas o que sobra: 12 - 16 = -4, nos quatro lados.
RECUO_DAS_BORDAS = -4


class Erro(Exception):
    pass


def destino_padrao():
    base = os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config")
    return Path(base) / "niri" / "cfg" / "wintermute.kdl"


def resolver_destino(caminho):
    """Segue o link simbólico até o alvo. Na F8 a pasta niri/ do repositório pode ser ligada por link à ~/.config, e eu
    tenho de escrever no alvo e deixar o link como está. Link quebrado devolve o caminho do alvo, que será criado.

    Um laço de links (a -> b -> a, ou um link para si mesmo), no arquivo ou numa pasta do caminho, é erro (P-89). Sem
    isto o realpath devolvia o próprio link, ele parecia um arquivo que não existe, e a troca atômica punha um arquivo
    comum no lugar do link, sem avisar."""
    caminho = Path(caminho).expanduser()
    try:
        # strict: quero o ELOOP do sistema em vez do caminho devolvido pela metade.
        return Path(os.path.realpath(caminho, strict=True))
    except FileNotFoundError:
        # Ainda não existe, ou é um link quebrado: sigo com o alvo, que será criado.
        destino = Path(os.path.realpath(caminho))
    except OSError as e:
        if e.errno == errno.ELOOP:
            raise Erro("%s passa por um laço de links simbólicos. Não escrevo nada: conserto o link e tento de novo" % caminho)
        raise Erro("não consegui resolver %s: %s" % (caminho, e))
    if destino.is_symlink():
        # O realpath sem strict para no primeiro link que não consegue seguir. Se o que sobrou ainda é link, escrever
        # ali trocaria o link por um arquivo comum.
        raise Erro("%s é um link simbólico que não consegui seguir até o fim. Não escrevo nada" % destino)
    return destino


def normalizar_cor(texto):
    """Só aceito #RRGGBB. Devolvo em maiúsculas, que é como a shell e o arquivo escrevem."""
    if not isinstance(texto, str) or not RE_COR.fullmatch(texto):
        raise Erro("cor inválida: %r. Preciso de #RRGGBB, ex. \"#52C2F6\"" % (texto,))
    return texto.upper()


def gerar(cor):
    return "\n".join([
        "// %s Gerado pela shell, por wintermute-shell/settings/appearance/niri_theme.py. Não edito este arquivo à mão:" % MARCADOR,
        "// a shell o reescreve quando a variação muda. Ele só vale com `include \"./cfg/wintermute.kdl\"` no fim do config.kdl.",
        "// Para desfazer: tiro essa linha do config.kdl e apago este arquivo.",
        "layout {",
        "    focus-ring {",
        "        width %d" % LARGURA_DO_ANEL,
        "        active-color \"%s\" // o acento da variação em uso" % cor,
        "    }",
        "    // Com o `gaps 16` do layout.kdl: 12 entre as janelas e as bordas (e a zona da barra), 16 entre uma coluna e a outra.",
        "    struts {",
        "        left %d" % RECUO_DAS_BORDAS,
        "        right %d" % RECUO_DAS_BORDAS,
        "        top %d" % RECUO_DAS_BORDAS,
        "        bottom %d" % RECUO_DAS_BORDAS,
        "    }",
        "}",
        "",
        "// Raio 12 em todas as janelas, depois do 20 do rules.kdl. O anel acompanha o raio da janela.",
        "window-rule {",
        "    geometry-corner-radius %d" % RAIO_DAS_JANELAS,
        "    clip-to-geometry true",
        "}",
        "",
    ])


def situacao(destino, texto):
    """O que aconteceria com o arquivo: "novo", "igual", "muda", ou um Erro se ele não é meu."""
    if not destino.exists():
        return "novo"
    if destino.is_dir():
        raise Erro("%s é uma pasta" % destino)
    try:
        atual = destino.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as e:
        raise Erro("não consegui ler %s: %s" % (destino, e))
    primeira = atual.split("\n", 1)[0]
    if MARCADOR not in primeira:
        raise Erro("%s já existe e não tem o marcador %s na primeira linha. Não é meu, então não escrevo nele" % (destino, MARCADOR))
    return "igual" if atual == texto else "muda"


def validar_no_niri(texto):
    """Passa o texto pelo `niri validate` antes de trocar o arquivo. Sem o niri, aviso e sigo."""
    if shutil.which("niri") is None:
        print("aviso: `niri` não está no PATH; não validei o arquivo antes de escrever", file=sys.stderr)
        return
    with tempfile.TemporaryDirectory() as pasta:
        arquivo = Path(pasta) / "config.kdl"
        arquivo.write_text(texto, encoding="utf-8")
        r = subprocess.run(["niri", "validate", "-c", str(arquivo)], capture_output=True, text=True)
    if r.returncode != 0:
        raise Erro("o `niri validate` recusou o arquivo, então não escrevi nada:\n%s" % (r.stdout + r.stderr).strip())


def escrever(texto, destino):
    # `destino` já é o alvo final (resolver_destino), então o provisório nasce na pasta do alvo e o os.replace não
    # atravessa sistemas de arquivos nem troca um link por arquivo comum.
    destino.parent.mkdir(parents=True, exist_ok=True)
    # Escrevo num arquivo ao lado e troco de nome, para o Niri (que observa o arquivo) nunca ler um pela metade.
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=destino.parent, prefix=destino.name + ".", suffix=".tmp", delete=False) as f:
        f.write(texto)
        provisorio = f.name
    try:
        os.replace(provisorio, destino)
    except OSError:
        # Não deixo o provisório para trás se a troca falhar.
        try:
            os.unlink(provisorio)
        except OSError:
            pass
        raise


def comando_check(args):
    destino = resolver_destino(args.output or destino_padrao())
    texto = gerar(normalizar_cor(args.accent))
    estado = situacao(destino, texto)
    print("%s: %s" % (destino, {"novo": "seria criado", "igual": "já está assim, não seria reescrito", "muda": "seria reescrito"}[estado]), file=sys.stderr)
    sys.stdout.write(texto)


def comando_generate(args):
    destino = resolver_destino(args.output or destino_padrao())
    texto = gerar(normalizar_cor(args.accent))
    estado = situacao(destino, texto)
    if estado == "igual":
        # Não reescrevo: o Niri recarrega a configuração a cada mudança num arquivo incluído, e não quero isso à toa.
        print("sem mudança em %s" % destino)
        return
    validar_no_niri(texto)
    try:
        escrever(texto, destino)
    except OSError as e:
        raise Erro("não consegui escrever em %s: %s" % (destino, e))
    print("%s %s" % ("criei" if estado == "novo" else "atualizei", destino))


def main(argv=None):
    p = argparse.ArgumentParser(description="Escreve o anel de foco no acento da variação, o recuo das bordas e o raio das janelas do Niri.")
    sub = p.add_subparsers(dest="comando", required=True)
    for nome, ajuda, funcao in (("check", "mostra o que escreveria, sem escrever", comando_check),
                                ("generate", "escreve o arquivo da shell na configuração do Niri", comando_generate)):
        c = sub.add_parser(nome, help=ajuda)
        c.add_argument("--accent", required=True, metavar="#RRGGBB", help="o acento da variação em uso")
        c.add_argument("--output", metavar="ARQUIVO", help="onde escrever (padrão: niri/cfg/wintermute.kdl dentro de XDG_CONFIG_HOME ou ~/.config)")
        c.set_defaults(funcao=funcao)

    args = p.parse_args(argv)
    try:
        args.funcao(args)
    except Erro as e:
        print("erro: %s" % e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
