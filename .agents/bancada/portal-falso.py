#!/usr/bin/env python3
"""Portal de mentira para testar o seletor de arquivo sem abrir diálogo de verdade.

Escrevi este script para a F4-T20. Ele toma o nome org.freedesktop.portal.Desktop
no barramento de sessão e implementa só o org.freedesktop.portal.FileChooser.OpenFile.
Grava num arquivo o que recebeu (título e opções) e responde conforme o modo.

Nunca o rodo no meu barramento de sessão: lá o nome pertence ao portal de verdade, e
o barramento ativa o xdg-desktop-portal pelo arquivo de serviço. Rodo sempre dentro
de um barramento privado e sem ativação de serviço, com um arquivo de configuração
que não tem <standard_session_servicedirs/> nem <servicedir>:

    cat > bus.conf <<'XML'
    <busconfig>
      <type>session</type>
      <listen>unix:tmpdir=/tmp</listen>
      <auth>EXTERNAL</auth>
      <policy context="default">
        <allow send_destination="*" eavesdrop="true"/>
        <allow eavesdrop="true"/>
        <allow own="*"/>
      </policy>
    </busconfig>
    XML
    export HOME="$PWD/casa" XDG_CONFIG_HOME="$PWD/casa/config" XDG_CACHE_HOME="$PWD/casa/cache"
    dbus-run-session --config-file=bus.conf -- bash -c '
        portal-falso.py --modo escolher --arquivo /caminho/da/foto.png --registro registro.json &
        until grep -q pronto registro.json 2>/dev/null; do sleep 0.1; done
        wintermute-shell/wallpaper/control.py pick
        kill %1'

As três variáveis do começo do exemplo não são enfeite: o control.py pick grava o
papel de parede escolhido em XDG_CONFIG_HOME e as miniaturas em XDG_CACHE_HOME. Sem
elas o teste escreveria na minha configuração de verdade.

Uso:
    portal-falso.py --registro ARQUIVO [--modo MODO] [--arquivo CAMINHO]

Modos:
    escolher    responde 0 com a URI de --arquivo (o padrão)
    cancelar    responde 1
    encerrar    responde 2
    sem-uris    responde 0 com um dicionário sem "uris"
    uri-remota  responde 0 com uma URI https, que não vira caminho local
    erro        devolve um erro de D-Bus na própria chamada
    outro-handle  como escolher, mas devolve um handle diferente do previsto e responde nele
    sumir       devolve o handle e sai sem responder, como um portal que caiu

O registro é um arquivo JSON. Ele recebe {"estado": "pronto"} quando o nome está
tomado e, depois de cada chamada, {"estado": "chamado", "titulo": ..., "opcoes": ...}.
"""
import argparse
import json
import os
import sys

from gi.repository import Gio, GLib

NOME = "org.freedesktop.portal.Desktop"
OBJETO = "/org/freedesktop/portal/desktop"
XML = """<node><interface name="org.freedesktop.portal.FileChooser">
<method name="OpenFile">
<arg type="s" name="parent_window" direction="in"/>
<arg type="s" name="title" direction="in"/>
<arg type="a{sv}" name="options" direction="in"/>
<arg type="o" name="handle" direction="out"/>
</method></interface></node>"""


def anotar(args, dados):
    with open(args.registro, "w") as arquivo:
        json.dump(dados, arquivo, indent=2)


def bytes_para_texto(valor):
    # O current_folder chega como bytes; mostro também o terminador nulo.
    return list(valor) if isinstance(valor, (bytes, bytearray)) else valor


def chamada(args, loop):
    def tratar(conexao, remetente, caminho, interface, metodo, parametros, invocacao):
        janela, titulo, opcoes = parametros.unpack()
        anotar(args, {"estado": "chamado", "janela": janela, "titulo": titulo,
                      "opcoes": {k: bytes_para_texto(v) for k, v in opcoes.items()}})
        if args.modo == "erro":
            invocacao.return_dbus_error("org.freedesktop.portal.Error.Failed",
                                        "Nenhum backend implementa o FileChooser\nsegunda linha do erro")
            return
        token = opcoes["handle_token"]
        previsto = f"{OBJETO}/request/{remetente[1:].replace('.', '_')}/{token}"
        handle = previsto + "_outro" if args.modo == "outro-handle" else previsto
        invocacao.return_value(GLib.Variant("(o)", (handle,)))
        if args.modo == "sumir":
            GLib.timeout_add(100, loop.quit)
            return
        resposta, resultados = 0, {}
        if args.modo in ("escolher", "outro-handle"):
            resultados = {"uris": GLib.Variant("as", [Gio.File.new_for_path(args.arquivo).get_uri()])}
        elif args.modo == "cancelar":
            resposta = 1
        elif args.modo == "encerrar":
            resposta = 2
        elif args.modo == "uri-remota":
            resultados = {"uris": GLib.Variant("as", ["https://example.com/foto.png"])}

        def responder():
            # Uma pequena espera, como num diálogo de verdade: o cliente já assinou e está no loop.
            conexao.emit_signal(remetente, handle, "org.freedesktop.portal.Request", "Response",
                                GLib.Variant("(ua{sv})", (resposta, resultados)))
            return False
        GLib.timeout_add(200, responder)
    return tratar


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--registro", required=True)
    parser.add_argument("--modo", default="escolher",
                        choices=["escolher", "cancelar", "encerrar", "sem-uris", "uri-remota", "erro",
                                 "outro-handle", "sumir"])
    parser.add_argument("--arquivo", default="")
    args = parser.parse_args()
    # Trava: no meu barramento de sessão o nome é do portal de verdade. Sem endereço no
    # ambiente o Gio cairia nele também, então recuso os dois casos.
    endereco = os.environ.get("DBUS_SESSION_BUS_ADDRESS", "")
    if not endereco or f"/run/user/{os.getuid()}/bus" in endereco:
        sys.exit("Recuso rodar no barramento de sessão de verdade. Use o dbus-run-session, como no cabeçalho.")
    loop = GLib.MainLoop()

    def tomou_o_nome(conexao, nome):
        conexao.register_object(OBJETO, Gio.DBusNodeInfo.new_for_xml(XML).interfaces[0], chamada(args, loop),
                                None, None)

    def pronto(conexao, nome):
        anotar(args, {"estado": "pronto"})

    def perdeu(conexao, nome):
        print("Não consegui tomar o nome do portal", file=sys.stderr)
        loop.quit()

    # O objeto é registrado no barramento antes de o nome ser anunciado como meu.
    Gio.bus_own_name(Gio.BusType.SESSION, NOME, Gio.BusNameOwnerFlags.NONE, tomou_o_nome, pronto, perdeu)
    loop.run()


if __name__ == "__main__":
    main()
