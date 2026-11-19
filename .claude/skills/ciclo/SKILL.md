---
name: ciclo
description: Roda o ciclo de agentes do projeto dotfiles. A sessão principal planeja, delega a implementação ao subagente dev-shell e a verificação ao qa-visual, revisa, faz o commit e registra no painel, tarefa atrás de tarefa, até o ciclo.sh apontar um portão meu (QA ao vivo, pendência, fase fora do alcance). Use quando eu digitar /ciclo ou pedir para o projeto andar sozinho. Só no Claude Code.
---

# Ciclo de agentes

O ciclo existe para eu não precisar abrir sessão por sessão (decisão 0014, ajuste A-03). Ele não muda o protocolo: cada bloco de trabalho abre como o `/retomar`, registra cada tarefa na hora e fecha com o `/encerrar-sessao`. O que muda é quem faz cada parte.

| Papel | Quem | O que faz |
|---|---|---|
| Orquestrador | Esta sessão (Fable, effort high) | Lê o painel, escolhe a tarefa, tira os valores das fichas e escreve o briefing, revisa o diff, faz o commit, escreve no painel |
| Implementação | Subagente `dev-shell` (Sonnet) | Implementa só o que o briefing pede |
| Verificação | Subagente `qa-visual` (Sonnet) | Confere o resultado contra a ficha, com a bancada e o lint, sem ter visto a implementação |
| Varreduras | Subagente `varredura` (Haiku) | Trabalho mecânico: textos, logs, buscas em massa |

O painel fica em `${DOTFILES_PAINEL:-~/Documents/Journal/projeto-dotfiles}`. Todo texto é em primeira pessoa, conforme o `AGENTS.md`.

## Regras que não mudam

- **Só esta sessão escreve no painel.** O painel não tem controle de versão, e os subagentes não recebem permissão nem instrução para escrever nele. Eles devolvem relatório; quem registra sou eu.
- **Quem decide se o ciclo continua é o `ciclo.sh`**, não a minha impressão de que acabou. Rodo `.agents/scripts/ciclo.sh estado --dentro` antes de cada tarefa e paro em qualquer resultado diferente de `continuar`.
- **Nenhuma fase recebe `go` do ciclo.** O veredito é meu, na sessão do Niri (`/qa-fase ao-vivo`).
- **Nada fora do repositório e do painel.** O ciclo não instala pacote, não usa `sudo`, não faz `git push` e não escreve em `~/.config/`. O que precisar mudar ali (binds do Niri, por exemplo, pela P-35) é preparado no repositório e entra na lista "Aplicar na sessão ao vivo" do handoff da fase.
- **Nunca inventar valor.** Se a ficha, os tokens, o Figma e a origem não dão um valor, abro uma pendência em `PENDENCIAS.md` e marco a tarefa na nota da fase com `(bloqueada: P-NN)` no fim da linha. Esse texto é o que o `ciclo.sh` lê. Depois sigo para a próxima tarefa que não depende da resposta. **Falta de board não é falta de valor:** peça ou estado sem desenho no Figma é composto pela regra "Peça sem desenho no Figma" do `AGENTS.md` (ajuste A-05), e o briefing diz isso ao `dev-shell`, com os componentes e os tokens a usar.

## Abrir

1. Rodar `.agents/scripts/ciclo.sh estado`. Se o resultado não for `continuar`, não abrir nada: devolver o resumo do item "Parar" abaixo.
2. Rodar `.agents/scripts/ciclo.sh trava`.
3. Seguir os passos 1 a 6 da skill `retomar` (painel, fase ativa, último relatório, pendências, git, consistência), sem parar no resumo. Se houver commit sem relatório, reconstruir pelo git e anotar para o relatório deste bloco.

## Para cada tarefa

1. **Escolher.** A próxima tarefa aberta da fase ativa, na ordem da nota, que não esteja marcada `bloqueada:`. Se a fase estiver `planejada` sem tarefas detalhadas, a primeira tarefa é detalhar a fase pela ficha e passar o estado para `em andamento`. Uma tarefa de NoGo vale antes das outras.
2. **Planejar.** Ler a ficha da peça, os tokens, a nota da fase e as respostas de pendência que tocam a tarefa. Quando precisar do Figma, usar o board pelo node-id de `docs/design/README.md` (skill `figma:figma-design-to-code` antes de `get_design_context`). Conferir na origem o que for comportamento. Montar o briefing com o modelo abaixo. Faltou valor: pendência e `bloqueada:`, como nas regras.
3. **Implementar.** Chamar o subagente `dev-shell` com o briefing. Para trabalho mecânico (trocar textos para inglês, ler um log, procurar um padrão em muitos arquivos), chamar o `varredura`.
4. **Revisar.** Ler o `git diff` inteiro. Conferir: cada valor visual sai de token ou da ficha; o escopo é o da tarefa; o espécime e o serviço fictício acompanham a peça (decisão 0011); comentários em primeira pessoa; interface em inglês (decisão 0012). Rodar `.agents/scripts/lint-proveniencia.sh`. Problema na revisão volta para o `dev-shell` com a lista do que corrigir. Se a tarefa criou ou mudou uma biblioteca pura (um `.js` da shell com `.pragma library`, sem QML), rodar `.agents/scripts/testar.sh`, conferir que o teste está em `.agents/testes/` com os esperados tirados da ficha, e transformar cada falha conhecida (`skip`) em pendência no painel.
5. **Verificar.** Chamar o `qa-visual` com o identificador da tarefa, os critérios do briefing e a lista de espécimes, sem o relato do dev. Ele devolve `APROVADO` ou `REPROVADO`, com evidência. Quando a tarefa toca uma biblioteca pura, o `testar.sh` e o teste dela entram nos critérios.
6. **Corrigir.** `REPROVADO` volta ao `dev-shell` com os achados do QA, e o QA roda de novo. Depois de duas reprovações na mesma tarefa, paro de insistir: abro uma pendência com os achados e marco a tarefa `(bloqueada: P-NN)`.
7. **Registrar**, na hora em que a tarefa passa:
   - copiar os prints aprovados para `handoffs/FN-prints/` no painel, com o nome `FN-TNN-<o-que-é>-<variação>.png`;
   - commit no padrão do `AGENTS.md`: em português, um assunto por commit, sem rodapé de coautoria, `git push` nunca;
   - marcar a tarefa na nota da fase no formato das anteriores: o que fiz, commits, o que medi, onde estão os prints e o que falta ver ao vivo;
   - acrescentar à nota da fase o que o QA ao vivo precisa conferir dessa tarefa, para o handoff.
8. **Conferir o portão.** `.agents/scripts/ciclo.sh estado --dentro`. Se não for `continuar`, ir para "Fechar o bloco".

## Fim de fase

Quando a fase ativa não tiver mais tarefa aberta, rodar a skill `qa-fase` em modo `preparar`. Pelo ajuste A-03, nas fases do lote (F4, F5 e F6) a fase vai para `aguardando QA` e a seguinte pode começar sem o meu veredito. O handoff traz o roteiro para eu seguir na sessão do Niri e a lista "Aplicar na sessão ao vivo".

## Fechar o bloco

Fecho um bloco quando o `ciclo.sh` aponta um portão, quando a fase muda de estado, ou depois de quatro tarefas, o que vier primeiro. Fechar é rodar a skill `encerrar-sessao` inteira: o relatório do bloco é um relatório de sessão normal, com os commits e os subagentes usados.

Depois de fechar, se o `ciclo.sh estado --dentro` ainda disser `continuar`, abro um bloco novo nesta mesma conversa, a partir do passo 3 de "Abrir". Os relatórios e o painel guardam o que importa, então a compactação automática do contexto não perde nada.

## Parar

Ao parar por portão, rodar `.agents/scripts/ciclo.sh solta` e devolver, curto:

- o resultado do `ciclo.sh` e o motivo;
- as tarefas concluídas desde que o ciclo começou, com os commits;
- as pendências abertas, cada uma com a pergunta em uma linha;
- **O que eu faço agora**, sempre a última linha, com a ação literal: responder `P-NN` (e depois `/ciclo`), entrar no Niri e rodar `/qa-fase ao-vivo`, ou `.agents/scripts/ciclo.sh liberar`.

## Modelo de briefing para o dev-shell

```markdown
## Tarefa
`FN-TNN`: o texto da tarefa na nota da fase.

## Contexto
Fase, ficha, board do Figma (node-id) e as pendências respondidas que valem aqui, com as palavras da resposta.

## Valores
Cada medida, cor, raio, tempo e fonte que a peça usa, com a origem: token do `Theme.qml`, linha da ficha ou nó do Figma. Nada fica para o dev descobrir.

## Arquivos
O que muda, o que é criado e o que é apagado. Espécime em `demo/` e serviço fictício, quando a peça lê serviço. Teste em `.agents/testes/<biblioteca>.test.js`, quando a tarefa cria ou muda uma biblioteca pura (decidido na `F6-T18`, P-82).

## Fora do escopo
O que não mexer, mesmo que pareça errado.

## Pronto quando
Os critérios que o QA vai conferir, um por linha.
```
