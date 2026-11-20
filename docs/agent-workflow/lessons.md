# Lessons

What worked and what did not in the week I ran this project with agents. Everything here comes from the "problems and discoveries" sections of the session reports and from the record of the live QA on 2026-11-20, kept in the F4, F5 and F6 handoffs. The method itself is described in [README.md](README.md) and [obsidian-panel.md](obsidian-panel.md).

The short version: the process kept the project coherent and caught many defects before I ever saw them, and the first session on the real compositor still found problems that no amount of bench runs could have shown.

## What worked

### Continuity held

Thirty-nine recorded sessions in two different tools, seventeen of them blocks of the agent cycle, and every one opened from the panel and closed by updating it. Each report ends with a next step specific enough for the following session to start from, and the registry in the panel shows the chain unbroken from `S00` to `S38`. The session-start hook compares the last commit with the last report, so a session that dies without recording is flagged at the start of the next one.

### Independent QA caught real defects

Of the 52 tasks closed through the agent cycle, the blind verifier (`qa-visual`) rejected 7 at least once, in 8 rejection rounds. None of the rejections was cosmetic nitpicking:

| Task | What the verifier found |
|---|---|
| `F4-T12` | The notification centre jumped by 1 px (226 to 227) when a notification arrived while it was open. The verifier returned the fix already tested. |
| `F4-T24` | A helper script accepted a key with a trailing line break. |
| `F5-T05` | Three defects in the launcher's action menu: the selection was stored by index and pointed at the wrong row when file search results arrived with the menu open. The orchestrator's review had not seen it. |
| `F6-T05` | A two-line hint rendered with a 17 px line where the card asks for 20. |
| `F6-T16` | A PNG truncated after its header was accepted into the clipboard history. |
| `F6-T08` (twice) | A regular expression let a colour value with a trailing line break through; then a symlink loop in the target path. |
| `F6-T09` | Two items missing from the documented list of differences between the specimen and the Figma board. |

The verifier also reported things without rejecting: a fake-portal test helper whose example invocation would have written to my real configuration, clipboard images orphaned when the shell restarted, and the launcher glass rendering much darker on the bench than on the board.

One practice I did not plan and would repeat: for the test suite, the verifier broke the libraries on purpose, one small defect at a time. It introduced 124 defects and the tests caught 108, which is how four gaps in the tests were found and closed.

### Pending questions instead of guesses

Ninety questions in a week sounds like friction. In practice a question arrived with the sources and the options already written out, so many answers were a choice between A and B, and several stopped a wrong build. The clearest case is `P-88`: numbers I had given in an earlier answer did not reproduce my own Figma board, and the agent stopped and asked instead of choosing either. The cycle kept working on unblocked tasks in the meantime, so a question cost me a short session, not a stalled day.

The questions also surfaced contradictions inside my own design: a board whose example HSL value was arithmetically wrong, two boards that placed the same bar at different distances from the edge, a board that drew the focus ring inside the window where the compositor draws it outside.

### The script as gate

The session registry shows the cycle stopping four times because every open task waited for an answer from me, twice because I paused it, and finally at the live QA gate with a clean tree. Every `go` in the panel carries a date and my words. Having the stop condition in a script that reads recorded state, instead of in the model's judgement, removed a whole class of "it says it finished" doubts.

### Fences added after incidents

The rules that held best were the ones backed by a mechanism, and most of the mechanisms were written the day after something went wrong:

| Incident | What changed |
|---|---|
| A `rm -rf` in an implementer's test script deleted a tracked wallpaper image (restored from git) | A hook on all three subagents that refuses deletion outside the repository or a temp folder, and refuses any path it cannot resolve |
| An implementer's test crashed a test instance of Quickshell and opened an error window on my screen | A rule in both subagent definitions on how to write test QML so it cannot bring the test process down |
| Test windows kept taking my monitor and keyboard focus | `tela-de-teste.sh`: a headless compositor just for tests |
| An implementer created test tooling in the repository that nobody asked for | I pulled it from the commit, opened a question, and it later became the versioned test suite with explicit rules |

## What did not work

### The bench approved everything, and the first live session still broke

By the time I opened the Niri session, every piece of F4, F5 and F6 had bench prints in three variations, checked against the cards by an independent verifier. The handoffs said plainly that nothing had been seen live. The live session ran for more than four hours and found this:

| Finding | Cause | Why no bench run could see it | Outcome |
|---|---|---|---|
| The wallpaper showed black | My Niri layout painted a background colour on every workspace, over the backdrop where the shell places the wallpaper | The cause was in my compositor configuration, outside the repository | Fixed in my Niri config during QA. Nothing in the repository delivers that line yet, so a fresh install would get a black screen. Recorded as task `F7-T10` |
| The notification centre flickered | A layer rule in my Niri config had `blur true`, which forces blur on the whole surface whenever the piece leaves its blur region empty, at the start of opening and during closing | The bench has no compositor blur at all | Removed from my rule; the flicker was gone and the glass looked the same. Same task `F7-T10` |
| The capture UI did not appear: the screen froze and nothing was drawn | A z-order mistake. The piece sat underneath its own frozen frame | The specimen draws the piece over a fictitious image, without the real capture window | One-line fix (`z: 2`), applied during QA |
| Capture's window mode cannot highlight tiled windows | The Niri IPC returned an empty position for a tiled window | The computation had only ever run with fictitious windows | Found before the script reached that step; the step itself was never run |
| Quickshell crashed six times | Segmentation fault inside Qt's Wayland client (five of the six in `QWaylandWindow::handleScreensChanged`), each time while the capture overlay or the colour-picker magnifier was in use | Every crash came with a real pointer in use, on two monitors. Closing the same window through IPC ten times crashed nothing | One attempted fix (hiding the window 150 ms after closing). It appeared to hold for two colours and two captures, then the shell crashed twice more. After the sixth crash the automatic restart failed too. Cause not closed |

F4 and F5 got Go. F5's Go came while the fix seemed to hold; the colour picker uses the same overlay window and is still under suspicion. F6 was left without a verdict: 14 of its 46 script steps have a live record. I paused the project there ([decision 0018](../decisoes/0018-pausa-e-apresentacao-em-ingles.md)); the capture crash is the first thing to pick up if it resumes.

None of these was a surprise in kind. The reports had already named the risks: the frame capture "never ran" and was called the most uncertain point of F5; the window positions were "only confirmed in the documentation"; two of the four pass criteria of F6 had no check at all outside Niri. Writing a risk down is not the same as retiring it.

### Batching the live QA moved the cost to the end

Adjustment A-03 let F5 and F6 start while F4 waited for my verdict, and it is what allowed the cycle to run for days. Its own "impact" paragraph predicted the downside: a problem that only appears live would be found after later phases were built. That is what happened. The z-order mistake was one line, and it stayed unnoticed until the live session because nothing in F6 had ever been opened on the compositor. The full-screen overlay that crashes was first written for the F5 magnifier and then used as the model for the F6 capture window.

The batch also made the live session too long to do well. The combined script had 116 steps. At one point I answered "passed" for eleven steps at once, and the agent noted from the log that the capture had not been opened between its question and my answer. The record is honest about it, but a verdict gathered that way is weaker than one step at a time.

### What the bench cannot see

Known and documented, but worth listing in one place:

- No compositor blur. Glass renders darker than on the Figma board (the launcher footer measured 19 against 48 on average), so the glass of the F4 to F6 pieces could only be judged live.
- It does not click. Hover states and open dropdowns needed ad hoc specimens. A real pointer resting over the bench window changed a print once.
- The headless test screen has no screen-capture, layer-shell or clipboard protocols and injects no keyboard or pointer input. Keys and drags were tested by calling the handlers directly.
- Two runs of the same state differ by up to 2 in 255 on a few hundred text pixels, so "pixel identical" only holds within that noise.
- The full component showcase does not open on the bench; verifiers loaded it in a modified copy.

### Subagents drifted from the briefing

Besides the incidents above: an implementer called a private function although the briefing said to stop in that case; another ran `git stash` and `git stash pop` by mistake in the middle of a task; another went to Figma by itself for positions the briefing had not passed (they matched what the verifier measured). The private call was replaced in the orchestrator's review of the diff, which is the argument for keeping that review even with a separate verifier.

The orchestrator made mistakes too. One briefing ordered a change that contradicted an answer I had already given, and it was the review of the resulting diff that caught it. A verifier hit its 80-turn limit before delivering a verdict on a task that touched every piece of the shell; such tasks need the verification split in two.

### Facts recorded without saying how they were checked

A statement written into the panel is trusted by every later session. Twice a recorded fact was wrong: one note said `node` did not run on the machine (it did), and one said the installed Niri reports the position of every window through IPC (true in the documentation, empty for tiled windows in practice). The later reports got better at this, with lines such as "this came from the documentation, not from a test". I would make that a rule from the first day.

Summaries lose detail in the same way. One question had an eight-point proposal that the panel kept only as a summary, and to act on my approval the agent had to go back to the transcript of the session that wrote it.

### The entry note outgrew its purpose

`PAINEL.md` is injected into every session and its own header says it must stay short. By the end it was 27.5 KB, most of it a session registry with one long paragraph per session. The information is useful, but it belongs in the session reports, with a one-line index in the entry note.

### It was not cheap

Each task cost one implementer round and one verifier round of five to ten minutes each, plus the orchestrator's planning and review. The orchestrator runs on the largest model, and that weighs on my account's usage limit; the pause switch and the session limits exist for that reason. The first permission mode I tried made every terminal command from three agents an approval prompt, and I had to switch modes on the first day of the cycle.

## Process rules I would keep

- **Write the QA criteria identical to the briefing.** The one time a task hit the two-rejection stop, the second rejection came from a criterion the orchestrator added in round two that the implementer had never been given. After that the "done when" list of the briefing became the verifier's list, and the two blocks that followed had a single rejection between them, over documentation.
- **Stop after two rejections.** It turned a possible loop between two agents into a question for me, with the findings attached. I answered it the same day and the task closed in the following block.
- **Never invent, always ask, and keep working on something else.** The combination is what makes the first two bearable.
- **The verifier does not see the implementer's report**, and cannot edit.
- **One writer for shared state.** The panel has no version control, so this rule is its only lock.
- **Expected values come from the specification, not from the code under test**, and a known failure stays visible as a skip instead of being adjusted to pass.

## What I would change

- **A live smoke test per phase for anything that needs the compositor.** Keep the batch for visual approval, but open each new layer window, capture path and IPC call on Niri once before the next phase builds on it. That is where the z-order mistake and the overlay crash would have shown up, before more work was built on top.
- **Let the shell deliver what it needs from the compositor.** Two of the five findings were lines in my own Niri configuration. A shell that depends on a compositor setting should write or check that setting itself.
- **Record how each fact was verified**: test, documentation or reading the code.
- **Keep the entry note to an index** and move the narrative to the reports.
- **Shorter live scripts, one step at a time**, with the verdict asked while the evidence is fresh.
