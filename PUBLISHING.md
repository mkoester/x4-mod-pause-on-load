# Publishing this extension to the Steam Workshop

Egosoft's `WorkshopTool` does the upload. The game itself cannot publish — it only
consumes the Workshop (Browse / View in Workshop), with no upload path anywhere in
its UI.

## Prerequisites

- **Own X4: Foundations on Steam.** Publishing an extension for a game you do not
  own fails.
- **Steam running and logged in** while the tool runs.
- **Accept the Steam Workshop Legal Agreement** once, on the Steam website.
- **Install "X Tools"** — Steam app `282160`. It appears in your Steam library under
  *Tools* because you own X4; also downloadable from egosoft.com. Launching it opens
  a command prompt in the folder holding `WorkshopTool.exe`.

⚠ **`WorkshopTool` is a Windows executable.** Whether it runs under Proton or Wine is
unverified — if it does not, this step needs a Windows machine with X4 installed.

Run `WorkshopTool` with no arguments to list every command and switch; the online
guides are older than the tool.

## First publish

From the X Tools command prompt, with paths pointing at wherever X4 is installed:

```
WorkshopTool publishx4 ^
  -path    "C:\...\X4 Foundations\extensions\mk_pause_on_load" ^
  -preview "C:\...\X4 Foundations\extensions\mk_pause_on_load\preview.jpg" ^
  -buildcat
```

- `-path` — the extension folder. The tool takes the **folder name** as the mod name
  and reads its `content.xml`.
- `-preview` — JPG or PNG, 640x360 or larger, widescreen. `preview.jpg` in this repo
  is 1920x1080.
- `-buildcat` — packs the loose files into `ext_01.cat` / `ext_01.dat` for you. Those
  are build output and are gitignored here; the loose files remain the source.

## Updating a published item

```
WorkshopTool update ^
  -path "C:\...\X4 Foundations\extensions\mk_pause_on_load" ^
  -buildcat -changenote "what changed in this version"
```

`-changenote` is required. Bump `version` in `content.xml` first — the value is
**x100**, so `101` displays as v1.01.

## ⚠ Publishing rewrites `content.xml`

On a successful first publish the tool **replaces the `id` attribute** with the
Workshop id (`ws_<number>`). That is how later updates find the item, so the change
must be kept:

```sh
git add content.xml && git commit -m "chore: record the Workshop id"
```

Anything keying on the old `id` breaks at that moment — see the note in the
x4-notes vault about re-pointing x4prof profiles.

## Rules Egosoft states

Do not publish extensions you did not make without the author's consent, do not
publish modified versions of other people's extensions without consent, and do not
publish the same extension twice.

## Folder name constraints

`a-z`, `0-9`, period, underscore, hyphen and space only; 32 characters maximum;
lowercased automatically. `mk_pause_on_load` satisfies all of these, and must stay
lowercase regardless — on Linux a mixed-case extension folder is skipped in silence.

## Sources

- [Steam Workshop for X Rebirth and X4](https://wiki.egosoft.com/X%20Rebirth%20Wiki/Modding%20support/Steam%20Workshop%20for%20X%20Rebirth%20and%20X4/) — Egosoft wiki
- [The same guide on Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=245117855)
- [X Tools Packages, app 282160](https://steamdb.info/app/282160/)
