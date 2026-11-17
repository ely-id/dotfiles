---
name: retomar
description: Abre uma sessão de trabalho no projeto dotfiles. Lê o painel do Obsidian, a fase ativa, o último relatório e o estado do git, e devolve um resumo de onde o projeto parou e qual é o próximo passo. Use no começo de toda sessão, antes de qualquer alteração.
---

# Retomar o projeto

O painel fica em `${DOTFILES_PAINEL:-~/Documents/Journal/projeto-dotfiles}`.

## Passos

1. Ler `PAINEL.md` inteiro.
2. Ler a nota da fase ativa em `fases/`. Na ordem da tabela do painel, a fase ativa é a primeira com estado `em andamento`, `aguardando QA` ou `no-go`; se nenhuma, a primeira `planejada`. Exceção do ajuste A-03: uma fase do lote (F4, F5, F6) em `aguardando QA` não segura a seguinte, então ela é pulada e a ativa é a próxima. `.agents/scripts/ciclo.sh estado` faz essa conta e serve de conferência.
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
- **O que eu faço agora:** a última linha do resumo, sempre. Quando o próximo passo é meu, ela traz a ação literal: o comando ou a frase que eu digito em seguida (por exemplo, `/qa-fase go`), ou o que eu preciso testar e onde. Quando o próximo passo é do agente, ela diz o que eu respondo para ele começar.

Não começar a implementar dentro desta skill. Ela termina no resumo. Se a fase ativa estiver `aguardando QA`, o próximo passo é o meu veredito, e nenhuma fase nova começa sem ele. A exceção são as fases do lote (ajuste A-03): enquanto a próxima fase também for do lote, o trabalho segue, e o resumo lembra quais fases esperam o QA ao vivo. Quando o trabalho pode seguir sozinho, a última linha pode ser `/ciclo`.

A skill `ciclo` usa os passos 1 a 6 desta skill para abrir cada bloco, sem parar no resumo.

O resumo existe para eu saber continuar sem pensar. Na primeira vez em que usei esta skill, ela descreveu o estado corretamente e eu fiquei sem saber o que digitar. Um resumo que termina em "o próximo passo é dar o veredito" está incompleto; o completo termina em "se está tudo certo, digite `/qa-fase go`".
