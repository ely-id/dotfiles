# Niri

The configuration of the Niri compositor for the new installation.

> **Status:** this folder is empty and will stay that way for now. It was meant to be filled by a later phase of the project (F8), which would collect my Niri configuration in one sweep. That phase never started: I paused the project on 2026-11-20 ([decision 0018](../docs/decisoes/0018-pausa-e-apresentacao-em-ingles.md)).

For what Wintermute Shell needs from Niri today, and which of those lines are not shipped by this repository, see [What the shell needs from Niri](../wintermute-shell/README.md#what-the-shell-needs-from-niri) in the shell's readme.

## Why only at the end

While I was building the shell, the Niri configuration in `~/.config/niri/` changed with every phase: new shortcuts for the launcher and the screen capture, window rules, the space reserved for the sidebar, the focus ring. Versioning that configuration early would have meant correcting it at every phase. I preferred to collect everything once, when the shell was done and the configuration was stable.

## What the sweep would have collected

- Keyboard shortcuts, in a single file that is easy to edit.
- Input: the `us altgr-intl` keyboard, touchpad and gestures.
- Outputs and scale.
- Layout: gaps, focus ring and the space reserved for the sidebar.
- `wintermute.kdl`: the focus ring in the accent of the active variation, the `struts` of −4 that give 12 px at the edges with the `gaps 16` of `layout.kdl`, and the window corner radius of 12. The shell writes and rewrites this file (`wintermute-shell/settings/appearance/niri_theme.py`, marked `[wintermute]`, [design card 19](../docs/design/pecas/19-desktops.md)). The sweep would have collected the file and the line `include "./cfg/wintermute.kdl"` from `config.kdl`.
- Window rules.
- Animations.
- Session startup: the shell and the services it depends on.
- Any file outside `~/.config/niri/` that the session needs in order to work (environment variables, portals, the session entry).

Each collected file would get a header comment saying what it configures, and data specific to my machine (monitor names, personal paths) would be kept apart from what is generic.
