---
name: qa-fase
description: Prepara uma fase do projeto dotfiles para avaliação Go/NoGo e registra o veredito. Use com "preparar" quando o trabalho de uma fase terminou e ela precisa de handoff com roteiro de teste, ou com "go" / "no-go" depois que eu avaliar a fase na sessão do Niri.
---

# QA de fase

O painel fica em `${DOTFILES_PAINEL:-~/Documents/Journal/projeto-dotfiles}`. O veredito é sempre meu. Esta skill nunca decide Go ou NoGo: ela prepara a avaliação e registra o que eu disser.

## Modo "preparar"

Usar quando todas as tarefas da fase (ou subfase) estão concluídas.

1. Conferir os critérios de PASS e FAIL da nota da fase, um a um, com evidência: medida conferida, print, comando e saída. Critério que não deu para verificar fora da sessão do Niri é marcado como "verificar ao vivo".
2. Tirar os prints possíveis e compará-los com a referência (PNG local ou board do Figma), nas três variações quando a peça usa acento.
3. Escrever `handoffs/FN-HANDOFF.md` a partir de `modelos/handoff.md`. O roteiro de teste é uma lista numerada de ações que eu executo na sessão do Niri, cada uma com o resultado esperado. Escrever para quem vai testar sem ler código: "pressione Super+B e a barra recolhe em 300 ms", não "conferir `collapseWidth`".
4. Listar com honestidade o que **não** foi verificado e as limitações conhecidas.
5. Mudar o estado da fase para `aguardando QA` na nota da fase e no `PAINEL.md`, e apontar o handoff em "Próximo passo".
6. Fazer commit do que mudou no repositório.

## Modo "go"

1. Registrar na nota da fase e no handoff: `veredito: go`, a data e as minhas palavras, sem resumir.
2. Mudar o estado da fase para `go` no `PAINEL.md`.
3. Observações que acompanharam o Go e não bloqueiam viram tarefas da fase seguinte ou pendências.
4. Apontar em "Próximo passo" a primeira tarefa da fase seguinte.

## Modo "no-go"

1. Registrar na nota da fase e no handoff: `veredito: no-go`, a data e as minhas palavras, sem resumir.
2. Criar a subfase seguinte (`FN.1`, `FN.2`) na nota da fase, com uma tarefa por problema apontado. Cada tarefa descreve o problema como eu o descrevi e o comportamento esperado.
3. Mudar o estado da fase para `no-go` no `PAINEL.md` e apontar a subfase em "Próximo passo".
4. Quando a subfase terminar, rodar esta skill de novo em modo "preparar": o handoff ganha uma seção nova para a subfase, sem apagar a anterior.

A fase seguinte só começa depois de um Go.
