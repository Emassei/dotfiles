#!/bin/sh

setxkbmap -option "caps:swapescape"
xbindkeys -f "$XDG_CONFIG_HOME"/xbindkeys
xrdb -merge ~/.config/X11/Xresources
feh --bg-fill --randomize --no-fehbg ~/media/pictures/wallpaper/vaporwave/* &
flameshot &
dunst &
picom &
dwm

