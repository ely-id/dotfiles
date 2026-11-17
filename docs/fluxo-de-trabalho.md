# Fluxo de trabalho

Organizei o projeto para resolver um problema que já me custou caro em outros: perder a continuidade entre uma sessão de trabalho e a seguinte. A solução tem três partes: um escopo que não muda, fases com portão de avaliação e um painel que sempre descreve o estado real.

## Escopo imutável e ajustes registrados

O objetivo do projeto está escrito em um documento de escopo que nunca é editado depois de aprovado. Quando algo precisa mudar, registro uma entrada nova em um documento de ajustes, com data, motivo e impacto. Assim consigo responder a duas perguntas a qualquer momento: o que eu queria no começo e o que mudou pelo caminho.

## Fases

| Fase | Entrega |
|---|---|
| B0 | Base do projeto: repositório, contratos, painel |
| F0 | Fundação da shell: código de partida, tema, fontes, ícones, shell abrindo no Niri |
| F1 | Vidro e componentes base |
| F2 | Barra lateral e organizador de workspaces |
| F3 | Pop-ups e painéis |
| F4 | Ajustes |
| F5 | Launcher, seletor de cor e emoji |
| F6 | Captura de tela, área de transferência e integração do desktop |
| F7 | Tela de bloqueio e tela de login |
| F8 | Varredura do Niri: recolher a configuração para `niri/` |
| F9 | Terminal e boot: recolher zsh, Starship, Ghostty, fastfetch e o tema do Plymouth |
| F10 | Instalação reproduzível: instalador, lista de pacotes, guia e teste em sistema limpo |
| F11 | Publicação: revisão de segredos, README final, capturas, repositório público |

Cada fase é pequena o bastante para ser avaliada de uma vez. Ajustes que surgem dentro de uma fase viram subfases numeradas (`F2.1`, `F2.2`), cada uma com sua própria lista de tarefas e seu próprio veredito.

## Portão Go/NoGo

Nenhuma fase avança sozinha. Quando o trabalho de uma fase termina, ela fica aguardando avaliação e recebe um handoff com o roteiro de teste. Eu entro na sessão do Niri, que roda em paralelo à do GNOME, sigo o roteiro e dou o veredito:

- **Go**: a fase está aceita e a seguinte pode começar.
- **NoGo**: os problemas apontados viram uma subfase, e o ciclo se repete.

O critério de aceite visual é sempre o mesmo: o print da peça ao lado da referência, com as medidas da ficha conferidas.

### QA ao vivo em lote nas fases de construção da shell

Na F4, na F5 e na F6 não avalio fase por fase (ajuste A-03). Cada uma termina em `aguardando QA`, com handoff e prints da bancada, e a seguinte começa. No fim da F6 entro na sessão do Niri, abro o Claude Code lá e digito `/qa-fase ao-vivo`: o agente aplica comigo o que ficou para a sessão ao vivo, me guia pelo roteiro das três fases um passo por vez e registra um veredito por fase. NoGo vira subfase, feita antes da F7. Da F7 em diante, volta o portão por fase.

## O painel

O acompanhamento vive em um vault do Obsidian, fora deste repositório, e funciona como um quadro de projeto:

| Nota | Papel |
|---|---|
| `PAINEL.md` | Estado de todas as fases, o que está em andamento e o próximo passo |
| `ESCOPO.md` | O escopo imutável |
| `AJUSTES-DE-ESCOPO.md` | Registro das mudanças de escopo; só recebe entradas novas |
| `PENDENCIAS.md` | Perguntas em aberto que bloqueiam ou vão bloquear alguma fase |
| `fases/` | Uma nota por fase, com tarefas, subfases e veredito |
| `sessoes/` | Um relatório por sessão de trabalho |
| `handoffs/` | Um handoff por fase, com o roteiro de avaliação |

A regra que sustenta tudo: uma sessão de trabalho só termina quando o painel descreve o estado real do projeto. O que foi decidido, descoberto ou adiado em uma sessão está escrito antes de ela fechar.

## Decisões

Toda decisão com consequência duradoura ganha um registro em [decisoes/](decisoes/README.md), com o contexto, a escolha e o motivo. Esses registros ficam no repositório porque explicam o produto, não o processo.

## Duas ferramentas, um protocolo

Trabalho com o Claude Code e com o Antigravity, nunca as duas ao mesmo tempo. As duas seguem o mesmo `AGENTS.md`, usam as mesmas skills (`/retomar`, `/encerrar-sessao`, `/qa-fase`) e recebem o mesmo aviso de início de sessão. A organização está em [decisoes/0010](decisoes/0010-ferramental-de-agente-em-agents.md) e o mapa de skills em `.agents/SKILLS.md`.

Antes da primeira sessão no Antigravity numa máquina:

1. Abro `~/Projects/dotfiles` como projeto e adiciono `~/Documents/Journal/projeto-dotfiles` como segunda pasta. Sem o painel no projeto, a sessão não consegue registrar nada.
2. Instalo os plugins Figma e Context7 do marketplace de parceiros do Antigravity. Rodo `.agents/scripts/instalar-skills-externas.sh --simular` para ver o que ele encontra nos plugins do Claude Code, e depois sem `--simular` para copiar.
3. Em Settings › Customizations, confiro que aparecem as três skills do projeto, a regra `antigravity`, os hooks `estado-do-projeto` e `protecao-de-arquivos` e os plugins Context7 e Figma. O Figma pede login na primeira vez.
4. Abro uma conversa nova, digito `/retomar` e confiro que o painel chegou no contexto sem eu colar nada.
5. Peço para acrescentar uma linha ao `ESCOPO.md` e confiro que a escrita é recusada pelo hook.

Trocar de ferramenta é seguro em qualquer fronteira de sessão: o que uma sessão deixa no painel é o que a próxima lê, venha de onde vier.

## Ciclo de agentes

Para o projeto andar sem eu abrir sessão por sessão, uso o ciclo de agentes ([decisões/0014](decisoes/0014-ciclo-de-agentes.md)). Ele só existe no Claude Code, porque depende de subagentes com modelo próprio.

| Papel | Quem |
|---|---|
| Orquestrar, planejar, revisar, commitar, registrar | A sessão principal, no Fable com effort high |
| Implementar | Subagente `dev-shell` (Sonnet) |
| Verificar, sem ter visto a implementação | Subagente `qa-visual` (Sonnet) |
| Trabalho mecânico | Subagente `varredura` (Haiku) |

### Como rodo pelo app de desktop

1. Abro uma sessão nova do Claude Code em `~/Projects/dotfiles`, escolho o Fable como modelo, o effort em high e o modo de permissão que aceita edições.
2. Digito `/ciclo`. A sessão trabalha tarefa atrás de tarefa, fecha um relatório a cada bloco e para sozinha no próximo portão meu.
3. Se eu quiser uma garantia de que ela não para antes da hora, uso o `/goal` no lugar: `/goal Seguir a skill ciclo até que a saída mais recente de .agents/scripts/ciclo.sh estado --dentro mostre um RESULTADO diferente de continuar`. O avaliador do `/goal` só lê a conversa, e a saída do `ciclo.sh` fica nela.
4. Quando ela para, a última linha diz o que eu faço: responder uma pendência e digitar `/ciclo` de novo, ou entrar no Niri para o QA ao vivo.

Para parar no meio: `.agents/scripts/ciclo.sh pausar` num terminal. A sessão para antes da próxima tarefa. `ciclo.sh liberar` desfaz.

### Os portões

`.agents/scripts/ciclo.sh estado` lê o painel e diz se o ciclo continua. Ele para quando:

- chegou a hora do QA ao vivo (as fases do lote acabaram, ou uma fase fora do lote ficou em `aguardando QA`);
- toda tarefa aberta da fase ativa está marcada `(bloqueada: P-NN)`, esperando uma resposta minha;
- a fase ativa está `bloqueada`, ou fora do alcance do ciclo (F8 em diante, que mexem no sistema e nos meus arquivos pessoais);
- outra sessão está rodando o ciclo, ou eu o pausei.

Tarefa sem valor na ficha não trava o ciclo: o orquestrador abre a pendência, marca a tarefa e segue para a próxima que não depende dela.

### Pelo terminal

Se o comando `claude` estiver no PATH, `.agents/scripts/ciclo.sh rodar` chama `claude -p /ciclo` em sequência, cada sessão com contexto novo, com limite de sessões, de turnos e de gasto (`CICLO_MAX_SESSOES`, `CICLO_MAX_TURNOS`, `CICLO_ORCAMENTO`), e avisa pelo `notify-send` quando para.

### Bancada e lint

- `.agents/scripts/bancada.sh <espécime> [props] [nome]` copia a shell para fora do repositório, troca os singletons do Bluetooth e das notificações pelos serviços fictícios e grava o print da peça nas três variações, numa janela comum. O desfoque do compositor não aparece; isso fica para o QA ao vivo.
- `.agents/scripts/lint-proveniencia.sh [commit]` reprova cor e família de fonte escritas direto nas linhas alteradas da shell.
