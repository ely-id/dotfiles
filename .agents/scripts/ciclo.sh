#!/usr/bin/env bash
# O portão do ciclo de agentes (decisão 0014).
#
# A skill /ciclo trabalha tarefa atrás de tarefa até chegar a um portão que é
# meu: o QA ao vivo, uma pendência que trava tudo, uma fase fora do alcance do
# ciclo. Quem decide se o ciclo continua é este script, lendo o painel, e não o
# modelo dizendo que terminou. A skill chama "estado" antes de cada tarefa.
#
# Comandos:
#   estado [--dentro]   diz se o ciclo pode continuar. --dentro ignora a trava
#                       da própria sessão que está rodando o ciclo.
#   trava               marca que uma sessão está rodando o ciclo
#   solta               tira a marca
#   pausar              faz o próximo "estado" parar o ciclo, até eu liberar
#   liberar             desfaz o pausar
#   rodar               alternativa pelo terminal: chama "claude -p /ciclo" em
#                       sequência enquanto o estado permitir (precisa do claude no PATH)
#
# Saída de "estado": um relatório curto e, na última linha, RESULTADO=<valor>.
#   0  continuar           há tarefa para fazer na fase ativa
#   10 portao-qa-ao-vivo   chegou a hora do meu QA na sessão do Niri
#   11 pendencias          toda tarefa aberta da fase ativa espera uma resposta minha
#   13 travado             outra sessão está rodando o ciclo
#   14 fora-do-alcance     a fase ativa é das que o ciclo não toca (F8 em diante)
#   15 bloqueada           a fase ativa está com estado "bloqueada"
#   16 pausado             eu pausei o ciclo
#   1  erro                painel ou fase não encontrados
#
# Configuração, por variável de ambiente:
#   DOTFILES_PAINEL   pasta do painel (padrão: ~/Documents/Journal/projeto-dotfiles)
#   CICLO_ALCANCE     fases que o ciclo trabalha (padrão: "F4 F5 F6 F7")
#   CICLO_LOTE        fases cujo QA ao vivo acontece junto, no fim (padrão: "F4 F5 F6", ajuste A-03)
#   CICLO_MAX_SESSOES, CICLO_MAX_TURNOS, CICLO_ORCAMENTO   limites do "rodar"

set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
painel="${DOTFILES_PAINEL:-$HOME/Documents/Journal/projeto-dotfiles}"
alcance="${CICLO_ALCANCE:-F4 F5 F6 F7}"
lote="${CICLO_LOTE:-F4 F5 F6}"
dir_estado="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-ciclo"
trava="$dir_estado/trava"
pausa="$dir_estado/pausa"
trava_vencida_horas=8

mkdir -p "$dir_estado"

contem() { case " $1 " in *" $2 "*) return 0 ;; *) return 1 ;; esac; }

resultado() { echo "RESULTADO=$2"; exit "$1"; }

nota_da_fase() { ls "$painel/fases/$1-"*.md 2>/dev/null | head -n 1; }

estado_da_fase() {
  # Lê o campo "estado:" do cabeçalho da nota da fase, que é a fonte mais detalhada.
  awk '/^---$/ { n++; next } n == 1 && /^estado:/ { sub(/^estado:[[:space:]]*/, ""); print; exit }' "$1"
}

ordem_das_fases() {
  # A ordem de execução é a da tabela do PAINEL.md, não a numérica (PROTOCOLO.md).
  grep -E '^\| \[\[[BF][0-9]+' "$painel/PAINEL.md" | sed -E 's/^\| \[\[([BF][0-9]+).*/\1/'
}

trava_ativa() {
  [ -f "$trava" ] || return 1
  local idade=$(( $(date +%s) - $(stat -c %Y "$trava") ))
  [ "$idade" -lt $(( trava_vencida_horas * 3600 )) ]
}

avisos_do_repositorio() {
  local ultimo instante_rel instante_commit
  ultimo="$(find "$painel/sessoes" -maxdepth 1 -name '*.md' -printf '%f\n' 2>/dev/null | sort | tail -n 1)"
  if [ -n "$ultimo" ]; then
    instante_rel="$(stat -c %Y "$painel/sessoes/$ultimo")"
    instante_commit="$(git -C "$repo" log -1 --format=%ct 2>/dev/null || echo 0)"
    [ "$instante_commit" -le $(( instante_rel + 120 )) ] \
      || echo "aviso: existe commit mais novo que o último relatório ($ultimo); o /retomar precisa reconstruir antes de seguir."
  fi
  [ -z "$(git -C "$repo" status --porcelain 2>/dev/null)" ] \
    || echo "aviso: a árvore do repositório tem alterações não commitadas; descobrir a que tarefa pertencem antes de mexer."
  diff -rq "$repo/.agents/skills" "$repo/.claude/skills" >/dev/null 2>&1 \
    || echo "aviso: .claude/skills/ difere de .agents/skills/; rodar .agents/scripts/sincronizar-skills.sh."
}

cmd_estado() {
  local dentro=0
  [ "${1:-}" = "--dentro" ] && dentro=1

  [ -r "$painel/PAINEL.md" ] || { echo "Não encontrei o painel em $painel."; resultado 1 erro; }

  avisos_do_repositorio

  if [ -f "$pausa" ]; then
    echo "O ciclo está pausado desde $(date -r "$pausa" '+%Y-%m-%d %H:%M'). Para liberar: .agents/scripts/ciclo.sh liberar"
    resultado 16 pausado
  fi
  if [ "$dentro" -eq 0 ] && trava_ativa; then
    echo "Outra sessão está rodando o ciclo: $(cat "$trava")."
    echo "Se ela morreu, apague a trava com: .agents/scripts/ciclo.sh solta"
    resultado 13 travado
  fi

  local fase nota est ativa="" esperando_qa=""
  for fase in $(ordem_das_fases); do
    nota="$(nota_da_fase "$fase")"
    [ -n "$nota" ] || { echo "Não encontrei a nota da fase $fase."; resultado 1 erro; }
    est="$(estado_da_fase "$nota")"
    case "$est" in
      go) continue ;;
      "aguardando QA")
        if contem "$lote" "$fase"; then
          esperando_qa="$esperando_qa $fase"
          continue
        fi
        echo "A $fase está aguardando QA e não faz parte do lote ($lote): o veredito vem antes da fase seguinte."
        resultado 10 portao-qa-ao-vivo ;;
      bloqueada)
        echo "A $fase está bloqueada. O motivo está em $(basename "$nota")."
        resultado 15 bloqueada ;;
      "em andamento"|no-go|planejada)
        ativa="$fase"; break ;;
      *)
        echo "A $fase tem um estado que não conheço: \"$est\"."
        resultado 1 erro ;;
    esac
  done

  esperando_qa="${esperando_qa# }"
  if [ -z "$ativa" ]; then
    [ -n "$esperando_qa" ] && { echo "Todas as fases terminaram; falta o QA ao vivo de: $esperando_qa."; resultado 10 portao-qa-ao-vivo; }
    echo "Não sobrou fase para fazer."
    resultado 14 fora-do-alcance
  fi

  # Uma fase de fora do lote só começa depois do Go das fases do lote.
  if [ -n "$esperando_qa" ] && ! contem "$lote" "$ativa"; then
    echo "A próxima fase é a $ativa, fora do lote. Antes dela vem o QA ao vivo de: $esperando_qa."
    resultado 10 portao-qa-ao-vivo
  fi

  nota="$(nota_da_fase "$ativa")"
  est="$(estado_da_fase "$nota")"
  echo "Fase ativa: $ativa ($est)."
  [ -z "$esperando_qa" ] || echo "Aguardando o QA ao vivo do lote: $esperando_qa."

  if ! contem "$alcance" "$ativa"; then
    echo "A $ativa está fora do alcance do ciclo ($alcance). Ela é trabalhada em sessão comigo."
    resultado 14 fora-do-alcance
  fi

  local abertas bloqueadas
  abertas=$(grep -cE '^[[:space:]]*- \[ \]' "$nota" || true)
  bloqueadas=$(grep -E '^[[:space:]]*- \[ \]' "$nota" | grep -c 'bloqueada:' || true)
  echo "Tarefas abertas na $ativa: $abertas, das quais $bloqueadas bloqueadas."

  if [ "$abertas" -eq 0 ]; then
    if [ "$est" = "planejada" ]; then
      echo "A $ativa não tem tarefa aberta e ainda está planejada: a primeira tarefa da sessão é detalhar a fase."
    else
      echo "Não sobrou tarefa aberta: o próximo passo é /qa-fase preparar."
    fi
    resultado 0 continuar
  fi
  if [ "$abertas" -eq "$bloqueadas" ]; then
    echo "Toda tarefa aberta espera uma resposta minha:"
    grep -E '^[[:space:]]*- \[ \]' "$nota" | sed -E 's/^[^`]*(`[^`]+`).*bloqueada: ([^)]*).*/  \1 espera \2/'
    resultado 11 pendencias
  fi
  resultado 0 continuar
}

cmd_trava() {
  if trava_ativa; then
    echo "Já existe uma trava: $(cat "$trava")." >&2
    exit 13
  fi
  echo "$(hostname) pid $PPID desde $(date '+%Y-%m-%d %H:%M')" > "$trava"
  echo "Trava criada."
}

cmd_solta() { rm -f "$trava"; echo "Trava removida."; }
cmd_pausar() { date > "$pausa"; echo "Ciclo pausado. A sessão em andamento para antes da próxima tarefa."; }
cmd_liberar() { rm -f "$pausa"; echo "Ciclo liberado."; }

avisar() {
  echo "$1"
  command -v notify-send >/dev/null && notify-send "Ciclo do dotfiles" "$1" || true
}

cmd_rodar() {
  command -v claude >/dev/null || {
    echo "O comando claude não está no PATH. No app de desktop, rode /ciclo numa sessão (veja docs/fluxo-de-trabalho.md)." >&2
    exit 1
  }
  local max="${CICLO_MAX_SESSOES:-5}" n=0 saida codigo log
  mkdir -p "$dir_estado/logs"
  while [ "$n" -lt "$max" ]; do
    saida="$(cmd_estado 2>&1)"; codigo=$?
    echo "$saida"
    if [ "$codigo" -ne 0 ]; then
      avisar "O ciclo parou: $(echo "$saida" | tail -n 1). $(echo "$saida" | grep -vE '^(RESULTADO|aviso)' | tail -n 1)"
      exit "$codigo"
    fi
    n=$(( n + 1 ))
    log="$dir_estado/logs/$(date +%Y%m%d-%H%M%S).json"
    echo "Sessão $n de $max do ciclo. Log: $log"
    (cd "$repo" && claude -p "/ciclo" --model fable --effort high \
        --permission-mode acceptEdits \
        --max-turns "${CICLO_MAX_TURNOS:-400}" \
        --max-budget-usd "${CICLO_ORCAMENTO:-25}" \
        --output-format json > "$log") \
      || { avisar "A sessão $n do ciclo terminou com erro. Log: $log"; exit 1; }
  done
  avisar "O ciclo fez $max sessões e parou no limite (CICLO_MAX_SESSOES)."
}

case "${1:-}" in
  estado) shift; cmd_estado "$@" ;;
  trava) cmd_trava ;;
  solta) cmd_solta ;;
  pausar) cmd_pausar ;;
  liberar) cmd_liberar ;;
  rodar) cmd_rodar ;;
  *) sed -n '/^# Comandos:/,/^#   CICLO_MAX_SESSOES/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
