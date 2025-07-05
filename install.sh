#!/usr/bin/env bash
# ensure you set the executable bit on the file with `chmod u+x install.sh`

# If you remove the .example extension from the file, once your workspace is created and the contents of this
# repo are copied into it, this script will execute.  This will happen in place of the default behavior of the workspace system,
# which is to symlink the dotfiles copied from this repo to the home directory in the workspace.
#
# Why would one use this file in stead of relying upon the default behavior?
#
# Using this file gives you a bit more control over what happens.
# If you want to do something complex in your workspace setup, you can do that here.
# Also, you can use this file to automatically install a certain tool in your workspace, such as vim.
#
# Just in case you still want the default behavior of symlinking the dotfiles to the root,
# we've included a block of code below for your convenience that does just that.

set -euo pipefail

# Function to install packages if they're not already installed
install_package() {
    if ! dpkg -l "$1" &> /dev/null; then
        echo "Installing $1..."
        sudo apt-get install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install required packages
install_package curl
install_package git
install_package zsh

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh!"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "Installed oh-my-zsh!"
else
    echo "oh-my-zsh is already installed."
fi

# Install oh-my-tmux if not already installed
TMUX_PATH="$HOME/tmux"
if [ ! -d "$TMUX_PATH" ]; then
    echo "Installing oh-my-tmux!"
    git clone --single-branch https://github.com/gpakosz/.tmux.git "$TMUX_PATH"
    mkdir -p ~/.config/tmux
    ln -sf "$TMUX_PATH/.tmux.conf" ~/.config/tmux/tmux.conf
    cp "$TMUX_PATH/.tmux.conf.local" ~/.config/tmux/tmux.conf.local
    echo "Installed oh-my-tmux!"
else
    echo "oh-my-tmux is already installed."
fi

# Determine the correct dotfiles path
# If this script is in the dotfiles directory, use its parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.zshrc" ] && [ -f "$SCRIPT_DIR/.mix-aliases" ]; then
    DOTFILES_PATH="$SCRIPT_DIR"
else
    # Fall back to the default location
    DOTFILES_PATH="$HOME/dotfiles"
fi

echo "Using dotfiles from: $DOTFILES_PATH"

# Symlink dotfiles to the root within your workspace
echo "Symlinking dotfiles!"
find "$DOTFILES_PATH" -type f -path "$DOTFILES_PATH/.*" | grep -v "/.git/" | grep -v "/.git$" |
while read df; do
    link=${df/$DOTFILES_PATH/$HOME}
    mkdir -p "$(dirname "$link")"
    ln -sf "$df" "$link"
    echo "Linked: $df -> $link"
done
echo "Symlinked dotfiles!"

# Set zsh as the default shell if it's not already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as the default shell..."
    chsh -s "$(which zsh)"
    echo "Zsh is now the default shell. Please log out and log back in for changes to take effect."
fi
