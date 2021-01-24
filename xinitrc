#!/bin/sh

setxkbmap -option "caps:swapescape"
xbindkeys -f "$XDG_CONFIG_HOME"/xbindkeys
xrdb -merge $HOME/dotfiles/Xresources
feh --bg-fill --randomize --no-fehbg ~/media/pictures/wallpaper/vaporwave/* &
flameshot &
dunst &
picom &
dwm

