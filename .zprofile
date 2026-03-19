# shellcheck shell=bash

# This file runs once at login.

# Add all local binaries to the system path and make sure they are first.
export PATH="${HOME}/.local/bin:${HOME}/.local/bin/local:${PATH}"

# Configure Mise (programming language run-time manager).
export PATH="${HOME}/.local/share/mise/shims:${PATH}"

# Default programs to run.
export EDITOR="nvim"
export DIFFPROG="nvim -d"

# Add colors to the less and man commands.
export LESS=-R
export LESS_TERMCAP_mb=$'\e[1;31m'    # begin blinking
export LESS_TERMCAP_md=$'\e[1;36m'    # begin bold
export LESS_TERMCAP_us=$'\e[1;32m'    # begin underline
export LESS_TERMCAP_so=$'\e[1;44;33m' # begin standout-mode - info box
export LESS_TERMCAP_me=$'\e[0m'       # end mode
export LESS_TERMCAP_ue=$'\e[0m'       # end underline
export LESS_TERMCAP_se=$'\e[0m'       # end standout-mode

# Configure delta (diffs) defaults.
export DELTA_FEATURES="diff-so-fancy"

# Configure zsh-vi-mode.
export ZVM_NORMAL_MODE_CURSOR="${ZVM_CURSOR_BLOCK}"
export ZVM_INSERT_MODE_CURSOR="${ZVM_CURSOR_BEAM}"

# Load local settings if they exist.
# shellcheck disable=SC1091
if [ -f "${HOME}/.zprofile.local" ]; then . "${HOME}/.zprofile.local"; fi
