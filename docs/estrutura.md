# Estrutura do repositório

```
dotfiles/
├── README.md               Apresentação, estado e licenças
├── LICENSE                 BSD-3-Clause
├── AGENTS.md               Contrato de trabalho para agentes de código
├── CLAUDE.md               Complemento do contrato para o Claude Code
├── .claude/                Configuração do Claude Code para este projeto
│   ├── settings.json       Hook de início de sessão, bloqueios e atribuição desligada
│   ├── hooks/              Scripts executados pelos hooks
│   ├── skills/             Skills do projeto (/retomar, /encerrar-sessao, /qa-fase)
│   └── SKILLS.md           Quando usar cada skill
├── docs/
│   ├── estrutura.md        Este arquivo
│   ├── fluxo-de-trabalho.md
│   ├── decisoes/           Um arquivo por decisão, numerado
│   └── design/
│       ├── tokens/         tokens.json e Theme.qml aprovados
│       └── pecas/          Uma ficha por peça ou grupo de peças
├── wintermute-shell/       A shell
└── niri/                   Configuração do Niri
```

## `wintermute-shell/`

Recebe o código da shell a partir da fase F0. A organização interna será documentada aqui quando o código entrar, com uma regra fixa desde já: quem quiser mudar um comportamento precisa encontrar o lugar certo sem ler o código inteiro. Por isso a pasta terá:

- um único arquivo de tema (`Theme.qml`), fonte de todas as cores, medidas e tempos;
- um único arquivo de atalhos, fácil de editar;
- uma pasta por peça (barra lateral, organizador, painéis, ajustes, launcher, captura, área de transferência);
- um `README.md` próprio explicando onde se configura cada coisa.

## `niri/`

Fica vazia até a fase F7. Quando a shell estiver pronta, recolho de `~/.config/niri/` tudo o que a instalação nova precisa: atalhos, entrada, telas, layout, regras de janela, animações e inicialização. Recolher no final evita versionar uma configuração que ainda muda a cada fase.

## `docs/design/`

É a fonte da verdade visual em formato de texto. Os valores vêm daqui, nunca de memória nem de estimativa. As imagens de referência não ficam no repositório por causa do tamanho. A explicação está em [design/README.md](design/README.md).

## O que fica fora do repositório

| O quê | Onde | Motivo |
|---|---|---|
| Painel do projeto | `~/Documents/Journal/projeto-dotfiles/` | É acompanhamento pessoal de processo, não parte do produto |
| Clone da Pond para estudo | `~/Projects/referencias/dotfiles-estudo/pond-interface/` | Material de leitura; não é meu código |
| Pacote de entrega original | `~/Projects/referencias/dotfiles-estudo/pacote-entrega-original/` | Preservado como veio; a versão corrigida das fichas está em `docs/design/` |
| PNGs de referência | dentro do pacote original, em `referencias/` | 40 MB de binários que inflariam o histórico para sempre |
| Configuração local do Claude Code | `.claude/settings.local.json` | Permissões específicas desta máquina |
