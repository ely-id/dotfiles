#!/usr/bin/env python3
"""Gera emoji.json, o inventário do seletor de emoji do launcher (ficha 16).

Leio cinco fontes de uma pasta que passo como argumento. As fontes cruas não
entram no repositório: só este script, o arquivo gerado e a cópia da licença
do Unicode (LICENSE-unicode.txt). De onde cada uma vem:

  emoji-test-17.txt   https://unicode.org/Public/17.0.0/emoji/emoji-test.txt
                      (Emoji 17.0: a lista, a ordem e os grupos)
  ann-en.json         https://raw.githubusercontent.com/unicode-org/cldr-json/48.0.0/cldr-json/cldr-annotations-full/annotations/en/annotations.json
  ann-pt.json         o mesmo caminho com .../annotations/pt/annotations.json
                      (CLDR 48: nome e palavras-chave de cada emoji, em inglês e em português)
  der-en.json         https://raw.githubusercontent.com/unicode-org/cldr-json/48.0.0/cldr-json/cldr-annotations-derived-full/annotationsDerived/en/annotations.json
  der-pt.json         o mesmo caminho com .../annotationsDerived/pt/annotations.json
                      (bandeiras, teclas e sequências que a anotação principal não traz)
  LICENSE-unicode.txt https://www.unicode.org/license.txt (Unicode License V3)

Como rodar, na raiz do repositório:

  python3 wintermute-shell/launcher/emoji/build.py <pasta-das-fontes>

Regras (decisão da P-14): só as linhas `fully-qualified`; fora o grupo
`Component`; fora toda sequência com modificador de tom de pele (U+1F3FB a
U+1F3FF), porque a primeira versão não tem tons de pele. A ordem dentro de cada
grupo é a do emoji-test. O gerador confere os totais e falha se algum emoji
ficar sem nome numa das línguas.

Formato do emoji.json (uma lista por emoji, sem chaves repetidas):
  { "emoji": "17.0", "cldr": "48", "groups": [nome, ...],
    "items": [[caractere, índice do grupo, nome em inglês, nome em português,
               [palavras-chave em inglês], [palavras-chave em português]], ...] }
"""

import json
import os
import re
import sys

ESPERADO = {
    "Smileys & Emotion": 171,
    "People & Body": 388,
    "Animals & Nature": 160,
    "Food & Drink": 131,
    "Travel & Places": 219,
    "Activities": 85,
    "Objects": 266,
    "Symbols": 224,
    "Flags": 270,
}
TOTAL = 1914
# Os arquivos do CLDR não trazem a versão; ela está na URL (cldr-json 48.0.0).
CLDR = "48"
VS16 = "️"
TONS = range(0x1F3FB, 0x1F400)


def falha(mensagem):
    sys.exit("build.py: " + mensagem)


def ler_json(pasta, nome):
    with open(os.path.join(pasta, nome), encoding="utf-8") as arquivo:
        return json.load(arquivo)


def ler_inventario(caminho):
    """Devolve (versão, grupos na ordem, lista de (sequência, índice do grupo))."""
    versao = ""
    grupos = []
    itens = []
    grupo_atual = None
    with open(caminho, encoding="utf-8") as arquivo:
        for linha in arquivo:
            linha = linha.rstrip("\n")
            achou = re.match(r"# Version: (\S+)", linha)
            if achou:
                versao = achou.group(1)
            achou = re.match(r"# group: (.+)", linha)
            if achou:
                grupo_atual = achou.group(1)
                continue
            if linha.startswith("#") or not linha.strip():
                continue
            codigos, resto = linha.split(";", 1)
            status = resto.split("#", 1)[0].strip()
            if status != "fully-qualified" or grupo_atual == "Component":
                continue
            pontos = [int(c, 16) for c in codigos.split()]
            if any(p in TONS for p in pontos):
                continue
            if grupo_atual not in grupos:
                grupos.append(grupo_atual)
            itens.append(("".join(chr(p) for p in pontos), grupos.index(grupo_atual)))
    return versao, grupos, itens


def procurar(sequencia, fontes):
    """A anotação da sequência como está e sem o U+FE0F, primeiro na principal e depois na derivada."""
    for fonte in fontes:
        for chave in (sequencia, sequencia.replace(VS16, "")):
            achado = fonte.get(chave)
            if achado and achado.get("tts"):
                return achado
    return None


def main():
    if len(sys.argv) != 2:
        falha("uso: build.py <pasta-das-fontes>")
    pasta = sys.argv[1]
    saida = os.path.join(os.path.dirname(os.path.abspath(__file__)), "emoji.json")

    versao, grupos, itens = ler_inventario(os.path.join(pasta, "emoji-test-17.txt"))
    anotacoes = {}
    for lingua in ("en", "pt"):
        principal = ler_json(pasta, "ann-%s.json" % lingua)
        derivada = ler_json(pasta, "der-%s.json" % lingua)
        anotacoes[lingua] = [principal["annotations"]["annotations"], derivada["annotationsDerived"]["annotations"]]

    contagem = {}
    for _, indice in itens:
        contagem[grupos[indice]] = contagem.get(grupos[indice], 0) + 1
    if contagem != ESPERADO or len(itens) != TOTAL:
        falha("contagem inesperada: %r (total %d)" % (contagem, len(itens)))
    if grupos != list(ESPERADO):
        falha("ordem dos grupos inesperada: %r" % grupos)

    linhas = []
    sem_nome = []
    for sequencia, indice in itens:
        pares = []
        for lingua in ("en", "pt"):
            achado = procurar(sequencia, anotacoes[lingua])
            if achado is None:
                sem_nome.append((sequencia, lingua))
                pares.append(("", []))
            else:
                pares.append((achado["tts"][0], achado.get("default", [])))
        linhas.append([sequencia, indice, pares[0][0], pares[1][0], pares[0][1], pares[1][1]])
    if sem_nome:
        falha("emoji sem nome: %r" % sem_nome[:10])

    def compacto(valor):
        return json.dumps(valor, ensure_ascii=False, separators=(",", ":"))

    with open(saida, "w", encoding="utf-8") as arquivo:
        arquivo.write('{"emoji":%s,"cldr":%s,"groups":%s,"items":[\n' % (compacto(versao), compacto(CLDR), compacto(grupos)))
        arquivo.write(",\n".join(compacto(linha) for linha in linhas))
        arquivo.write("\n]}\n")
    print("emoji.json: %d emojis em %d grupos (Emoji %s, CLDR %s), %d bytes" % (len(linhas), len(grupos), versao, CLDR, os.path.getsize(saida)))


main()
