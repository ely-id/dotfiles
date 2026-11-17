# Decisões

Cada arquivo registra uma decisão: o contexto em que ela foi tomada, o que escolhi, o motivo e o que isso acarreta. Decisões não são reescritas. Quando uma deixa de valer, crio uma nova que a substitui e marco a antiga como substituída.

| Nº | Decisão | Estado |
|---|---|---|
| [0001](0001-cachyos-como-base.md) | CachyOS como base do sistema | Aceita |
| [0002](0002-niri-e-qa-em-sessao-paralela.md) | Niri como compositor e avaliação em sessão paralela ao GNOME | Aceita |
| [0003](0003-base-de-codigo-da-pond.md) | Partir do código da interface da Pond, sem vínculo com o repositório de origem | Aceita |
| [0004](0004-painel-no-obsidian.md) | Painel do projeto no Obsidian, fora do repositório | Aceita |
| [0005](0005-referencias-fora-do-git.md) | Material de estudo e imagens de referência fora do git | Aceita |
| [0006](0006-voz-e-atribuicao.md) | Primeira pessoa em tudo e atribuição apenas no README | Aceita |
| [0007](0007-bloqueio-login-terminal-e-boot.md) | Tela de bloqueio, tela de login, terminal e boot entram no projeto | Aceita |
| [0008](0008-o-que-a-shell-traz-de-fora.md) | O que a shell traz de fora da pasta `shell/` da origem | Aceita |
| [0009](0009-compatibilidade-do-tema-ate-a-f6.md) | Tema Armitage único, com uma camada de compatibilidade até a F6 | Aceita |
| [0010](0010-ferramental-de-agente-em-agents.md) | Ferramental de agente comum em `.agents/`, para o Claude Code e o Antigravity | Aceita |
| [0011](0011-pecas-leem-service-e-vitrine-com-dados-ficticios.md) | As peças leem o estado por `service`, e a vitrine usa a peça real com dados fictícios | Aceita |
| [0012](0012-interface-em-ingles.md) | A interface da shell fala inglês | Aceita |
| [0013](0013-marca-logo-e-wintermute.md) | Na interface, a marca é o logo com a palavra "Wintermute" | Aceita |

## Modelo

```markdown
# NNNN — Título da decisão

- **Data:** AAAA-MM-DD
- **Estado:** Aceita | Substituída por NNNN

## Contexto

O que estava em jogo e quais eram as opções.

## Decisão

O que escolhi.

## Motivo

Por que escolhi isso e não as alternativas.

## Consequências

O que passa a valer, o que fica mais difícil e o que precisa ser lembrado.
```
