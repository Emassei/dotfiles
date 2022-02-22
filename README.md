# Dotfiles, a mix of parth, luke smith and me.

## Installation

Once the repo is cloned, execute the deploy script:
```
./deploy
```

This script guides you through the following:

1. Checks to see if you have software installed.
2. Installs them using your default package manager if you don't have some of them installed.
3. Checks to see if your default shell is zsh.
4. Sets zsh to your default shell.

Pretty convenient for configuring new servers.

# Summary of Changes

## Basic runtime opperations

All default dotfiles (`.zshrc`, `.vimrc`, etc) source something within the dotfiles repository. This helps separate changes that are synced across all your machines with system specific changes.


### Prompt

The prompt takes on the form:

```
[plugin, plugin, ...]:
```

Each plugin is sensitive to where you are and what you're doing, they reveal themselves when it's contextually relevant. Plugins include:

* `PWD plugin`: always present, tells you where you are. Always the first plugin.
* `Status code plugin`: appears anytime a program returns with a non-zero status code. Tells you what status code the program completed with.
* `Git plugin`: appears when you're in a git repository. Tells you what branch you're on, and how many files have been changed since the last commit.
* `Sudo plugin`: tells you when you can sudo without a password. Or when you're logged in as root.
* `Time plugin`: appears when a program took more than 1s to execute. Tells you how long it took to execute.
* `PID plugin`: appears when you background a task. Tells you what the PID of the task is.


### Plugins

* [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): Searches your history while you type and provides suggestions.
* [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/tree/ad522a091429ba180c930f84b2a023b40de4dbcc): Provides fish style syntax highlighting for zsh.
* [ohmyzsh](https://github.com/robbyrussell/oh-my-zsh/tree/291e96dcd034750fbe7473482508c08833b168e3): Borrowed things like tab completion, fixing ls, tmux's vi-mode plugin.
* [vimode-zsh](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/vi-mode) allows you to hit `esc` and navigate the current buffer using vim movement keys.

## [Vim](https://en.wikipedia.org/wiki/Vim_(text_editor))

* Leader key has ben remapped to `,`

## [Tmux](https://en.wikipedia.org/wiki/Tmux)

* Ctrl-B has been remapped to the backtick character (&#96;). If you want to type the actual backtick character (&#96;) itself, just hit the key twice.
* `%` has been remapped to `v`.
* Use vim movement keys for moving between panes.
* Copy buffer is coppied to xclip.
* Status bar tells you date, time, user, and hostname. Especially useful with nested ssh sessions.

### Local Plugins outside of the dot files

* Install vimplug from https://github.com/junegunn/vim-plug, and then run :InstallPlug in the vim console
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
* For arch you need to run ./install.sh --clang-completer --system-libclang

## Port forward a ftp server

```
#Install ftp locally, assuming you are using a pi

sudo apt install proftpd

sudo vim /etc/proftpd/proftpd.conf
# add the following to the conf
ServerName "RaspberryPi"
# create a local directory for the service to use
DefaultRoot /home/pi/downloads/share
# You might have to create a user specifically for this purpose


sudo service proftpd reload
sudo service proftpd status

# Port Forwarding

# add a port forwarding for the local ip of the pi

# the external ports:
# 20,21
# and the internal port:
# 21
# using both udp and tcp
```

## For mycli client pspg pager add to .my.cnf, this will make pspg the default pager
```
[client]
pager = pspg -X --quit-if-one-screen
```


