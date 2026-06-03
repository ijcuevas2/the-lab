# Neovim Setup on macOS

## 1. Install Neovim and dependencies

```bash
brew install neovim
brew install ripgrep fd          # required by Telescope
brew install latexmk             # or install MacTeX which includes it
pip3 install pynvim              # required by UltiSnips
```

## 2. Install a Nerd Font

nvim-tree uses icons that require a Nerd Font. Download one from [nerdfonts.com](https://www.nerdfonts.com/), install it, and set it as your terminal font.

Example via Homebrew:
```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Then set `JetBrainsMono Nerd Font` (or whichever you chose) as your terminal's font.

## 3. Install a PDF viewer

This config uses **Skim** on macOS (instead of Zathura on Linux).

```bash
brew install --cask skim
```

Enable "Reload automatically" in Skim → Preferences → Sync so the PDF updates live while compiling.

## 4. Copy config files

```bash
mkdir -p ~/.config/nvim/UltiSnips
cp init.lua ~/.config/nvim/
cp lazy-lock.json ~/.config/nvim/
cp UltiSnips/tex.snippets ~/.config/nvim/UltiSnips/
```

## 5. Change the PDF viewer in init.lua

Open `~/.config/nvim/init.lua` and find this line:

```lua
vim.g.vimtex_view_method = "zathura"   -- change to "skim" on macOS
```

Change it to:

```lua
vim.g.vimtex_view_method = "skim"
```

## 6. Launch Neovim

```bash
nvim
```

lazy.nvim will bootstrap itself and install all plugins automatically on the first launch. Wait for it to finish, then restart Neovim.

## 7. Verify everything works

Run `:checkhealth` inside Neovim. It will flag any missing dependencies. Common ones to fix:

| Warning | Fix |
|---|---|
| `pynvim` not found | `pip3 install pynvim` |
| `ripgrep` not found | `brew install ripgrep` |
| `fd` not found | `brew install fd` |
| `latexmk` not found | `brew install latexmk` or install MacTeX |
| Nerd Font icons broken | Set a Nerd Font in your terminal preferences |

## Key mappings (quick reference)

| Key | Action |
|---|---|
| `<Space>e` | Toggle file explorer |
| `<Space>ff` | Find files (Telescope) |
| `<Space>fg` | Live grep (Telescope) |
| `,ll` | Compile LaTeX |
| `,lv` | View PDF in Skim |
| `,lk` | Stop compiler |
| `,lc` | Clean aux files |
| `,lt` | Open table of contents |
| `<Space>us` | Edit UltiSnips snippets |
| `<Tab>` | Expand / jump forward in snippet |
| `<Shift-Tab>` | Jump backward in snippet |
