# CLAUDE.md

O contrato do repositório está em `AGENTS.md` e vale integralmente:

@AGENTS.md

## Específico do Claude Code

- No início de cada sessão, o hook `.agents/hooks/estado-do-projeto.sh` injeta o `PAINEL.md` no contexto. Isso não substitui o protocolo de sessão: a nota da fase ativa e o último relatório continuam sendo lidos.
- Skills do projeto: `/retomar` (abrir a sessão), `/encerrar-sessao` (fechar a sessão) e `/qa-fase` (preparar o handoff e registrar o veredito). O mapa completo, com as skills externas úteis em cada fase, está em `.agents/SKILLS.md`.
- As skills do projeto moram em `.agents/skills/`. `.claude/skills/` é a cópia que o Claude Code lê: skill nova ou alterada é escrita em `.agents/skills/` e copiada com `.agents/scripts/sincronizar-skills.sh` no mesmo commit, nunca editada direto na cópia.
- A atribuição automática de commits está desligada em `.claude/settings.json`. Não reintroduzir rodapés de coautoria.
- O painel do projeto e a pasta de referências ficam fora do repositório. O painel aceita escrita; `ESCOPO.md` e `~/Projects/referencias/` têm regra de bloqueio em `.claude/settings.json`.
- A memória automática do Claude Code não é o registro do projeto. O que precisa sobreviver entre sessões vai para o painel.
