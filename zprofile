#!/bin/zsh

# Default programs:

export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="brave"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_BIN="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"


export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export HISTFILE="$XDG_DATA_HOME"/zsh/history/.zsh_history
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export LESSHISTFILE="-"
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export PYLINTHOME="$XDG_CACHE_HOME"/pylint
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/pythonrc
export TEXMFVAR=$XDG_CACHE_HOME/texlive/texmf-var
#source $XDG_DATA_BIN'/virtualenvwrapper.sh'
