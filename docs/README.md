# Documentation

An index of what is in `docs/`.

| Path | What it is | Language |
|---|---|---|
| [showcase/](showcase/) | The visual catalogue: every piece of Wintermute Shell, in the three variations | English |
| [agent-workflow/](agent-workflow/) | How the project was run: phases with a gate, the project panel, and the roles in the work cycle | English |
| [design/](design/README.md) | The visual source of truth in text: the Armitage tokens (`tokens/tokens.json`) and one design card per piece (`pecas/`), with measurements, states and behaviour | Portuguese |
| [decisoes/](decisoes/README.md) | Decision records. Each one states the context, what I chose, the reason and the consequences | Portuguese |
| [estrutura.md](estrutura.md) | Map of the repository: where each thing lives and where it is configured | Portuguese |
| [fluxo-de-trabalho.md](fluxo-de-trabalho.md) | How the project moves forward: phases, subphases and the Go/NoGo evaluation | Portuguese |

The technical readme of the shell is in [`wintermute-shell/README.md`](../wintermute-shell/README.md).

## Why part of it is in Portuguese

When I paused the project, I moved its presentation to English and kept the working record in Portuguese, as history ([decision 0018](decisoes/0018-pausa-e-apresentacao-em-ingles.md)). Translating the decisions, the design cards and the code comments would mean rewriting that history, and it is worth more as it was written, in the language I thought and decided in.

The day-to-day tracking (tasks, sessions, handoffs and open questions) is not in this repository. It lives in the project panel, described in [fluxo-de-trabalho.md](fluxo-de-trabalho.md).

## Decision records

Decisions are not rewritten. When one stops being valid, I write a new one that replaces it and mark the old one as superseded. All eighteen are currently accepted. The titles below are translated; the records themselves are in Portuguese.

| No. | Decision |
|---|---|
| [0001](decisoes/0001-cachyos-como-base.md) | CachyOS as the base of the system |
| [0002](decisoes/0002-niri-e-qa-em-sessao-paralela.md) | Niri as the compositor, evaluated in a session parallel to GNOME |
| [0003](decisoes/0003-base-de-codigo-da-pond.md) | Start from the code of Pond's interface, with no link to the source repository |
| [0004](decisoes/0004-painel-no-obsidian.md) | The project panel lives in Obsidian, outside the repository |
| [0005](decisoes/0005-referencias-fora-do-git.md) | Study material and reference images stay out of git |
| [0006](decisoes/0006-voz-e-atribuicao.md) | First person everywhere, and attribution only in the README |
| [0007](decisoes/0007-bloqueio-login-terminal-e-boot.md) | Lock screen, login screen, terminal and boot join the project |
| [0008](decisoes/0008-o-que-a-shell-traz-de-fora.md) | What the shell brings from outside the origin's `shell/` folder |
| [0009](decisoes/0009-compatibilidade-do-tema-ate-a-f6.md) | A single Armitage theme, with a compatibility layer until phase F6 |
| [0010](decisoes/0010-ferramental-de-agente-em-agents.md) | Shared workflow tooling in `.agents/`, common to the two coding tools I used |
| [0011](decisoes/0011-pecas-leem-service-e-vitrine-com-dados-ficticios.md) | Pieces read their state through a `service`, and the showcase uses the real piece with fictitious data |
| [0012](decisoes/0012-interface-em-ingles.md) | The shell's interface speaks English |
| [0013](decisoes/0013-marca-logo-e-wintermute.md) | In the interface, the brand is the logo with the word "Wintermute" |
| [0014](decisoes/0014-ciclo-de-agentes.md) | The work cycle: one role orchestrates, another implements and verifies, and a script decides when to stop |
| [0015](decisoes/0015-um-arquivo-so-para-os-atalhos.md) | One file for the shortcuts: the Manual and Niri's binds come from the same list |
| [0016](decisoes/0016-dados-de-emoji-do-unicode-no-repositorio.md) | The emoji data comes from Unicode and enters the repository already generated |
| [0017](decisoes/0017-a-captura-recorta-o-quadro-congelado.md) | Screen capture crops the frozen frame instead of calling Niri's screenshot |
| [0018](decisoes/0018-pausa-e-apresentacao-em-ingles.md) | Project pause, presentation in English, and the documentation of the workflow |
