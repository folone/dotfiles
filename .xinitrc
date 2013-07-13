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
exec xmonad
