time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

#if command -v tmux >/dev/null 2>&1 && [ "${display}" ]; then
    ## if not inside a tmux session, and if no session is started, start a new session
    #[ -z "${tmux}" ] && (tmux attach >/dev/null 2>&1 || tmux)
#fi
vpn_scan
#echo "What up Nerd? Write in your stupid journal!"
#(cd ~/dotfiles && time_out 3 git pull && time_out 3 git submodule update --init --recursive)
#(cd ~/dotfiles && git pull && git submodule update --init --recursive)
source ~/dotfiles/zsh/zshrc.sh
