# Launcher

[Back to the index](README.md)

The launcher is a piece I designed from scratch: one 640 px glass window that searches apps, files, settings and session commands, does arithmetic, and hosts three tools as sub-pages (colour picker, emoji picker and clipboard history). **Super+E** opens it on the focused monitor; Esc or a click outside closes it.

The launcher, the colour picker and the emoji picker are phase F5, which passed my live QA on Niri. The clipboard history is phase F6 and was not validated live.

## Empty state and tools

| Opened by the shortcut | Opened by the "+" of a workspace |
|---|---|
| ![Empty launcher with three recent apps and four tool chips: Color picker, Emoji, Screenshot, Clipboard](assets/launcher-empty-chiba.png) | ![The same empty launcher with an On workspace 3 tag in the search header](assets/launcher-on-workspace-chiba.png) |

With an empty search, the launcher shows the last apps I opened through it and four tool chips. Down goes from the list into the chips, Left and Right move between them, Enter opens the tool.

When it is opened by the "+" of a row in the [workspace organizer](sidebar.md#workspace-organizer), a tag in the header says which workspace it is, and the app I pick is born there.

**Status:** passed live QA on Niri (F5).

## Search and grouped results

![Launcher with the letters ter typed, a ghost completion to terminal, and a Best match section with an app, a setting and a file](assets/launcher-typing-chiba.png)

Results update on every key. Matching ignores case and accents and looks for a continuous piece of text, with no fuzzy search; a prefix of the title ranks first. When the text is the start of the first result's title, the rest appears as a ghost suggestion and **Tab** accepts it. With up to three results, they come in a single "Best match" section.

| Chiba | Freeside | Sprawl |
|---|---|---|
| ![Launcher with grouped results for the search no: Apps, Files, Settings and Commands, Chiba](assets/launcher-grouped-chiba.png) | ![Launcher with grouped results, Freeside](assets/launcher-grouped-freeside.png) | ![Launcher with grouped results, Sprawl](assets/launcher-grouped-sprawl.png) |

With four or more results they are grouped in a fixed order, Apps, Files, Settings, Commands, with up to five rows each. Up and Down move the selection, Enter opens. The sources are:

- **Apps:** the desktop entries that show up in menus.
- **Files:** a search by name with `fd` in the standard user folders, from two characters on. Without `fd` installed the group does not appear.
- **Settings:** the settings pages, opened directly.
- **Commands:** Lock screen, Sleep, Restart, Power off and Log out. Restart, Power off and Log out have a danger-coloured icon and ask for a second Enter to confirm.

The rows in these pictures are bench demo data, not the real lists.

**Status:** passed live QA on Niri (F5). "Lock screen" and "Sleep" had no effect in live QA, because the lock screen was never built.

## Calculator

![Launcher in calculator mode: the expression 128 × 3.5 + 12 on the left, the result 460 on the right, and two rows to copy the result or its hexadecimal form](assets/launcher-calculator-chiba.png)

When the whole text is an expression with at least one operation, the launcher becomes a calculator. It accepts `+`, `-`, `*`, `/` and parentheses, with comma or point as the decimal separator, and the expression is parsed by my own code, never evaluated as code. **Enter** copies the result and closes; a second row offers the hexadecimal form when the result is a non-negative integer.

**Status:** passed live QA on Niri (F5).

## Actions menu

![Actions sub-page for the app Notes: Open, Open on workspace, Remove from recent](assets/launcher-actions-chiba.png)

**Ctrl+K** opens the actions of the selected row as a sub-page: for an app, open, open on a chosen workspace, or remove from the recent list; for a file, open, show in folder or copy the path; for a calculation, copy the result or its hexadecimal form. Esc or Backspace go back one step.

**Status:** passed live QA on Niri (F5).

## No result

![Launcher with nothing found for xyzzy, offering Search the web and Search files](assets/launcher-no-result-chiba.png)

When nothing matches, the launcher offers two actions. "Search the web" opens the default browser with the search. "Search files" repeats the file search inside the launcher across the whole home folder, including hidden folders, and shows the results in a single Files section.

**Status:** passed live QA on Niri (F5).

## Colour picker

| Result page | Loupe |
|---|---|
| ![Colour picker result: a swatch named Deep sky blue, HEX, RGB and HSL rows with the HEX row marked Copied, and a history of twelve swatches](assets/color-picker-result-chiba.png) | ![Loupe over a sample scene: a circle magnifying 7 by 7 pixels with the centre pixel marked, the hex value below and a hint pill](assets/color-picker-loupe-chiba.png) |

Picking a colour freezes the screen and replaces the pointer with a loupe that magnifies the 7 × 7 pixels around it, with the value under the centre pixel shown below. A click picks the colour, the arrow keys move one pixel at a time, Esc cancels.

The result page names the colour after the nearest CSS named colour and shows it in HEX, RGB and HSL, each with a copy button; **Enter** copies the HEX and **P** picks another colour. The history keeps the last twelve colours.

**Status:** passed live QA on Niri (F5), with an open defect. During that QA, picking a colour crashed Quickshell twice. I changed the loupe window to disappear a moment after closing and the crash did not repeat in a sample of two colours, but the same change did not stop the screen capture, which uses the same kind of window, from crashing later that day. I did not find the cause, which is inside Qt, so the loupe can still crash with a real pointer on two monitors. The loupe was not seen on a monitor with a scale other than 1. The loupe picture is a bench scene, since the bench cannot capture the screen.

## Emoji picker

| Grid | Search |
|---|---|
| ![Emoji picker with category tabs, a Recent row and the Smileys and emotion grid](assets/emoji-grid-chiba.png) | ![Emoji picker searching for gato, the Portuguese word for cat, with twelve cat results](assets/emoji-search-chiba.png) |

A grid of 1,914 emoji from Unicode 17, in colour, with six category tabs and a row of the last eleven I copied. The arrow keys move through the grid, Tab jumps to the next category, and **Enter** copies the selected emoji and closes. Search works in English and in Portuguese, ignores case and accents, and matches at the start of words. Skin tones are not in this version.

**Status:** passed live QA on Niri (F5).

## Clipboard history

| Text | Image |
|---|---|
| ![Clipboard history with five items of different kinds on the left and a text preview with source, time and size on the right](assets/clipboard-text-chiba.png) | ![Clipboard history with an image item selected and its preview, source and size](assets/clipboard-image-chiba.png) |

![Clipboard history with a Pinned section above Today and the footer showing Unpin](assets/clipboard-pinned-chiba.png)

**Super+V** opens the launcher directly on this page; the "Clipboard" chip opens it too. The left column lists what I copied, classified as command, image, link, e-mail, colour or text; the right side previews the selected item with its source app, time and size. **Enter** puts the item back on the clipboard and closes, so I paste with Ctrl+V. **Ctrl+P** pins or unpins, **Del** deletes, and **Ctrl+K** opens the actions menu, which also has "Clear history". Typing filters by text, link, colour and source app.

The history lives only in the session: up to 50 unpinned items, nothing written to disk, and whatever a password manager marks as sensitive is not stored. Only PNG images are kept. The source app is the window that had focus when the item arrived, so it can be wrong.

**Status:** not validated live (F6). The page and the service were tested on the bench and with fabricated input only. Listening to a real clipboard, pasting back, the password-manager hint and copy and paste between Wayland and XWayland apps were never run on Niri.
