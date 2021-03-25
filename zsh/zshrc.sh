source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/history.zsh
source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/key-bindings.zsh
source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/completion.zsh
source ~/dotfiles/zsh/plugins/vi-mode.plugin.zsh
source ~/dotfiles/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dotfiles/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/dotfiles/zsh/keybindings.sh
source ~/dotfiles/zsh/zsh_functions.sh
source ~/dotfiles/zsh/prompt.sh
source ~/dotfiles/zsh/plugins/fixls.zsh


# Vars
SAVEHIST=1000
setopt inc_append_history # To save every command before it is executed
setopt share_history # setopt inc_append_history
git config --global push.default current

# Aliases
alias tmux='tmux -f "$HOME/dotfiles/tmux/tmux.conf"'
alias v="nvim -p"
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias r='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias gitfind='git checkout --track $(git branch -r | fzf) && git pull'

alias colombia="curl https://corona-stats.online/co"

alias translate="spanish_translate"

alias stopwatch="stopwatch"
alias speed_test="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

alias vpn_chile="connect_to_vpn chile"
alias vpn_florida="connect_to_vpn florida"
alias vpn_mexico="connect_to_vpn mexico"
alias vpn_netflix="connect_to_vpn netflix"
alias vpn_torrent_california="connect_to_vpn torrent_california"
alias vpn_torrent_canada="connect_to_vpn torrent_canada"
alias vpn_amazon_prime="connect_to_vpn amazon_prime"
alias screenshot="flameshot gui"

alias chill="random_music_track chill"
alias classical="random_music_track classical"
alias coltrane="mpv ~/music/john_coltrane/coltrane.mp3"
alias punk="random_track_from_directory punk"
alias where_am_i="curl -s 'ipinfo.io' | jq '.city, .country, .ip'"
alias spanish="trans -I es:en"
alias english="trans -I en:es"
alias latin="trans -I la:en"

alias english-latin="trans -I en:la"
alias french="tans -I fr:en"

alias pi='ssh pi@192.168.1.120'
alias define='sdcv'
alias local_db='pgcli postgres://postgres:postgres@localhost:5432'

# Vim Mode in Zsh
bindkey -v

# For vim mappings:
	stty -ixon

autoload -U compinit

plugins=(
	docker
)

for plugin ($plugins); do
    fpath=(~/dotfiles/zsh/plugins/oh-my-zsh/plugins/$plugin $fpath)
done

compinit

# Fix for arrow-key searching
# start typing + [Up-Arrow] - fuzzy find history forward
if [[ "${terminfo[kcuu1]}" != "" ]]; then
	autoload -U up-line-or-beginning-search
	zle -N up-line-or-beginning-search
	bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi

# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${terminfo[kcud1]}" != "" ]]; then
	autoload -U down-line-or-beginning-search
	zle -N down-line-or-beginning-search
	bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

export PATH=$PATH:$HOME/dotfiles/utils
export PATH="$HOME/.local/bin:$PATH"
#this is for python plugins to work with coc
export PATH="$PATH:/usr/bin/python"
export VIRTUAL_ENV_DISABLE_PROMPT=1
if systemctl -q is-active graphical.target && [[ ! $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec startx ~/dotfiles/xinitrc_dwm
elif systemctl -q is-active graphical.target && [[ ! $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then
  exec startx ~/dotfiles/xinitrc_xfce
fi

#mkdir -p /tmp/log
