# 0014 — Ciclo de agentes: o Fable orquestra, o Sonnet implementa e verifica, um script decide quando parar

- **Data:** 2026-11-17
- **Estado:** Aceita

## Contexto

A fundação da shell ficou pronta (F0 a F3 em Go) e o protocolo de sessão funciona: o painel sempre diz o estado real, e `/retomar` e `/encerrar-sessao` abrem e fecham cada sessão. O que segurava o ritmo era eu ser o gatilho de tudo: abrir cada sessão, digitar `/retomar`, esperar, abrir a próxima. Sobram cerca de setenta tarefas da F4 à F11.

Os pontos em que eu entro são de quatro tipos, e só um deles é trabalho repetitivo:

1. abrir a sessão: repetitivo, e é o que dá para tirar de mim;
2. responder pendências: é a regra "nunca inventar valor", fica comigo;
3. o veredito Go/NoGo ao vivo no Niri: é meu pelo contrato;
4. mexer no sistema (pacotes, permissões, `~/.config/`): fica comigo.

Eu uso o Claude Code pelo app de desktop. O ciclo precisa funcionar ali, sem depender de terminal.

## Decisão

- **Papéis.** A sessão principal roda no Fable com effort high e orquestra: escolhe a tarefa, tira os valores das fichas e escreve um briefing completo, revisa o diff, faz o commit e registra no painel. A implementação vai para o subagente `dev-shell` (Sonnet), a verificação para o `qa-visual` (Sonnet, sem ferramentas de escrita, sem ver o relato do dev) e o trabalho mecânico para o `varredura` (Haiku). As definições ficam em `.claude/agents/`, e o roteiro da sessão principal na skill `/ciclo`.
- **Um escritor só.** Só a sessão principal escreve no painel. `dev-shell` e `varredura` têm um hook (`.agents/hooks/so-no-repositorio.py`) que recusa escrita fora do repositório.
- **O portão é um script.** `.agents/scripts/ciclo.sh estado` lê o estado das fases nas notas, a ordem do painel e as tarefas marcadas `(bloqueada: P-NN)`, e diz se o ciclo continua. A skill o chama antes de cada tarefa. O mesmo script tem trava, pausa e um modo pelo terminal (`rodar`).
- **Bancada e lint versionados.** `.agents/scripts/bancada.sh` grava os prints de uma peça nas três variações fora do Niri, do mesmo jeito que as sessões da F3 e da F4 faziam à mão no scratchpad. `.agents/scripts/lint-proveniencia.sh` reprova cor e família de fonte literais nas linhas alteradas.
- **Perfil de permissões.** `.claude/settings.json` libera os scripts do projeto, o git local e o `qs -p`, e manda perguntar antes de `sudo`, gerenciadores de pacote, `git push`, `rfkill`, `usermod`, `gpasswd`, `systemctl` e escrita em `~/.config/`. Numa sessão sem ninguém para responder, o que pergunta é recusado.
- **No app de desktop**, o ciclo é uma sessão só: `/ciclo` trabalha em blocos, fecha um relatório de sessão a cada bloco e continua na mesma conversa enquanto o portão permitir. Pelo terminal, `ciclo.sh rodar` abre uma sessão nova por bloco.

## Motivo

O raciocínio mais difícil deste projeto não está em orquestrar, porque o painel já é uma máquina de estados. Está em achar o valor certo entre a ficha, o Figma e a origem e não inventar nenhum. Por isso o Fable não fica só despachando: ele planeja cada tarefa e entrega ao implementador os valores já conferidos, e revisa o resultado. Um modelo menor implementando a partir de um briefing completo erra menos do que um modelo menor procurando valores sozinho.

O verificador separado, que não viu a implementação, existe para o trabalho não se avaliar sozinho. O script de portão existe porque "terminei" dito pelo modelo não é critério; o estado do painel é.

Não paralelizei a implementação. Quase toda tarefa mexe na vitrine (`ComponentDemoPanel.qml`, perto de duas mil linhas) e no `Theme.qml`, e o painel aceita um escritor só. O gargalo do projeto são os meus portões, não a velocidade.

## Consequências

- O ciclo é só do Claude Code. No Antigravity, as fases andam em sessões comuns com o mesmo protocolo, e a trava do `ciclo.sh` evita as duas ao mesmo tempo.
- O alcance do ciclo é F4 a F7. Da F8 em diante, as fases mexem no sistema e nos meus arquivos pessoais e são feitas comigo.
- O que precisa ser aplicado no sistema durante uma fase vai para a seção "Aplicar na sessão ao vivo" do handoff, e a `/qa-fase ao-vivo` aplica comigo.
- A bancada abre uma janela por um instante a cada print. Ela não mostra o desfoque do compositor, que continua sendo coisa do QA ao vivo.
- O lint só olha cor e fonte. Medida e tempo literais são legítimos no QML, e continuam sendo conferidos pela revisão e pelo QA contra a ficha.
- Uso do Fable pesa no limite da minha conta. A pausa (`ciclo.sh pausar`) e, pelo terminal, os limites de sessões, turnos e gasto são os freios.
