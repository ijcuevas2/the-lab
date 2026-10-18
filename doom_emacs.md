# Restore my Doom Emacs setup on a fresh Ubuntu install

> **Note for me (the human), before wiping the disk:**
> 1. Commit and push this file (`~/repos/the-lab/doom_emacs.md`). It holds the
>    complete config, so after the reinstall it's the only thing you need.
> 2. Optional: to keep open workspaces, recent files, minibuffer history and
>    persistent undo history, copy this tarball somewhere off the machine:
>    `tar czf doom-state.tgz -C ~/.config/emacs/.local etc/workspaces cache/recentf cache/savehist cache/undo-fu-session`
> 3. After the reinstall, clone the-lab and start the agent with:
>    *"Follow the instructions in ~/repos/the-lab/doom_emacs.md exactly."*
>
> Everything below the line is the prompt for the agent.

---

## Your task

You are an agentic CLI running on my freshly installed Ubuntu machine. Restore
my **Doom Emacs** setup so it's **functionally identical** to the one I had
before the reinstall. That means the same Emacs, the same Doom version, the same
private config (byte-for-byte), the same snippets, the same native helper
binaries (vterm module, pdf-tools' `epdfinfo`), and the same external tools
(ripgrep, fd, LaTeX/latexmk, and so on). Then **prove** it works with the
verification steps at the end.

This file is the single source of truth. All of my private Doom config is
embedded below, with a SHA-256 checksum for each file. Don't fetch my config
from anywhere else, and don't use Doom's generated templates in place of it.

### Snapshot this was captured from (2026-10-18)

| Item | Value |
|---|---|
| OS | Ubuntu 26.10 (Stonking Stingray), x86_64 |
| Shell | bash (`$SHELL=/bin/bash`) |
| Emacs | GNU Emacs **30.2** from apt (`emacs` → `emacs-gtk` 1:30.2+1-11ubuntu1, plus `emacs-el`) |
| Doom Emacs | `https://github.com/doomemacs/doomemacs`, commit **`e9ef35c5ba7c2efd7a60778f7254769e281477c9`** (2026-07-10), core version 2.2.0 |
| Doom install dir (`EMACSDIR`) | `~/.config/emacs` |
| Private config dir (`DOOMDIR`) | `~/.config/doom` (contains `init.el`, `config.el`, `packages.el`, `snippets/LaTeX-mode/*`) |
| Doom profiles | only the default profile, no custom profiles |
| Envvar file | **none** (`doom env` was never run) |
| `~/.emacs`, `~/.emacs.d`, `~/.doom.d` | **must not exist** (they would shadow the XDG locations) |
| `org-directory` | `~/org/` (the directory didn't exist at snapshot time) |
| `doom` on `PATH` | **no**. It was always called by full path, `~/.config/emacs/bin/doom` |
| `~/.local/bin` on `PATH` | yes, via `~/.profile` and `~/.bashrc` |
| `~/.local/bin/fd` | symlink → `/usr/bin/fdfind` |
| Nerd/icon fonts | none installed (`fc-list \| grep -i nerd` was empty) |
| `emacs.service` user unit | present from the package but **disabled** (I don't use the daemon) |

### Ground rules

1. **Restore, don't redesign.** Don't edit, reformat, "modernize", uncomment, or
   reorder anything in the embedded files. Don't enable extra Doom modules or
   add packages. Every embedded file must match its SHA-256 exactly.
2. **Extract the files with a script, not by retyping them.** Section 4 includes
   an extractor. Retyping hundreds of lines by hand risks silent corruption.
3. **Ask me before anything destructive or hard to undo:** deleting or
   overwriting an existing `~/.config/emacs`, `~/.config/doom`, `~/.emacs.d`,
   `~/.doom.d` or `~/.emacs`; editing my shell rc files; enabling services. If
   something already exists, move it aside to `*.bak-<timestamp>` (with my OK)
   instead of deleting it.
4. **Only use `sudo` for `apt`.** Don't `sudo` git, doom, emacs, or anything in
   `$HOME`. Every file under `~/.config` must be owned by me.
5. **Pin, don't upgrade.** Never run `doom upgrade`, `doom sync -u`, or
   `git pull` in `~/.config/emacs`. Package versions come from the pinned Doom
   commit.
6. **Report as you go.** After each phase, give one or two lines saying what you
   did and anything unexpected. If a step fails, show the actual error output
   and stop to ask me. Don't guess at workarounds that change my config.
7. Commands below that use `~/.config/emacs/.local/straight/build-*/…` contain a
   glob because the directory is named after the Emacs version (it was
   `build-30.2`). Resolve it with `ls -d` and make sure exactly one match exists.

---

## Phase 1: Survey the fresh system (read-only)

Run these and summarize the results for me before changing anything:

```bash
cat /etc/os-release | head -5
uname -m
echo "$SHELL"; echo "$PATH" | tr ':' '\n'
command -v emacs git rg fd fdfind latexmk cmake python3 || true
emacs --version 2>/dev/null | head -1
ls -ld ~/.emacs ~/.emacs.d ~/.doom.d ~/.config/emacs ~/.config/doom ~/org 2>&1
ls -l ~/.local/bin 2>&1 | head
grep -n '\.local/bin\|config/emacs/bin' ~/.profile ~/.bashrc 2>/dev/null
echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
```

What to look for:
- If `~/.config/doom` already exists (for example, `/home` survived the
  reinstall or I restored a backup), **don't overwrite it.** Instead, compare it
  against the checksums in Section 4. If everything matches, skip writing the
  config. If anything differs, show me the diff and ask.
- If `~/.emacs.d`, `~/.emacs` or `~/.doom.d` exists, tell me. Emacs loads
  `~/.emacs.d` in preference to `~/.config/emacs`, and Doom prefers `~/.doom.d`
  over `~/.config/doom`, so either would silently hijack the setup.
- `python3` is needed for the extractor in Section 4. It ships with Ubuntu; if
  it's missing, install it with `sudo apt install python3`.

## Phase 2: Install system packages (apt)

```bash
sudo apt update
```

Install the following, grouped by the reason each is needed. If a package name
doesn't exist on this Ubuntu release, find the equivalent with
`apt-cache search` / `apt-cache policy`, tell me what you substituted, and keep
going.

**Core: Emacs and Doom's hard requirements**
```bash
sudo apt install -y emacs emacs-el git ripgrep fd-find
```
- `emacs` must resolve to a **GUI build**. It was `emacs-gtk` before. Check with
  `dpkg -l | grep -E '^ii +emacs-(gtk|pgtk|lucid|nox)'`. If apt picked
  `emacs-nox`, stop and ask me. If the release offers both `emacs-gtk` and
  `emacs-pgtk`, use `emacs-gtk` to match the old setup.
- Emacs must be **>= 28.1** (`config.el` uses `auto-save-visited-predicate`,
  which arrived in 28.1). Ideally use 30.x, as before. **Don't use the snap**
  version of Emacs.
- `emacs-el` (the elisp sources) was installed before. It makes `K` / `gd` /
  `SPC h f` jump to the source of built-in functions.

**vterm (`:term vterm`): native module build**
```bash
sudo apt install -y build-essential cmake libtool-bin
```
(`libvterm-dev` is optional. Without it, vterm's build fetches and compiles
libvterm itself, which is what happened before.)

**pdf-tools (`:tools pdf`): `epdfinfo` server build**
```bash
sudo apt install -y libpoppler-glib-dev libpng-dev zlib1g-dev autoconf automake pkg-config
```

**LaTeX (`:lang (latex +latexmk)`), which is my main use case.** My config runs
`latexmk -pvc` continuously on every `.tex` buffer.
```bash
sudo apt install -y texlive-full latexmk
```
`texlive-full` is what I had (it's several GB). **Ask me first** whether to
install all of it or a smaller set. The minimum my snippets and documents need
is `texlive-latex-base texlive-latex-recommended texlive-latex-extra
texlive-science texlive-fonts-recommended texlive-fonts-extra texlive-pictures
latexmk`. The `fig` snippet needs `float.sty` (`[H]`), and the `lst`/`ll`
snippets need `listings.sty`.

**Spelling dictionaries (installed before, even though `:checkers spell` is
off)**
```bash
sudo apt install -y aspell aspell-en hunspell hunspell-en-us
```

**Clipboard integration**
- Wayland session: `sudo apt install -y wl-clipboard` (I had this).
- X11 session: `sudo apt install -y xclip`.

**Optional, so `doom doctor` stops complaining.** Ask before installing these.
- `shellcheck`, for `:lang sh` + `:checkers syntax` linting (I didn't have it before).
- `pandoc`, for `:lang markdown` preview. Mine came from Anaconda, not apt.

## Phase 3: Make `fd` available under its normal name

Ubuntu ships `fd` as `fdfind`. Recreate my symlink:

```bash
mkdir -p ~/.local/bin
ln -sfn /usr/bin/fdfind ~/.local/bin/fd
ls -l ~/.local/bin/fd   # → /usr/bin/fdfind
```

`~/.local/bin` was on my `PATH` through Ubuntu's stock `~/.profile` (which adds
it when the directory exists at login) and an
`export PATH="$HOME/.local/bin:$PATH"` line in `~/.bashrc`. If neither is
present on the new system, **ask me** before editing a shell rc file. Note that
`~/.profile` only picks the directory up on the *next* login, so for the rest of
this session, use full paths or `export PATH="$HOME/.local/bin:$PATH"` in your
own shell.

## Phase 4: Write my private config (`~/.config/doom`)

Do this **before** installing Doom, so `doom install` finds an existing `DOOMDIR`
and doesn't generate template files over it.

### 4a. Extract the embedded files with this script

Every embedded file below is preceded by a marker line of this form:
`<!-- restore-file path="…" sha256="…" final-newline="yes|no" -->`. The marker is
followed by a fenced block that opens with four backticks. The file's content is
every line between the opening and closing fences. `final-newline` says whether
the real file ends with a newline.

**Important:** the 24 snippet files have **no trailing newline**, and that's
intentional. A trailing newline in a yasnippet file becomes a stray blank line
in every expansion; `config.el` even disables `require-final-newline` in
`snippet-mode` for that reason. The three `.el` files each end with exactly one
`\n`.

Save this script **outside** `~/.config` (for example in a fresh temp dir) and run
it, passing this markdown file and the target directory:

```python
#!/usr/bin/env python3
"""Extract embedded Doom config files from doom_emacs.md, verify, and write them.

Usage: python3 -I extract_doom.py <path/to/doom_emacs.md> <target DOOMDIR>
Verifies every SHA-256 before writing anything. Refuses to overwrite a file
whose existing content differs from the embedded one.
"""
import hashlib
import os
import re
import sys

md_path, target = sys.argv[1], os.path.expanduser(sys.argv[2])
lines = open(md_path, encoding="utf-8").read().split("\n")
marker_re = re.compile(
    r'^<!-- restore-file path="([^"]+)" sha256="([0-9a-f]{64})" '
    r'final-newline="(yes|no)" -->$'
)

files, bad = [], []
i = 0
while i < len(lines):
    m = marker_re.match(lines[i])
    if not m:
        i += 1
        continue
    rel, want, final_nl = m.groups()
    if not lines[i + 1].startswith("````"):
        sys.exit(f"malformed block for {rel}: no opening fence")
    j = i + 2
    while lines[j] != "````":
        j += 1
    data = ("\n".join(lines[i + 2:j]) + ("\n" if final_nl == "yes" else "")).encode()
    got = hashlib.sha256(data).hexdigest()
    print(f"{'OK      ' if got == want else 'MISMATCH'} {rel}")
    if got != want:
        bad.append(rel)
    files.append((rel, data))
    i = j + 1

print(f"{len(files)} files found")
if bad or len(files) != 27:
    sys.exit(f"refusing to write: mismatches={bad}, count={len(files)} (expected 27)")

for rel, data in files:
    dest = os.path.join(target, rel)
    if os.path.exists(dest):
        if open(dest, "rb").read() == data:
            continue
        sys.exit(f"refusing to overwrite differing existing file: {dest}")
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(dest, "wb") as f:
        f.write(data)
print(f"wrote config to {target}")
```

```bash
python3 -I /path/to/extract_doom.py ~/repos/the-lab/doom_emacs.md ~/.config/doom
```

If this prompt was pasted to you instead of read from
`~/repos/the-lab/doom_emacs.md`, write it verbatim to a temp file first and run
the extractor on that. If pasting mangled anything, the checksums will catch it.
If any checksum fails, **stop and tell me**. Don't "fix" content to make a
checksum pass.

### 4b. Verify independently

```bash
cd ~/.config/doom && sha256sum -c <<'EOF'
1300602537a32ee6b870f0f50e4bde399a318ae38971c5a7deee0b9fc9044ee9  init.el
a8c9a7ed72f894e8b619a1b5263d04520e195c9a52cb2781e93f2630c7ed5c61  config.el
ce36023ef4c75f5cf4026e016b478e0c583623b3ed22715b0426cb7cf372aea0  packages.el
7eafe1f8771c2c5cff6a3726df92f0cf2f50cf69f0839d80e88e2bec62fff8b4  snippets/LaTeX-mode/align
48ae71f7a1d6cdee29765cfb8a6734bba4274b6d016db3322cd044596478462d  snippets/LaTeX-mode/bf
c6a83a726b258f648d0061615aa9e310f16657791f8f5347e140d6233e20f087  snippets/LaTeX-mode/defbox
18087f67738f22a13e67403be0bb25f5861b22b85ff1da8a4756354168e2c23a  snippets/LaTeX-mode/enumerate
6e66f11adc150f758ad8170b989de5e7c7e58adce1ea49f2d35580b6a5b72d1f  snippets/LaTeX-mode/eq
25ddc09287ccb670a509a0282881599798b59b37b901af66f742e870aa0e3e5a  snippets/LaTeX-mode/fig
48343545480662495339fe647d82b8f46f5ca66a746888fb0cd0c8c6c589b553  snippets/LaTeX-mode/frac
477ec191bdaae3d61d05d4d8dc29308a0cbb10b0bbaaffc27266499718acc44e  snippets/LaTeX-mode/int
b4a13ee5b668c541bab393f91c249295531fa88cc7633f7e26a8029c7b6d5745  snippets/LaTeX-mode/it
1ff14e1edbb0fa534f535ec7f9d348157a7887dcb8c4ca9ef64a33bd1b3d2259  snippets/LaTeX-mode/item
baaca48df3512115b19e4de8084a38c26a0a25dfd3f9a76fc91f79f44ad8c998  snippets/LaTeX-mode/itemize
5dec92725f1e23b2ed2e3689ebffbc23726754dbaccca611efb673ad975f225f  snippets/LaTeX-mode/lim
fac310d3a78d29a2eb2a72063db50e6d62b636483a637cad356bb054e5f46540  snippets/LaTeX-mode/ll
a49242395a33392414807f2431487a24cd0dc06cf7b540ea99a5018063a7c1b4  snippets/LaTeX-mode/lst
fceeeff804beb046dff882a9fcb82610ddfa232c1b642429ed95b95afacabf1c  snippets/LaTeX-mode/sqrt
1783ee80d482eeab2186274611821626eeff1f8fc8cd56979ec3c1c29774fd42  snippets/LaTeX-mode/subsection
2ba668b9a0b2b5e9858f32f247dd78dbd70a0c6e063e94608cb5385ccc4b5c83  snippets/LaTeX-mode/subsubsection
a53ad9304b32c7e92e6e43737ccff5a5233255fd10e3801a063be71ee1517329  snippets/LaTeX-mode/sum
00e687b0f8e247af4ae5944b21b575bdd3d737e5aecde996cf2b75839b0d34e4  snippets/LaTeX-mode/table1
faad5a2cfc2d97ba0bcf862e56c3a5e03d0bb54bb635166ab457b6f5f4653a70  snippets/LaTeX-mode/table2
1e4c444d28bb333bdf98c7e2a00f067a1900edcd7d8660409ae6f8702c45c951  snippets/LaTeX-mode/table3
0c0c0820771937f92073ed091b57aecfc1d50fcdec5caa158e69524ea95edd5a  snippets/LaTeX-mode/table4
b51c779a1b8b197ef3e60c6c0121033bf927855d4e71dd1ae6c202886ac605af  snippets/LaTeX-mode/table5
ac3e571d9a4507bba9d6707cfb48128a9aa2a3411ad0d895fa241dd55bcd7b6a  snippets/LaTeX-mode/table6
EOF
find ~/.config/doom -type f | wc -l     # → 27
for f in ~/.config/doom/snippets/LaTeX-mode/*; do [ "$(tail -c1 "$f" | xxd -p)" = "0a" ] && echo "UNEXPECTED trailing newline: $f"; done
```

### 4c. What the config does (so you can sanity-check behavior later)

`init.el` enables exactly these Doom modules (everything else is commented out,
so leave it that way):
- **:completion** `(corfu +orderless)`, `vertico`
- **:ui** `doom`, `dashboard`, `hl-todo`, `modeline`, `ophints`, `(popup +defaults)`, `(vc-gutter +pretty)`, `vi-tilde-fringe`, `workspaces`
- **:editor** `(evil +everywhere)`, `file-templates`, `fold`, `snippets`, `(whitespace +guess +trim)`
- **:emacs** `dired`, `electric`, `tramp`, `undo`, `vc`
- **:term** `vterm`
- **:checkers** `syntax`
- **:tools** `(eval +overlay)`, `lookup`, `magit`, `pdf`
- **:os** `(:if (featurep :system 'macos) macos)`, which does nothing on Linux
- **:lang** `emacs-lisp`, `(latex +latexmk)`, `markdown`, `org`, `sh`
- **:config** `(default +bindings +smartparens)`

`packages.el` is Doom's stock template with **no** `package!` declarations, so
there are no extra packages.

`config.el` customizations:
- Theme `doom-one`, absolute line numbers (`display-line-numbers-type t`),
  `org-directory` `~/org/`. No custom font (Doom's default font resolution).
- Corfu **doesn't auto-popup** (`corfu-auto nil`). In insert state, `C-n`/`C-p`
  trigger `completion-at-point`. yasnippet-capf candidates ignore the
  prefix-length threshold.
- Insert-state `TAB` and `<tab>` run `+yas-expand-or-insert-spaces`: expand a
  snippet if one matches, otherwise insert two spaces.
- Insert-state `C-e`/`C-y` scroll by one line, like normal state.
- `zt` → `+evil-scroll-line-to-top-with-context` (`recenter 6`).
- evil-snipe is kept off (removed from `doom-first-input-hook`), so `s`/`S` work
  as in vanilla Vim.
- `electric-indent-mode` is off, `evil-auto-indent` is nil, and
  `yas-indent-line` is `nothing`.
- Snippet files: `require-final-newline` is nil.
- LaTeX: `abbrev-mode` with `ii` → `\item ` (only at the start of a line),
  `save-abbrevs` nil; no `$`→`$$` auto-pairing; `auto-save-visited-mode` limited
  to LaTeX buffers with a 2 s interval; `auctex-cont-latexmk-mode` on every
  LaTeX buffer (continuous `latexmk -pvc`).
- PDF viewers auto-revert, and a reverted pdf-tools buffer scrolls to match
  point in its LaTeX source (SyncTeX forward search via
  `+latex-pdf-follow-edit-h`).

## Phase 5: Install Doom Emacs at the pinned commit

```bash
git clone https://github.com/doomemacs/doomemacs ~/.config/emacs
git -C ~/.config/emacs checkout e9ef35c5ba7c2efd7a60778f7254769e281477c9
git -C ~/.config/emacs log -1 --format='%H %ci'
```

(A detached HEAD is expected and fine. Doom pins every package per commit, which
is how the old package versions get reproduced.)

```bash
~/.config/emacs/bin/doom install --no-config --no-env
```

- `--no-config`: my `DOOMDIR` already exists, so don't create templates.
- `--no-env`: I never had an envvar file. Only generate one later (with
  `doom env`) if GUI Emacs launched from the desktop can't find `rg`/`fd`/`latexmk`,
  and tell me if you do.
- First, run `~/.config/emacs/bin/doom install --help` to confirm those flags
  still exist on this commit. (They do on `e9ef35c`.)
- If it prompts about anything else, read the prompt and choose the option that
  doesn't modify `~/.config/doom`. If you're unsure, ask me.
- Cloning roughly 130 packages and native-compiling them takes a while. Run it
  in the foreground with a long timeout, or in the background and wait for it.
  Don't interrupt it.

**Fallback if the pinned commit doesn't work:** if `doom install`/`doom sync`
fails at `e9ef35c` because of an incompatibility with this Emacs version (for
example, a much newer Emacs than 30.2), show me the error. With my OK, check out
the latest `master`
(`git -C ~/.config/emacs checkout master && git -C ~/.config/emacs pull`) and
run `~/.config/emacs/bin/doom sync` again. Don't touch my config to work around
the problem.

Then run:
```bash
~/.config/emacs/bin/doom sync
```

## Phase 6: Build the native helpers

Both were built before and live inside the straight build dir. Build them
headlessly now, so GUI Emacs doesn't prompt on first use.

**vterm module**, which should produce `vterm-module.so` next to `vterm.el`:
```bash
VTERM_DIR=$(ls -d ~/.config/emacs/.local/straight/build-*/vterm)
emacs --batch -L "$VTERM_DIR" \
  --eval '(progn (setq vterm-always-compile-module t) (require (quote vterm)))'
ls -l "$VTERM_DIR"/vterm-module.so
```
If that fails, run the same command vterm uses internally:
`cd "$VTERM_DIR" && mkdir -p build && cd build && cmake -G 'Unix Makefiles' -DUSE_SYSTEM_LIBVTERM=no .. && make`.

**pdf-tools `epdfinfo`**, which should end up at
`~/.config/emacs/.local/straight/build-*/pdf-tools/epdfinfo`:
```bash
PDF_BUILD=$(ls -d ~/.config/emacs/.local/straight/build-*/pdf-tools)
PDF_REPO=~/.config/emacs/.local/straight/repos/pdf-tools
cd "$PDF_REPO/server" && ./autobuild -h      # check the flags first
./autobuild -i "$PDF_BUILD"                  # add the "don't install OS packages" flag if available (deps came from Phase 2)
ls -l "$PDF_BUILD"/epdfinfo
```
If `autobuild` fails, show me the output. As a last resort, I can run
`M-x pdf-tools-install` myself in GUI Emacs.

## Phase 7: Directories and leftovers

```bash
mkdir -p ~/org          # org-directory; harmless if empty
```
- **Don't** enable `emacs.service`. It was disabled before.
- **Don't** add `~/.config/emacs/bin` to `PATH` unless I ask. I always called
  `doom` by full path. (At the end, offer to add it to `~/.bashrc`.)
- **Don't** install nerd-icons fonts unless I ask. I didn't have them. (If I want
  icons later: `M-x nerd-icons-install-fonts`.)
- **Optional state restore:** if I tell you I have the `doom-state.tgz` from the
  note at the top, extract it **while no Emacs is running** with
  `tar xzf doom-state.tgz -C ~/.config/emacs/.local`. Otherwise skip this.
  Don't search my disk for it.

## Phase 8: Verify everything

### 8a. Doom's own health check
```bash
~/.config/emacs/bin/doom doctor
```
Report every **error**. Expected, acceptable warnings: missing nerd-icons fonts;
`shellcheck` or `pandoc` not found (if I declined them); no envvar file. Anything
about `rg`, `fd`, `git`, Emacs version, missing `DOOMDIR` files, or an
out-of-date `doom sync` is a real problem, so fix it or ask me.

### 8b. Load the full config in a throwaway daemon and check every customization

```bash
emacs --daemon=doom-restore-check 2>&1 | tail -20      # must finish without "Error"
ec() { emacsclient -s doom-restore-check --eval "$1"; }
ec 'doom-theme'                                  # → doom-one
ec 'display-line-numbers-type'                   # → t
ec 'org-directory'                               # → "~/org/"
ec 'electric-indent-mode'                        # → nil
ec 'evil-auto-indent'                            # → nil
ec 'save-abbrevs'                                # → nil
ec '(list auto-save-visited-mode auto-save-visited-interval)'   # → (t 2)
ec '(progn (require (quote corfu)) corfu-auto)'                 # → nil
ec '(progn (require (quote yasnippet)) yas-indent-line)'        # → nothing
ec '(lookup-key evil-motion-state-map "zt")'     # → +evil-scroll-line-to-top-with-context
ec '(mapcar (lambda (k) (lookup-key evil-insert-state-map (kbd k))) (list "C-n" "C-p" "TAB" "<tab>" "C-e" "C-y"))'
   # → (completion-at-point completion-at-point +yas-expand-or-insert-spaces +yas-expand-or-insert-spaces evil-scroll-line-down evil-scroll-line-up)
ec '(list (memq (quote evil-snipe-mode) doom-first-input-hook) (memq (quote evil-snipe-override-mode) doom-first-input-hook))'   # → (nil nil)
ec '(and (memq (quote abbrev-mode) LaTeX-mode-hook) (memq (quote auctex-cont-latexmk-mode) LaTeX-mode-hook) t)'               # → t
ec '(abbrev-expansion "ii" LaTeX-mode-abbrev-table)'           # → "\\item "
ec '(progn (require (quote yasnippet)) (seq-some (lambda (d) (file-equal-p d "~/.config/doom/snippets")) (yas-snippet-dirs)))'   # → t
ec '(progn (require (quote vterm)) (featurep (quote vterm-module)))'   # → t
ec '(progn (require (quote pdf-tools)) (pdf-info-check-epdfinfo) "epdfinfo ok")'   # → "epdfinfo ok"
ec '(fboundp (quote +latex-pdf-follow-edit-h))'                # → t
ec '(executable-find "rg")'; ec '(executable-find "fd")'; ec '(executable-find "latexmk")'   # → non-nil paths
```

Snippet tests. Insert-state TAB is what I actually use, but `yas-expand`
exercises the same snippet tables. `delay-mode-hooks` keeps `LaTeX-mode-hook`
from running in the temp buffer, so latexmk doesn't start on a file-less buffer.
(Don't `let`-bind `LaTeX-mode-hook` instead. That errors with "Defining as
dynamic an already lexical var".) These exact forms and outputs were verified on
the old machine:

```bash
# All 24 of my snippet files are loaded (23 distinct keys, since "item" is used by both item and itemize):
ec '(progn (require (quote latex)) (require (quote yasnippet)) (with-temp-buffer (delay-mode-hooks (LaTeX-mode)) (yas-minor-mode 1) (sort (delete-dups (mapcar (lambda (tpl) (yas--template-key tpl)) (seq-filter (lambda (tpl) (string-prefix-p (expand-file-name "~/.config/doom/snippets") (or (yas--template-load-file tpl) ""))) (yas--all-templates (yas--get-snippet-tables))))) (function string<))))'
   # → ("align" "bf" "def" "enum" "eq" "fig" "frac" "int" "it" "item" "lim" "ll" "lst"
   #    "sqrt" "ssub" "sub" "sum" "table1" "table2" "table3" "table4" "table5" "table6")
ec '(progn (require (quote latex)) (require (quote yasnippet)) (with-temp-buffer (delay-mode-hooks (LaTeX-mode)) (yas-minor-mode 1) (insert "bf") (yas-expand) (buffer-string)))'
   # → "\\textbf{}"
ec '(progn (require (quote latex)) (require (quote yasnippet)) (with-temp-buffer (delay-mode-hooks (LaTeX-mode)) (yas-minor-mode 1) (insert "eq") (yas-expand) (buffer-string)))'
   # → "\\begin{equation}\n    \\label{eq:label}\n    a^2 + b^2 = c^2\n\\end{equation}\n"
   #   (4-space indentation preserved: proves yas-indent-line = nothing works, and no stray trailing blank line)
```

### 8c. End-to-end LaTeX loop (continuous latexmk)

```bash
T=$(mktemp -d)
cat > "$T/test.tex" <<'EOF'
\documentclass{article}
\usepackage{float,listings,graphicx,amsmath}
\begin{document}
Hello \lstinline|x = 1|.
\begin{equation} a^2 + b^2 = c^2 \end{equation}
\end{document}
EOF
ec "(progn (find-file \"$T/test.tex\") (list major-mode (bound-and-true-p auctex-cont-latexmk-mode) abbrev-mode))"
   # → (LaTeX-mode t t)
sleep 15; ls -l "$T"/test.pdf "$T"/test.synctex.gz     # both should exist
ec "(with-current-buffer \"test.tex\" (set-buffer-modified-p nil) (kill-buffer))"   # stops latexmk
```

### 8d. Clean up and hand off
```bash
ec '(kill-emacs)'
pgrep -a latexmk || true      # nothing left running
rm -rf "$T"
```

## Phase 9: Final report

Give me a short summary with:
1. The Emacs version and Doom commit actually installed. Point out any deviation
   from the snapshot table (for example, a different Emacs version, or `master`
   used instead of the pinned commit).
2. Confirmation that all 27 config files passed their SHA-256 checks.
3. The apt packages you installed, any you substituted, and any you skipped.
4. The `doom doctor` result (errors and remaining warnings).
5. The pass/fail result of every Phase 8 check.
6. Things only I can check in GUI Emacs. Ask me to launch `emacs` from the
   desktop and confirm: the dashboard and `doom-one` theme appear;
   `SPC o t` / `M-x +vterm/toggle` opens a terminal; opening a `.tex` file and
   running `SPC m v` shows the PDF in pdf-tools, and it scrolls along as I type.
7. Optional follow-ups for me to approve: add `~/.config/emacs/bin` to `PATH`;
   `M-x nerd-icons-install-fonts`; `shellcheck`/`pandoc`.

---

## Section 4 payload: the embedded config files

Don't edit anything below this line. The extractor reads it.

### `init.el`

<!-- restore-file path="init.el" sha256="1300602537a32ee6b870f0f50e4bde399a318ae38971c5a7deee0b9fc9044ee9" final-newline="yes" -->
````elisp
;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE: Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;   documentation. There you'll find a link to Doom's Module Index where all of
;;   our modules are listed, including what flags they support.

;; NOTE: Move your cursor over a module's name (or its flags) and press 'K' (or
;;   'C-c c k' for non-vim users) to view its documentation. This works on flags
;;   as well (those symbols that start with a plus).
;;
;;   Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;   directory (for easy access to its source code).

(doom! :input
       ;;bidi              ; (tfel ot) thgir etirw uoy gnipleh
       ;;chinese
       ;;japanese
       ;;layout            ; auie,ctsrnm is the superior home row

       :completion
       ;;company           ; the ultimate code completion backend
       (corfu +orderless)  ; complete with cap(f), cape and a flying feather!
       ;;helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ;;ivy               ; a search engine for love and life
       vertico           ; the search engine of the future

       :ui
       ;;deft              ; notational velocity for Emacs
       doom              ; what makes DOOM look the way it does
       dashboard         ; a nifty splash screen for Emacs
       ;;doom-quit         ; DOOM quit-message prompts when you quit Emacs
       ;;(emoji +unicode)  ; 🙂
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       ;;indent-guides     ; highlighted indent columns
       ;;ligatures         ; ligatures and symbols to make your code pretty again
       ;;minimap           ; show a map of the code on the side
       modeline          ; snazzy, Atom-inspired modeline, plus API
       ;;nav-flash         ; blink cursor line after big motions
       ;;neotree           ; a project drawer, like NERDTree for vim
       ophints           ; highlight the region an operation acts on
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       ;;smooth-scroll     ; So smooth you won't believe it's not butter
       ;;tabs              ; a tab bar for Emacs
       ;;treemacs          ; a project drawer, like neotree but cooler
       ;;unicode           ; extended unicode support for various languages
       (vc-gutter +pretty) ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       ;;window-select     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces
       ;;zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       ;;(format +onsave)  ; automated prettiness
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp, for people who don't like vim
       ;;multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent
       ;;parinfer          ; turn lisp into python, sort of
       ;;rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. They type so I don't have to
       (whitespace +guess +trim)  ; a butler for your whitespace
       ;;word-wrap         ; soft wrapping with language-aware indent

       :emacs
       dired             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       ;;eww               ; the internet is gross
       ;;ibuffer           ; interactive buffer management
       tramp             ; remote files at your arthritic fingertips
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       vterm             ; almost the best terminal emulation in Emacs
       ;;ghostel           ; the best terminal emulation in Emacs

       :checkers
       syntax              ; tasing you for every semicolon you forget
       ;;(spell +flyspell) ; tasing you for misspelling mispelling
       ;;grammar           ; tasing grammar mistake every you make

       :tools
       ;;ansible
       ;;biblio            ; Writes a PhD for you (citation needed)
       ;;collab            ; buffers with friends
       ;;debugger          ; stepping through code, to help you add bugs
       ;;direnv
       ;;docker
       ;;editorconfig      ; let someone else argue about tabs vs spaces
       ;;ein               ; tame Jupyter notebooks with emacs
       (eval +overlay)     ; run code, run (also, repls)
       lookup              ; navigate your code and its documentation
       ;;llm               ; when I said you needed friends, I didn't mean...
       ;;(lsp +eglot)      ; M-x vscode
       magit             ; a git porcelain for Emacs
       ;;make              ; run make tasks from Emacs
       ;;pass              ; password manager for nerds
       pdf                 ; pdf enhancements
       ;;terraform         ; infrastructure as code
       ;;tmux              ; an API for interacting with tmux
       ;;tree-sitter       ; syntax and parsing, sitting in a tree...
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS
       ;;tty               ; improve the terminal Emacs experience

       :lang
       ;;ada               ; In strong typing we (blindly) trust
       ;;(agda +local)     ; types of types of types of types...
       ;;beancount         ; mind the GAAP
       ;;(cc +lsp)         ; C > C++ == 1
       ;;clojure           ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c
       ;;csharp            ; unity, .NET, and mono shenanigans
       ;;data              ; config/data formats
       ;;(dart +flutter)   ; paint ui and not much else
       ;;dhall
       ;;elixir            ; erlang done right
       ;;elm               ; care for a cup of TEA?
       emacs-lisp        ; drown in parentheses
       ;;erlang            ; an elegant language for a more civilized age
       ;;ess               ; emacs speaks statistics
       ;;factor
       ;;faust             ; dsp, but you get to keep your soul
       ;;fortran           ; in FORTRAN, GOD is REAL (unless declared INTEGER)
       ;;fsharp            ; ML stands for Microsoft's Language
       ;;fstar             ; (dependent) types and (monadic) effects and Z3
       ;;gdscript          ; the language you waited for
       ;;(go +lsp)         ; the hipster dialect
       ;;(graphql +lsp)    ; Give queries a REST
       ;;(haskell +lsp)    ; a language that's lazier than I am
       ;;hy                ; readability of scheme w/ speed of python
       ;;idris             ; a language you can depend on
       ;;json              ; At least it ain't XML
       ;;janet             ; Fun fact: Janet is me!
       ;;(java +lsp)       ; the poster child for carpal tunnel syndrome
       ;;javascript        ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia             ; a better, faster MATLAB
       ;;kotlin            ; a better, slicker Java(Script)
       (latex +latexmk)  ; writing papers in Emacs has never been so fun
       ;;lean              ; for folks with too much to prove
       ;;ledger            ; be audit you can be
       ;;lua               ; one-based indices? one-based indices
       markdown          ; writing docs for people to ignore
       ;;nim               ; python + lisp at the speed of c
       ;;nix               ; I hereby declare "nix geht mehr!"
       ;;ocaml             ; an objective camel
       ;;odin              ; C, minus its footguns
       org               ; organize your plain life in plain text
       ;;php               ; perl's insecure younger brother
       ;;plantuml          ; diagrams for confusing people more
       ;;graphviz          ; diagrams for confusing yourself even more
       ;;purescript        ; javascript, but functional
       ;;python            ; beautiful is better than ugly
       ;;qt                ; the 'cutest' gui framework ever
       ;;racket            ; a DSL for DSLs
       ;;raku              ; the artist formerly known as perl6
       ;;rest              ; Emacs as a REST client
       ;;rst               ; ReST in peace
       ;;(ruby +rails)     ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       ;;(rust +lsp)       ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scad              ; trust the preview, regret the render
       ;;scala             ; java, but good
       ;;(scheme +guile)   ; a fully conniving family of lisps
       sh                ; she sells {ba,z,fi}sh shells on the C xor
       ;;sml
       ;;solidity          ; do you need a blockchain? No.
       ;;swift             ; who asked for emoji variables?
       ;;terra             ; Earth and Moon in alignment for performance.
       ;;web               ; the tubes
       ;;yaml              ; JSON, but readable
       ;;zig               ; C, but simpler

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;calendar
       ;;emms
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;irc               ; how neckbeards socialize
       ;;(rss +org)        ; emacs as an RSS reader

       :config
       ;;literate
       (default +bindings +smartparens))
````

### `config.el`

<!-- restore-file path="config.el" sha256="a8c9a7ed72f894e8b619a1b5263d04520e195c9a52cb2781e93f2630c7ed5c61" final-newline="yes" -->
````elisp
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Corfu only auto-shows completions once `corfu-auto-prefix' characters have
;; been typed (default 3), so short snippet keys like "eq" never pop up on
;; their own. Tell Corfu to skip that check specifically for yasnippet-capf,
;; so snippet candidates show in the overlay from the first character typed,
;; without lowering the threshold for other (more expensive) backends.
(after! yasnippet-capf
  (setq yasnippet-capf--properties
        (plist-put yasnippet-capf--properties :company-prefix-length t)))

;; Yasnippet reindents each line of an expanded snippet via the major mode's
;; indentation function by default (`yas-indent-line' is `auto'). That
;; reformats hand-indented snippet bodies (e.g. the 4-space bodies in `eq'
;; and `fig') to whatever AUCTeX's indenter thinks is correct. `nothing'
;; disables all snippet-side indentation, so snippets are inserted exactly
;; as written in the snippet file.
(after! yasnippet
  (setq yas-indent-line 'nothing))

;; Disable Emacs's general auto-indentation (reindenting the current line on
;; RET/certain characters), which is enabled globally by default.
(electric-indent-mode -1)

;; Evil's "o"/"O" (open line below/above) call `indent-according-to-mode' on
;; the new line when this is non-nil (`electric-indent-mode' has no say over
;; this path). Default is t.
(setq evil-auto-indent nil)

;; "zt" normally scrolls so the cursor line becomes the very first line in
;; the window (`recenter 0'). Instead, keep up to 6 lines of preceding
;; context visible above the cursor line -- i.e. `recenter 6', which puts
;; the cursor line on the 7th screen line. Near the top of the buffer, where
;; fewer than 6 lines precede it, `recenter' simply can't scroll past
;; `point-min', so it shows whatever's available -- "at most" 6 lines above.
(evil-define-command +evil-scroll-line-to-top-with-context (count)
  "Like `evil-scroll-line-to-top', but leaves up to 6 lines of context
above the cursor line instead of putting it on the very first screen line."
  :repeat nil
  :keep-visual t
  (interactive "<c>")
  (when count
    (evil-save-column
      (goto-char (point-min))
      (forward-line (1- count))))
  (recenter 6))

(map! :map evil-motion-state-map
      "zt" #'+evil-scroll-line-to-top-with-context)

;; Doom binds "s"/"S" to evil-snipe's 2-char sneak-style search by default,
;; shadowing Vim's standard substitute-char/substitute-line commands.
;; Doom enables evil-snipe-mode/evil-snipe-override-mode on
;; `doom-first-input-hook' (i.e. on your first keystroke, not at startup),
;; so disabling the mode directly in config.el is undone the moment you type
;; something. Removing them from the hook instead prevents them from ever
;; turning on, restoring vanilla Evil's s/S/f/F/t/T behavior.
(remove-hook 'doom-first-input-hook #'evil-snipe-mode)
(remove-hook 'doom-first-input-hook #'evil-snipe-override-mode)

;; Corfu normally pops up on its own once `corfu-auto-prefix' characters
;; have been typed. Disable that and instead trigger completion manually
;; with C-n/C-p (Vim-style keyword-completion muscle memory). This
;; overrides Evil's default insert-state C-n/C-p (`evil-complete-next'/
;; `evil-complete-previous', simple in-buffer word completion) in favor of
;; Corfu's completion-at-point. Once the Corfu popup is open, its own
;; transient keymap takes precedence, so C-n/C-p continue to mean
;; next/previous candidate rather than re-triggering completion.
(after! corfu
  (setq corfu-auto nil))

(map! :map evil-insert-state-map
      "C-n" #'completion-at-point
      "C-p" #'completion-at-point)

;; Make TAB, while typing, try Yasnippet expansion first (so typing a
;; snippet's key, e.g. "lst", and hitting TAB still expands it) and
;; otherwise insert two literal space characters -- instead of a tab
;; character or Emacs's usual context-aware reindentation
;; (`indent-for-tab-command'). Scoped to Evil's insert-state keymap only, so
;; it doesn't clobber TAB's other jobs: Corfu's completion popup and
;; Yasnippet's own field-navigation (once a snippet is already being edited)
;; both install their own higher-precedence keymaps while active and are
;; unaffected, and Org's heading-cycling on TAB (which runs in normal state)
;; is untouched.
;;
;; We check `yas--templates-for-key-at-point' ourselves rather than just
;; calling `yas-expand' unconditionally: when there's no matching snippet,
;; `yas-expand' runs `yas-fallback-behavior' instead of doing nothing, and
;; that fallback is not guaranteed to be "insert two spaces".
;;
;; Caveat: some modes require a literal tab character syntactically (e.g.
;; Makefile recipe lines) -- this binding makes TAB unable to produce one; use
;; `C-q TAB' (quoted-insert) there instead.
;;
;; Must bind both "TAB" and "<tab>": in GUI Emacs the physical Tab key sends
;; the function-key event `<tab>', which takes precedence over a `TAB'
;; (C-i) binding in the same keymap. Binding only "TAB" left `<tab>' to fall
;; through to whatever lower-precedence binding produced it (a literal
;; newline) -- the snippet still expanded via `yas--on-field-overlay-modified'
;; or similar, but that stray newline came along with it. This is a
;; documented Doom/Evil gotcha (see `:completion corfu's README, "Fixing TAB
;; Keybindings"). A TTY sends "TAB" for both, so the `<tab>' binding below is
;; simply unused there.
(defun +yas-expand-or-insert-spaces ()
  "Expand the Yasnippet at point, or insert two spaces if there isn't one."
  (interactive)
  (if (and (bound-and-true-p yas-minor-mode)
           (yas--templates-for-key-at-point))
      (yas-expand)
    (insert "  ")))

(map! :map evil-insert-state-map
      "TAB"   #'+yas-expand-or-insert-spaces
      "<tab>" #'+yas-expand-or-insert-spaces)

;; Evil's insert state binds C-e/C-y to vim's "copy character from line
;; below/above" (`evil-copy-from-below'/`evil-copy-from-above') by default,
;; while normal state binds them to scroll-the-window-by-one-line
;; (`evil-scroll-line-down'/`evil-scroll-line-up', from
;; `evil-motion-state-map'). Rebind insert state to match normal state's
;; scroll behavior so C-e/C-y are consistent across both states.
(map! :map evil-insert-state-map
      "C-e" #'evil-scroll-line-down
      "C-y" #'evil-scroll-line-up)

;; Yasnippet uses a snippet file's contents (after "# --") verbatim as the
;; expansion template, with no trimming. Doom's global `require-final-newline'
;; (t) means Emacs auto-appends a trailing newline whenever such a file is
;; saved, and that newline then shows up as a literal extra blank line at the
;; end of every expansion. Disable it specifically for snippet files so
;; editing/saving them doesn't silently reintroduce the bug.
(add-hook 'snippet-mode-hook (lambda () (setq-local require-final-newline nil)))

;; Auto-expand "ii" -> "\item " as soon as it's typed (followed by a space,
;; punctuation, or newline) with no popup and no confirmation keystroke.
;; This uses Emacs's built-in abbrev-mode instead of yasnippet/corfu, since
;; those always require an explicit accept keystroke to expand a candidate.
(add-hook 'LaTeX-mode-hook #'abbrev-mode)

;; abbrev-mode matches on the whole word immediately before point, so
;; without a guard "ii" expands anywhere it appears as a standalone token --
;; a roman numeral "(ii)", an index variable, etc. -- silently inserting
;; "\item " (and its trailing space) in the middle of unrelated text.
;;
;; `\item' is always the first thing on its line, so restrict expansion to
;; that case: only when "ii" (after any leading indentation) is everything
;; on the line so far. `:enable-function' runs *before* the triggering
;; separator (space/punctuation/newline) is inserted, with point right
;; after "ii", so checking from `line-beginning-position' to `point'
;; doesn't need to account for the separator at all.
(defun +latex--item-abbrev-p ()
  "Only expand the `ii' -> `\\item ' abbrev when `ii' starts its line."
  (string-match-p "\\`[ \t]*ii\\'"
                   (buffer-substring-no-properties (line-beginning-position) (point))))

(define-abbrev-table 'LaTeX-mode-abbrev-table
  '(("ii" "\\item " nil :enable-function +latex--item-abbrev-p)))
;; Abbrevs above are defined in code, not learned interactively, so don't
;; prompt to save them to `abbrev-file-name' on exit.
(setq save-abbrevs nil)

;; `smartparens-latex.el' auto-pairs "$" into "$$" (with point in between) in
;; (La)TeX modes. Disable that specific pairing so "$" just inserts "$".
;;
;; This must hook `smartparens-latex' specifically, not `smartparens': the
;; core `smartparens' feature loads early at startup, but the "$"/"$" pair
;; is defined by the separate `smartparens-latex' language file, which only
;; loads later when a (La)TeX buffer is actually opened. Hooking `smartparens'
;; ran our override too early -- `smartparens-latex' loaded afterward and
;; silently re-registered the pair, clobbering it. Doom's own `:lang latex'
;; module hits this same trap and works around it the same way.
(after! smartparens-latex
  (sp-local-pair '(tex-mode plain-tex-mode latex-mode LaTeX-mode) "$" nil :actions nil))

;; Auto-save .tex files to disk as you type. Emacs's regular auto-save
;; (`auto-save-mode') only writes a separate `#file#' recovery file, which
;; nothing compiling the document would ever see -- `auto-save-visited-mode'
;; is the one that periodically saves the actual visited file.
;;
;; It's a global minor mode with no per-mode variant, so it's turned on
;; globally but scoped down to just LaTeX buffers via
;; `auto-save-visited-predicate' (Emacs 28+): everywhere else, saving stays
;; manual.
(setq auto-save-visited-predicate (lambda () (derived-mode-p 'LaTeX-mode))
      ;; Save after 2s idle instead of the default 5s, since latexmk is
      ;; waiting on this save to trigger a recompile.
      auto-save-visited-interval 2)
(auto-save-visited-mode 1)

;; Auto-compile .tex files: run `latexmk -pvc' continuously in the
;; background for every LaTeX buffer (via `auctex-cont-latexmk-mode', from
;; the already-installed `auctex-cont-latexmk' package -- the `+latexmk'
;; flag on the `:lang latex' module). latexmk watches the file on disk and
;; recompiles automatically whenever it changes, which is what the
;; auto-save above feeds it -- so together, typing in a .tex buffer alone
;; keeps the PDF continuously up to date, no manual save or compile.
;;
;; This does not open a viewer. Use `SPC m v' (`TeX-view') to open one once,
;; or the existing `+latex/live-preview' command, which does both at once.
(add-hook 'LaTeX-mode-hook #'auctex-cont-latexmk-mode)

;; The PDF on disk stays current (via `auctex-cont-latexmk-mode' above), but
;; an already-open PDF viewer buffer doesn't notice on its own -- neither
;; `doc-view-mode' nor `pdf-view-mode' turns on `auto-revert-mode' by
;; default, so the buffer keeps showing whatever it last rendered until
;; something reverts it.
;;
;; The `:tools pdf' module would normally wire a *different* mechanism for
;; this: it hooks `TeX-after-compilation-finished-functions' to
;; `TeX-revert-document-buffer', reverting the PDF right after AUCTeX
;; finishes a compile. That doesn't apply to this setup regardless -- it
;; only fires for AUCTeX's own one-shot `TeX-command-*' invocations, and
;; `auctex-cont-latexmk-mode' runs latexmk as its own independent background
;; watch process outside that machinery, so the hook would never fire.
;;
;; `auto-revert-mode' sidesteps all of that: it watches the PDF file itself
;; (via inotify) and reverts the buffer whenever it changes on disk, however
;; the file got regenerated. `doc-view-mode' is kept covered here too in
;; case `:tools pdf' (and thus `pdf-view-mode') ever gets disabled again.
(add-hook 'doc-view-mode-hook #'auto-revert-mode)
(add-hook 'pdf-view-mode-hook #'auto-revert-mode)

;; Scroll the PDF to match the last edit whenever it auto-reverts, so typing
;; in the .tex buffer keeps the preview following along with no manual sync.
;;
;; `pdf-sync-forward-search' (from pdf-tools' `pdf-sync') is the primitive
;; AUCTeX itself uses for forward search (`SPC m v' / `C-c C-v' with
;; `TeX-source-correlate-mode' on, via `TeX-pdf-tools-sync-view'): it must
;; be called with a LaTeX source buffer current, and jumps/scrolls the
;; matching PDF window to the page/position under that buffer's point --
;; the SyncTeX data for this comes from `-synctex=1', already on by default
;; in `auctex-cont-latexmk-command'. `doc-view-mode' has no equivalent in
;; AUCTeX, so this only runs for `pdf-view-mode' buffers.
;;
;; `after-revert-hook' runs inside the PDF buffer, not the .tex buffer, so
;; we first have to find the right source buffer: the most recently
;; selected `LaTeX-mode' buffer whose master resolves to this PDF (matters
;; for multi-file `\include'-based documents, where more than one buffer
;; can share the same output PDF) -- `buffer-list' is already ordered
;; most-recently-selected first, so the first match is the right one.
(defun +latex--pdf-source-buffer ()
  "Return the LaTeX buffer this PDF buffer was compiled from, or nil."
  (let ((pdf-file (buffer-file-name)))
    (seq-find (lambda (buf)
                (with-current-buffer buf
                  (and (derived-mode-p 'LaTeX-mode)
                       (fboundp 'TeX-master-file)
                       (ignore-errors
                         (file-equal-p (TeX-master-file "pdf") pdf-file)))))
              (buffer-list))))

(defun +latex-pdf-follow-edit-h ()
  "Scroll this PDF buffer to match point in its LaTeX source buffer.
Only does this when the PDF is already showing in some window: `pdf-sync-
forward-search' calls `display-buffer' unconditionally, which otherwise
pops open a brand new split for it on every single recompile whenever the
viewer isn't currently open -- exactly the behavior we don't want here."
  (when (and (fboundp 'pdf-sync-forward-search)
             (get-buffer-window (current-buffer) t))
    (when-let* ((tex-buf (+latex--pdf-source-buffer)))
      (with-current-buffer tex-buf
        (pdf-sync-forward-search)))))

(add-hook 'pdf-view-mode-hook
          (lambda () (add-hook 'after-revert-hook #'+latex-pdf-follow-edit-h nil t)))
````

### `packages.el`

<!-- restore-file path="packages.el" sha256="ce36023ef4c75f5cf4026e016b478e0c583623b3ed22715b0426cb7cf372aea0" final-newline="yes" -->
````elisp
;;; $DOOMDIR/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

;; To install a package:
;;
;;   1. Declare them here in a `package!' statement,
;;   2. Run 'doom sync' in the shell,
;;   3. Restart Emacs.
;;
;; Use 'C-h f package\!' to look up documentation for the `package!' macro.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)
````

### `snippets/LaTeX-mode/align` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/align" sha256="7eafe1f8771c2c5cff6a3726df92f0cf2f50cf69f0839d80e88e2bec62fff8b4" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: align Environment
# key: align
# --
\begin{align*}
$0
\end{align*}
````

### `snippets/LaTeX-mode/bf` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/bf" sha256="48ae71f7a1d6cdee29765cfb8a6734bba4274b6d016db3322cd044596478462d" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: boldface Environment
# key: bf
# --
\textbf{$0}
````

### `snippets/LaTeX-mode/defbox` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/defbox" sha256="c6a83a726b258f648d0061615aa9e310f16657791f8f5347e140d6233e20f087" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: DefBox Environment
# key: def
# --
\begin{defbox}{$0}
\end{defbox}
````

### `snippets/LaTeX-mode/enumerate` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/enumerate" sha256="18087f67738f22a13e67403be0bb25f5861b22b85ff1da8a4756354168e2c23a" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: enumerate Environment
# key: enum
# --
\begin{enumerate}
\item
$0
\end{enumerate}
````

### `snippets/LaTeX-mode/eq` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/eq" sha256="6e66f11adc150f758ad8170b989de5e7c7e58adce1ea49f2d35580b6a5b72d1f" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Equation Environment
# key: eq
# --
\begin{equation}
    \label{eq:${1:label}}
    ${2:a^2 + b^2 = c^2}
\end{equation}
$0
````

### `snippets/LaTeX-mode/fig` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/fig" sha256="25ddc09287ccb670a509a0282881599798b59b37b901af66f742e870aa0e3e5a" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Figure Environment
# key: fig
# --
\begin{figure}[H]
  \begin{center}
    \includegraphics[width=0.8\linewidth]{$0}
    \caption{}
  \end{center}
\end{figure}
````

### `snippets/LaTeX-mode/frac` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/frac" sha256="48343545480662495339fe647d82b8f46f5ca66a746888fb0cd0c8c6c589b553" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Fraction
# key: frac
# --
`(if (texmathp) "" "$")`\frac{$1}{$2}`(if (texmathp) "" "$")`$0
````

### `snippets/LaTeX-mode/int` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/int" sha256="477ec191bdaae3d61d05d4d8dc29308a0cbb10b0bbaaffc27266499718acc44e" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Integral
# key: int
# --
`(if (setq yas--texmathp (texmathp)) "" "$")`\int_{$1}^{$2} $3`(if yas--texmathp "" "$")`$0
````

### `snippets/LaTeX-mode/it` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/it" sha256="b4a13ee5b668c541bab393f91c249295531fa88cc7633f7e26a8029c7b6d5745" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: italic Environment
# key: it
# --
\textit{$0}
````

### `snippets/LaTeX-mode/item` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/item" sha256="1ff14e1edbb0fa534f535ec7f9d348157a7887dcb8c4ca9ef64a33bd1b3d2259" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Item
# --
\item $0
````

### `snippets/LaTeX-mode/itemize` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/itemize" sha256="baaca48df3512115b19e4de8084a38c26a0a25dfd3f9a76fc91f79f44ad8c998" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: itemize Environment
# key: item
# --
\begin{itemize}
\item
$0
\end{itemize}
````

### `snippets/LaTeX-mode/lim` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/lim" sha256="5dec92725f1e23b2ed2e3689ebffbc23726754dbaccca611efb673ad975f225f" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Limit
# key: lim
# --
`(if (setq yas--texmathp (texmathp)) "" "$")`\lim_{$1 \to $2} $3`(if yas--texmathp "" "$")`$0
````

### `snippets/LaTeX-mode/ll` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/ll" sha256="fac310d3a78d29a2eb2a72063db50e6d62b636483a637cad356bb054e5f46540" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: lstinline Environment
# key: ll
# --
\lstinline|$0|
````

### `snippets/LaTeX-mode/lst` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/lst" sha256="a49242395a33392414807f2431487a24cd0dc06cf7b540ea99a5018063a7c1b4" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: lstlisting Environment
# key: lst
# --
\begin{lstlisting}
$0
\end{lstlisting}
````

### `snippets/LaTeX-mode/sqrt` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/sqrt" sha256="fceeeff804beb046dff882a9fcb82610ddfa232c1b642429ed95b95afacabf1c" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Square Root
# key: sqrt
# --
`(if (setq yas--texmathp (texmathp)) "" "$")`\sqrt{$1}`(if yas--texmathp "" "$")`$0
````

### `snippets/LaTeX-mode/subsection` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/subsection" sha256="1783ee80d482eeab2186274611821626eeff1f8fc8cd56979ec3c1c29774fd42" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: subsection Environment
# key: sub
# --
\subsection{$0}
````

### `snippets/LaTeX-mode/subsubsection` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/subsubsection" sha256="2ba668b9a0b2b5e9858f32f247dd78dbd70a0c6e063e94608cb5385ccc4b5c83" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: subsubsection Environment
# key: ssub
# --
\subsubsection{$0}
````

### `snippets/LaTeX-mode/sum` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/sum" sha256="a53ad9304b32c7e92e6e43737ccff5a5233255fd10e3801a063be71ee1517329" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Summation
# key: sum
# --
`(if (setq yas--texmathp (texmathp)) "" "$")`\sum_{$1}^{$2} $3`(if yas--texmathp "" "$")`$0
````

### `snippets/LaTeX-mode/table1` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/table1" sha256="00e687b0f8e247af4ae5944b21b575bdd3d737e5aecde996cf2b75839b0d34e4" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Table (1 column)
# key: table1
# --
\begin{tabular}{|p{6cm}|}
\hline
${0} \\\\
\hline
\end{tabular}
````

### `snippets/LaTeX-mode/table2` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/table2" sha256="faad5a2cfc2d97ba0bcf862e56c3a5e03d0bb54bb635166ab457b6f5f4653a70" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Table (2 columns)
# key: table2
# --
\begin{tabular}{|p{6cm}|p{6cm}|}
\hline
$0 &  \\\\
\hline
\end{tabular}
````

### `snippets/LaTeX-mode/table3` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/table3" sha256="1e4c444d28bb333bdf98c7e2a00f067a1900edcd7d8660409ae6f8702c45c951" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Table (3 columns)
# key: table3
# --
\begin{tabular}{|p{4cm}|p{4cm}|p{4cm}|}
\hline
$0 &  &  \\\\
\hline
\end{tabular}
$0
````

### `snippets/LaTeX-mode/table4` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/table4" sha256="0c0c0820771937f92073ed091b57aecfc1d50fcdec5caa158e69524ea95edd5a" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Table (4 columns)
# key: table4
# --
\begin{tabular}{|p{3.5cm}|p{3.5cm}|p{3.5cm}|p{3.5cm}|}
\hline
$0 & &  & \\\\
\hline
\end{tabular}
````

### `snippets/LaTeX-mode/table5` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/table5" sha256="b51c779a1b8b197ef3e60c6c0121033bf927855d4e71dd1ae6c202886ac605af" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Table (5 columns)
# key: table5
# --
\begin{tabular}{|p{3cm}|p{3cm}|p{3cm}|p{3cm}|p{3cm}|}
\hline
$0 &  &  &  &  \\\\
\hline
\end{tabular}
````

### `snippets/LaTeX-mode/table6` (no trailing newline)

<!-- restore-file path="snippets/LaTeX-mode/table6" sha256="ac3e571d9a4507bba9d6707cfb48128a9aa2a3411ad0d895fa241dd55bcd7b6a" final-newline="no" -->
````snippet
# -*- mode: snippet -*-
# name: Table (6 columns)
# key: table6
# --
\begin{tabular}{|p{2.5cm}|p{2.5cm}|p{2.5cm}|p{2.5cm}|p{2.5cm}|p{2.5cm}|}
\hline
$0 &  &  &  &  &  \\\\
\hline
\end{tabular}
````

