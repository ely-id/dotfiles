# AGENTS.md

Este arquivo é o contrato de trabalho do repositório. Todo agente de código que abrir uma sessão aqui lê este arquivo inteiro antes de qualquer ação e segue o que está escrito.

## O projeto em uma frase

Estou construindo, na instalação atual, os dotfiles completos da minha próxima instalação: a **Wintermute Shell** (Quickshell/QML sobre o Niri) e as configurações do Niri, de forma reproduzível e fácil de instalar no CachyOS, por mim ou por qualquer pessoa.

## Regra 1: a voz é a minha

Tudo o que for escrito neste repositório e no painel do projeto usa **primeira pessoa do singular**, como se eu tivesse construído cada parte: código, comentários, documentação, decisões, mensagens de commit, relatórios e handoffs.

- Certo: "Escolhi o CachyOS porque o fix do TSC só existe no kernel dele."
- Errado: "Ely pediu o CachyOS", "o usuário decidiu", "o agente implementou", "foi solicitado que".

Toda decisão registrada explica o motivo, para que eu entenda a escolha ao reler meses depois.

A atribuição ao Claude Code existe em um único lugar: a seção "Licenças e reconhecimentos" do `README.md`. Em nenhum outro ponto. Isso inclui mensagens de commit: **sem** rodapé `Co-Authored-By` e sem menção a ferramentas de IA.

**Exceções desde a pausa do projeto (decisão `0018`, 2026-11-20):** a apresentação do repositório é em inglês (`README.md` da raiz, da shell e de `niri/`, `docs/showcase/` e `docs/agent-workflow/`), ainda em primeira pessoa; e `docs/agent-workflow/` documenta a estrutura de agentes e o painel pelo nome das ferramentas. O resto do registro continua em português, e as mensagens de commit continuam como esta regra diz.

## Onde fica cada coisa

| Lugar | O que guarda | Entra no git? |
|---|---|---|
| `wintermute-shell/` | A shell: código QML, tema, ícones, configuração | Sim |
| `niri/` | Configuração do Niri, recolhida na fase F8 | Sim |
| `terminal/` | Configuração do terminal (zsh, Starship, Ghostty, fastfetch), recolhida na fase F9 | Sim |
| `plymouth/` | Tema de boot do Plymouth, recolhido na fase F9 | Sim |
| `docs/` | Documentação durável: estrutura, decisões, design | Sim |
| `docs/design/` | Fichas das peças e tokens aprovados (fonte da verdade visual em texto) | Sim |
| `~/Documents/Journal/projeto-dotfiles/` | Painel do projeto no Obsidian: escopo, fases, tarefas, sessões, handoffs, pendências | Não (vault pessoal) |
| `~/Projects/referencias/dotfiles-estudo/` | Material de estudo: clone da Pond e cópia do pacote de entrega com as PNGs de referência | Não (somente leitura) |
| `~/Documents/pacote-entrega/` | Pacote de entrega completo, com o material de apoio: `spec-pond-shell.md` e `armitage-shell/` | Não (somente leitura) |

O caminho do painel pode ser trocado pela variável de ambiente `DOTFILES_PAINEL`.

## Protocolo de sessão

O problema que este protocolo resolve é a perda de continuidade entre sessões. Nenhuma etapa é opcional.

### Ao abrir a sessão

1. Ler `PAINEL.md` no painel do projeto. Ele diz a fase ativa, o próximo passo e onde está o último handoff.
2. Ler a nota da fase ativa em `fases/` e o último relatório em `sessoes/`.
3. Conferir `git status` e `git log -5`. Se houver commit mais novo que o último relatório de sessão, a sessão anterior terminou sem registrar: reconstruir o que aconteceu a partir do git **antes** de continuar e registrar isso no relatório novo.
4. Só então começar o trabalho, dentro da fase ativa.

### Durante a sessão

- Trabalhar em **uma fase por vez**, na ordem do painel. Não adiantar tarefa de fase futura.
- Marcar cada tarefa concluída na nota da fase no momento em que ela termina, não no fim da sessão.
- Tudo que aparecer fora do plano vai para o painel na hora: ajuste dentro da fase vira **subfase** (`F2.1`, `F2.2`), dúvida vira item em `PENDENCIAS.md`, ideia fora do escopo vira item em `AJUSTES-DE-ESCOPO.md`. Nada fica só na conversa.
- Decisão técnica com consequência duradoura vira um registro em `docs/decisoes/`.

### Ao encerrar a sessão

1. Fazer commit do que mudou no repositório.
2. Escrever o relatório em `sessoes/AAAA-MM-DD-SNN-assunto.md` a partir de `modelos/sessao.md`.
3. Atualizar a nota da fase (tarefas, subfases, estado).
4. Atualizar `PAINEL.md`: estado de cada fase, "Agora", "Próximo passo" e o registro de sessões.
5. Se a fase ficou pronta para avaliação, escrever `handoffs/FN-HANDOFF.md` com o roteiro de QA.

O commit vem antes do relatório de propósito: o hook de início de sessão trata um commit mais novo que o último relatório como sinal de sessão não registrada. O relatório é sempre a última coisa escrita.

A sessão só está encerrada quando o painel descreve o estado real. Se o contexto estiver acabando, o encerramento tem prioridade sobre terminar a tarefa.

## Fases, subfases e Go/NoGo

- O projeto é dividido em fases (`B0`, `F0` a `F11`). A lista completa e o estado de cada uma estão em `PAINEL.md`.
- Estados possíveis: `planejada`, `em andamento`, `aguardando QA`, `go`, `no-go`, `bloqueada`.
- Uma fase termina em `aguardando QA`, nunca em `go`. O veredito é meu: eu entro na sessão do Niri, sigo o roteiro do handoff e digo Go ou NoGo. O agente registra o veredito com a data e as minhas palavras, e nunca marca `go` por conta própria.
- NoGo abre uma subfase com os ajustes apontados. A fase seguinte só começa depois do Go.
- **Exceção das fases de construção da shell (ajuste A-03).** Na F4, na F5 e na F6, a fase seguinte pode começar com a anterior em `aguardando QA`. O QA ao vivo das três acontece junto, numa sessão do Niri no fim da F6, que eu conduzo com `/qa-fase ao-vivo`. A F7 só começa depois do Go das três, e da F7 em diante vale de novo o portão por fase. NoGo no QA conjunto abre subfases, que são feitas antes da F7.
- A sessão do Niri roda em paralelo à do GNOME. Nenhuma fase migra esta máquina para fora do GNOME.

## Escopo

- `ESCOPO.md` (no painel) é imutável. Nenhum agente edita esse arquivo, em nenhuma circunstância.
- Mudança de escopo é registrada como uma entrada nova em `AJUSTES-DE-ESCOPO.md`, com data, motivo e impacto nas fases. O arquivo só cresce: entradas antigas não são reescritas.
- Em caso de conflito, vale o `ESCOPO.md` somado aos ajustes registrados, do mais antigo para o mais novo.

## Regras de design

- **Nunca inventar valor.** Cor, medida, raio, tempo e tipografia saem de `docs/design/tokens/` e das fichas em `docs/design/pecas/`. Se faltar, perguntar e registrar em `PENDENCIAS.md`.
- **Peça sem desenho no Figma (ajuste A-05).** Quando uma peça ou um estado de que a shell precisa não tem board, ele é composto com os componentes, os tokens e os padrões que a shell já usa (linhas, chaves, menus, pilha de cartões, grade de 4 px), na mesma direção visual e de interação do resto. Isso não é inventar valor: nenhuma cor, fonte ou medida sem origem, e um valor novo só quando sai de uma conta sobre tokens, com a conta escrita na ficha. A composição fica registrada na ficha da peça e é aprovada por mim no QA ao vivo, pelo print. Divergência entre fontes e decisão de comportamento ou de conteúdo continuam virando pendência.
- Itens marcados como *A CONFIRMAR* nas fichas estão consolidados em `PENDENCIAS.md`. Não se chuta: pergunta-se.
- O aceite visual de uma peça é o print dela ao lado da referência (PNG local ou board do Figma), com as medidas da ficha conferidas. Os prints fora do Niri saem de `.agents/scripts/bancada.sh`, nas três variações.
- Cor e família de fonte escritas direto numa peça são valor inventado. `.agents/scripts/lint-proveniencia.sh` confere as linhas alteradas e precisa passar antes de cada commit de código da shell.
- A shell é sempre escura. As três variações (Chiba, Freeside, Sprawl) mudam só o acento.
- Dados de exemplo são fictícios. Nenhum segredo, dado real da máquina ou caminho pessoal entra no código ou nos prints.

## Fontes e ordem de confiança

Quando duas fontes divergem, vale a que está mais acima. A divergência é registrada em `PENDENCIAS.md`; não se escolhe em silêncio.

1. O que eu decidi: `ESCOPO.md`, os ajustes de escopo, as pendências resolvidas e os registros de `docs/decisoes/`.
2. As fichas e os tokens em `docs/design/`.
3. O meu arquivo do Figma.
4. O código de origem no clone de estudo, para comportamento.
5. O material de apoio do pacote de entrega: `spec-pond-shell.md` e a pasta `armitage-shell/` (scripts do Figma, `status.md`, notas).

O item 5 existe para adiantar o trabalho e **não é autoridade**. A especificação foi escrita lendo o código sem executá-lo, a partir de uma versão anterior à do clone, e ela mesma admite diferença de até 1 px nas medidas calculadas. Os scripts e o `status.md` citam identificadores de outro arquivo do Figma. Por isso, tudo o que sair dali é conferido no código de origem ou no Figma antes de virar implementação. Usar esse material para encontrar rápido onde olhar é certo; copiar um valor dele sem conferir é errado.

## Código de origem externa

A shell parte de uma cópia do código da interface da Pond (BSD-3-Clause). A decisão está em `docs/decisoes/0003-base-de-codigo-da-pond.md`. Na prática:

- O material em `~/Projects/referencias/` é somente leitura. Nada ali é editado.
- Não existe vínculo técnico com o repositório de origem: sem fork do GitHub, sem remoto `upstream`, sem submódulo, sem importar histórico.
- O aviso de licença BSD-3 da origem é preservado. É a única menção obrigatória.
- Identificadores, nomes e marca da origem são substituídos pelos da Wintermute ao longo das fases, e a fase F11 confere que não sobrou nenhum.

## Git

- Branch principal: `main`. Commits pequenos, um assunto por commit.
- Mensagens em português, no padrão Conventional Commits: `tipo(escopo): resumo no imperativo`. Tipos: `feat`, `fix`, `docs`, `refactor`, `style`, `chore`. Escopos usuais: `shell`, `niri`, `docs`, `design`, `instalacao`.
- O corpo da mensagem explica o motivo quando ele não é óbvio, em primeira pessoa.
- O autor dos commits é o do meu `git config` global. Se o ambiente da sessão definir `GIT_AUTHOR_NAME` com outro nome, o commit é feito com `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL git commit ...`, para que autor e committer fiquem iguais.
- Nunca entram no git: segredos, dados reais da máquina, o painel do Obsidian, o material de `~/Projects/referencias/`, PNGs pesadas de referência.
- `git push` só quando eu pedir.

## O que nenhum agente faz sem eu pedir

- Instalar pacotes, alterar o sistema ou mexer em `~/.config/` desta máquina.
- Trocar o GNOME, o gerenciador de sessão ou o kernel.
- Tornar o repositório público.
- Apagar ou alterar algo no Figma.
- Editar `ESCOPO.md`.

## Ferramentas de agente

Trabalho neste repositório com o Claude Code e com o Antigravity, uma ferramenta por vez. O protocolo é o mesmo nas duas, e o que é comum fica em `.agents/` (decisão `0010`):

- `.agents/skills/`: as skills do projeto, `/retomar`, `/encerrar-sessao` e `/qa-fase`. É a fonte. `.claude/skills/` é uma cópia para o Claude Code, refeita por `.agents/scripts/sincronizar-skills.sh`; skill se edita só em `.agents/skills/`, e a cópia entra no mesmo commit.
- `.agents/hooks/estado-do-projeto.sh`: o aviso de início de sessão, chamado pelas duas ferramentas.
- `.agents/SKILLS.md`: quando usar cada skill, e o que existe em cada ferramenta.

O que é de uma ferramenta só fica com ela: `CLAUDE.md` e `.claude/settings.json` para o Claude Code; `.agents/rules/antigravity.md` e `.agents/hooks.json` para o Antigravity.

## Ciclo de agentes

No Claude Code, o projeto também anda pelo ciclo de agentes (decisão 0014, skill `/ciclo`). Ele segue este contrato inteiro e acrescenta quatro regras:

- **Papéis.** A sessão principal orquestra: escolhe a tarefa, tira os valores da ficha, escreve o briefing, revisa o diff, faz o commit e registra no painel. O subagente `dev-shell` implementa, o `qa-visual` verifica sem ter visto a implementação e o `varredura` faz trabalho mecânico. As definições estão em `.claude/agents/`.
- **Um escritor só.** Só a sessão principal escreve no painel. Os subagentes que editam código têm um hook que recusa escrita fora do repositório, e os três têm outro que recusa apagar arquivo (`rm`, `rmdir`, `unlink`, `shred`, `find -delete`) fora do repositório ou de pasta temporária.
- **Quem decide se continua é o `ciclo.sh`.** `.agents/scripts/ciclo.sh estado` lê o painel e para o ciclo em qualquer portão meu: QA ao vivo, fase em que toda tarefa espera uma pendência, fase bloqueada, fase fora do alcance (F8 em diante) ou pausa (`ciclo.sh pausar`).
- **Nada fora do repositório e do painel.** O ciclo não escreve em `~/.config/`, não instala, não usa `sudo`. O que precisar ser aplicado no sistema é preparado no repositório e entra na lista "Aplicar na sessão ao vivo" do handoff da fase.

O ciclo nunca roda ao mesmo tempo que uma sessão minha no Antigravity ou no Claude Code. A trava do `ciclo.sh` existe para isso.

