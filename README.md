# Pause On Load — an X4: Foundations extension

Pauses the game a few seconds after a savegame finishes loading, so you arrive
in a stopped world instead of one that is already moving. It does that by
opening the Options menu. Press **ESC** to resume.

That is the whole mod. Four files, no dependencies, no UI, no settings.

## Why the delay is not arbitrary

Pausing the *instant* the world comes up leaves the map's **per-sector resource
display empty for the rest of the session** — the overlay is not built while the
game is paused, and on an established save it never recovers. Measured 2026-09-20
with this extension as the only mod enabled.

So the pause is deferred three seconds past `md.Setup.Start`. Pausing by hand any
time later never reproduces the fault, because by then the data exists.

If you ever see the mining overlay missing after a load, that is the symptom, and
a longer delay is the fix.

## Why the cue is instantiating

An MD cue without `instantiate="true"` fires **once per game**, not once per
load: it completes, and the completed state is saved with the game. Version 101
did exactly that. It paused on the first load and never again on any save
written after it. Fixed in 102, which also renames the cue so the stale
`complete` state already in those saves has nothing to attach to.

## How it works

| File | Role |
| --- | --- |
| `md/mk_pause_on_load.xml` | instantiating cue on `md.Setup.Start`, `<delay exact="3s"/>`, raises a Lua event |
| `ui/mk_pause_on_load.lua` | handles the event, opens the Options menu |
| `ui.xml` | declares the addon — no dependencies |
| `content.xml` | the manifest |

**Why a menu and not a bare `Pause()`.** `Pause()` and `Unpause()` are the *menu*
pause. Every base-game caller pairs them: a menu pauses in `onShowMenu` and unpauses
in `cleanup`. The pause key (**P**) toggles a separate player pause and cannot lift
a menu pause. Earlier builds called `Pause()` alone: **P** did nothing visible, and only
**ESC ESC** freed the game, because opening and closing Options ran its `Unpause()`.
Opening the Options menu gives the pause an owner, and ESC is its sanctioned exit.
101 already had the flaw. It went unnoticed because 101 only ever paused once (see above).

## Install

The repository root *is* the extension, so there is nothing to extract:

```sh
X4="$HOME/.local/share/Steam/steamapps/common/X4 Foundations"
git clone https://github.com/mkoester/x4-mod-pause-on-load.git "$X4/extensions/mk_pause_on_load"   # target name matters on Linux
git -C "$X4/extensions/mk_pause_on_load" pull             # update
```

On Linux the folder name **must** be lowercase — a mixed-case extension directory
is skipped in silence, with no error anywhere.

## Licence

[MIT](LICENSE) — Copyright (c) 2026 Mirko Köster.

## Credit

The approach is taken from **kuertee's [Autocamera-Autopilot-Autopause]**, whose
pause-on-load option is the feature this replaces: the `md.Setup.Start` trigger
and the idea of staging post-load work behind a short delay are both from reading
that mod. No code is shared, but since 102 the method is the same: open the
Options menu, because a bare `Pause()` has no exit the player can reach.

Written because only that one feature was wanted, without the rest of the mod or
its `kuertee_ui_extensions` dependency.

[Autocamera-Autopilot-Autopause]: https://steamcommunity.com/sharedfiles/filedetails/?id=3627877774
