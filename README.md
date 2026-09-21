# dotfiles

Personal dotfiles layered on top of [nickjj/dotfriedrice](https://github.com/nickjj/dotfriedrice).

## Setup

```sh
./install.sh
```

This will:
- Clone and run nickjj/dotfriedrice (requires manual interaction)
- Install apt packages the local zsh config needs: `curl`, `zsh-antigen`,
  `command-not-found`
- Symlink the local zsh config (`.zshrc.local`, `.zprofile.local`)
- Link Claude settings (`settings.json`, `CLAUDE.md`)
- Link the nvim plugin overrides (`dd-lsp.lua`)
- Link the tmux overrides and install any missing tmux plugins
- Link the per-project neoconf files for `dd-go` and `dd-source`, if present
- Install tools via mise: golangci-lint, lazygit, rtk
- Set up Claude Code plugin marketplaces, plugins, and MCP servers

## IdeaVim

The `.config/ideavimrc/.ideavimrc` config depends on
[cufarvid/lazy-idea](https://github.com/cufarvid/lazy-idea) to work. To use it:

1. Clone the lazy-idea repo into `~/.lazy-idea`:

   ```sh
   git clone https://github.com/cufarvid/lazy-idea.git ~/.lazy-idea
   ```

2. Symlink `lazy-idea.vim` from that repo to your home directory as
   `~/.lazy-idea.ideavimrc` (the name the config sources):

   ```sh
   ln -s ~/.lazy-idea/lazy-idea.vim ~/.lazy-idea.ideavimrc
   ```

3. Symlink the `.ideavimrc` from this repo to your home directory:

   ```sh
   ln -s "$(pwd)/.config/ideavimrc/.ideavimrc" ~/.ideavimrc
   ```

4. Install the required JetBrains Marketplace plugins (**Settings → Plugins →
   Marketplace**), then restart the IDE. Only **IdeaVim** is bundled; the rest
   ship separately, and without them the corresponding `set`/`WhichKeyDesc_*`
   lines are silently ignored while the plain keybindings still work:

   - **IdeaVim** — the Vim engine itself
   - **IdeaVim-WhichKey** — the key-hint popups (`WhichKeyDesc_*` entries)
   - **IdeaVim-EasyMotion** + **AceJump** — the `s` flash-jump motion

After editing `.ideavimrc`, reload it in the IDE with `<leader>vr` (or restart).
