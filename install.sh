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
sudo apt-get update -y
sudo apt-get install -y build-essential procps curl file git

if [ ! -d /home/linuxbrew ]; then
    echo "Installing homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi
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

# Installing .tmux
if [ ! -d ~/.tmux ]; then
    cd
    git clone --single-branch https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf .tmux.conf
    ln -s -f .tmux/.tmux.conf.local .tmux.conf.local
    cat >> .tmux/.tmux.conf.local << EOF
# Remove SSH_AUTH_SOCK to disable tmux automatically resetting the variable
set -g update-environment "DISPLAY KRB5CCNAME SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"
# Use a symlink to look up SSH authentication
setenv -g SSH_AUTH_SOCK \$HOME/.ssh/ssh_auth_sock
EOF
else
    echo ".tmux already installed."
fi

# Define dotfiles path
DOTFILES_PATH="$HOME/dotfiles"
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
