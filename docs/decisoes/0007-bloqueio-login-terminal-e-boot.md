# 0007 — Tela de bloqueio, tela de login, terminal e boot entram no projeto

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

O plano inicial cobria duas coisas: a shell e a configuração do Niri. Ao fechar a base do projeto, ficaram duas perguntas em aberto. A primeira: a instalação nova teria tela de bloqueio e de login com o visual Wintermute, já que as fichas do design não desenham essas telas? A segunda: o que "dotfiles completo" inclui além da shell e do compositor?

## Decisão

Entram no projeto:

- **Tela de bloqueio e tela de login** com o visual Wintermute. O design dessas telas é produzido por mim no Figma antes de a fase começar.
- **Terminal**: a configuração do zsh, do Starship, do Ghostty e do fastfetch.
- **Boot**: o tema do Plymouth.

Ficam de fora o tema GTK, os cursores e os ícones dos aplicativos, que eu continuo configurando à parte.

## Motivo

Um desktop com shell própria e tela de bloqueio genérica fica pela metade: o bloqueio é a primeira e a última coisa que eu vejo em cada sessão. E "reproduzível" só é verdade se, depois de instalar, eu abrir o terminal e encontrar o meu ambiente, sem uma tarde de ajustes manuais.

Terminal e boot já existem configurados nesta máquina. Trazê-los para o repositório é trabalho de recolher e limpar, não de construir.

## Consequências

- O projeto ganha duas fases: a de bloqueio e login, depois que a shell está completa, e a de terminal e boot, depois da varredura do Niri.
- A fase de bloqueio e login não começa sem design aprovado. Para essas telas valem as mesmas regras das outras peças: ficha, tokens e nenhum valor inventado.
- Esta decisão revê um ponto da [decisão 0003](0003-base-de-codigo-da-pond.md), que deixava a tela de bloqueio de fora. Se o código da tela de bloqueio parte ou não do projeto de origem é uma escolha da própria fase, registrada em decisão própria.
- O tema de boot que entra é o meu. O tema de inicialização do projeto de origem continua fora.
- O repositório ganha as pastas `terminal/` e `plymouth/`. A localização da tela de bloqueio e de login é definida na fase correspondente.
- Configuração de terminal costuma carregar dado pessoal: aliases de trabalho, caminhos, tokens. A fase que recolhe esses arquivos separa o genérico do pessoal antes de versionar.
