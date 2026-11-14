# Skills: quando usar cada uma

Este é o mapa das skills que uso no projeto. As três primeiras são do próprio repositório e sustentam a continuidade entre sessões. As demais vêm dos plugins instalados na minha máquina e entram em momentos específicos.

## Skills do projeto (sempre)

| Skill | Quando | O que faz |
|---|---|---|
| `/retomar` | No começo de toda sessão | Lê o painel, a fase ativa, o último relatório e o git, e resume onde parei e o próximo passo |
| `/encerrar-sessao` | Antes de terminar toda sessão | Escreve o relatório, atualiza a fase e o painel, registra pendências e ajustes, faz o commit |
| `/qa-fase preparar` | Quando o trabalho de uma fase termina | Confere os critérios de aceite e escreve o handoff com o roteiro de teste |
| `/qa-fase go` ou `/qa-fase no-go` | Depois que eu avalio a fase no Niri | Registra o meu veredito e abre a subfase em caso de NoGo |

## Por momento do trabalho

| Momento | Skill ou ferramenta | Observação |
|---|---|---|
| Antes de ler um board do Figma para implementar | `figma:figma-design-to-code` | Obrigatória antes de `get_design_context`. Os node-ids estão em `docs/design/README.md` |
| Dúvida sobre API do Quickshell, do Niri ou do Qt/QML | Context7 (`resolve-library-id` e `query-docs`) | Consultar a documentação atual em vez de responder de memória |
| Algo não funciona e a causa não é óbvia | `mattpocock-skills:diagnosing-bugs` ou `engineering:debug` | Reproduzir, isolar, diagnosticar e só então corrigir |
| Antes de começar uma fase grande (F2, F5, F6) | `mattpocock-skills:grilling` | Testar o plano da fase contra perguntas duras antes de escrever código |
| Antes de `/qa-fase preparar` | `/code-review` | Revisar o diff da fase atrás de erros de correção |
| Depois da revisão, se o código ficou pesado | `/simplify` | Só qualidade: reaproveitamento e simplificação |
| Decisão técnica com consequência duradoura | `engineering:architecture` | Ajuda a estruturar o registro em `docs/decisoes/` |
| Escrever handoff, contrato ou instrução para outro agente | `mattpocock-skills:writing-for-agents` | O handoff precisa funcionar para quem não viu a conversa |
| Guia de instalação e README final (F10, F11) | `engineering:documentation` | Documentação para quem nunca viu o projeto |
| Antes de tornar o repositório público (F11) | `/security-review` | Procurar segredos, dados da máquina e caminhos pessoais em todo o histórico |
| Mudar hook, permissão ou configuração do Claude Code | `update-config` | Sempre ler o `settings.json` antes de alterar |
| Criar uma skill nova para o projeto | `anthropic-skills:skill-creator` | A skill nova entra em `.claude/skills/` e ganha uma linha neste arquivo |

## O que não usar aqui

- Skills que criam listas de tarefas próprias (`productivity:task-management`, `TASKS.md`). O quadro de tarefas do projeto é o painel do Obsidian, e um segundo quadro é exatamente o tipo de duplicidade que faz as coisas se perderem.
- `productivity:memory-management` e a memória automática como registro do projeto. O que precisa sobreviver vai para o painel.
- `frontend-design:frontend-design` para definir visual. O visual já está aprovado nas fichas e nos tokens; a tarefa é implementar com fidelidade, não criar.
