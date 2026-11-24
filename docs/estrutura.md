# Estrutura do repositório

> **Nota (pausa em 2026-11-20):** este arquivo registra a estrutura planejada do repositório. Com a pausa do projeto ([decisão 0018](decisoes/0018-pausa-e-apresentacao-em-ingles.md)), as fases F7 a F11 não começaram: `niri/` permaneceu vazia e as pastas `terminal/` e `plymouth/` nunca foram criadas. Mantive a árvore abaixo como registro histórico do plano.

```
dotfiles/
├── README.md               Apresentação, estado e licenças
├── LICENSE                 BSD-3-Clause
├── AGENTS.md               Contrato de trabalho para agentes de código
├── CLAUDE.md               Complemento do contrato para o Claude Code
├── .agents/                Ferramental de agente comum ao Claude Code e ao Antigravity
│   ├── skills/             Skills do projeto (/retomar, /encerrar-sessao, /qa-fase, /ciclo), a fonte
│   ├── hooks/              Aviso de início de sessão, adaptadores do Antigravity e o hook dos subagentes
│   ├── scripts/            Ciclo, bancada, lint, testes das bibliotecas, sincronização das skills e skills externas
│   ├── testes/             Testes das bibliotecas puras da shell (um `<biblioteca>.test.js` cada), o apoio e o runner
│   ├── bancada/            shell.qml de teste que a bancada põe numa cópia da shell
│   ├── rules/              Regra específica do Antigravity
│   ├── hooks.json          Hooks do Antigravity
│   └── SKILLS.md           Quando usar cada skill, nas duas ferramentas
├── .claude/                Configuração do Claude Code para este projeto
│   ├── settings.json       Hook de início de sessão, permissões e atribuição desligada
│   ├── agents/             Subagentes do ciclo: dev-shell, qa-visual e varredura
│   └── skills/             Cópia de .agents/skills/, refeita pelo script de sincronização
├── docs/
│   ├── estrutura.md        Este arquivo
│   ├── fluxo-de-trabalho.md
│   ├── decisoes/           Um arquivo por decisão, numerado
│   └── design/
│       ├── tokens/         tokens.json aprovado
│       └── pecas/          Uma ficha por peça ou grupo de peças
├── wintermute-shell/       A shell
├── niri/                   Configuração do Niri
├── terminal/               zsh, Starship, Ghostty e fastfetch
└── plymouth/               Tema de boot
```

## `wintermute-shell/`

Recebe o código da shell a partir da fase F0. A organização interna será documentada aqui quando o código entrar, com uma regra fixa desde já: quem quiser mudar um comportamento precisa encontrar o lugar certo sem ler o código inteiro. Por isso a pasta terá:

- um único arquivo de tema (`Theme.qml`), fonte de todas as cores, medidas e tempos;
- um único arquivo de atalhos, fácil de editar;
- uma pasta por peça (barra lateral, organizador, painéis, ajustes, launcher, captura, área de transferência);
- um `README.md` próprio explicando onde se configura cada coisa.

## `niri/`

Fica vazia até a fase F8. Quando a shell estiver pronta, recolho de `~/.config/niri/` tudo o que a instalação nova precisa: atalhos, entrada, telas, layout, regras de janela, animações e inicialização. Recolher no final evita versionar uma configuração que ainda muda a cada fase.

## Tela de bloqueio e tela de login

Entram na fase F7. Ainda não têm pasta porque o lugar depende de uma decisão dessa fase: se são parte da shell ou um componente separado, como acontece no projeto de origem. A decisão será registrada em `docs/decisoes/` antes de qualquer código.

## `terminal/`

Fica vazia até a fase F9. Recebe a configuração do zsh, do Starship, do Ghostty e do fastfetch, uma subpasta para cada um, depois de eu separar o que é genérico do que é pessoal (aliases de trabalho, caminhos, tokens).

## `plymouth/`

Fica vazia até a fase F9. Recebe o tema de boot do Plymouth, que hoje vive em um projeto separado nesta máquina.

## `docs/design/`

É a fonte da verdade visual em formato de texto. Os valores vêm daqui, nunca de memória nem de estimativa. As imagens de referência não ficam no repositório por causa do tamanho. A explicação está em [design/README.md](design/README.md).

## O que fica fora do repositório

| O quê | Onde | Motivo |
|---|---|---|
| Painel do projeto | `~/Documents/Journal/projeto-dotfiles/` | É acompanhamento pessoal de processo, não parte do produto |
| Clone da Pond para estudo | `~/Projects/referencias/dotfiles-estudo/pond-interface/` | Material de leitura; não é meu código |
| Pacote de entrega original | `~/Projects/referencias/dotfiles-estudo/pacote-entrega-original/` | Preservado como veio; a versão corrigida das fichas está em `docs/design/` |
| Material de apoio do pacote | `~/Documents/pacote-entrega/` (`spec-pond-shell.md`, `armitage-shell/`) | Serve para adiantar o trabalho; não é fonte de valores |
| PNGs de referência | dentro do pacote original, em `referencias/` | 40 MB de binários que inflariam o histórico para sempre |
| Configuração local do Claude Code | `.claude/settings.local.json` | Permissões específicas desta máquina |
| Permissões do Antigravity | Configuração global do Antigravity | A ferramenta não tem arquivo de permissão por projeto; os bloqueios do projeto estão no hook de `.agents/hooks.json` |
| Skills externas no Antigravity | `~/.gemini/config/skills/` | São de terceiros, com licenças próprias; `.agents/scripts/instalar-skills-externas.sh` copia dos plugins do Claude Code |
| Figma e Context7 no Antigravity | Plugins de parceiros, na configuração global do Antigravity | Cada plugin traz o servidor MCP e as skills mantidos pelo próprio fornecedor |
