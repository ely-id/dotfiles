#!/usr/bin/env python3
"""Transforma uma mudança da área de transferência em uma linha de JSON para o histórico (clipboard/State.qml).

`wl-paste --type text --watch python3 watch.py text --max-bytes N` e
`wl-paste --type image/png --watch python3 watch.py image --max-bytes N --dir DIR` rodam este script uma vez por mudança. O
conteúdo chega na entrada padrão e `CLIPBOARD_STATE` diz o que ele é (`data`, `nil`, `clear` ou `sensitive`). A saída padrão é
herdada do `wl-paste`, então o que eu imprimo é o que a shell lê.

  text   {"type": "text", "text": "..."}
  image  {"type": "image", "path": "...", "width": 1920, "height": 1080, "bytes": 412345, "hash": "..."}

Não imprimo nada, e saio com 0, para a área de transferência vazia, para a cópia que o gerenciador de senhas marcou como
sigilosa, para texto vazio ou só de espaços, para o que passa do teto de tamanho e para o que não é um PNG íntegro (assinatura,
cabeçalho e fim do arquivo). Nunca escrevo o conteúdo de uma cópia sigilosa em lugar nenhum (nem no log): nesse caso eu nem leio a
entrada padrão.

A terceira ação não escuta nada: `python3 watch.py sweep --dir DIR` é a limpeza que a shell faz ao começar. Apaga da pasta das
imagens só os arquivos que eu mesmo gravei (`<64 hex>.png` e o temporário `<64 hex>.png.tmp-<pid>` de uma gravação interrompida).
"""

import argparse
import hashlib
import json
import os
import re
import stat
import subprocess
import sys

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
# O chunk IEND inteiro (tamanho 0, tipo, CRC fixo): todo PNG íntegro termina com estes 12 bytes.
PNG_IEND = b"\x00\x00\x00\x00IEND\xaeB`\x82"
# Menor PNG possível: assinatura (8) + IHDR (25) + IEND (12).
PNG_MIN_SIZE = 8 + 25 + 12
SENSITIVE_HINT = "x-kde-passwordmanagerhint"
# Tipos em que uma cópia de texto simples é oferecida. Só serve para separar o texto de verdade da metade de texto de uma cópia de imagem.
PLAIN_TEXT_TYPES = {"text/plain", "text/plain;charset=utf-8", "utf8_string", "string"}
# Os nomes que eu gravo na pasta das imagens (o hash é um SHA-256 em hexadecimal minúsculo), e só esses a limpeza apaga.
OWN_FILE = re.compile(r"[0-9a-f]{64}\.png(\.tmp-[0-9]+)?", re.ASCII)
CHUNK = 1024 * 1024


def offered_types():
    """Os tipos MIME da seleção atual, ou None quando não consigo perguntar (aí trato a cópia como sigilosa)."""
    try:
        result = subprocess.run(["wl-paste", "--list-types"], capture_output=True, text=True, timeout=3, check=True)
    except (OSError, subprocess.SubprocessError):
        return None
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def read_limited(limit):
    """Lê a entrada padrão até `limit` bytes. Devolve None quando o conteúdo é maior, depois de esvaziar o resto da entrada
    para que o aplicativo que serve a cópia não leve um pipe quebrado."""
    data = sys.stdin.buffer.read(limit + 1)
    if len(data) <= limit:
        return data
    while sys.stdin.buffer.read(CHUNK):
        pass
    return None


def emit(event):
    sys.stdout.write(json.dumps(event, ensure_ascii=True) + "\n")
    sys.stdout.flush()


def png_size(data):
    """(largura, altura) do chunk IHDR, ou None quando `data` não é um PNG que eu aceite.

    Confiro a assinatura, o IHDR e o fim do arquivo (os 12 bytes do IEND). Não descomprimo nem confiro o CRC dos outros chunks:
    o que preciso é recusar o PNG cortado no meio e o que tem lixo no fim, que a prévia da peça não conseguiria abrir."""
    if len(data) < PNG_MIN_SIZE or not data.startswith(PNG_SIGNATURE) or data[12:16] != b"IHDR":
        return None
    if not data.endswith(PNG_IEND):
        return None
    width = int.from_bytes(data[16:20], "big")
    height = int.from_bytes(data[20:24], "big")
    if width < 1 or height < 1 or width > 0x7FFFFFFF or height > 0x7FFFFFFF:
        return None
    return width, height


def store_png(directory, digest, data):
    """Grava `<digest>.png` em `directory` (só o dono lê) se ele ainda não estiver lá. Devolve o caminho."""
    os.makedirs(directory, mode=0o700, exist_ok=True)
    path = os.path.join(directory, digest + ".png")
    if os.path.exists(path):
        return path
    temporary = "%s.tmp-%d" % (path, os.getpid())
    descriptor = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        with os.fdopen(descriptor, "wb") as out:
            os.fchmod(out.fileno(), 0o600)
            out.write(data)
        os.replace(temporary, path)
    except BaseException:
        try:
            os.unlink(temporary)
        except OSError:
            pass
        raise
    return path


def sweep(directory):
    """Apaga da pasta `directory` os arquivos que eu gravei, e nada mais. Devolve False se alguma coisa não deu para apagar.

    Só entra o arquivo regular, direto dentro da pasta, com nome de `OWN_FILE`. Não sigo link simbólico (o link de nome igual
    é deixado onde está, e o alvo dele nunca é tocado), não desço em subpasta e não apago a pasta. Pasta que não existe não é erro.
    Trabalho pelo descritor da pasta, para o nome que eu listei ser o mesmo que eu apago."""
    try:
        descriptor = os.open(directory, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    except FileNotFoundError:
        return True
    except OSError:
        return False
    ok = True
    try:
        for name in os.listdir(descriptor):
            if not OWN_FILE.fullmatch(name):
                continue
            try:
                info = os.stat(name, dir_fd=descriptor, follow_symlinks=False)
                if stat.S_ISREG(info.st_mode):
                    os.unlink(name, dir_fd=descriptor)
            except FileNotFoundError:
                pass
            except OSError:
                ok = False
    finally:
        os.close(descriptor)
    return ok


def watch_text(max_bytes, types):
    # Uma seleção que oferece PNG e nenhum texto simples é uma cópia de imagem (o "copiar imagem" de um navegador oferece também o
    # HTML dela): quem pega é a escuta de imagem, e eu só acrescentaria um segundo item feito de marcação.
    lowered = [t.lower() for t in types]
    if "image/png" in lowered and not any(t in PLAIN_TEXT_TYPES for t in lowered):
        return
    data = read_limited(max_bytes)
    if data is None:
        return
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        return
    if text.strip() == "":
        return
    emit({"type": "text", "text": text})


def watch_image(max_bytes, directory):
    data = read_limited(max_bytes)
    if data is None:
        return
    size = png_size(data)
    if size is None:
        return
    digest = hashlib.sha256(data).hexdigest()
    path = store_png(directory, digest, data)
    emit({"type": "image", "path": path, "width": size[0], "height": size[1], "bytes": len(data), "hash": digest})


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("kind", choices=["text", "image", "sweep"])
    parser.add_argument("--max-bytes", type=int)
    parser.add_argument("--dir", default="")
    args = parser.parse_args()
    if args.kind in ("image", "sweep") and not args.dir:
        parser.error("--dir is required for image and sweep")
    if args.kind in ("text", "image") and args.max_bytes is None:
        parser.error("--max-bytes is required for text and image")

    # A limpeza não escuta a área de transferência: não passa pelas barreiras abaixo.
    if args.kind == "sweep":
        if not sweep(args.dir):
            print("clipboard watch: failed", file=sys.stderr)
            sys.exit(1)
        return

    # Primeira barreira: o que o wl-paste diz. Qualquer coisa que não seja dado de verdade para aqui, antes de tocar na entrada padrão.
    state = os.environ.get("CLIPBOARD_STATE", "data")
    if state in ("sensitive", "nil", "clear"):
        return
    # Segunda barreira, para as versões do wl-clipboard que não definem `sensitive`: pergunto os tipos oferecidos.
    types = offered_types()
    if types is None or SENSITIVE_HINT in (t.lower() for t in types):
        return

    if args.kind == "text":
        watch_text(args.max_bytes, types)
    else:
        watch_image(args.max_bytes, args.dir)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except BaseException:
        # Mensagem fixa: o texto de uma exceção poderia carregar um pedaço do que foi copiado.
        print("clipboard watch: failed", file=sys.stderr)
        sys.exit(1)
