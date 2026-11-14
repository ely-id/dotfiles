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

## Onde fica cada coisa

| Lugar | O que guarda | Entra no git? |
|---|---|---|
| `wintermute-shell/` | A shell: código QML, tema, ícones, configuração | Sim |
| `niri/` | Configuração do Niri, recolhida na fase F7 | Sim |
| `docs/` | Documentação durável: estrutura, decisões, design | Sim |
| `docs/design/` | Fichas das peças e tokens aprovados (fonte da verdade visual em texto) | Sim |
| `~/Documents/Journal/projeto-dotfiles/` | Painel do projeto no Obsidian: escopo, fases, tarefas, sessões, handoffs, pendências | Não (vault pessoal) |
| `~/Projects/referencias/dotfiles-estudo/` | Material de estudo: clone da Pond, pacote de entrega original, PNGs de referência | Não (somente leitura) |

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

1. Escrever o relatório em `sessoes/AAAA-MM-DD-SNN-assunto.md` a partir de `modelos/sessao.md`.
2. Atualizar a nota da fase (tarefas, subfases, estado).
3. Atualizar `PAINEL.md`: estado de cada fase, "Agora", "Próximo passo" e o registro de sessões.
4. Se a fase ficou pronta para avaliação, escrever `handoffs/FN-HANDOFF.md` com o roteiro de QA.
5. Fazer commit do que mudou no repositório.

A sessão só está encerrada quando o painel descreve o estado real. Se o contexto estiver acabando, o encerramento tem prioridade sobre terminar a tarefa.

## Fases, subfases e Go/NoGo

- O projeto é dividido em fases (`B0`, `F0` a `F9`). A lista completa e o estado de cada uma estão em `PAINEL.md`.
- Estados possíveis: `planejada`, `em andamento`, `aguardando QA`, `go`, `no-go`, `bloqueada`.
- Uma fase termina em `aguardando QA`, nunca em `go`. O veredito é meu: eu entro na sessão do Niri, sigo o roteiro do handoff e digo Go ou NoGo. O agente registra o veredito com a data e as minhas palavras, e nunca marca `go` por conta própria.
- NoGo abre uma subfase com os ajustes apontados. A fase seguinte só começa depois do Go.
- A sessão do Niri roda em paralelo à do GNOME. Nenhuma fase migra esta máquina para fora do GNOME.

## Escopo

- `ESCOPO.md` (no painel) é imutável. Nenhum agente edita esse arquivo, em nenhuma circunstância.
- Mudança de escopo é registrada como uma entrada nova em `AJUSTES-DE-ESCOPO.md`, com data, motivo e impacto nas fases. O arquivo só cresce: entradas antigas não são reescritas.
- Em caso de conflito, vale o `ESCOPO.md` somado aos ajustes registrados, do mais antigo para o mais novo.

## Regras de design

- **Nunca inventar valor.** Cor, medida, raio, tempo e tipografia saem de `docs/design/tokens/` e das fichas em `docs/design/pecas/`. Se faltar, perguntar e registrar em `PENDENCIAS.md`.
- Itens marcados como *A CONFIRMAR* nas fichas estão consolidados em `PENDENCIAS.md`. Não se chuta: pergunta-se.
- O aceite visual de uma peça é o print dela ao lado da referência (PNG local ou board do Figma), com as medidas da ficha conferidas.
- A shell é sempre escura. As três variações (Chiba, Freeside, Sprawl) mudam só o acento.
- Dados de exemplo são fictícios. Nenhum segredo, dado real da máquina ou caminho pessoal entra no código ou nos prints.

## Código de origem externa

A shell parte de uma cópia do código da interface da Pond (BSD-3-Clause). A decisão está em `docs/decisoes/0003-base-de-codigo-da-pond.md`. Na prática:

- O material em `~/Projects/referencias/` é somente leitura. Nada ali é editado.
- Não existe vínculo técnico com o repositório de origem: sem fork do GitHub, sem remoto `upstream`, sem submódulo, sem importar histórico.
- O aviso de licença BSD-3 da origem é preservado. É a única menção obrigatória.
- Identificadores, nomes e marca da origem são substituídos pelos da Wintermute ao longo das fases, e a fase F9 confere que não sobrou nenhum.

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

A configuração do Claude Code fica em `.claude/` e o mapa de quando usar cada skill está em `.claude/SKILLS.md`.
