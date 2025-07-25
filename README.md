# Example dotfiles repo for initializing workspaces

This repository is supposed to be used as a template for dotfiles you
would like to have added to each new workspace that is created.  To use
it, first you must create a new personal repository with this specified
as a template. Go to http://github.com/new and initialize the repo as
follows

![Setting up dotfiles](docs/new_repo_screen.png)

Alternatively, [this link](https://github.com/new?owner=@me&template_name=workspaces-dotfiles-template&template_owner=DataDog&name=dotfiles&visibility=public&description=Home+directory+initialization+for+workspaces)
will pre-fill the form with valid values.

Once `Create repository` has been selected, clone the new repository locally, modify
it as appropriate following comments in the provided files. At the very least,
replace text within `<Angle Brackets>` with values more appropriate to you.
Commit the changes, push and supply the url of the repository to the `--dotfiles`
parameter the next time you create a workspace.  This can also be persisted in the
workspaces configuration file.

## Ubuntu Compatibility Note

The `install.sh` script has been updated to work on Ubuntu machines. However, please note that some of the aliases and configurations in the dotfiles (particularly in `.mix-aliases` and `.mix-exports`) are macOS-specific and may not work on Ubuntu. You may want to review and modify these files to remove or replace macOS-specific commands with Ubuntu-equivalent commands if you're primarily using Ubuntu workspaces.

Some examples of macOS-specific commands in the dotfiles:
- `pbcopy` (use `xclip` or `xsel` on Ubuntu)
- `defaults write` commands for macOS preferences
- Homebrew-related commands and paths
- macOS-specific paths like `/System/Library/...`

See [Getting Started with Workspaces Personalization](https://datadoghq.atlassian.net/wiki/spaces/DEVX/pages/3068528729/Getting+Started+with+Workspaces+Personalization)
for details.
