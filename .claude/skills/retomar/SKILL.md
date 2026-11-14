---
name: retomar
description: Abre uma sessão de trabalho no projeto dotfiles. Lê o painel do Obsidian, a fase ativa, o último relatório e o estado do git, e devolve um resumo de onde o projeto parou e qual é o próximo passo. Use no começo de toda sessão, antes de qualquer alteração.
---

# Retomar o projeto

O painel fica em `${DOTFILES_PAINEL:-~/Documents/Journal/projeto-dotfiles}`.

## Passos

1. Ler `PAINEL.md` inteiro.
2. Ler a nota da fase ativa em `fases/` (a fase com estado `em andamento`, `aguardando QA` ou `no-go`; se nenhuma, a primeira `planejada`).
3. Ler o relatório mais recente em `sessoes/` e, se a fase anterior tiver handoff, o arquivo correspondente em `handoffs/`.
4. Ler `PENDENCIAS.md` e separar as pendências que bloqueiam a fase ativa.
5. Rodar `git status` e `git log --oneline -10` no repositório.
6. Conferir a consistência:
   - Existe commit mais novo que o último relatório? Então a sessão anterior não registrou. Reconstruir pelo `git log` e pelo diff, e anotar isso para o relatório desta sessão.
   - Existe alteração não commitada? Descobrir a que tarefa pertence antes de mexer.
   - O estado no `PAINEL.md` bate com a nota da fase? Se não bater, a nota da fase é a fonte mais detalhada; corrigir o painel e avisar.

## O que devolver

Um resumo curto, em primeira pessoa, com:

- **Onde parei:** fase ativa, estado dela e última coisa feita.
- **Próximo passo:** a próxima tarefa aberta da fase, pelo identificador (`F2-T03`).
- **Bloqueios:** pendências que travam a fase e veredito de QA que esteja faltando.
- **Inconsistências:** qualquer divergência encontrada no passo 6.

Não começar a implementar dentro desta skill. Ela termina no resumo. Se a fase ativa estiver `aguardando QA`, o próximo passo é o meu veredito, e nenhuma fase nova começa sem ele.
