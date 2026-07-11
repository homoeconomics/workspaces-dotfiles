# dotfiles

Personal dotfiles layered on top of [nickjj/dotfriedrice](https://github.com/nickjj/dotfriedrice).

## Setup

```sh
./install.sh
```

This will:
- Clone and run nickjj/dotfriedrice (requires manual interaction)
- Install zsh-antigen
- Symlink the local zsh config
- Link Claude settings
- Install golangci-lint via mise

## IdeaVim

The `.config/ideavimrc/.ideavimrc` config depends on
[cufarvid/lazy-idea](https://github.com/cufarvid/lazy-idea) to work. To use it:

1. Clone the lazy-idea repo:

   ```sh
   git clone https://github.com/cufarvid/lazy-idea.git
   ```

2. Symlink `lazy-idea.vim` from that repo to your home directory as
   `~/.lazy-idea.ideavimrc` (the name the config sources):

   ```sh
   ln -s /path/to/lazy-idea/lazy-idea.vim ~/.lazy-idea.ideavimrc
   ```

3. Symlink the `.ideavimrc` from this repo to your home directory:

   ```sh
   ln -s "$(pwd)/.config/ideavimrc/.ideavimrc" ~/.ideavimrc
   ```
