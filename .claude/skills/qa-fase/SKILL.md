---
name: qa-fase
description: Prepara uma fase do projeto dotfiles para avaliação Go/NoGo e registra o veredito. Use com "preparar" quando o trabalho de uma fase terminou e ela precisa de handoff com roteiro de teste, com "ao-vivo" quando eu abrir a sessão do Niri para avaliar, ou com "go" / "no-go" depois que eu avaliar a fase.
---

# QA de fase

O painel fica em `${DOTFILES_PAINEL:-~/Documents/Journal/projeto-dotfiles}`. O veredito é sempre meu. Esta skill nunca decide Go ou NoGo: ela prepara a avaliação e registra o que eu disser.

## Modo "preparar"

Usar quando todas as tarefas da fase (ou subfase) estão concluídas.

1. Conferir os critérios de PASS e FAIL da nota da fase, um a um, com evidência: medida conferida, print, comando e saída. Critério que não deu para verificar fora da sessão do Niri é marcado como "verificar ao vivo".
2. Tirar os prints possíveis e compará-los com a referência (PNG local ou board do Figma), nas três variações quando a peça usa acento.
3. Escrever `handoffs/FN-HANDOFF.md` a partir de `modelos/handoff.md`. O roteiro de teste é uma lista numerada de ações que eu executo na sessão do Niri, cada uma com o resultado esperado. Escrever para quem vai testar sem ler código: "pressione Super+B e a barra recolhe em 300 ms", não "conferir `collapseWidth`".
4. Listar com honestidade o que **não** foi verificado e as limitações conhecidas.
5. Escrever no handoff a seção **"Aplicar na sessão ao vivo"**: o que foi preparado no repositório e só pode ir para o sistema comigo presente (binds no `~/.config/niri/`, permissões, pacotes), com o comando e o que ele muda. "Nada" se não houver.
6. Mudar o estado da fase para `aguardando QA` na nota da fase e no `PAINEL.md`. Fora do lote, apontar o handoff em "Próximo passo". Nas fases do lote (F4, F5, F6, ajuste A-03), a fase seguinte pode começar: "Próximo passo" aponta a primeira tarefa dela e lembra quais fases esperam o QA ao vivo.
7. Fazer commit do que mudou no repositório.

## Modo "ao-vivo"

Usar quando eu abrir o Claude Code dentro da sessão do Niri para avaliar. Pelo ajuste A-03, isso acontece uma vez no fim da F6 para as fases do lote, e depois a cada fase.

1. Conferir que a sessão é do Niri (`NIRI_SOCKET` definido). Se não for, parar e dizer.
2. Rodar `.agents/scripts/ciclo.sh estado` e listar as fases em `aguardando QA`, com o handoff de cada uma.
3. Passar pela seção "Aplicar na sessão ao vivo" de cada handoff, um item por vez: dizer o que vai mudar, aplicar só com o meu ok e registrar no handoff o que foi aplicado. O que entrar no `~/.config/niri/` vai marcado com `wintermute` (P-35).
4. Abrir a shell como o README dela indica e ler o log dela em busca de erro.
5. Seguir o roteiro de cada handoff **um passo por vez**: dizer a ação e o resultado esperado, esperar a minha resposta e anotar no handoff o que eu disser, com as minhas palavras. Quando ajudar, tirar um print da tela e guardar junto dos prints da fase.
6. Ao fim de cada fase, pedir o meu veredito e registrar pelo modo "go" ou "no-go" abaixo, uma fase de cada vez.
7. Encerrar com a skill `encerrar-sessao`.

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

A fase seguinte só começa depois de um Go, com a exceção das fases do lote (ajuste A-03).
