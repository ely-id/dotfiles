# 0004 — Painel do projeto no Obsidian, fora do repositório

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

O problema que mais me atrapalha em projetos longos é a falta de continuidade: cada sessão de trabalho começa sem saber exatamente onde a anterior parou, e coisas decididas ou adiadas se perdem. Eu precisava de um lugar único que guardasse o estado do projeto e a memória do que aconteceu.

## Decisão

O acompanhamento do projeto vive em um vault do Obsidian, em `~/Documents/Journal/projeto-dotfiles/`, e funciona como um quadro de projeto: escopo, fases, tarefas, relatórios de sessão, handoffs e pendências. O repositório guarda o produto e as decisões que o explicam.

## Motivo

Já uso o Obsidian como diário, então o painel fica onde eu naturalmente olho. São arquivos Markdown simples, que qualquer agente de código lê e escreve sem ferramenta extra.

Mantive o painel fora do repositório porque ele é processo, não produto. Quem clonar estes dotfiles quer a shell e a configuração, não o registro das minhas sessões de trabalho. As decisões, que explicam por que o produto é como é, ficam no repositório.

## Consequências

- Toda sessão de trabalho começa lendo o painel e termina atualizando-o. As regras estão em `AGENTS.md` e resumidas em [fluxo-de-trabalho.md](../fluxo-de-trabalho.md).
- O escopo é um documento imutável. Mudanças entram em um registro separado que só cresce.
- O painel não é versionado pelo git deste repositório. A proteção dele é a sincronização e o backup do próprio vault.
- Os contratos de agente referenciam um caminho fora do repositório. Para quem clonar, esse caminho não existe e as ferramentas que dependem dele simplesmente não fazem nada.
