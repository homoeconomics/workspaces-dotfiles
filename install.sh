#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

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

# 4. Install tools via mise
mise use -g golangci-lint
mise use -g lazygit

echo "Done! Restart your shell or run: source ~/.config/zsh/.zshrc"
