# Remove nickjj/dotfiles Dependency

## Goal

Migrate from a two-layer dotfiles setup (nickjj/dotfiles base + personal overrides) to a self-contained dotfiles repo. Copy the needed configs from nickjj into this repo and remove the bootstrap dependency.

## Current State

- Repo has 4 files: `install.sh`, `zshrc.local`, `zprofile.local`, `.claude/settings.json`
- These are "override" files that layer on top of nickjj/dotfiles
- Setup requires running nickjj's `BOOTSTRAP=1` installer first, then our `install.sh`
- nickjj's configs live at `~/.config/zsh/`, using XDG paths with `ZDOTDIR`

## Target State

A single self-contained repo that sets up the full dev environment with one `install.sh` run (mise is the only prerequisite).

## Platform

Ubuntu only.

## Repo Structure

```
dotfiles/
├── .zshrc                    # Base zsh interactive config (from nickjj, adapted)
├── .zshrc.local              # Personal overrides (existing, updated)
├── .zprofile                 # Base login shell config (from nickjj, adapted)
├── .aliases                  # Aliases (from nickjj, curated)
├── .config/
│   ├── tmux/
│   │   ├── tmux.conf         # From nickjj
│   │   └── theme.conf        # Inlined tokyonight-moon theme (was a symlink)
│   ├── nvim/
│   │   ├── init.lua          # LazyVim bootstrap
│   │   ├── lazy-lock.json
│   │   ├── lazyvim.json
│   │   ├── filetype.lua
│   │   ├── stylua.toml
│   │   ├── .neoconf.json
│   │   ├── lua/
│   │   │   ├── config/       # options.lua, keymaps.lua, autocmds.lua, lazy.lua
│   │   │   └── plugins/      # all plugin specs + data/
│   │   ├── snippets/         # markdown, ruby, shell
│   │   ├── spell/
│   │   └── after/queries/
│   ├── fzf/
│   │   └── config.sh         # From nickjj (theme colors inlined)
│   └── bat/
│       └── config            # From nickjj
├── .claude/
│   └── settings.json         # Existing
├── .gitignore                # Ignore tmux plugins dir, etc.
├── install.sh                # Rewritten
└── README.md                 # Updated
```

## What We Copy From nickjj/dotfiles

### Zsh (.zshrc, .zprofile, .aliases)

**Adapted to use home directory paths instead of `~/.config/zsh/`.**

`.zshrc` (base):
- Default prompt: `user@host:dir (git-branch)` (overridden by agnoster theme in `.zshrc.local`)
- 50,000-line history at `~/.zsh_history` (hardcoded, not using `DOTFILES_PATH`)
- 4 plugins loaded natively (git-cloned by install script): fast-syntax-highlighting, zsh-autosuggestions, zsh-vi-mode, fzf-tab
- Vi mode keybindings with Home/End support
- Case-insensitive tab completion with dircolors
- Sources `~/.aliases`, then `~/.aliases.local` (if exists), then `~/.zshrc.local`

`.zprofile` (base):
- Prepends `~/.local/bin` and mise shims to `PATH`
- Sets `EDITOR=nvim`, `DIFFPROG="nvim -d"`
- Colored man pages via `LESS_TERMCAP_*`
- Sources `~/.zprofile.local` (if exists)

**Removals from nickjj's `.zprofile`:**
- Remove `GNUPGHOME` export (default `~/.gnupg` is correct)
- Remove `PASSWORD_STORE_DIR` export (default `~/.password-store` is correct)
- Remove `PASSWORD_STORE_GPG_OPTS`
- Remove `.xdg.local` sourcing (not needed)
- Keep `ZVM_*_CURSOR` settings (needed for zsh-vi-mode)

`.aliases` (curated from nickjj):
- Keep: `ll`, `la`, `l` (file listing), `diff` (colored), `k`/`tf` (k8s/terraform), `drun` (docker), `gi` (git init), `pf` (fzf picker), `run` (./run)
- Adapt: `sz` — change `${ZDOTDIR}` to `$HOME`; `dt` — change `${DOTFILES_PATH}` to `$HOME/dotfiles`
- Remove: `SZ` (needs tmux-shell-cmd script), `start-rec`/`stop-rec` (need recording scripts), `lz`/`lp` (reference XDG_DATA_HOME), `vss`/`vdt` (reference XDG_CONFIG_HOME/XDG_STATE_HOME)
- Keep `eza` aliases only if eza is installed (see install script)

### .zshrc.local (personal, updated)

- Keeps antigen setup for user-specific plugins: oh-my-zsh, git, tmux, z, pip, lein, command-not-found, you-should-use, agnoster theme
- **Remove** `vi-mode`, `zsh-syntax-highlighting`, and `zsh-autosuggestions` bundles from antigen (loaded natively by base `.zshrc`)
- Keeps `claude-yolo` alias and Datadog credential exports
- Remove `DOTFILES_PATH` reference to nickjj-dotfiles

### Plugin installation strategy

The base `.zshrc` sources 4 plugins natively from `~/.local/share/`:
- `fast-syntax-highlighting`
- `zsh-autosuggestions`
- `zsh-vi-mode`
- `fzf-tab`

The install script git-clones these into `~/.local/share/`. Antigen in `.zshrc.local` handles additional user-specific plugins (oh-my-zsh bundles, you-should-use, agnoster theme). No overlap — each plugin is loaded by exactly one mechanism.

**Note:** The agnoster theme from antigen overrides the base `.zshrc` custom prompt. This is intentional — agnoster is the active prompt.

### Tmux (.config/tmux/)

Copied from nickjj with two fixes:

`tmux.conf`:
- Backtick prefix, Alt+Arrow pane nav, mouse enabled
- 50,000-line history, 256-color, 1-based pane indexing
- Plugins: tmux-resurrect, tmux-yank via TPM
- **Fix:** Remove `clip-copy` override from tmux-yank config. tmux-yank falls back to system clipboard (`xclip`/`xsel`). Install `xclip` via apt.

`theme.conf` (new file, inlined):
- Currently `~/.config/tmux/theme.conf` is a symlink into nickjj's theme system
- Inline the tokyonight-moon tmux theme content directly (about 8 lines of color settings)
- This makes `source-file "~/.config/tmux/theme.conf"` in `tmux.conf` work without the theme system

### Neovim (.config/nvim/)

Copied from nickjj — full LazyVim distribution including all subdirectories:
- `init.lua`, `lazy-lock.json`, `lazyvim.json`, `filetype.lua`, `stylua.toml`, `.neoconf.json`
- `lua/config/` — options.lua, keymaps.lua, autocmds.lua, lazy.lua
- `lua/plugins/` — all plugin specs + `data/` subdirectory
- `snippets/`, `spell/`, `after/queries/`

**Fix:** `lua/plugins/theme.lua` is currently a symlink to nickjj's theme system (`themes/tokyonight-moon/nvim.lua`). Resolve the symlink and inline the content — approximately 8 lines setting the LazyVim colorscheme to `tokyonight-moon`.

**Fix:** Remove `theme-hot-reload.lua` plugin if present — it's part of nickjj's theme switching system which we are not copying.

### fzf (.config/fzf/config.sh)

Copied from nickjj:
- Ripgrep as backend, bat for preview
- Sourced from `.zshrc`

**Fix:** nickjj's config sources a theme file from his theme system. Inline the tokyonight-moon fzf color settings directly into `config.sh`.

### bat (.config/bat/config)

Copied as-is from nickjj. No changes needed.

## What We Delete

- `zprofile.local` — was only needed to undo nickjj's XDG overrides. No longer necessary.
- `.zshenv` — not copied; only existed to set `ZDOTDIR`.

## What We Do NOT Copy

- `.local/bin/` scripts (30+ utility scripts)
- GPG/SSH key generation
- Theme system (gruvbox/tokyonight switching) — theme colors are inlined where needed
- GUI/Wayland configs (niri, waybar, mako, etc.)
- Git config (`~/.gitconfig` is managed by employer)

## Install Script

**Prerequisite:** `mise` must be installed (`curl https://mise.run | sh`). Documented in README.

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# --- System packages (apt-get) ---
sudo apt-get update && sudo apt-get install -y \
  zsh \
  tmux \
  bat \
  fontconfig \
  curl \
  git \
  unzip \
  xclip \
  zsh-antigen

# --- bat symlink (Ubuntu installs as batcat) ---
mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"

# --- Tools via mise ---
mise use -g neovim
mise use -g fzf
mise use -g delta
mise use -g ripgrep
mise use -g eza
mise use -g golangci-lint
mise use -g lazygit
mise use -g node
mise use -g python

# --- Nerd Font (Inconsolata) ---
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
curl -fsSL -o /tmp/inconsolata.zip \
  "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.zip"
unzip -o /tmp/inconsolata.zip -d "$FONT_DIR/Inconsolata"
fc-cache -f
rm /tmp/inconsolata.zip

# --- Zsh plugins (git clone into ~/.local/share) ---
ZSH_PLUGINS_DIR="$HOME/.local/share"
declare -A ZSH_PLUGINS=(
  [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-vi-mode]="https://github.com/jeffreytse/zsh-vi-mode"
  [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
)
for plugin in "${!ZSH_PLUGINS[@]}"; do
  if [ ! -d "$ZSH_PLUGINS_DIR/$plugin" ]; then
    git clone "${ZSH_PLUGINS[$plugin]}" "$ZSH_PLUGINS_DIR/$plugin"
  fi
done

# --- Symlinks: zsh files to home directory ---
for f in .zshrc .zshrc.local .zprofile .aliases; do
  ln -sf "$DOTFILES_DIR/$f" "$HOME/$f"
done

# --- Symlinks: .config directories ---
mkdir -p "$HOME/.config"
for dir in tmux nvim fzf bat; do
  ln -sfn "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
done

# --- Symlinks: Claude settings ---
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

# --- Tmux Plugin Manager (TPM) ---
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- Set default shell to zsh (may prompt for password) ---
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

echo "Done! Restart your shell or run: source ~/.zshrc"
```

Key decisions:
- `set -euo pipefail` for safer script execution
- `apt-get` for stable system tools (zsh, tmux, bat, git, fontconfig, unzip, xclip, zsh-antigen)
- `mise` for version-sensitive tools (neovim, fzf, delta, ripgrep, eza, node, python, golangci-lint, lazygit)
- `bat` → `batcat` symlink created in `~/.local/bin/`
- `ripgrep` installed via mise (needed by fzf config)
- `eza` installed via mise (needed by aliases)
- `xclip` installed via apt (needed by tmux-yank)
- Zsh plugins git-cloned into `~/.local/share/`
- Nerd Font from GitHub releases
- TPM cloned for tmux plugin management (install plugins with prefix + I)
- `.config/tmux/plugins/` must be in `.gitignore` (TPM clones into the symlinked dotfiles dir)
- `.config/` dirs symlinked as directories (`ln -sfn`)
- `chsh` to make zsh the default (may prompt for password — noted in README)
- `mise` is a prerequisite, not installed by this script (documented in README)

## README

```markdown
# dotfiles

Personal development environment dotfiles for Ubuntu.

## Prerequisites

Install [mise](https://mise.jdx.dev):
curl https://mise.run | sh

## Setup

git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh

Note: `chsh` at the end may prompt for your password to set zsh as default shell.

## After install

- Restart your shell (or `source ~/.zshrc`)
- Open tmux and press `` ` `` + `I` to install tmux plugins
- Open nvim — plugins will auto-install on first launch
```
