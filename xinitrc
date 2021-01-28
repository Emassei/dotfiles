#!/bin/sh

setxkbmap -option "caps:swapescape"
xbindkeys -f $HOME/dotfiles/xbindkeys
xrdb -merge $HOME/dotfiles/Xresources
feh --bg-fill --randomize --no-fehbg ~/media/pictures/wallpaper/vaporwave/* &
flameshot &
dunst &
picom &
dwm

