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
