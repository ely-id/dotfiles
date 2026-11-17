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
- **Ciclo de agentes** (decisão 0014): `/ciclo` roda tarefa atrás de tarefa até um portão meu. Uso pelo app de desktop, numa sessão aberta em `~/Projects/dotfiles` com o Fable em effort high e o modo de permissão que aceita edições. Os subagentes `dev-shell`, `qa-visual` e `varredura` estão em `.claude/agents/` e só existem no Claude Code. Como rodar e como pausar: `docs/fluxo-de-trabalho.md`.
- **Perfil de permissões** em `.claude/settings.json`: os scripts do projeto, o git local e o `qs -p` rodam sem pergunta; `sudo`, gerenciadores de pacote, `git push`, `rfkill`, `usermod`, `gpasswd`, `systemctl` e escrita em `~/.config/` sempre perguntam. Numa sessão sem ninguém para responder, o que pergunta é recusado, e o ciclo segue sem aquilo.
