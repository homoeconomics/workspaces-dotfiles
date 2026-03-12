# dotfiles

Personal dotfiles layered on top of [nickjj/dotfiles](https://github.com/nickjj/dotfiles).

## Setup

### 1. Bootstrap nickjj/dotfiles

Run this first — it requires manual interaction:

```sh
BOOTSTRAP=1 bash <(curl -fsSL https://raw.githubusercontent.com/nickjj/dotfiles/master/install)
```

### 2. Run the install script

```sh
./install.sh
```

This will:
- Install zsh-antigen
- Symlink the local zsh config
- Link Claude settings
- Install golangci-lint via mise
