# Terminal

Configuração do meu ambiente de terminal para a instalação nova.

> **Estado:** esta pasta fica vazia até a fase F9.

## O que entra

| Ferramenta | Papel |
|---|---|
| zsh | Shell de linha de comando |
| Starship | Prompt |
| Ghostty | Emulador de terminal |
| fastfetch | Resumo do sistema na abertura do terminal |

Cada uma ganha uma subpasta com a configuração e um cabeçalho dizendo o que o arquivo faz.

## O que a fase F9 faz antes de versionar

Esses arquivos existem hoje nesta máquina e carregam coisas que não servem para mais ninguém. Antes de entrar no repositório, cada um passa por uma limpeza:

- aliases, funções e caminhos de trabalho saem ou vão para um arquivo local que não é versionado;
- tokens, chaves e qualquer segredo são removidos;
- o que depende de um programa que a instalação nova não terá é removido ou protegido por uma verificação;
- as cores seguem o tema Armitage, para o terminal combinar com a shell.
