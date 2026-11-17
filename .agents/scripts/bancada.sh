#!/usr/bin/env bash
# Bancada de prints da Wintermute Shell, fora do Niri.
#
# Até a S11, cada sessão montava a própria bancada no scratchpad: copiava a
# shell, trocava dois singletons por stubs e escrevia um shell.qml de teste.
# Versionei esse procedimento para que o agente de QA o rode sempre igual.
#
# O que faço, a cada chamada:
#   1. copio wintermute-shell/ para uma pasta de execução fora do repositório;
#   2. troco bluetooth/State.qml e notifications/State.qml por stubs feitos dos
#      serviços fictícios de demo/, para não registrar o agente de pareamento
#      nem disputar o nome de notificações do GNOME no D-Bus (decisão 0011);
#   3. ponho .agents/bancada/bancada.qml no lugar do shell.qml da cópia;
#   4. para cada variação, gravo o theme.json numa XDG_CONFIG_HOME só da
#      bancada, abro a peça numa janela comum, gravo o PNG e fecho;
#   5. resumo os erros e avisos do log.
#
# A janela aparece por um instante na tela: a peça precisa ser desenhada de
# verdade. Funciona no GNOME e no Niri. O desfoque do compositor não aparece
# nos prints; isso só se confere ao vivo.
#
# Uso:
#   bancada.sh [opções] <alvo.qml> [props-json] [nome]
#
#   alvo.qml    arquivo relativo a wintermute-shell/, em geral um espécime de demo/
#   props-json  propriedades da peça, como na vitrine (padrão: {})
#   nome        prefixo dos arquivos (padrão: o nome do arquivo sem .qml)
#
# Opções:
#   --variacoes "chiba freeside sprawl"   variações a gravar (padrão: as três)
#   --espera MS                            espera antes do print (padrão: 1200)
#   --margem PX                            folga em volta da peça (padrão: 32)
#   --fundo PNG                            imagem atrás da peça (padrão: transparente)
#   --saida PASTA                          onde gravar (padrão: uma pasta nova no cache)
#
# Exemplo:
#   .agents/scripts/bancada.sh demo/WifiSpecimen.qml '{"page": "join", "height": 468}' wifi-join
#
# Saída: <pasta>/<nome>-<variação>.png e <nome>-<variação>.log. Termina com 0
# quando todos os prints foram gravados e o log não tem erro de QML; 2 quando
# falta print; 3 quando há erro de QML; 1 para uso errado.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
shell_src="$repo/wintermute-shell"

uso() { sed -n '/^# Uso:/,/^# Saída:/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

variacoes="chiba freeside sprawl"
espera=1200
margem=32
fundo=""
saida=""

while [ $# -gt 0 ]; do
  case "$1" in
    --variacoes) variacoes="$2"; shift 2 ;;
    --espera) espera="$2"; shift 2 ;;
    --margem) margem="$2"; shift 2 ;;
    --fundo) fundo="$(realpath "$2")"; shift 2 ;;
    --saida) saida="$2"; shift 2 ;;
    -h|--ajuda|--help) uso; exit 0 ;;
    --) shift; break ;;
    -*) echo "Opção desconhecida: $1" >&2; uso >&2; exit 1 ;;
    *) break ;;
  esac
done

[ $# -ge 1 ] || { uso >&2; exit 1; }
alvo="$1"
props="${2:-}"
[ -n "$props" ] || props='{}'
nome="${3:-$(basename "$alvo" .qml)}"

[ -f "$shell_src/$alvo" ] || { echo "Não encontrei wintermute-shell/$alvo." >&2; exit 1; }
command -v qs >/dev/null || { echo "O Quickshell (qs) não está no PATH." >&2; exit 1; }
python3 -c 'import json, sys; json.loads(sys.argv[1])' "$props" 2>/dev/null \
  || { echo "As propriedades não são um JSON válido: $props" >&2; exit 1; }
[ -n "${WAYLAND_DISPLAY:-}" ] || echo "Aviso: WAYLAND_DISPLAY vazio; a janela pode não abrir." >&2

base="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-bancada"
execucao="$base/execucoes/$(date +%Y%m%d-%H%M%S)-$$"
[ -n "$saida" ] || saida="$base/prints/$(date +%Y%m%d-%H%M%S)-$nome"
mkdir -p "$execucao" "$saida"

# A cópia da shell, com os stubs e o shell.qml da bancada.
cp -a "$shell_src" "$execucao/shell"
find "$execucao/shell" -name __pycache__ -type d -prune -exec rm -rf {} +
stub() {
  # O serviço fictício tem a mesma superfície do singleton real (decisão 0011).
  # Basta trocar a raiz QtObject pela Singleton do Quickshell.
  { echo "pragma Singleton"; echo "import Quickshell"; sed '0,/^QtObject {/s//Singleton {/' "$1"; } > "$2"
}
stub "$shell_src/demo/BluetoothService.qml" "$execucao/shell/bluetooth/State.qml"
stub "$shell_src/demo/NotificationService.qml" "$execucao/shell/notifications/State.qml"
cp "$repo/.agents/bancada/bancada.qml" "$execucao/shell/shell.qml"

# Só a configuração e o estado mudam de lugar. As fontes e o cache do
# fontconfig continuam os da máquina, senão a Geist some.
config="$execucao/xdg/config"
estado="$execucao/xdg/state"
mkdir -p "$config/wintermute-shell" "$estado"

faltou=0
erros_total=0
limite=$(( espera / 1000 + 25 ))

for v in $variacoes; do
  printf '{"theme": "%s"}\n' "$v" > "$config/wintermute-shell/theme.json"
  png="$saida/$nome-$v.png"
  log="$saida/$nome-$v.log"
  rm -f "$png"

  env XDG_CONFIG_HOME="$config" XDG_STATE_HOME="$estado" \
      BANCADA_ALVO="$alvo" BANCADA_PROPS="$props" BANCADA_SAIDA="$png" \
      BANCADA_ESPERA="$espera" BANCADA_MARGEM="$margem" BANCADA_FUNDO="$fundo" \
      qs -p "$execucao/shell" > "$log" 2>&1 &
  pid=$!

  passos=$(( limite * 2 ))
  while [ "$passos" -gt 0 ]; do
    [ -s "$png" ] && break
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.5
    passos=$(( passos - 1 ))
  done
  sleep 0.3
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true

  # O ruído do textinput do Wayland é do Qt e é inofensivo (nota da F10).
  erros=$(grep -E 'ERROR|TypeError|ReferenceError|is not a type|is not installed|Cannot assign|Cannot override|BANCADA: não' "$log" \
    | grep -v 'qt.qpa.wayland.textinput' || true)
  avisos=$(grep -E 'WARN' "$log" | grep -v 'qt.qpa.wayland.textinput' || true)
  n_erros=$(printf '%s' "$erros" | grep -c . || true)
  n_avisos=$(printf '%s' "$avisos" | grep -c . || true)
  erros_total=$(( erros_total + n_erros ))

  if [ -s "$png" ]; then
    echo "[$v] print: $png ($n_erros erro(s), $n_avisos aviso(s) no log)"
  else
    echo "[$v] FALTOU O PRINT. Log: $log"
    faltou=1
  fi
  [ -z "$erros" ] || printf '%s\n' "$erros" | head -n 15 | sed "s/^/[$v] erro: /"
  [ -z "$avisos" ] || printf '%s\n' "$avisos" | head -n 8 | sed "s/^/[$v] aviso: /"
done

rm -rf "$execucao"
echo "Pasta dos prints: $saida"

[ "$faltou" -eq 0 ] || exit 2
[ "$erros_total" -eq 0 ] || exit 3
exit 0
