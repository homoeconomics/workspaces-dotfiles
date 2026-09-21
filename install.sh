#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/workspaces-dotfiles"

# --- XDG base directories ---

# Resolve these once, here, and use them for every path below — including the
# values baked into dotfriedrice-config. A box may already provision them
# (workspace images point them at /var/...), so honor what's set and fall back
# to the spec defaults otherwise. Getting this wrong is silent: dotfriedrice's
# .zshrc sources "${XDG_CONFIG_HOME}/zsh/.zshrc.local", so overrides linked to
# the wrong prefix are simply never read.
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME

# --- tmux ~/.config compatibility shim ---

# dotfriedrice installs its tmux files under $XDG_CONFIG_HOME/tmux, but the
# tmux.conf it ships hardcodes a literal ~/.config/tmux for theme.conf, the
# @resurrect-dir, the reload binding and — fatally — the tpm init on its last
# line. When XDG_CONFIG_HOME points elsewhere all four dangle, and `run` is a
# silent no-op for a missing command, so tpm never sets
# TMUX_PLUGIN_MANAGER_PATH. Every later `tpm/bin/install_plugins` then dies:
#
#     unknown variable: TMUX_PLUGIN_MANAGER_PATH
#     FATAL: Tmux Plugin Manager not configured in tmux.conf
#
# That kills dotfriedrice's own install_tmux_plugins step under `set -o
# errexit`, taking the rest of its run (themes, ssh key, healthcheck) with it —
# so this has to be in place BEFORE ./dotfriedrice, not just before step 5.
#
# Bridge the two locations with a symlink instead of patching the vendored
# tmux.conf, which would conflict on every `git pull` in ~/dotfriedrice.
#
# Refuse to proceed if something real is already sitting there. `ln -sfn` would
# NOT fail on a real directory — it silently creates ~/.config/tmux/tmux inside
# it — leaving tmux reading a half-populated dir with no visible error.
if [ "$XDG_CONFIG_HOME" != "$HOME/.config" ]; then
  if [ -e "$HOME/.config/tmux" ] && [ ! -L "$HOME/.config/tmux" ]; then
    echo "ERROR: $HOME/.config/tmux exists and is not a symlink." >&2
    echo "       Move it aside so it can point at $XDG_CONFIG_HOME/tmux." >&2
    exit 1
  fi
  mkdir -p "$XDG_CONFIG_HOME/tmux" "$HOME/.config"
  ln -sfn "$XDG_CONFIG_HOME/tmux" "$HOME/.config/tmux"
fi

# --- nickjj/dotfriedrice ---

DOTFRIEDRICE_PATH="$HOME/dotfriedrice"

if [ ! -d "$DOTFRIEDRICE_PATH" ]; then
  # Clone the repo manually so we can customize dotfriedrice-config before
  # running ./dotfriedrice. The upstream `bootstrap` script clones and execs
  # the installer in one go with no hook to edit the config in between.
  sudo apt-get update && sudo apt-get install -y git
  git clone https://github.com/nickjj/dotfriedrice "$DOTFRIEDRICE_PATH"

  # Seed dotfriedrice-config from the example, then append our overrides
  cp "$DOTFRIEDRICE_PATH/dotfriedrice-config.example" "$DOTFRIEDRICE_PATH/dotfriedrice-config"
  cat >> "$DOTFRIEDRICE_PATH/dotfriedrice-config" <<'EOF'
export PACKAGES_APT_SKIP=("git-delta" "du-dust")
export PACKAGES_AUTO_CONFIRM=1
EOF

  # Pin the XDG dirs to the values resolved above. dotfriedrice-config.example
  # assigns these unconditionally (no :- fallback) and dotfriedrice sources it,
  # so it would otherwise clobber whatever the box provisioned; appending after
  # the example's block wins. Note this heredoc is deliberately UNQUOTED so the
  # paths are expanded now and written literally — a "${XDG_CONFIG_HOME:-...}"
  # in this file would be a no-op, since the example's own assignment has
  # already overwritten the ambient value by the time it would be evaluated.
  cat >> "$DOTFRIEDRICE_PATH/dotfriedrice-config" <<EOF
export XDG_CACHE_HOME="$XDG_CACHE_HOME"
export XDG_CONFIG_HOME="$XDG_CONFIG_HOME"
export XDG_DATA_HOME="$XDG_DATA_HOME"
export XDG_STATE_HOME="$XDG_STATE_HOME"
EOF

  # Run the nickjj installer (requires manual input)
  (cd "$DOTFRIEDRICE_PATH" && ./dotfriedrice)
else
  echo "nickjj/dotfriedrice already installed at $DOTFRIEDRICE_PATH — skipping"
fi

# --- Local dotfiles ---

# 1. Install apt packages our local zsh config needs:
#    - curl, zsh-antigen: required by zshrc.local's antigen setup
#    - command-not-found: backs the oh-my-zsh command-not-found plugin. The
#      package installs an apt hook that builds the command->package database on
#      the next `apt update`, so we refresh again afterwards to populate it.
sudo apt-get update && sudo apt-get install -y curl zsh-antigen command-not-found
sudo apt-get update

# 2. Symlink our antigen config as .zshrc.local
mkdir -p "$XDG_CONFIG_HOME/zsh"
ln -sf "$DOTFILES_DIR/zshrc.local" "$XDG_CONFIG_HOME/zsh/.zshrc.local"
ln -sf "$DOTFILES_DIR/zprofile.local" "$XDG_CONFIG_HOME/zsh/.zprofile.local"

# 3. Link Claude settings
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
    mv "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak"
fi
ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
ln -sf "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# 4. Link nvim plugin overrides, resolving through the $XDG_CONFIG_HOME/nvim
#    symlink dotfriedrice creates. If this fails don't `mkdir -p` the parent:
#    a real dir there shadows dotfriedrice's config and it can't undo that.
ln -sf "$DOTFILES_DIR/.config/nvim/lua/plugins/dd-lsp.lua" "$XDG_CONFIG_HOME/nvim/lua/plugins/dd-lsp.lua"

# 5. Link tmux overrides over dotfriedrice's, then install any not-yet-cloned
#    plugins (tmux-continuum for automatic session save + restore). Mirrors
#    dotfriedrice's own install_tmux_plugins; install_plugins is headless and
#    reads the @plugin list (following source-file), cloning only what's missing.
#    Unlike nvim above, mkdir here is safe: dotfriedrice symlinks tmux.conf
#    *inside* this directory rather than symlinking the directory itself, so
#    creating it can't shadow anything.
mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -sf "$DOTFILES_DIR/.config/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
"$XDG_CONFIG_HOME/tmux/plugins/tpm/bin/install_plugins"

# 6. Link per-project neoconf files (gopls directory filters)
DATADOG_ROOT="$HOME/go/src/github.com/DataDog"
if [ -d "$DATADOG_ROOT/dd-go" ]; then
    ln -sf "$DOTFILES_DIR/neoconf/dd-go.neoconf.json" "$DATADOG_ROOT/dd-go/.neoconf.json"
fi

DD_SOURCE="$HOME/dd/dd-source"
if [ -d "$DD_SOURCE" ]; then
    ln -sf "$DOTFILES_DIR/neoconf/dd-source.neoconf.json" "$DD_SOURCE/.neoconf.json"
fi

# 7. Install tools via mise
mise use -g golangci-lint
mise use -g lazygit
mise use -g rtk

# 8. Claude Code: marketplaces, plugins, and MCP servers
if command -v claude &>/dev/null; then
  # Marketplaces
  claude plugin marketplace add anthropics/claude-plugins-official
  claude plugin marketplace add DataDog/claude-marketplace
  claude plugin marketplace add DietrichGebert/ponytail

  # Plugins (user scope)
  claude plugin install dd@datadog-claude-plugins -s user
  claude plugin install odp-sql@datadog-claude-plugins -s user
  claude plugin install marketplace-auto-update@datadog-claude-plugins -s user
  claude plugin install diagrams@datadog-claude-plugins -s user
  claude plugin install coach@datadog-claude-plugins -s user
  claude plugin install code-simplifier@claude-plugins-official -s user
  claude plugin install commit-commands@claude-plugins-official -s user
  claude plugin install gopls-lsp@claude-plugins-official -s user
  claude plugin install superpowers@claude-plugins-official -s user
  claude plugin install ponytail@ponytail -s user

  # MCP servers (HTTP, user scope)
  # Remove-then-add to stay idempotent (claude mcp add errors on duplicates)
  claude mcp remove odp-staging -s user 2>/dev/null || true
  claude mcp add --transport http odp-staging \
    https://odp-mcp-server.mcp.us1.staging.dog/internal/unstable/odp-mcp-server/mcp \
    -s user
  claude mcp remove datadog-staging -s user 2>/dev/null || true
  claude mcp add --transport http datadog-staging \
    "https://mcp.datad0g.com/api/unstable/mcp-server/mcp" \
    -s user
  claude mcp remove datadog-prod -s user 2>/dev/null || true
  claude mcp add --transport http datadog-prod \
    "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp?toolsets=core,software-delivery,error-tracking,profiling,widgets,data-observability" \
    -s user
  claude mcp remove atlassian -s user 2>/dev/null || true
  claude mcp add --transport http -s user atlassian \
    https://mcp.atlassian.com/v1/mcp/authv2
  claude mcp remove datadog-google-workspace -s user 2>/dev/null || true
  claude mcp add --transport http datadog-google-workspace \
    https://google-workspace-mcp-server-834963730936.us-central1.run.app/mcp \
    -s user
  claude mcp remove slack -s user 2>/dev/null || true
  claude mcp add --transport http slack \
    --client-id 1601185624273.8899143856786 --callback-port 3118 \
    https://mcp.slack.com/mcp \
    -s user
else
  echo "claude not found — skipping plugin and MCP setup"
fi

echo "Done! Restart your shell or run: source $XDG_CONFIG_HOME/zsh/.zshrc"
