#!/bin/bash
export BROWSER=chromium
export DE=openbox

# Dbus fix
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# Gtk themes 
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

#exec openbox-session
xcompmgr -c &
xrdb -merge .Xresources &
xsetroot -cursor_name left_ptr &
setxkbmap -option ctrl:nocaps &
exec trayer --edge top --align right --widthtype pixel --width 100 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 16 &
volume-applet &
exec dbus-launch xmonad
