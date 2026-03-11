#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
NICKJJ_DOTFILES="$HOME/.nickjj-dotfiles"

# 1. Install zsh-antigen (required for our local config)
sudo apt-get update && sudo apt-get install -y zsh-antigen

# 2. Clone nickjj's dotfiles if not present
if [ ! -d "$NICKJJ_DOTFILES" ]; then
    git clone https://github.com/nickjj/dotfiles.git "$NICKJJ_DOTFILES"
fi

# 3. Run nickjj's install script
cd "$NICKJJ_DOTFILES"
./install

# 4. Symlink our antigen config as .zshrc.local
mkdir -p "$HOME/.config/zsh"
ln -sf "$DOTFILES_DIR/zshrc.local" "$HOME/.config/zsh/.zshrc.local"

# 5. Link Claude settings
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
    mv "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak"
fi
ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

# 6. Install golangci-lint via mise
mise use -g golangci-lint

echo "Done! Restart your shell or run: source ~/.config/zsh/.zshrc"
