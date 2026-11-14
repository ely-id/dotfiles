#!/usr/bin/env bash
# Copia para o Antigravity as skills externas que uso neste projeto.
#
# As skills externas do .agents/SKILLS.md vêm de plugins do Claude Code
# instalados nesta máquina. O Antigravity não lê plugins do Claude Code, então
# copio cada skill para a pasta global dele, ~/.gemini/config/skills/, que vale
# para o app e para a CLI. A cópia fica fora do repositório: as skills são de
# terceiros, com licenças próprias, e o repositório vai ser público na F11.
#
# Rodo de novo depois de atualizar os plugins no Claude Code.
# Uso: .agents/scripts/instalar-skills-externas.sh [--simular]

set -euo pipefail

plugins="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins"
destino="$HOME/.gemini/config/skills"
simular=0
[ "${1:-}" = "--simular" ] && simular=1

# plugin:skill, na mesma grafia do .agents/SKILLS.md
skills=(
    figma:figma-design-to-code
    mattpocock-skills:diagnosing-bugs
    mattpocock-skills:grilling
    mattpocock-skills:writing-for-agents
    engineering:debug
    engineering:architecture
    engineering:documentation
)

[ -d "$plugins" ] || { echo "Não encontrei os plugins do Claude Code em $plugins." >&2; exit 1; }
[ "$simular" -eq 1 ] || mkdir -p "$destino"

faltaram=0
for item in "${skills[@]}"; do
    plugin="${item%%:*}"
    skill="${item#*:}"

    # A versão instalada fica em cache/; marketplaces/ guarda o catálogo. Entre
    # várias versões, fico com a modificada mais recentemente.
    origem="$(find "$plugins/cache" "$plugins/marketplaces" -path "*/$plugin/*" \
        -path "*/skills/$skill/SKILL.md" -printf '%T@ %h\n' 2>/dev/null \
        | sort -rn | head -n 1 | cut -d' ' -f2- || true)"

    if [ -z "$origem" ]; then
        echo "FALTOU   $item (plugin não instalado no Claude Code?)"
        faltaram=$((faltaram + 1))
        continue
    fi

    if [ "$simular" -eq 1 ]; then
        echo "COPIARIA $item  <-  $origem"
    else
        rm -rf "${destino:?}/$skill"
        cp -rL "$origem" "$destino/$skill"
        echo "COPIEI   $item  ->  $destino/$skill"
    fi
done

echo
if [ "$faltaram" -gt 0 ]; then
    echo "$faltaram skill(s) não encontrada(s). As outras foram processadas."
fi
[ "$simular" -eq 1 ] || echo "No app do Antigravity, abra uma conversa nova para ele carregar a lista."
