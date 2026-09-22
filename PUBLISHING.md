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

**`WorkshopTool` is a Windows executable, and it runs fine under Proton** (measured
2026-09-21, tool v1.15, publishing this mod). Launching X Tools from Steam drops you
in a `cmd` shell at the Steam library root; Wine maps `Z:` to `/`, so Linux paths go
in as `Z:\home\...`. No Windows machine needed.

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
  **The tool also deletes them again on cleanup** unless `-keepcatfiles` is given, so
  after a publish the staging folder holds only the sources. Nothing is lost:
  `XRCatTool` packs files **verbatim** — no compression, no XML stripping — so `.dat`
  is the payloads concatenated in index order, and `.cat` is a text index of
  `path size mtime md5`. Verified 2026-09-21: all four entries matched the committed
  files on both size and MD5. Only the `mtime` column is not derivable from the repo
  (it is the staging copy's mtime), so a rebuild is byte-identical apart from that.

  That gives a cheap pre-upload check — build with `-keepcatfiles` and compare the
  index against the repo before answering `y`, which proves the packed bytes are the
  committed bytes:

  ```sh
  while read -r f size ts md5; do          # NB: not `path` — zsh ties it to $PATH
    [ "$md5" = "$(md5sum "$f" | cut -d' ' -f1)" ] && echo "ok   $f" || echo "DIFF $f"
  done < ext_01.cat
  ```

⚠ **Do not publish from the working tree — use a clean staging copy.** `-buildcat`
packs *everything* under `-path`, and the tool uploads any loose `.txt`/`.pdf`/`.cur`/
`.mkv` beside the catalog. From this repo that would ship `README.md`, `PUBLISHING.md`,
`workshop-description.txt` and **`.git/`** to every subscriber. The catalog tool's own
filters drop root-level `.xml`/`.jpg`/`.png` and a few extensions, but nothing else —
they are not a safety net. Stage only what the game loads, plus `LICENSE`:

```sh
STAGE=../.publish/mk_pause_on_load        # gitignored in the workspace
rm -rf "$STAGE" && mkdir -p "$STAGE"
cp -r content.xml ui.xml md ui LICENSE "$STAGE"/
```

Then check `ext_01.cat` — it is a plain-text index, one line per packed file — before
answering `y` at the upload prompt.

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
Workshop id (`ws_<number>`), and adds `sync` and `lastupdate`. That is how later
updates find the item, so the change must be kept.

⚠ **It rewrites the file at `-path`, which is the staging copy** — not this repo. The
2026-09-21 publish only landed the id here because it ran from the extensions symlink,
straight into the git tree; published the documented way, from `../.publish/`, the
rewritten file is over there and this repo never sees it. Copy it back first:

```sh
cp ../.publish/mk_pause_on_load/content.xml content.xml
git diff content.xml                                    # id= should now read ws_<number>
git add content.xml && git commit -m "chore: record the Workshop id"
```

Anything keying on the old `id` breaks at that moment — see the note in the
x4-notes vault about re-pointing x4prof profiles.

## What happens after a successful publish

- **The item is created hidden.** Visibility is set on its web page, so a first publish
  is safe to run and review. `WorkshopTool showpage` opens it.
- **Subscribers read the name and description from Steam, not from `content.xml`**,
  unless a localisation entry for their language is supplied there. So the BBCode in
  `workshop-description.txt` is pasted into the page by hand; `-namedesc up` pushes
  `content.xml`'s text on a later `update`.
- **The listing shows the Steam account name as the author**, not `content.xml`'s
  `author` attribute — ours reads *MirkoMachine* there. Nothing in `content.xml`
  changes that, so do not go hunting when the name on the page is not the one in
  the file.
- This mod is **`ws_3805880311`**, published 2026-09-21:
  [Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3805880311).

## ⚠ A subscribed copy collides with a dev symlink

**Subscribers get the `-foldername`, not the id** — measured 2026-09-21 against the
installed mods (`sn_mod_support_apis` holds `id="ws_2042901274"`; only a *failed*
download is left named `ws_<id>`). So this mod lands in every subscriber's
`extensions/mk_pause_on_load/` — the same path a development symlink uses, and both
carry the same `id`, which is what the user `content.xml` keys enabled/disabled on.
One machine cannot hold both.

Worse, **a Workshop sync then points at the git tree**: `x4launch --sync` with that
symlink in place has X4 write the downloaded copy through it. Untested, and not worth
testing on the repo.

So on a machine that develops this mod, **do not subscribe**. To check what a
subscriber actually receives, do it deliberately: remove the symlink, subscribe, sync,
test, unsubscribe, restore the symlink. To run both at once, the dev copy needs its own
folder name *and* its own `id` (and its MD cue and Lua event names are shared, so two
enabled copies pause twice).

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
