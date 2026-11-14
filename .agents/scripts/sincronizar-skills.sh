#!/usr/bin/env bash
# Refaz .claude/skills/ como cópia exata de .agents/skills/.
#
# As skills do projeto moram em .agents/skills/, que o Antigravity lê. O
# Claude Code só procura em .claude/skills/, então mantenho ali uma cópia.
# Escolhi cópia em vez de link simbólico porque o Claude Code tem falhas
# registradas com skills em links simbólicos e o Antigravity não documenta se
# segue links (decisão 0010). O hook de início de sessão avisa quando as duas
# pastas divergem.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fonte="$repo/.agents/skills"
copia="$repo/.claude/skills"

[ -d "$fonte" ] || { echo "Não encontrei $fonte." >&2; exit 1; }

rm -rf "$copia"
cp -r "$fonte" "$copia"

echo "Copiei $(find "$fonte" -name SKILL.md | wc -l) skills de .agents/skills/ para .claude/skills/."
