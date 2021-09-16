# git
	function git_prepare() {
		if [ -n "$BUFFER" ];
			then
				BUFFER="git add -A && git commit -m \"$BUFFER\" && git push"
		fi

		if [ -z "$BUFFER" ];
			then
				BUFFER="git add -A && git commit -v && git push"
		fi

		zle accept-line
	}
	zle -N git_prepare
	bindkey "^g" git_prepare


# Edit and rerun
	function edit_and_run() {
		BUFFER="fc"
		zle accept-line
	}
	zle -N edit_and_run
	bindkey "^v" edit_and_run


# In the above setting, -s option is used to translate the input string to output string so that when you press the shortcut, it is replaced with the command you want to run. ^M or \n is used to represent the Enter key so that the command is run automatically.
bindkey -s '^f' 'nvim $(fzf)^M'
