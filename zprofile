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
export GOPATH="$XDG_DATA_HOME"/go

# Keep $HOME clean: relocate tool dirs to XDG paths
export XDG_STATE_HOME="$HOME/.local/state"
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AZURE_CONFIG_DIR="$XDG_DATA_HOME"/azure
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/password-store
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGet/packages
export PYTHON_HISTORY="$XDG_STATE_HOME"/python_history
export MYSQL_HISTFILE="$XDG_STATE_HOME"/mysql_history
export PSQL_HISTORY="$XDG_STATE_HOME"/psql_history
export SQLITE_HISTORY="$XDG_STATE_HOME"/sqlite_history
export MYCLI_HISTFILE="$XDG_STATE_HOME"/mycli_history
export WGETRC="$XDG_CONFIG_HOME"/wgetrc
#source $XDG_DATA_BIN'/virtualenvwrapper.sh'

# Google Cloud SDK (installed via official installer, not AUR)
if [ -d "$HOME/.local/opt/google-cloud-sdk" ]; then
    source "$HOME/.local/opt/google-cloud-sdk/path.zsh.inc"
    source "$HOME/.local/opt/google-cloud-sdk/completion.zsh.inc"
fi
