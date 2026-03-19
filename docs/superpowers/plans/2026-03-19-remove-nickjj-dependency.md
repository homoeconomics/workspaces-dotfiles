# Remove nickjj/dotfiles Dependency — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the dotfiles repo self-contained by copying needed configs from nickjj/dotfiles, adapting paths, and rewriting the install script.

**Architecture:** Flat repo structure mirroring target locations. Zsh files at root symlinked to `~/`, `.config/` subtree symlinked as directories to `~/.config/`. Install script handles apt packages, mise tools, font, zsh plugin cloning, symlinks, and TPM.

**Tech Stack:** Zsh, tmux, Neovim (LazyVim), fzf, bat, mise, apt-get

**Spec:** `docs/superpowers/specs/2026-03-19-remove-nickjj-dependency-design.md`

---

## File Map

### New files to create

| File | Source | Notes |
|------|--------|-------|
| `.zshrc` | nickjj `.config/zsh/.zshrc` | Adapt all XDG/ZDOTDIR paths to `$HOME` |
| `.zprofile` | nickjj `.config/zsh/.zprofile` | Remove GPG/password-store/xdg.local, adapt paths |
| `.aliases` | nickjj `.config/zsh/.aliases` | Curate: keep/adapt/remove per spec |
| `.gitignore` | new | Ignore `.config/tmux/plugins/` |
| `.config/tmux/tmux.conf` | nickjj `.config/tmux/tmux.conf` | Remove `clip-copy` override |
| `.config/tmux/theme.conf` | nickjj `themes/tokyonight-moon/tmux.conf` | Inlined theme |
| `.config/nvim/init.lua` | nickjj (copy as-is) | |
| `.config/nvim/lazyvim.json` | nickjj (copy as-is) | |
| `.config/nvim/lazy-lock.json` | nickjj (copy as-is) | |
| `.config/nvim/filetype.lua` | nickjj (copy as-is) | |
| `.config/nvim/stylua.toml` | nickjj (copy as-is) | |
| `.config/nvim/.neoconf.json` | nickjj (copy as-is) | |
| `.config/nvim/lua/config/options.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/config/keymaps.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/config/autocmds.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/config/lazy.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/theme.lua` | nickjj `themes/tokyonight-moon/nvim.lua` | Inlined (was symlink) |
| `.config/nvim/lua/plugins/_disabled.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/colorschemes.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/completions.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/grug-far.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/lsp.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/lualine.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/markdown.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/mason.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/multicursor.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/snacks.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/treesitter.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/vim-better-whitespace.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/vim-hugo.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/vim-jinja2-syntax.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/vim-test.lua` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/data/.markdownlint-cli2.yaml` | nickjj (copy as-is) | |
| `.config/nvim/lua/plugins/data/github-markdown.css` | nickjj (copy as-is) | Large file (1237 lines) |
| `.config/nvim/snippets/package.json` | nickjj (copy as-is) | |
| `.config/nvim/snippets/markdown.json` | nickjj (copy as-is) | |
| `.config/nvim/snippets/ruby.json` | nickjj (copy as-is) | |
| `.config/nvim/snippets/sh.json` | nickjj (copy as-is) | |
| `.config/nvim/spell/en.utf-8.add` | nickjj (copy as-is) | Large file (700+ words) |
| `.config/nvim/after/queries/gitcommit/highlights.scm` | nickjj (copy as-is) | |
| `.config/fzf/config.sh` | nickjj `.config/fzf/config.sh` | Inline theme, adapt paths |
| `.config/bat/config` | nickjj (copy as-is) | |

### Files to modify

| File | Change |
|------|--------|
| `.zshrc.local` (rename from `zshrc.local`) | Remove vi-mode, syntax-highlighting, autosuggestions from antigen |
| `install.sh` | Full rewrite |
| `README.md` | Full rewrite |

### Files to delete

| File | Reason |
|------|--------|
| `zprofile.local` | No longer needed — was only undoing nickjj's XDG overrides |
| `zshrc.local` | Replaced by `.zshrc.local` (dot prefix, same content updated) |

### Files NOT copied (explicitly excluded)

| File | Reason |
|------|--------|
| `.config/nvim/lua/plugins/theme-hot-reload.lua` | Part of nickjj's theme switching system |

---

## Task 1: Create .gitignore and .zprofile

**Files:**
- Create: `.gitignore`
- Create: `.zprofile`

- [ ] **Step 1: Create `.gitignore`**

```
# Tmux plugins (cloned by TPM into symlinked dir)
.config/tmux/plugins/

# Tmux resurrect session data
.config/tmux/resurrect/
```

Note: `.config/tmux/plugins/` is gitignored because TPM clones into the symlinked dotfiles directory (since `~/.config/tmux` → `~/dotfiles/.config/tmux`).

- [ ] **Step 2: Create `.zprofile`**

Adapted from nickjj's `.config/zsh/.zprofile`. Changes:
- Remove the `.xdg.local` sourcing (line 6 of nickjj's version)
- Remove `GNUPGHOME` export (line 30)
- Remove `PASSWORD_STORE_DIR` export (line 34)
- Remove `PASSWORD_STORE_GPG_OPTS` (not present in nickjj's `.zprofile` but was unset in old `.zprofile.local`)
- Fix LESS_TERMCAP bugs from nickjj's original: `$'\e[1;31mm'` → `$'\e[1;31m'`, `$'\e[1;332m'` → `$'\e[1;32m'`
- Remove duplicate `LESS_TERMCAP_ue` assignment (lines 131-132 of nickjj's version are a leftover)
- Change `${XDG_DATA_HOME}/mise/shims` to `${HOME}/.local/share/mise/shims`
- Change `.zprofile.local` sourcing path from `${XDG_CONFIG_HOME}/zsh/.zprofile.local` to `${HOME}/.zprofile.local`

Note: The current `zprofile.local` also contains `PKG_CONFIG_PATH` for librdkafka. This is intentionally dropped — if needed in the future, create a `~/.zprofile.local` file.

```bash
# shellcheck shell=bash

# This file runs once at login.

# Add all local binaries to the system path and make sure they are first.
export PATH="${HOME}/.local/bin:${HOME}/.local/bin/local:${PATH}"

# Configure Mise (programming language run-time manager).
export PATH="${HOME}/.local/share/mise/shims:${PATH}"

# Default programs to run.
export EDITOR="nvim"
export DIFFPROG="nvim -d"

# Add colors to the less and man commands.
export LESS=-R
export LESS_TERMCAP_mb=$'\e[1;31m'    # begin blinking
export LESS_TERMCAP_md=$'\e[1;36m'    # begin bold
export LESS_TERMCAP_us=$'\e[1;32m'    # begin underline
export LESS_TERMCAP_so=$'\e[1;44;33m' # begin standout-mode - info box
export LESS_TERMCAP_me=$'\e[0m'       # end mode
export LESS_TERMCAP_ue=$'\e[0m'       # end underline
export LESS_TERMCAP_se=$'\e[0m'       # end standout-mode

# Configure delta (diffs) defaults.
export DELTA_FEATURES="diff-so-fancy"

# Configure zsh-vi-mode.
export ZVM_NORMAL_MODE_CURSOR="${ZVM_CURSOR_BLOCK}"
export ZVM_INSERT_MODE_CURSOR="${ZVM_CURSOR_BEAM}"

# Load local settings if they exist.
# shellcheck disable=SC1091
if [ -f "${HOME}/.zprofile.local" ]; then . "${HOME}/.zprofile.local"; fi
```

- [ ] **Step 3: Verify zsh can parse `.zprofile`**

Run: `zsh -n /home/bits/dotfiles/.zprofile`
Expected: No output (clean parse)

- [ ] **Step 4: Commit**

```bash
git add .gitignore .zprofile
git commit -m "Add .gitignore and .zprofile for self-contained dotfiles"
```

---

## Task 2: Create .aliases

**Files:**
- Create: `.aliases`

- [ ] **Step 1: Create `.aliases`**

Curated from nickjj's `.config/zsh/.aliases` per spec decisions:
- Keep: `ll`, `la`, `l`, `eza`, `diff`, `pf`, `gi`, `gcl`, `ge`, `drun`, `k`, `tf`, `run`, `755d`, `644f`
- Adapt: `sz` (use `$HOME`), `dt` (use `$HOME/dotfiles`)
- Remove: `SZ`, `lz`, `lp`, `start-rec`, `stop-rec`, `vss`, `vdt`, `ymp3`, `jek`

```bash
# shellcheck shell=bash

alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

alias eza="EZA_ICON_SPACING=2 eza --long --all --octal-permissions --group --group-directories-first --time-style long-iso --header --icons auto"

alias diff="diff --color -u"

alias sz='. ${HOME}/.zprofile && . ${HOME}/.zshrc'
alias dt='cd ${HOME}/dotfiles && nvim .'

alias 755d="find . -type d -exec chmod 755 {} \;"
alias 644f="find . -type f -exec chmod 644 {} \;"

# shellcheck disable=SC2139
alias pf="fzf ${FZF_CTRL_T_OPTS}"

alias gi="git init && git symbolic-ref HEAD refs/heads/main"
alias gcl="git diff --name-only --diff-filter=U"
alias ge="rg '[\p{Emoji}--\p{Ascii}]'"

alias drun='docker container run --rm -it -v "${PWD}":/app -w /app'

alias k="kubectl"
alias tf="terraform"

# A way to define and run tasks in a project. It's like make except it's pure
# Bash so there's no make limitations like not being able to forward arguments.
alias run=./run
```

- [ ] **Step 2: Verify zsh can parse `.aliases`**

Run: `zsh -n /home/bits/dotfiles/.aliases`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add .aliases
git commit -m "Add curated .aliases from nickjj/dotfiles"
```

---

## Task 3: Create .zshrc

**Files:**
- Create: `.zshrc`

- [ ] **Step 1: Create `.zshrc`**

Adapted from nickjj's `.config/zsh/.zshrc`. Changes:
- `HISTFILE` changed from `${DOTFILES_PATH}/.config/zsh/.zsh_history` to `${HOME}/.zsh_history`
- fzf config sourcing changed from `${XDG_CONFIG_HOME}/fzf/config.sh` to `${HOME}/.config/fzf/config.sh`
- Plugin sourcing changed from `${XDG_DATA_HOME}/...` to `${HOME}/.local/share/...`
- Aliases sourcing changed from `${XDG_CONFIG_HOME}/zsh/.aliases` to `${HOME}/.aliases`
- `.zshrc.local` sourcing changed from `${XDG_CONFIG_HOME}/zsh/.zshrc.local` to `${HOME}/.zshrc.local`
- `.aliases.local` sourcing changed from `${XDG_CONFIG_HOME}/zsh/.aliases.local` to `${HOME}/.aliases.local`

```bash
# shellcheck shell=bash

# Load colors so we can access $fg and more.
autoload -U colors && colors

# Disable CTRL-s from freezing your terminal's output.
stty stop undef

# Enable comments when working in an interactive shell.
setopt interactive_comments

# Prompt. Using single quotes around the PROMPT is very important, otherwise
# the git branch will always be empty. Using single quotes delays the
# evaluation of the prompt. Also PROMPT is an alias to PS1.
git_prompt() {
  local branch
  branch="$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3-)"
  local branch_truncated="${branch:0:30}"
  if ((${#branch} > ${#branch_truncated})); then
    branch="${branch_truncated}..."
  fi

  [ -n "${branch}" ] && echo " (${branch})"
}
setopt PROMPT_SUBST
# shellcheck disable=SC2016
PROMPT='%B%{$fg[green]%}%n@%{$fg[green]%}%M %{$fg[blue]%}%~%{$fg[yellow]%}$(git_prompt)%{$reset_color%} %(?.$.%{$fg[red]%}$)%b '
export PROMPT

# History settings.
export HISTFILE="${HOME}/.zsh_history"
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:   "
export HISTSIZE=50000       # History lines stored in mememory.
export SAVEHIST=50000       # History lines stored on disk.
setopt INC_APPEND_HISTORY   # Immediately append commands to history file.
setopt HIST_IGNORE_ALL_DUPS # Never add duplicate entries.
setopt HIST_IGNORE_SPACE    # Ignore commands that start with a space.
setopt HIST_REDUCE_BLANKS   # Remove unnecessary blank lines.

# Use modern completion system. Other than enabling globdots for showing
# hidden files, these ares values in the default generated zsh config.
autoload -U compinit
compinit
_comp_options+=(globdots)

zstyle ":completion:*" menu select=2
zstyle ":completion:*" auto-description "specify: %d"
zstyle ":completion:*" completer _expand _complete _correct _approximate
zstyle ":completion:*" format "Completing %d"
zstyle ":completion:*" group-name ""

# dircolors is a GNU utility that's not on macOS by default. With this not
# being used on macOS it means zsh's complete menu won't have colors.
command -v dircolors >/dev/null 2>&1 && eval "$(dircolors -b)"

# shellcheck disable=SC2016,SC2296
zstyle ":completion:*:default" list-colors '${(s.:.)LS_COLORS}'
zstyle ":completion:*" list-colors ""
zstyle ":completion:*" list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ":completion:*" matcher-list "" "m:{a-z}={A-Z}" "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=* l:|=*"
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ":completion:*" use-compctl false
zstyle ":completion:*" verbose true

# Use Vim key binds.
bindkey -v

# Ensure home / end keys continue to work.
bindkey "\e[1~" beginning-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[7~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[F" end-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[3~" delete-char

# Allows your gpg passphrase prompt to spawn (useful for signing commits).
GPG_TTY="$(tty)"
export GPG_TTY

# zsh-vi-mode-plugin sets a few key binds such as CTRL+r/p/n which may conflict
# with other binds. This ensures fzf and our binds always win. If you choose
# to remove this zsh plugin then each array item can exist normally in zshrc.
zvm_after_init_commands+=(
  ". <(fzf --zsh)"
  "bindkey '^p' history-search-backward"
  "bindkey '^n' history-search-forward"
  "bindkey '^[OA' history-search-backward"
  "bindkey '^[OB' history-search-forward"
  "bindkey '^[[A' history-search-backward"
  "bindkey '^[[B' history-search-forward"
)

# Configure fzf.
# shellcheck disable=SC1091
. "${HOME}/.config/fzf/config.sh"

# zsh-autosuggestions settings.
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Load / source zsh plugins.
# shellcheck disable=SC1091
. "${HOME}/.local/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
# shellcheck disable=SC1091
. "${HOME}/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# shellcheck disable=SC1091
. "${HOME}/.local/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
# shellcheck disable=SC1091
. "${HOME}/.local/share/fzf-tab/fzf-tab.plugin.zsh"

# Ensure colors match by using FZF_DEFAULT_OPTS.
zstyle ":fzf-tab:*" use-fzf-default-opts yes

# Preview file contents when tab completing directories.
zstyle ":fzf-tab:complete:cd:*" fzf-preview "ls --color=always \${realpath}"

# Load aliases if they exist.
# shellcheck disable=SC1091
[ -f "${HOME}/.aliases" ] && . "${HOME}/.aliases"

# Load local settings if they exist.
# shellcheck disable=SC1091
[ -f "${HOME}/.zshrc.local" ] && . "${HOME}/.zshrc.local"
# shellcheck disable=SC1091
if [ -f "${HOME}/.aliases.local" ]; then . "${HOME}/.aliases.local"; fi
```

- [ ] **Step 2: Verify zsh can parse `.zshrc`**

Run: `zsh -n /home/bits/dotfiles/.zshrc`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add .zshrc
git commit -m "Add .zshrc adapted from nickjj/dotfiles for home directory"
```

---

## Task 4: Update .zshrc.local and delete zprofile.local

**Files:**
- Create: `.zshrc.local` (new file with dot prefix, based on existing `zshrc.local`)
- Delete: `zshrc.local` (old file without dot prefix)
- Delete: `zprofile.local`

- [ ] **Step 1: Create `.zshrc.local`**

Based on existing `zshrc.local` with these changes:
- Remove `antigen bundle vi-mode` (loaded natively by base `.zshrc` as `zsh-vi-mode`)
- Remove `antigen bundle zsh-users/zsh-syntax-highlighting` (loaded natively as `fast-syntax-highlighting`)
- Remove `antigen bundle zsh-users/zsh-autosuggestions` (loaded natively)

```bash
# Antigen plugin manager
source /usr/share/zsh-antigen/antigen.zsh

# oh-my-zsh plugins
antigen use oh-my-zsh
antigen bundle git
antigen bundle tmux
antigen bundle z
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found

# External plugins
antigen bundle MichaelAquilina/zsh-you-should-use

# Theme
antigen theme agnoster

# Apply
antigen apply

# Custom aliases
alias claude-yolo="claude --dangerously-skip-permissions"

# Datadog credentials (loaded from password store)
export DD_API_KEY=$(pass show Datadog/dd.datad0g.com_api-key) DD_APP_KEY=$(pass show Datadog/dd.datad0g.com_app-key)
```

- [ ] **Step 2: Delete old files**

```bash
git rm zshrc.local zprofile.local
```

- [ ] **Step 3: Verify zsh can parse `.zshrc.local`**

Run: `zsh -n /home/bits/dotfiles/.zshrc.local`
Expected: No output (clean parse)

- [ ] **Step 4: Commit**

```bash
git add .zshrc.local
git commit -m "Replace zshrc.local with .zshrc.local, remove zprofile.local

Removed duplicate plugin bundles (vi-mode, syntax-highlighting,
autosuggestions) now loaded natively by the base .zshrc.
Deleted zprofile.local as its overrides are no longer needed."
```

---

## Task 5: Create tmux config

**Files:**
- Create: `.config/tmux/tmux.conf`
- Create: `.config/tmux/theme.conf`

- [ ] **Step 1: Create `.config/tmux/theme.conf`**

Inlined from nickjj's `themes/tokyonight-moon/tmux.conf`:

```
set -g mode-style "fg=#82aaff,bg=#3b4261"

set -g pane-border-style "fg=#3b4261"
set -g pane-active-border-style "fg=#4a5480"

set -g status-style "fg=#82aaff,bg=#1e2030"
set -g window-status-style "fg=#828bb8,bg=#1e2030"
set -g window-status-current-style "fg=#82aaff,bg=#1e2030"
```

- [ ] **Step 2: Create `.config/tmux/tmux.conf`**

Copied from nickjj with one change: remove the `clip-copy` override line.

Remove this line:
```
set -g @override_copy_command "clip-copy"
```

Full file (with the line removed):

```
# -----------------------------------------------------------------------------
# This config is targeted for tmux 3.1+.
#
# Read the "Plugin Manager" section (bottom) before trying to use this config!
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global options
# -----------------------------------------------------------------------------

# Set a new prefix / leader key.
set -g prefix `
bind ` send-prefix

# By default tmux starts a login shell which runs your profile each time you
# open a pane or window. This disables that to prevent your profile script from
# running many times instead of once. This can be problematic when you start
# a window manager from your profile (you don't want multiples of them).
set -g default-command "${SHELL}"

# Allow opening multiple terminals to view the same session at different sizes.
setw -g aggressive-resize on

# Remove delay when switching between Vim modes.
set -sg escape-time 1

# Allow Vim's FocusGained to work when your terminal gains focus.
#   Requires Vim plugin: https://github.com/tmux-plugins/vim-tmux-focus-events
set -g focus-events on

# Add a bit more scroll history in the buffer.
set -g history-limit 50000

# Enable color support inside of tmux as well as home, end, etc. keys.
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Send xterm compatible control arrow keys so they work with Vim.
setw -g xterm-keys on

# Ensure window titles get renamed automatically.
setw -g automatic-rename

# Ensure window index numbers get reordered on delete.
set-option -g renumber-windows on

# Start windows and panes index at 1, not 0.
set -g base-index 1
setw -g pane-base-index 1

# Enable full mouse support.
set -g mouse on

# Various colors and styles.
source-file "~/.config/tmux/theme.conf"

set -g status-left ""
set -g status-left-length 0
set -g status-right ""
set -g status-right-length 0

# Display a clock on the bottom right of the status bar.
#set -g status-right "%a %Y-%m-%d %H:%M"
#set -g status-right-length 20

# -----------------------------------------------------------------------------
# Key bindings
# -----------------------------------------------------------------------------

# Unbind default keys.
unbind C-b
unbind '"'
unbind %

# Reload the tmux config.
bind-key r source-file "~/.config/tmux/tmux.conf"

# Split panes.
bind-key b split-window -v
bind-key v split-window -h

# Move around panes with ALT + arrow keys.
bind-key -n M-Up select-pane -U
bind-key -n M-Left select-pane -L
bind-key -n M-Down select-pane -D
bind-key -n M-Right select-pane -R

# -----------------------------------------------------------------------------
# Plugin Manager - https://github.com/tmux-plugins/tpm
# If you didn't use my dotfiles install script you'll need to:
#   Step 1) git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
#   Step 2) Reload tmux if it's already started with `r
#   Step 3) Launch tmux and hit `I (capital i) to fetch any plugins
# -----------------------------------------------------------------------------

# List of plugins.
set -g @plugin "tmux-plugins/tpm"
set -g @plugin "tmux-plugins/tmux-resurrect"
set -g @plugin "tmux-plugins/tmux-yank"

# Customize where resurrect save files are stored.
set -g @resurrect-dir "~/.config/tmux/resurrect"

# Prevent yank from scrolling to the bottom of your buffer after copying.
set -g @yank_action "copy-pipe"

# Initialize TPM (keep this line at the very bottom of your tmux.conf).
run "~/.config/tmux/plugins/tpm/tpm"
```

- [ ] **Step 3: Verify clip-copy is not in tmux.conf**

Run: `grep -c "clip-copy" .config/tmux/tmux.conf || echo "OK"`
Expected: "OK"

- [ ] **Step 4: Commit**

```bash
git add .config/tmux/
git commit -m "Add tmux config with inlined tokyonight-moon theme"
```

---

## Task 6: Create nvim config

**Files:**
- Create: All files under `.config/nvim/` (34 files total)

This is the largest task. All files are copied as-is from nickjj/dotfiles EXCEPT:
1. `theme.lua` — inlined from `themes/tokyonight-moon/nvim.lua` (instead of symlink)
2. `theme-hot-reload.lua` — NOT copied (part of theme switching system)

- [ ] **Step 1: Bulk-copy nvim config from nickjj**

Clone nickjj/dotfiles to a temp directory and copy the nvim config:

```bash
git clone --depth 1 https://github.com/nickjj/dotfiles /tmp/nickjj-dotfiles
cp -r /tmp/nickjj-dotfiles/.config/nvim .config/nvim
rm -rf /tmp/nickjj-dotfiles
```

- [ ] **Step 2: Remove theme-hot-reload.lua and fix theme.lua**

```bash
rm .config/nvim/lua/plugins/theme-hot-reload.lua
```

If `.config/nvim/lua/plugins/theme.lua` is a symlink (it will be broken since the themes dir wasn't copied), remove it — we create the real file in Step 5.

```bash
rm -f .config/nvim/lua/plugins/theme.lua
```

- [ ] **Step 3: Verify theme-hot-reload.lua is gone and theme.lua is removed**

Run: `ls -la .config/nvim/lua/plugins/theme*.lua`
Expected: No files found (both removed)

- [ ] **Step 4: Verify no broken symlinks remain**

Run: `find .config/nvim -type l`
Expected: No output (no symlinks — theme.lua was the only one)

The remaining files are all regular files copied as-is. For reference, the root config files are:

`.config/nvim/init.lua`:
```lua
-- Global variables.
MAP = vim.keymap.set
DEL = vim.keymap.del

-- Bootstrap lazy.nvim, LazyVim and your plugins.
require("config.lazy")
```

`.config/nvim/lazyvim.json`:
```json
{
  "extras": [
    "lazyvim.plugins.extras.coding.luasnip",
    "lazyvim.plugins.extras.coding.mini-surround",
    "lazyvim.plugins.extras.editor.illuminate",
    "lazyvim.plugins.extras.lang.docker",
    "lazyvim.plugins.extras.lang.git",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.markdown",
    "lazyvim.plugins.extras.lang.python",
    "lazyvim.plugins.extras.lang.toml",
    "lazyvim.plugins.extras.lang.yaml",
    "lazyvim.plugins.extras.util.gitui",
    "lazyvim.plugins.extras.util.mini-hipatterns"
  ],
  "install_version": 8,
  "news": {
    "NEWS.md": "11866"
  },
  "version": 8
}
```

`.config/nvim/stylua.toml`:
```toml
indent_type = "Spaces"
indent_width = 2
column_width = 79
```

`.config/nvim/.neoconf.json`:
```json
{
  "neodev": {
    "library": {
      "enabled": true,
      "plugins": true
    }
  },
  "neoconf": {
    "plugins": {
      "lua_ls": {
        "enabled": true
      }
    }
  }
}
```

Already copied in bulk in Step 1. All `lua/config/` and `lua/plugins/` files are present except `theme-hot-reload.lua` (removed in Step 2) and `theme.lua` (removed in Step 2, recreated in Step 5).

- [ ] **Step 5: Create `lua/plugins/theme.lua` (inlined)**

This replaces what was a symlink to `themes/tokyonight-moon/nvim.lua`:

```lua
return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-moon",
		},
	},
}
```

Already copied in bulk in Step 1. All data files, snippets, spell dictionary, queries, and `lazy-lock.json` are present.

- [ ] **Step 6: Verify file count**

Run: `find .config/nvim -type f | wc -l`
Expected: 33 files (34 from nickjj minus `theme-hot-reload.lua`)

- [ ] **Step 7: Commit**

```bash
git add .config/nvim/
git commit -m "Add full LazyVim nvim config from nickjj/dotfiles

Inlined tokyonight-moon theme (was a symlink).
Excluded theme-hot-reload.lua (part of theme switching system)."
```

---

## Task 7: Create fzf and bat configs

**Files:**
- Create: `.config/fzf/config.sh`
- Create: `.config/bat/config`

- [ ] **Step 1: Create `.config/fzf/config.sh`**

Based on nickjj's version with the theme sourcing line replaced by inlined tokyonight-moon colors from `themes/tokyonight-moon/fzf.sh`:

```bash
export FZF_DEFAULT_COMMAND="rg --files --follow --hidden --glob '!.git'"
export FZF_DEFAULT_OPTS="--highlight-line --info=inline-right --ansi --layout=reverse --border=none --bind shift-up:preview-page-up,shift-down:preview-page-down"
export FZF_CTRL_T_OPTS="--height=100% --preview='bat --color=always {}'"

# Tokyonight-moon theme colors (inlined).
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} \
  --color=bg+:#2d3f76 \
  --color=bg:#1e2030 \
  --color=border:#589ed7 \
  --color=fg:#c8d3f5 \
  --color=gutter:#1e2030 \
  --color=header:#ff966c \
  --color=hl+:#65bcff \
  --color=hl:#65bcff \
  --color=info:#545c7e \
  --color=label:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#65bcff \
  --color=query:#c8d3f5:regular \
  --color=scrollbar:#589ed7 \
  --color=separator:#ff966c \
  --color=spinner:#ff007c \
"
```

- [ ] **Step 2: Create `.config/bat/config`**

Copied as-is from nickjj:

```
--theme="base16"
--style="numbers,changes"
```

- [ ] **Step 3: Commit**

```bash
git add .config/fzf/ .config/bat/
git commit -m "Add fzf and bat configs with inlined tokyonight-moon theme"
```

---

## Task 8: Rewrite install.sh

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Rewrite `install.sh`**

Full replacement per spec:

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

- [ ] **Step 2: Verify bash can parse `install.sh`**

Run: `bash -n /home/bits/dotfiles/install.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "Rewrite install.sh for self-contained dotfiles setup"
```

---

## Task 9: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rewrite `README.md`**

```markdown
# dotfiles

Personal development environment dotfiles for Ubuntu.

## Prerequisites

Install [mise](https://mise.jdx.dev):

```sh
curl https://mise.run | sh
```

## Setup

```sh
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Note: `chsh` at the end may prompt for your password to set zsh as the default shell.

## After install

- Restart your shell (or `source ~/.zshrc`)
- Open tmux and press `` ` `` + `I` to install tmux plugins
- Open nvim — plugins will auto-install on first launch
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "Update README for self-contained dotfiles setup"
```

---

## Task 10: Final verification

- [ ] **Step 1: Verify all files are tracked**

Run: `git status`
Expected: Clean working tree (nothing untracked or modified)

- [ ] **Step 2: Verify repo structure matches spec**

Run: `git ls-files | head -60`
Expected: All files from the spec's repo structure diagram are present

- [ ] **Step 3: Verify no stale references remain**

Run: `grep -r "nickjj\|DOTFILES_PATH\|XDG_CONFIG_HOME\|XDG_DATA_HOME\|XDG_STATE_HOME\|ZDOTDIR\|clip-copy\|theme-hot-reload\|xdg\.local" --include="*.sh" --include="*.lua" --include="*.local" --include="*.conf" --include="*.json" --include="*.toml" . | grep -v '.git/' | grep -v 'docs/'`
Expected: No matches (all nickjj/XDG references have been replaced, clip-copy removed, theme-hot-reload excluded)

- [ ] **Step 4: Verify theme-hot-reload.lua is absent**

Run: `test ! -f .config/nvim/lua/plugins/theme-hot-reload.lua && echo "OK"`
Expected: "OK"

- [ ] **Step 5: Verify theme.lua is a regular file (not a symlink)**

Run: `test -f .config/nvim/lua/plugins/theme.lua && ! test -L .config/nvim/lua/plugins/theme.lua && echo "OK"`
Expected: "OK"

- [ ] **Step 6: Verify tmux.conf does not contain clip-copy**

Run: `grep -c "clip-copy" .config/tmux/tmux.conf || echo "OK - not found"`
Expected: "OK - not found"

- [ ] **Step 7: Verify zsh configs parse cleanly**

Run: `zsh -n .zshrc && zsh -n .zprofile && zsh -n .aliases && zsh -n .zshrc.local && echo "All clean"`
Expected: "All clean"

- [ ] **Step 8: Verify bash install script parses cleanly**

Run: `bash -n install.sh && echo "Clean"`
Expected: "Clean"
