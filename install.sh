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

echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install build-essential procps curl file git

echo "Installing homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing fzf"
brew update
brew install fzf

# Install antigen if not already installed
ANTIGEN_DIR="$HOME/.antigen"
if [ ! -f "$ANTIGEN_DIR/antigen.zsh" ]; then
    echo "Installing antigen..."
    mkdir -p "$ANTIGEN_DIR"

    # Download antigen from the source
    if ! curl -fsSL git.io/antigen -o "$ANTIGEN_DIR/antigen.zsh.tmp"; then
        echo "Error: Failed to download antigen from git.io. Aborting antigen installation."
        rm -f "$ANTIGEN_DIR/antigen.zsh.tmp"
        exit 1
    fi

    # Verify the file is not empty
    if [ -s "$ANTIGEN_DIR/antigen.zsh.tmp" ]; then
        mv "$ANTIGEN_DIR/antigen.zsh.tmp" "$ANTIGEN_DIR/antigen.zsh"
        echo "Antigen installed successfully."
    else
        echo "Error: Downloaded antigen file is empty. Aborting antigen installation."
        rm -f "$ANTIGEN_DIR/antigen.zsh.tmp"
        exit 1
    fi
else
    echo "Antigen is already installed."
fi

# Define dotfiles path
DOTFILES_PATH="$HOME/dotfiles"

# Download .tmux.conf from gpakosz/.tmux repository
echo "Downloading .tmux.conf from gpakosz/.tmux repository..."
TMUX_CONF_URL="https://raw.githubusercontent.com/gpakosz/.tmux/master/.tmux.conf"
TMUX_CONF_PATH="$DOTFILES_PATH/.tmux.conf"

if ! curl -fsSL "$TMUX_CONF_URL" -o "$TMUX_CONF_PATH.tmp"; then
    echo "Error: Failed to download .tmux.conf from GitHub. Keeping existing file if present."
    rm -f "$TMUX_CONF_PATH.tmp"
    exit 1
else
    # Verify the file is not empty
    if [ -s "$TMUX_CONF_PATH.tmp" ]; then
        mv "$TMUX_CONF_PATH.tmp" "$TMUX_CONF_PATH"
        echo ".tmux.conf downloaded successfully."
    else
        echo "Error: Downloaded .tmux.conf file is empty. Keeping existing file if present."
        rm -f "$TMUX_CONF_PATH.tmp"
        exit 1
    fi
fi

# Symlink dotfiles to the root within your workspace or append content if file exists
echo "Processing dotfiles!"
find "$DOTFILES_PATH" -type f -path "$DOTFILES_PATH/.*" | grep -v "/.git/" | grep -v "/.git$" |
while read df; do
    link=${df/$DOTFILES_PATH/$HOME}
    mkdir -p "$(dirname "$link")"

    # Check if the target file already exists and is not a symlink
    if [ -f "$link" ] && [ ! -L "$link" ]; then
        # Append content to the existing file
        echo "Appending content from $df to existing file $link"
        cat "$df" >> "$link"
    else
        # Create a symlink if the file doesn't exist or is already a symlink
        ln -sf "$df" "$link"
        echo "Linked: $df -> $link"
    fi
done
echo "Processed dotfiles!"
