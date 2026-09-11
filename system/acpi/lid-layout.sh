#!/bin/sh
# acpid lid hook → rerun the lid-aware screen layout as ernie.
# startx puts the X cookie in /tmp/serverauth.*, fresh path each boot.
auth=$(ls -t /tmp/serverauth.* 2>/dev/null | head -1)
exec su ernie -c "DISPLAY=:0 XAUTHORITY=$auth /home/ernie/dotfiles/utils/twoscreens"
