#!/usr/bin/env bash
# Tela de teste: rodo um comando numa tela que não aparece em monitor nenhum.
#
# Os testes dos agentes abrem janelas o tempo todo (a bancada de prints, os
# QML de teste com o `qs`). Na minha sessão elas apareciam no monitor em que
# o ponteiro estava e roubavam o foco do teclado enquanto eu trabalhava. O
# Wayland não deixa a janela escolher o monitor: quem decide é o compositor.
# Por isso, em vez de mandar a janela para o monitor interno, subo um
# compositor só para o teste, sem tela (o Mutter em modo headless, com um
# monitor virtual), e aponto o comando para ele.
#
# O que faço:
#   1. abro um barramento D-Bus de sessão só do teste, sem ativação de serviço,
#      para o comando não registrar nada no barramento da minha sessão nem
#      acordar portal, chaveiro ou gvfs;
#   2. subo o Mutter sem tela, com um monitor virtual e um soquete do Wayland
#      de nome próprio;
#   3. rodo o comando com WAYLAND_DISPLAY nesse soquete e sem DISPLAY;
#   4. derrubo o compositor e devolvo o código de saída do comando.
#
# O desenho sai igual ao da tela de verdade: comparei um print da bancada
# feito aqui com o mesmo print feito na sessão, e a diferença ficou no ruído
# de sempre.
#
# Uso:
#   tela-de-teste.sh <comando> [argumentos...]
#
#   TELA_DE_TESTE_TAMANHO=LxA   tamanho do monitor virtual (padrão: 2560x1600)
#
# Sem `mutter` ou sem `dbus-run-session`, aviso e rodo o comando na tela de
# verdade, para o teste não deixar de rodar. Chamado de dentro de uma tela de
# teste, só repasso o comando.

set -euo pipefail

[ $# -ge 1 ] || { sed -n '/^# Uso:/,/^#$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2; exit 1; }

if [ -n "${WINTERMUTE_TELA_DE_TESTE:-}" ]; then
  exec "$@"
fi

if ! command -v mutter >/dev/null || ! command -v dbus-run-session >/dev/null; then
  echo "Aviso: sem mutter ou sem dbus-run-session; o teste abre na tela de verdade." >&2
  exec "$@"
fi

if [ "$1" != "--dentro-do-barramento" ]; then
  pasta="$(mktemp -d "${TMPDIR:-/tmp}/wintermute-tela-de-teste.XXXXXX")"
  cat > "$pasta/bus.conf" <<'EOF'
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <type>session</type>
  <listen>unix:tmpdir=/tmp</listen>
  <policy context="default">
    <allow send_destination="*" eavesdrop="true"/>
    <allow eavesdrop="true"/>
    <allow own="*"/>
  </policy>
</busconfig>
EOF
  codigo=0
  dbus-run-session --config-file="$pasta/bus.conf" -- \
    "${BASH_SOURCE[0]}" --dentro-do-barramento "$pasta" "$@" || codigo=$?
  rm -f "$pasta/bus.conf" "$pasta/mutter.log"
  rmdir "$pasta" 2>/dev/null || true
  exit "$codigo"
fi

shift
pasta="$1"
shift

nome="wintermute-teste-$$"
soquete="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$nome"

mutter --headless --wayland --no-x11 \
  --virtual-monitor "${TELA_DE_TESTE_TAMANHO:-2560x1600}" \
  --wayland-display "$nome" > "$pasta/mutter.log" 2>&1 &
compositor=$!
trap 'kill "$compositor" 2>/dev/null || true; wait "$compositor" 2>/dev/null || true' EXIT

passos=100
while [ ! -S "$soquete" ] && [ "$passos" -gt 0 ]; do
  kill -0 "$compositor" 2>/dev/null || break
  sleep 0.1
  passos=$(( passos - 1 ))
done
if [ ! -S "$soquete" ]; then
  echo "A tela de teste não subiu. Fim do log do Mutter:" >&2
  tail -n 5 "$pasta/mutter.log" >&2 || true
  exit 1
fi

codigo=0
env -u DISPLAY WINTERMUTE_TELA_DE_TESTE=1 WAYLAND_DISPLAY="$nome" "$@" || codigo=$?
exit "$codigo"
