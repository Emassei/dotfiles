#!/bin/sh
# Shared hook: acpid fires it on lid open/close, udev on display
# hotplug (95-monitor-hotplug.rules). Reruns the lid-aware layout.
# startx puts the X cookie in /tmp/serverauth.*, fresh path each boot.
sleep 1   # give the connector a beat to publish its EDID after hotplug
auth=$(ls -t /tmp/serverauth.* 2>/dev/null | head -1)
exec su ernie -c "DISPLAY=:0 XAUTHORITY=$auth /home/ernie/dotfiles/utils/twoscreens"
