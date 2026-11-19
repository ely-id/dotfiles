#!/usr/bin/env bash
# Roda os testes das bibliotecas puras da shell (F6-T18, P-82).
#
# "Biblioteca pura" é um .js da shell com `.pragma library` e sem QML: só contas. Os testes moram em .agents/testes/, um arquivo
# por biblioteca (`<nome>.test.js`), fora de wintermute-shell/ porque aquela pasta é o que a instalação copia e teste não é
# produto. Rodam no motor de JavaScript do Qt, o mesmo da shell, pelo `qs`, dentro da tela de teste: é o único jeito de o
# `.pragma library` e o `.import` de uma biblioteca por outra (o Clipboard.js importa o Colors.js) valerem como na shell. Não uso o
# `node`, e nenhuma janela aparece.
#
# O Quickshell só lê arquivo de dentro da pasta do shell dele, então, para cada arquivo de teste, copio para uma pasta temporária:
# as bibliotecas que o teste importa (as linhas `.import "launcher/Search.js" as S` do começo dele, com o caminho a partir de
# wintermute-shell/, e as que essas importam, mantendo os caminhos relativos), o apoio.js, o próprio teste (como caso.test.js) e o
# runner (como shell.qml). Rodo `qs -p` lá e leio o resultado no log. Tudo, até o runtime e o cache do Quickshell, fica nessa pasta
# temporária, que é apagada no fim: nada sobra em /tmp nem no repositório.
#
# Imprime uma linha por biblioteca (`selection: ok, 70 testes` ou `selection: FALHOU, 2 de 70`, com as linhas das falhas) e lista à
# parte as falhas conhecidas (`skip` nos testes: o que a ficha pede e a biblioteca ainda não faz). Termina com 0 se tudo passou, 1
# se algum caso falhou ou um runner não chegou ao fim, e 2 se o uso estiver errado (nome sem teste).
#
# Uso:
#   testar.sh                        roda todos os arquivos de .agents/testes/
#   testar.sh selection clipboard    roda só esses
#
#   TESTAR_TESTES=<pasta>   usa os testes desta pasta em vez de .agents/testes/ (para conferir o script com uma cópia quebrada)
#   TESTAR_SHELL=<pasta>    usa as bibliotecas desta pasta em vez de wintermute-shell/ (para ver os testes pegarem uma biblioteca quebrada)
#   TESTAR_LIMITE=<s>       tempo máximo de cada runner, em segundos (padrão: 60)

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
shell="$(cd "${TESTAR_SHELL:-$repo/wintermute-shell}" && pwd)"
testes="$(cd "${TESTAR_TESTES:-$repo/.agents/testes}" && pwd)"
limite="${TESTAR_LIMITE:-60}"

erro() {
  echo "testar.sh: $*" >&2
  exit 2
}

disponiveis() {
  local arquivo
  for arquivo in "$testes"/*.test.js; do
    [ -e "$arquivo" ] || continue
    basename "$arquivo" .test.js
  done
}

# ---- Fora da tela de teste: confiro os nomes e me chamo de novo lá dentro, uma vez só para todos os arquivos ----

if [ -z "${TESTAR_DENTRO:-}" ]; then
  command -v qs >/dev/null || erro "o qs (Quickshell) não está no PATH"
  nomes=()
  for pedido in "$@"; do
    nome="${pedido%.js}"
    nome="${nome%.test}"
    [[ "$nome" =~ ^[A-Za-z0-9_-]+$ ]] && [ -f "$testes/$nome.test.js" ] \
      || erro "não existe teste '$pedido' (existem: $(disponiveis | paste -sd' ' -))"
    nomes+=("$nome")
  done
  if [ "${#nomes[@]}" -eq 0 ]; then
    mapfile -t nomes < <(disponiveis)
    [ "${#nomes[@]}" -gt 0 ] || erro "não há nenhum *.test.js em $testes"
  fi
  TESTAR_DENTRO=1 exec "$repo/.agents/scripts/tela-de-teste.sh" "${BASH_SOURCE[0]}" "${nomes[@]}"
fi

# ---- Dentro da tela de teste ----

base="$(mktemp -d "${TMPDIR:-/tmp}/testar-XXXXXX")"
trap 'rm -rf "$base"' EXIT
mkdir -m 700 "$base/run"
mkdir "$base/cache"

# O Quickshell guarda o log e o socket de cada instância em $XDG_RUNTIME_DIR/quickshell, e a cada rodada deixaria mais um diretório
# lá. Aponto o runtime e o cache para a pasta temporária. O soquete do Wayland da tela de teste está no runtime de verdade, então
# passo o caminho completo dele em WAYLAND_DISPLAY (o Qt aceita).
tela="${WAYLAND_DISPLAY:-}"
if [ -n "$tela" ] && [[ "$tela" != /* ]]; then
  tela="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$tela"
fi

# Copia a biblioteca `origem` (caminho absoluto, dentro da shell) para a pasta do runner, no mesmo caminho relativo, e depois as
# que ela importa. `vistas` evita copiar duas vezes e laço de importação.
copiar_biblioteca() {
  local origem="$1" relativo
  [[ "$origem" == "$shell"/* ]] || { echo "importa um arquivo fora da shell: $origem" >&2; return 1; }
  [ -f "$origem" ] || { echo "a biblioteca não existe: ${origem#"$shell"/}" >&2; return 1; }
  [ -z "${vistas[$origem]:-}" ] || return 0
  vistas[$origem]=1
  relativo="${origem#"$shell"/}"
  mkdir -p "$pasta/$(dirname "$relativo")"
  cp "$origem" "$pasta/$relativo"
  local importada
  while IFS= read -r importada; do
    copiar_biblioteca "$(realpath -m "$(dirname "$origem")/$importada")" || return 1
  done < <(grep -oP '^\.import\s+"\K[^"]+(?="\s+as\b)' "$origem" || true)
}

falhou=0

rodar() {
  local nome="$1"
  local arquivo="$testes/$nome.test.js"
  local log="$base/$nome.log"
  local -A vistas=()
  pasta="$base/pasta-$nome"
  mkdir "$pasta"

  cp "$testes/apoio.js" "$pasta/apoio.js"
  cp "$testes/runner.qml" "$pasta/shell.qml"
  cp "$arquivo" "$pasta/caso.test.js"

  local importada
  while IFS= read -r importada; do
    [ "$importada" = "apoio.js" ] && continue
    if ! copiar_biblioteca "$(realpath -m "$shell/$importada")" 2> "$base/copia.log"; then
      echo "$nome: ERRO, $(cat "$base/copia.log")"
      falhou=1
      return
    fi
  done < <(grep -oP '^\.import\s+"\K[^"]+(?="\s+as\b)' "$arquivo" || true)

  # O runner sai sozinho quando termina e quando o QML não carrega (erro de sintaxe, import que não existe). O laço abaixo só
  # impede que um runner pendurado segure o script: passado o limite, ele é derrubado e a biblioteca conta como não terminada.
  env XDG_RUNTIME_DIR="$base/run" XDG_CACHE_HOME="$base/cache" ${tela:+WAYLAND_DISPLAY="$tela"} \
      qs --no-color -p "$pasta" > "$log" 2>&1 &
  local pid=$!
  local passos=$(( limite * 10 ))
  while kill -0 "$pid" 2>/dev/null && [ "$passos" -gt 0 ]; do
    if grep -q 'TESTE|FIM|' "$log"; then
      # O FIM já saiu: dou um instante para o qs sair e, se não sair, derrubo.
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.1
      done
      break
    fi
    sleep 0.1
    passos=$(( passos - 1 ))
  done
  local pendurado=0
  if kill -0 "$pid" 2>/dev/null; then
    grep -q 'TESTE|FIM|' "$log" || pendurado=1
    kill "$pid" 2>/dev/null || true
  fi
  wait "$pid" 2>/dev/null || true

  local fim
  fim="$(grep -o 'TESTE|FIM|.*' "$log" | tail -n 1 || true)"
  if [ -z "$fim" ]; then
    if [ "$pendurado" -eq 1 ]; then
      echo "$nome: NÃO TERMINOU, passou de $limite s (um caso em laço?)"
    else
      echo "$nome: NÃO TERMINOU"
    fi
    grep -E 'ERROR|WARN.*\.js\[' "$log" | sed 's/caso\.test\.js/'"$nome"'.test.js/g' | head -n 8 | sed 's/^/  /' || true
    falhou=1
    return
  fi

  # O QML não derruba o runner por uma exceção no corpo do arquivo, fora de um `test` (uma variável que não existe, uma chamada errada): ele
  # só escreve um aviso "@arquivo.js[linha:coluna]: Error: ..." e deixa de rodar o resto do arquivo. Sem esta conferência o resultado
  # seria "ok" com casos a menos.
  local avisos
  avisos="$(grep -E '(WARN|ERROR).*\.js\[' "$log" | sed 's/caso\.test\.js/'"$nome"'.test.js/g' || true)"
  if [ -n "$avisos" ]; then
    echo "$nome: ERRO FORA DE UM CASO, o resto do arquivo não rodou"
    printf '%s\n' "$avisos" | head -n 8 | sed 's/^/  /'
    falhou=1
    return
  fi

  local ok falhas pulados
  IFS='|' read -r _ _ ok falhas pulados <<< "$fim"
  if [ "$falhas" -eq 0 ]; then
    echo "$nome: ok, $ok testes"
  else
    echo "$nome: FALHOU, $falhas de $(( ok + falhas ))"
    grep -o 'TESTE|FALHA|.*' "$log" | sed 's/^TESTE|FALHA|/  - /' || true
    falhou=1
  fi
  # As falhas conhecidas ficam fora da contagem. O estado diz se o corpo ainda falha ou se já passa (aí é hora de tirar o `skip`).
  local rotulo motivo estado
  while IFS='|' read -r _ _ rotulo motivo estado; do
    echo "  falha conhecida: $rotulo ($motivo) [$estado]"
  done < <(grep -o 'TESTE|SKIP|.*' "$log" || true)
}

for nome in "$@"; do
  rodar "$nome"
done

exit "$falhou"
