time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

#if command -v tmux>/dev/null; then
	#[ -z $TMUX ] && exec tmux
#else
	#echo "tmux not installed. Run ./deploy to configure dependencies"
#fi

echo "What up Nerd? Write in your stupid journal"
#(cd ~/dotfiles && time_out 3 git pull && time_out 3 git submodule update --init --recursive)
#(cd ~/dotfiles && git pull && git submodule update --init --recursive)
source ~/dotfiles/zsh/zshrc.sh
