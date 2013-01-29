#!/bin/sh

dmode="$(cat /sys/class/drm/card0-VGA-1/status)"

# This script is called as root and without X knowledge
export DISPLAY=:0.0

if [ "${dmode}" = disconnected ]; then
	xrandr --output VGA-1 --off

elif [ "${dmode}" = connected ]; then

	xrandr --output VGA-1 --auto
	xrandr --output VGA-1 --right-of LVDS-1
        xrandr --output LVDS-1 --auto

fi
