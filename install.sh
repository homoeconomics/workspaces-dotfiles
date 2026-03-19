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

# --- Install mise if not present ---
if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
fi
eval "$(~/.local/bin/mise activate bash)"

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
