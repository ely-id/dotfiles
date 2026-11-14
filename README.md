# dotfiles

Meus dotfiles para uma instalação do CachyOS com o compositor Niri e a **Wintermute Shell**, uma shell de desktop em Quickshell/QML com barra lateral, organizador de workspaces, painéis, launcher, captura de tela e histórico da área de transferência. O repositório também reúne a tela de bloqueio e de login, a configuração do terminal e o tema de boot.

> **Estado:** em construção. A shell ainda não está neste repositório e não existe instalador. Este README será reescrito quando o projeto chegar à fase de publicação.

## Por que este repositório existe

Vou reinstalar o sistema e quero que a migração seja consciente: construo e valido tudo na instalação atual, em uma sessão do Niri paralela ao GNOME, e só depois levo o resultado para a instalação nova. O objetivo é que essa instalação seja reproduzível a partir daqui, por mim ou por qualquer pessoa.

## Estrutura

```
dotfiles/
├── wintermute-shell/   A shell (Quickshell/QML)
├── niri/               Configuração do Niri
├── terminal/           zsh, Starship, Ghostty e fastfetch
├── plymouth/           Tema de boot
└── docs/
    ├── estrutura.md    Mapa do repositório e onde configurar cada coisa
    ├── decisoes/       Decisões do projeto e o motivo de cada uma
    └── design/         Fichas das peças e tokens do visual Armitage
```

O mapa detalhado está em [docs/estrutura.md](docs/estrutura.md).

## Base do sistema

| Camada | Escolha | Motivo |
|---|---|---|
| Distribuição | CachyOS | [Decisão 0001](docs/decisoes/0001-cachyos-como-base.md) |
| Compositor | Niri | [Decisão 0002](docs/decisoes/0002-niri-e-qa-em-sessao-paralela.md) |
| Shell | Wintermute Shell | [Decisão 0003](docs/decisoes/0003-base-de-codigo-da-pond.md) |

## Design

O visual se chama **Armitage** e tem três variações que mudam apenas a cor de acento: Chiba, Freeside e Sprawl. A shell é sempre escura. Os tokens e as fichas de cada peça estão em [docs/design/](docs/design/README.md).

## Instalação

Ainda não disponível. O instalador e o guia passo a passo fazem parte da fase de instalação reproduzível do projeto.

## Licenças e reconhecimentos

Este repositório é distribuído sob a licença BSD-3-Clause. Veja [LICENSE](LICENSE).

- **Pond** (Butterfly Interaction, Inc.): a interface da Pond é a referência de design e de comportamento da Wintermute Shell, e o código da shell parte do código da interface da Pond, distribuído sob BSD-3-Clause. O aviso de copyright e a licença originais acompanham o código derivado.
- **Lucide**: ícones, licença ISC.
- **Geist, Geist Mono e Geist Serif**: tipografia, licença SIL Open Font License 1.1.
- **Niri** e **Quickshell**: o compositor e o toolkit sobre os quais a shell roda.
- **Claude Code** (Anthropic): este projeto é construído com o apoio do Claude Code como agente de programação.
