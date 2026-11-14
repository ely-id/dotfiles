#!/usr/bin/env bash
# Injeta o estado do projeto no contexto de cada sessão nova.
#
# Leio o PAINEL.md do painel do projeto e aviso quando existe commit mais
# novo que o último relatório de sessão, sinal de que a sessão anterior
# terminou sem registrar o que fez.
#
# O caminho do painel pode ser trocado pela variável DOTFILES_PAINEL.
# Sem painel (por exemplo, em um clone de outra pessoa), o script não faz nada.

painel="${DOTFILES_PAINEL:-$HOME/Documents/Journal/projeto-dotfiles}"
arquivo="$painel/PAINEL.md"
repo="${CLAUDE_PROJECT_DIR:-$(pwd)}"

[ -r "$arquivo" ] || exit 0

echo "<estado-do-projeto origem=\"$arquivo\">"
cat "$arquivo"
echo "</estado-do-projeto>"
echo

ultimo_relatorio=""
if [ -d "$painel/sessoes" ]; then
    ultimo_relatorio="$(find "$painel/sessoes" -maxdepth 1 -name '*.md' -printf '%f\n' 2>/dev/null | sort | tail -n 1)"
fi

if [ -n "$ultimo_relatorio" ]; then
    echo "Último relatório de sessão: sessoes/$ultimo_relatorio"
    instante_relatorio="$(stat -c %Y "$painel/sessoes/$ultimo_relatorio" 2>/dev/null || echo 0)"
    instante_commit="$(git -C "$repo" log -1 --format=%ct 2>/dev/null || echo 0)"
    # Dois minutos de folga para commit e relatório escritos no mesmo momento.
    if [ "$instante_commit" -gt "$((instante_relatorio + 120))" ]; then
        echo "ATENÇÃO: existe commit mais novo que o último relatório de sessão."
        echo "A sessão anterior pode ter terminado sem registrar. Antes de continuar,"
        echo "reconstrua o que aconteceu com 'git log' e registre no relatório desta sessão."
    fi
else
    echo "Ainda não existe relatório de sessão no painel."
fi

echo
echo "Siga o protocolo de sessão do AGENTS.md: leia a nota da fase ativa e o último"
echo "relatório antes de agir, e atualize o painel antes de encerrar."
