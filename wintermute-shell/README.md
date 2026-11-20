# Wintermute Shell

A desktop shell for the [Niri](https://github.com/YaLTeR/niri) compositor, written in Quickshell/QML. It draws a sidebar with a workspace organiser, stacked panels (Wi-Fi, Bluetooth, sound, battery, calendar, notifications), a Settings screen, a launcher with a colour picker and an emoji picker, screen capture with an annotation editor, and a clipboard history. The visual system is called **Armitage** and comes in three dark variations: **Chiba**, **Freeside** and **Sprawl**.

> **Status:** paused on 2026-11-20 ([decision 0018](../docs/decisoes/0018-pausa-e-apresentacao-em-ingles.md)). The shell runs and I used it in a live Niri session, but there is no installer, part of what it needs from Niri is not shipped here, and screen capture is not stable. Read [What the shell needs from Niri](#what-the-shell-needs-from-niri) and [Known issues](#known-issues) before trying it.

The interface is in English. The comments in the code, the design cards and the decision records are in Portuguese, which is the language I worked in.

## Contents

- [Requirements](#requirements)
- [Running it](#running-it)
- [IPC commands](#ipc-commands)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Configuration and state files](#configuration-and-state-files)
- [The three variations](#the-three-variations)
- [What the shell needs from Niri](#what-the-shell-needs-from-niri)
- [The drag plugin (optional, C++)](#the-drag-plugin-optional-c)
- [Folder map](#folder-map)
- [How the larger pieces work](#how-the-larger-pieces-work)
- [Fonts and icons](#fonts-and-icons)
- [Known issues](#known-issues)
- [Licence](#licence)

## Requirements

There is no installer and no package list: the phase that would have written them never started. This is what the code calls, read from the code itself.

| What | Used for |
|---|---|
| Niri | The compositor. I developed against Niri 26.04 |
| Quickshell | The toolkit. I developed against Quickshell 0.3.2, with its Wayland, Io, Widgets, Networking, Bluetooth and Services modules (UPower, SystemTray, Pipewire, Notifications, Mpris) |
| Python 3 with PyQt6 and PyGObject | The helper scripts: wallpaper thumbnails and picker, Bluetooth actions, Settings, clipboard |
| NetworkManager (`nmcli`) | Wi-Fi panel |
| BlueZ, `rfkill` | Bluetooth panel, and unblocking the Bluetooth radio |
| PipeWire, `pactl` | Sound panel and volume |
| UPower, `power-profiles-daemon` | Battery pop-up and power profile selector |
| `brightnessctl`, `ddcutil` | Screen brightness: the backlight of a built-in panel, and DDC for external monitors |
| `wl-clipboard` (`wl-paste`, `wl-copy`) | Clipboard history and copying a capture |
| `fd`, `xdg-open` | File search and opening results in the launcher |
| `fastfetch` | The Information page in Settings |
| `gsettings` | Light and dark mode for applications |
| `cachy-update` | The updates badge (CachyOS) |
| `wpctl`, `playerctl` | Only the media-key lines of the default shortcut list |
| Geist, Geist Mono, Geist Serif, Noto Color Emoji | Fonts, installed on the system (see [Fonts and icons](#fonts-and-icons)) |
| `cmake`, a C++ compiler, Qt 6.11 headers | Only for the optional drag plugin |

## Running it

The shell is self-contained: everything it needs lives in this folder and is imported by relative path, so nothing has to be copied to `~/.config/quickshell/`. Inside an active Niri session (with `NIRI_SOCKET` in the environment), I point Quickshell at the folder. From the repository root:

```bash
qs -p wintermute-shell
```

Any path to this folder works in place of `wintermute-shell`.

The first time the shell runs it opens the shortcut Manual by itself and creates `~/.local/state/wintermute-shell/manual-shown`. Deleting that file makes the Manual open again on the next start.

## IPC commands

With the shell open, I trigger actions through Quickshell's IPC, using the same path the shell was started with:

```bash
qs -p wintermute-shell ipc call <target> <function> [arguments]
```

These are the handlers that exist in `shell.qml`, `Shortcuts.qml` and `installs/State.qml`:

| Target and function | What it does |
|---|---|
| `sidebar toggle` | Collapses or expands the sidebar (the card goes from 156 px to 48 px wide) |
| `sidebar demoCards` | Turns the sidebar's sample cards on or off (fictitious data, for inspection) |
| `launcher toggle` / `open` / `close` | Opens or closes the launcher on the focused monitor |
| `launcher clipboard` | Opens the launcher straight on the clipboard history page, or closes it if that page is already open. Super+V calls this one |
| `settings toggle` | Opens or closes the Settings home screen |
| `settings open <page>` | Opens a page directly: `appearance`, `wallpaper`, `customize`, `information`, `manual`, `display`, `arrange`, `system`, `mouse`, `lock` or `keyboard`. An unknown name is ignored |
| `settings close` | Closes Settings |
| `manual open` | Opens the shortcut Manual |
| `screenshot open` / `close` / `toggle` | Opens or closes the screen capture overlay on the focused monitor. Super+Shift+1 calls `open` |
| `volume increase` / `decrease` | Changes the output volume in steps of 10% |
| `volume muteOutput` / `muteInput` | Toggles mute on the output or on the microphone |
| `brightness increase` / `decrease` | Changes the brightness of the focused monitor in steps of 10% |
| `media playPause` / `next` / `previous` | Controls the active MPRIS player |
| `installs update <id> <name> <status> <percentage> <message> <icon>` | Feeds the install progress card in the sidebar |
| `demo toggle` / `open` / `close` | Opens or closes the component demo panel, with the Armitage base component library and its states |
| `test toggle` / `open` / `close` | Opens or closes the font test panel (Geist Serif, Geist, Geist Mono and a quick variation switch) |

The launcher, Settings, the capture overlay, the annotation editor and the colour-picker loupe all ask for exclusive keyboard focus, so opening one closes the others.

## Keyboard shortcuts

The shortcuts live in one file, `settings/manual/shortcuts.json` ([decision 0015](../docs/decisoes/0015-um-arquivo-so-para-os-atalhos.md)). The Manual page in Settings takes the keys it shows from that list, and `settings/manual/keybinds.py` generates Niri's `binds { }` block from it. I edit shortcuts only in the JSON, never in the generated `keybinds.kdl`.

The ones that open a piece of the shell:

| Keys | Action |
|---|---|
| Super+` | Collapse or expand the sidebar |
| Super+E | Launcher |
| Super+V | Clipboard history |
| Super+Escape | Settings |
| Super+Shift+1 | Screenshot a region, with the shell's capture overlay |
| Super+Shift+2, Super+Shift+3 | Screenshot the screen or the window, with Niri's own screenshot actions |
| Super+L | Lock screen. Generated commented out: it waits for the lock screen, which was never built |
| Brightness keys | `brightness increase` and `decrease` over IPC |
| Volume and media keys | `wpctl` and `playerctl`, directly |

The rest of the list (73 binds in total) covers applications, windows, workspaces, layout and system actions.

### The list format

Each item is either a section (`{ "section": "Windows" }`, which becomes a comment in the KDL) or a shortcut with:

- `bind`: the key as Niri writes it, for example `Mod+Shift+A`;
- `label`: the description, in English;
- one action: `niri` (a Niri action), `spawn` (a program), `sh` (a shell command) or `ipc` (a call to this shell's IPC).

Optional fields:

- `options` carries Niri properties, such as `cooldown-ms=150`;
- `"manual": false` hides the shortcut from the Manual;
- `"overlay": true` uses the `label` as the bind's title in Niri's hotkey overlay. It is not valid on a line with `binds`, nor together with `"manual": false`;
- `"waits": "F7"` marks a shortcut whose action does not exist yet; it is generated commented out;
- a Manual line that groups several binds (the wheel, Super+1 to 9) uses `keys` and `binds`.

### The generator

```bash
wintermute-shell/settings/manual/keybinds.py check      # validates the list
wintermute-shell/settings/manual/keybinds.py generate   # writes the binds { } block to standard output
wintermute-shell/settings/manual/keybinds.py generate --output ~/.config/niri/cfg/keybinds.kdl --apply
```

- `--shell PATH` changes the shell folder written into the IPC commands. Without it the generator uses the folder where the script lives, with a leading home directory written as `~`.
- `--list FILE` reads another `shortcuts.json`.
- Writing inside `~/.config` requires `--apply`, which first saves a copy named `keybinds.kdl.bak-YYYYMMDD-HHMMSS` next to the file and only applies the result if `niri validate` accepts it.

## Configuration and state files

`Theme.qml` is the single source of truth in code for colours, typography, radii, shadows, measurements and durations. It mirrors `../docs/design/tokens/tokens.json`. No piece writes a colour or a font family of its own.

Every path below respects the matching XDG variable (`XDG_CONFIG_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`). Several still carry the name of the code's origin; see [Known issues](#known-issues).

| Path | Read or written | What it holds |
|---|---|---|
| `~/.config/wintermute-shell/theme.json` | Both | The active variation: `{"theme": "chiba"}`, `"freeside"` or `"sprawl"`. `Theme.qml` watches the file and applies a change at once |
| `~/.config/wintermute-shell/apps.json` | Both | Whether applications switch between light and dark by time of day |
| `~/.config/pond-interface/wallpaper.json` | Both | The wallpaper choice |
| `~/.config/pond-interface/idle.json` | Both | Idle timeouts on mains and on battery, and "Ask for password on wake" |
| `~/.config/niri/cfg/wintermute.kdl` | Written | Focus ring, struts and corner radius for Niri (next section) |
| `~/.config/niri/cfg/display.kdl` | Both | Monitor modes, scale and arrangement, from the Display pages in Settings. Validated and written under the lock file `~/.config/niri/.pond-display.lock` |
| `~/.config/niri/cfg/input.kdl` | Both | Keyboard layouts and mouse and touchpad settings, from the System pages in Settings |
| `~/.local/state/wintermute-shell/manual-shown` | Both | Marks that the Manual has already opened once |
| `~/.local/state/wintermute-shell/launcher-recents.json` | Both | Recent launcher items |
| `~/.local/state/wintermute-shell/colors.json` | Both | Colour picker history |
| `~/.local/state/wintermute-shell/emoji-recents.json` | Both | Recent emojis |
| `~/.local/state/pond-interface/notifications.json` | Both | Notification history |
| `~/.cache/pond-interface/wallpapers/` | Written | Wallpaper thumbnails |
| `$XDG_RUNTIME_DIR/wintermute-shell/` | Written | Temporary PNGs from screen capture, and the images of the clipboard history in `clipboard/`. Gone at logout |
| `~/Pictures/Wallpapers/` | Read | My own wallpapers, next to the three shipped in `wallpaper/included/` |
| `~/Pictures/Screenshots/` | Written | Saved captures |

## The three variations

The shell is always dark. The three variations change only the accent; the neutrals and the layout are identical.

| Variation | Accent |
|---|---|
| Chiba | `#52C2F6` |
| Freeside | `#7F89E1` |
| Sprawl | `#F4A846` |

I switch with the three discs on the **Appearance** page in Settings, or by writing `{"theme": "chiba"}` to `~/.config/wintermute-shell/theme.json`. When the variation changes, the shell also rewrites Niri's focus ring in the new accent.

## What the shell needs from Niri

The desktop only looks as designed when Niri is configured for it. Part of that the shell writes by itself; the rest I set by hand during the live QA on 2026-11-20, and **the repository does not ship it yet**. The measurements and the reasoning are in [design card 19](../docs/design/pecas/19-desktops.md).

### What the shell writes: `wintermute.kdl`

`settings/appearance/niri_theme.py`, called by `settings/appearance/NiriTheme.qml`, writes `~/.config/niri/cfg/wintermute.kdl` once when the shell starts and again whenever the variation changes:

```kdl
layout {
    focus-ring {
        width 2
        active-color "#52C2F6"
    }
    struts {
        left -4
        right -4
        top -4
        bottom -4
    }
}
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}
```

- The focus ring is 2 px in the accent of the active variation.
- Niri has a single `gaps` value, used both between columns and at the edges. With `gaps 16` in my layout and `struts` of −4 on all four sides, windows sit **12 px** from the edges and **16 px** from each other. One depends on the other: if `gaps` changes, the edge becomes `gaps` − 4.
- The sidebar window reserves **176 px** expanded and **68 px** collapsed (10 + the 156 or 48 px card + 10), so the first window starts at x 188 or x 80. Niri moves the windows when the zone changes; the shell only changes the zone.
- The corner radius of every window is 12.

The file belongs to the shell. It starts with a `[wintermute]` marker, and the script refuses to write over an existing file that does not have it. The script validates the text with `niri validate` before replacing the file, and does not rewrite it when nothing changed. `niri_theme.py check --accent "#RRGGBB"` shows what it would write, without writing.

**The file only takes effect once this is the last line of Niri's `config.kdl`:**

```kdl
include "./cfg/wintermute.kdl"
```

I add that line by hand; the shell never writes to `config.kdl`. It has to come last so that the radius of 12 wins over any earlier window rule. To undo everything, I remove the line and delete the file.

### What I set by hand

These lines live in my local Niri configuration, not in this repository. Without them, a fresh setup shows a black screen behind the windows.

```kdl
layout {
    gaps 16
    // The wallpaper sits in Niri's backdrop; an opaque workspace colour covers it.
    background-color "transparent"
}

// Keeps the shell's wallpaper in the backdrop.
layer-rule {
    match namespace="^pond-wallpaper$"
    place-within-backdrop true
}

// The glass of the shell's layers. No `blur true` here.
layer-rule {
    match namespace="^wintermute-sidebar$"
    match namespace="^pond-((volume|brightness|keyboard)$|calendar-|battery-|notification-|settings-)"
    match namespace="^wintermute-(launcher|annotate|screenshot-saved)-"
    background-effect {
        xray false
        saturation 1.0
    }
}

// Stops a drag in the sidebar's workspace organiser from scrolling Niri's view at the screen edge.
gestures {
    dnd-edge-view-scroll {
        max-speed 0
    }
}
```

- **`background-color "transparent"` is required.** The wallpaper layer is placed in the backdrop by the `place-within-backdrop` rule, and with an opaque workspace background it shows black.
- **The layer rule must not force `blur true`.** The pieces ask for the blur themselves, over their own region. With `blur true` in the rule, the notification centre flashed a full-screen blur when opening and closing.
- The third `match` line covers the launcher, the annotation editor and the "Screenshot saved" toast; without it their glass only blurs the wallpaper.

The proposal I left open was for `niri_theme.py` to write these lines into `wintermute.kdl` as well, next to the focus ring and the struts. It was not started when I paused the project.

## The drag plugin (optional, C++)

Dragging the capture thumbnail from the sidebar into another application uses a Qt plugin written in C++ (`screenshot/native/`). It has to be built once, with `cmake`, a C++ compiler and the Qt 6 headers (the build asks for Qt 6.11). From the repository root:

```bash
cmake -S wintermute-shell/screenshot/native -B wintermute-shell/screenshot/native/build
cmake --build wintermute-shell/screenshot/native/build
```

The `build/` folder stays out of git.

**The shell opens the same way without the plugin.** Dragging the preview does not exist (the cursor over it stays the normal one), one warning line goes to the log, and the preview still copies, saves, annotates and closes.

Qt has to find the module `Wintermute.Screenshot.Native`, and there are two ways:

- **Installed on the system.** `sudo cmake --install wintermute-shell/screenshot/native/build --prefix /usr` copies the module to `lib/qt6/qml/Wintermute/Screenshot/Native`, which is Qt's QML module folder on CachyOS. Without `--prefix` the destination would be `/usr/local`, where Qt does not look. Installed there, I open the shell normally.
- **Straight from the build folder, without installing.** I point `QML_IMPORT_PATH` at `build/` when opening the shell:

  ```bash
  QML_IMPORT_PATH="$PWD/wintermute-shell/screenshot/native/build" qs -p wintermute-shell
  ```

I looked for a way to make the shell find `build/` by itself and there is no clean one. Quickshell's `//@ pragma Env QML_IMPORT_PATH = ...` works, but the value is copied as written and a relative path counts from the folder where `qs` was started, not from the shell's folder; and an import by relative path does not find the plugin inside `qs`. An absolute path in `shell.qml` would put a personal path in the code, so the variable is left to whoever opens the shell.

## Folder map

| Path | What it holds |
|---|---|
| `shell.qml` | The root: creates the wallpaper, the sidebar, the pop-ups, Settings, the launcher and the capture windows per monitor, and the IPC handlers |
| `Theme.qml` | Armitage tokens, accent variations and Geist typography, including the measurements of every piece. The only theme file |
| `Sidebar.qml`, `BottomControls.qml` | The sidebar window (a layer-shell surface) and the bottom controls card (Wi-Fi, sound, Settings and collapse) |
| `NiriMsg.qml` | Integration with Niri (`niri msg event-stream` and the IPC socket): workspaces, windows, focus, and the launcher request from the organiser's "+" |
| `Shortcuts.qml` | IPC handlers for volume, media and brightness |
| `GlassSurface.qml`, `GradientFill.qml`, `PanelBorder.qml`, `Shadow.qml`, `Card.qml`, `CardStack.qml`, `CardLayer.qml`, `PanelBackground.qml` | The Armitage glass surface (vertical gradient with dithering, inner gradient border, 1 px top highlight, accent glow at the base, two-layer shadow) and the stacked cards |
| `IconButton.qml`, `PanelCloseButton.qml`, `ActionButton.qml`, `Toggle.qml`, `Slider.qml`, `Field.qml`, `CheckBox.qml`, `RadioButton.qml`, `ListRow.qml`, `SettingsRow.qml`, `SegmentedSelector.qml`, `Chip.qml`, `Tag.qml`, `KeyCap.qml`, `AppTile.qml`, `DeviceList.qml`, `DeviceDetails.qml` | The Armitage base component library (design card `00-componentes-base.md`) |
| `OsdCard.qml`, `VolumeFeedback.qml`, `BrightnessFeedback.qml`, `KeyboardFeedback.qml`, `KeyboardLayoutCard.qml` | The on-screen displays for volume, brightness and keyboard layout |
| `IdleFade.qml` | Fades every screen to black when the "turn off the screen" time passes, then powers the monitors off |
| `ComponentDemoPanel.qml`, `FontTestPanel.qml` | Inspection panels: base components, and fonts with the variations |
| `icons/` | The 113 Lucide icons, drawn in white: the colour always comes from the piece, by colourising with a token. Also `LICENSE-lucide.txt` |
| `minimap/` | The workspace organiser in the sidebar: rows, window circles, the "+" button, dragging, and the status indicator shown on terminal windows (working, waiting for attention, finished) |
| `calendar/` | The clock and battery card in the sidebar (`Clock.qml`) and the monthly calendar pop-up |
| `media/` | The MPRIS player card in the sidebar |
| `notifications/` | The notifications card in the sidebar, the notification centre (`CenterWindow.qml`) and the toasts shown with the sidebar collapsed (`ToastWindow.qml`) |
| `installs/`, `updates/` | The install progress card in the sidebar and the updates badge on the Settings screen |
| `wifi/` | Stacked Wi-Fi panel: network list, password, hidden network, details and status (`State.qml`, through `nmcli`) |
| `bluetooth/` | Stacked Bluetooth panel: paired, nearby, pairing and details (`actions.py`, through BlueZ over D-Bus) |
| `audio/` | Sound panel: output and input tabs, volume slider and the PipeWire device list |
| `battery/` | Battery pop-up, power profile selector, indicator and low-battery alert |
| `launcher/` | The launcher, the colour picker, the actions menu and the emoji picker |
| `clipboard/` | Clipboard history, shown inside the launcher |
| `settings/` | The Settings home screen, session buttons (`session.py`), system tray (`Tray.qml`), drop-down menu (`Dropdown.qml`), KDL reader (`kdl.py`) and the pages in `appearance/`, `display/`, `system/`, `information/` and `manual/` |
| `screenshot/` | Screen capture, the preview in the sidebar, the annotation editor, saving, and the C++ drag plugin in `native/` |
| `wallpaper/` | The wallpaper layer per monitor (`desktop/`), the dynamic sky shader (`daylight/`), the three shipped wallpapers (`included/`, with `catalog.json`) and the selection script (`control.py`) |
| `demo/` | Specimens: each piece rendered with fictitious data through a stand-in service, for the showcase and for prints taken outside Niri |
| `assets/` | Visual resources inherited from the code's origin. Only `brand/logo.svg` and `information/arch.svg` are still referenced |

## How the larger pieces work

Each piece has a design card in `../docs/design/pecas/` with its measurements, states and behaviour.

### Launcher (`launcher/`)

Cards [14](../docs/design/pecas/14-launcher.md), [15](../docs/design/pecas/15-color-picker.md) and [16](../docs/design/pecas/16-emoji.md).

- One window per screen, with a veil, the glass with the search field, a list in sections and a footer. `State.qml` is the state the piece reads.
- **Search** (`Search.js`, a pure library) matches and ranks applications, files (`FileSearch.qml`, which runs `fd`), Settings pages and session commands. When nothing is found, the launcher offers "Search the web" (through `xdg-open`) and "Search files", which repeats the file search over the whole home folder, hidden folders included and `.git` excluded.
- **Colour picker.** A loupe over the frozen screen (`LoupeWindow.qml` per screen, `LoupeState.qml`, the piece `ColorLoupe.qml`, and `PixelReader.qml`, which reads the pixels of any item) and a result page (`ColorPage.qml`; `Colors.js` holds the formats, the colour name and the history).
- **Actions menu** (Ctrl+K, `ActionsHeader.qml` and `Actions.js`): a subpage with the actions of the selected item, such as open, open on a workspace, copy the path, run, copy the result.
- **Emoji picker** (`EmojiPage.qml`, `Emoji.js`). The inventory `emoji/emoji.json` is generated by `emoji/build.py` from Unicode 17 and CLDR 48, with search in English and in Portuguese, and is drawn with Noto Color Emoji.

### Clipboard history (`clipboard/`)

Card [18](../docs/design/pecas/18-clipboard.md).

- The page `ClipboardPage.qml` lives inside the launcher: a "Search history" field, the list with "Pinned" and "Today" (or "N results"), a preview of text, image or link with its metadata, and the empty state. Enter puts the item back on the clipboard and closes, Ctrl+P pins, Del deletes, and Ctrl+K opens the actions menu with Copy, Pin, Delete and "Clear history". The pure logic is in `Clipboard.js`.
- `State.qml` is the service. It listens with two `wl-paste --watch` processes (text and `image/png`) that call `watch.py` once per change. It only starts when the real `shell.qml` calls `start()`; the specimens never get a process.
- It keeps up to 50 unpinned items for the session only. Nothing goes to disk: images stay in `$XDG_RUNTIME_DIR/wintermute-shell/clipboard/`, which is memory and disappears at logout.
- It does not keep what a password manager marks as sensitive.
- Memory caps: text up to 1 MB, a PNG up to 16 MB, images adding up to 64 MB.
- It needs `wl-clipboard` and a compositor with the data-control protocol, such as Niri. Under GNOME the history stays empty, with one warning line in the log.

### Screen capture (`screenshot/`)

Card [17](../docs/design/pecas/17-screenshot.md) and [decision 0017](../docs/decisoes/0017-a-captura-recorta-o-quadro-congelado.md).

- **The overlay.** One window per screen (`CaptureWindow.qml`) holds a frozen frame of the monitor. The piece `Capture.qml` draws the veil, the crosshair with coordinates, the hint, the mode bar (`CaptureModeBar.qml`) and the area selection (`CaptureSelection.qml`, the size pill and `CaptureActions.qml`). The Window and Screen modes draw the ring and the pill in `CaptureTarget.qml`. `CaptureState.qml` always opens from scratch, with no selection.
- **Capturing crops the frozen frame** instead of calling Niri's screenshot. The window takes two frames per monitor (without and with the cursor), `FrameCropper.qml` crops what is showing and writes a PNG to `$XDG_RUNTIME_DIR/wintermute-shell/`, and the state copies the file and hands it to the preview. The arithmetic is in pure libraries: `Selection.js`, `Windows.js`, `Crop.js`.
- **The preview in the sidebar** (`Preview.qml`, `PreviewButton.qml`): a 156×112 thumbnail, or 48×48 with the sidebar collapsed, with a veil and buttons on hover. It disappears by itself after 6 seconds and stays while the pointer is over it. Copying goes through `clipboard.py`. Dragging it into another application needs the [drag plugin](#the-drag-plugin-optional-c): `NativeDrag.qml` imports the module, and `Preview.qml` loads it through a `Loader`, so the preview also opens without the plugin.
- **The annotation editor** (`AnnotateWindow.qml` and the 720×480 piece `Annotate.qml`): tools, five colours, undo, "Copy" and "Save". Marks are stored in image pixels (`Annotate.js`, `AnnotateDocument.qml`), drawn by `AnnotateMark.qml` inside a scene the size of the image (`AnnotateScene.qml`), and exported with `FrameCropper.qml` from that same scene. It opens from the capture (the pencil button in the selection's pill) and from the preview.
- **Saving** exists in three places: the selection's action pill, the preview, and the editor's "Save". It writes a PNG to `~/Pictures/Screenshots` with Niri's file name pattern, never overwrites, and shows the "Screenshot saved" toast (`SavedToast.qml`, in `SavedToastWindow.qml`, at the bottom next to the sidebar).

## Fonts and icons

- **Geist** is the interface font, **Geist Mono** the monospaced one, and **Geist Serif** is used for titles. They are not in the repository and have to be installed on the system. If Geist is missing, `Theme.qml` falls back to Inter.
- **Noto Color Emoji** draws the emoji picker. Without it the text falls back to the system font.
- **Icons** are Lucide: 113 SVG files in `icons/`, the 111 of the Armitage set plus `cable` and `log-out`, which I brought from Lucide later. They are drawn in white (`#FFFFFF`) and a piece never uses the file's colour: it colourises the icon with a token.

## Known issues

- **Quickshell can crash with the capture overlay or the colour-picker loupe.** On a two-monitor setup, using either of them with a real pointer brought Quickshell down with a segmentation fault inside Qt Wayland (`QWaylandWindow::handleScreensChanged`). There were six crashes during the live QA on 2026-11-20, five with that stack and one in another Wayland event handler of the same Qt library. The pattern I saw is a full-screen window holding a frozen frame that goes away after a click on it. Opening and closing the overlay over IPC on purpose, ten times, never reproduced it. I tried one workaround, hiding those two windows 150 ms after they close instead of at once; it looked good for a few captures and then the crashes came back. The delay is still in the code (`screenshot/CaptureWindow.qml`, `launcher/LoupeWindow.qml`). Quickshell normally restarts by itself after the crash; once it did not, and the shell stayed down until I started it again. The cause is still open.
- **Capture's Window mode cannot highlight tiled windows.** The position comes from the `layout` Niri reports for each window, and the Niri IPC returned no `tile_pos_in_workspace_view` for tiled windows (`niri msg --json windows`). Without it, `screenshot/Windows.js` has nowhere to draw the ring. I found this in the IPC output and paused the project before confirming it with the overlay open.
- **Lock and Sleep do nothing yet.** The session buttons, the launcher commands and the idle timeouts for lock and sleep call `settings/session.py`, which looks for a lock screen that does not exist and refuses to suspend without one. The lock screen was planned for a later phase. Super+L is generated commented out for the same reason.
- **A warning at startup.** `qt.svg.draw: The requested buffer size is too big, ignoring` appears four times every time the shell starts. Nothing seems to be missing on screen, and I have not identified which piece asks for an oversized SVG.
- **Names from the code's origin.** Several layer-shell namespaces (`pond-wallpaper`, `pond-volume`, `pond-calendar-…`, `pond-notification-…`, `pond-settings-…` and others), the paths under `~/.config/pond-interface/`, `~/.local/state/pond-interface/` and `~/.cache/pond-interface/`, the lock file `.pond-display.lock` and a few file names still carry the name of the code's origin. Renaming them was planned for the last phase. The Niri layer rules above match these names as they are today.
- **The Niri side is not shipped.** See [What I set by hand](#what-i-set-by-hand).

## Licence

The code starts from a copy of Pond's shell (`LICENSE-origem.txt`, BSD-3-Clause). The code of Wintermute Shell derives from the code of Pond's interface, by Butterfly Interaction, Inc., distributed under BSD-3-Clause, and the original copyright notice and licence accompany the derived code in that file.

Other material in this folder:

- **Lucide** icons, ISC licence: `icons/LICENSE-lucide.txt`.
- **Unicode** emoji data (Emoji 17.0, with CLDR 48 names), Unicode License V3: `launcher/emoji/LICENSE-unicode.txt`.

The licence of the repository as a whole and the full acknowledgements are in the [root README](../README.md).
