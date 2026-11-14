---
name: encerrar-sessao
description: Fecha uma sessão de trabalho no projeto dotfiles. Escreve o relatório da sessão no painel do Obsidian, atualiza a nota da fase e o PAINEL.md, registra pendências e ajustes que surgiram e faz o commit. Use sempre antes de terminar uma sessão, e também quando o contexto estiver perto do fim.
---

# Encerrar a sessão

O painel fica em `${DOTFILES_PAINEL:-~/Documents/Journal/projeto-dotfiles}`. Todo texto é em primeira pessoa, conforme o `AGENTS.md`.

## Passos, nesta ordem

1. **Levantar o que aconteceu.** Rodar `git status` e `git diff --stat`, e repassar a conversa atrás de: tarefas concluídas, tarefas começadas e não terminadas, decisões tomadas, perguntas que ficaram sem resposta, ideias adiadas e problemas encontrados.

2. **Decisões.** Decisão técnica com consequência duradoura vira um arquivo novo em `docs/decisoes/` no repositório, e a tabela de `docs/decisoes/README.md` ganha a linha correspondente.

3. **Commit.** Fazer commit do que mudou no repositório, no padrão do `AGENTS.md`, sem rodapé de coautoria. `git push` só se eu tiver pedido. O commit vem antes do relatório porque o hook de início de sessão trata commit mais novo que o último relatório como sessão não registrada.

4. **Relatório da sessão.** Criar `sessoes/AAAA-MM-DD-SNN-assunto.md` a partir de `modelos/sessao.md`. `SNN` é o número seguinte ao do último relatório. Preencher todas as seções; onde não houver nada, escrever "Nada" em vez de apagar a seção. Citar os commits da sessão.

5. **Nota da fase.** Em `fases/`, marcar as tarefas concluídas, acrescentar tarefas novas descobertas, criar subfase (`FN.M`) para ajuste que surgiu e atualizar o campo `estado` do cabeçalho.

6. **Pendências.** Toda pergunta sem resposta vira um item novo em `PENDENCIAS.md`, com identificador, fase que ela bloqueia e o contexto mínimo para eu responder sem reler a conversa. Pendência respondida nesta sessão é movida para a seção de resolvidas, com a resposta.

7. **Ajustes de escopo.** Tudo que foi pedido ou decidido fora do `ESCOPO.md` vira uma entrada nova no fim de `AJUSTES-DE-ESCOPO.md`. Nunca editar `ESCOPO.md` nem entradas antigas.

8. **PAINEL.md.** Atualizar a tabela de fases, as seções "Agora" e "Próximo passo" e acrescentar a linha da sessão no registro. "Próximo passo" tem que ser específico o bastante para a próxima sessão começar sem perguntar nada.

9. **Conferência final.** Reler o `PAINEL.md` como se fosse a primeira vez: ele descreve o estado real? Se alguém abrir uma sessão nova só com ele, sabe o que fazer?

## Se o contexto estiver acabando

Os passos 3, 4, 5 e 8 têm prioridade sobre terminar a tarefa em andamento. Uma tarefa pela metade registrada com precisão vale mais do que uma tarefa terminada e não registrada.

## O que devolver

O caminho do relatório criado, o estado em que a fase ficou e o próximo passo, em três linhas.
