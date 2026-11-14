---
trigger: always_on
description: O que é específico do Antigravity neste repositório. Complementa o AGENTS.md, que vale inteiro.
---

# Específico do Antigravity

O contrato do repositório está no `AGENTS.md` e vale integralmente. Esta regra só cobre o que muda quando a sessão roda no Antigravity.

- **Painel.** O painel do projeto fica fora do repositório, em `~/Documents/Journal/projeto-dotfiles/`. Ele precisa estar adicionado como segunda pasta do projeto no Antigravity; sem isso a sessão não consegue escrever o relatório. Se o painel não estiver acessível, a sessão para e me avisa, em vez de seguir sem registrar.
- **Início de sessão.** O hook `SessionStart` de `.agents/hooks.json` injeta o `PAINEL.md` no contexto. Isso não substitui o protocolo: a nota da fase ativa e o último relatório continuam sendo lidos.
- **Skills do projeto:** `/retomar` (abrir a sessão), `/encerrar-sessao` (fechar a sessão) e `/qa-fase` (preparar o handoff e registrar o veredito). O mapa de quando usar cada skill, com o que existe em cada ferramenta, está em `.agents/SKILLS.md`.
- **Skills e cópia.** As skills do projeto moram em `.agents/skills/`. A pasta `.claude/skills/` é uma cópia para o Claude Code. Toda edição de skill é feita em `.agents/skills/` e seguida de `.agents/scripts/sincronizar-skills.sh`, no mesmo commit.
- **Bloqueios.** `ESCOPO.md` e `~/Projects/referencias/` são bloqueados para as ferramentas de escrita pelo hook `PreToolUse`. Esses caminhos também não são alterados por comando de terminal.
- **Commits.** Vale a regra do `AGENTS.md`: sem rodapé de coautoria e sem menção a ferramenta de IA, mesmo que a ferramenta sugira um. O autor é o do meu `git config`.
- **Memória.** O Knowledge e qualquer memória automática do Antigravity não são o registro do projeto. O que precisa sobreviver entre sessões vai para o painel.
- **Uma ferramenta por vez.** Não abro sessão no Antigravity enquanto houver sessão aberta no Claude Code, e o contrário. O painel não tem controle de versão.
