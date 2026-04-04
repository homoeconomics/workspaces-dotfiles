#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/workspaces-dotfiles"

# --- nickjj/dotfiles ---

# Bootstrap the nickjj/dotfiles repo into /tmp/nickjj-dotfiles/
BOOTSTRAP=1 bash <(curl -fsSL https://raw.githubusercontent.com/nickjj/dotfiles/master/install)

# Customize the install-config before running the nickjj install
cat >> /tmp/nickjj-dotfiles/install-config <<'EOF'

export PACKAGES_APT_SKIP=("git-delta")
export PACKAGES_AUTO_CONFIRM=1
EOF

# Run the nickjj install (requires manual input)
/tmp/nickjj-dotfiles/install

# --- Local dotfiles ---

# 1. Install zsh-antigen (required for our local config)
sudo apt-get update && sudo apt-get install -y curl zsh-antigen

# 2. Symlink our antigen config as .zshrc.local
mkdir -p "$HOME/.config/zsh"
ln -sf "$DOTFILES_DIR/zshrc.local" "$HOME/.config/zsh/.zshrc.local"
ln -sf "$DOTFILES_DIR/zprofile.local" "$HOME/.config/zsh/.zprofile.local"

# 3. Link Claude settings
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
    mv "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak"
fi
ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

# 4. Link nvim plugin overrides
mkdir -p "$HOME/.config/nvim/lua/plugins"
ln -sf "$DOTFILES_DIR/.config/nvim/lua/plugins/dd-lsp.lua" "$HOME/.config/nvim/lua/plugins/dd-lsp.lua"

# 5. Link per-project neoconf files (gopls directory filters)
DATADOG_ROOT="$HOME/go/src/github.com/DataDog"
if [ -d "$DATADOG_ROOT/dd-go" ]; then
    ln -sf "$DOTFILES_DIR/neoconf/dd-go.neoconf.json" "$DATADOG_ROOT/dd-go/.neoconf.json"
fi

DD_SOURCE="$HOME/dd/dd-source"
if [ -d "$DD_SOURCE" ]; then
    ln -sf "$DOTFILES_DIR/neoconf/dd-source.neoconf.json" "$DD_SOURCE/.neoconf.json"
fi

# 6. Install tools via mise
mise use -g golangci-lint
mise use -g lazygit

# 7. Claude Code: marketplaces, plugins, and MCP servers
if command -v claude &>/dev/null; then
  # Marketplaces
  claude plugin marketplace add anthropics/claude-plugins-official
  claude plugin marketplace add DataDog/claude-marketplace

  # Plugins (user scope)
  claude plugin install dd@datadog-claude-plugins -s user
  claude plugin install odp-sql@datadog-claude-plugins -s user
  claude plugin install feature@datadog-claude-plugins -s user
  claude plugin install marketplace-auto-update@datadog-claude-plugins -s user
  claude plugin install code-simplifier@claude-plugins-official -s user
  claude plugin install commit-commands@claude-plugins-official -s user
  claude plugin install gopls-lsp@claude-plugins-official -s user
  claude plugin install superpowers@claude-plugins-official -s user

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
  claude mcp remove datadog-atlassian -s user 2>/dev/null || true
  claude mcp add --transport http datadog-atlassian \
    https://atlassian-mcp-server-834963730936.us-central1.run.app/mcp \
    -s user
else
  echo "claude not found — skipping plugin and MCP setup"
fi

echo "Done! Restart your shell or run: source ~/.config/zsh/.zshrc"
