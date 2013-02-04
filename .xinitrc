#!/bin/sh
#export BROWSER=firefox
#export DE=openbox
#exec dbus-launch openbox-session

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    # Do not launch dbus before ConsoleKit (FS#25031)
    #[ -x "$f" ] && . "$f"
    [ "$f" -ne "/etc/X11/xinit/xinitrc.d/30-dbus" ] && [ -x "$f" ] && . "$f"
  done
  unset f
fi

feh --bg-max /home/folone/Images/wallpaper/ml.png &
xrdb -merge .Xresources &
xsetroot -cursor_name left_ptr &
(sleep 30 && sbxkb) &
dropboxd &
volumeicon &
exec dbus-launch /usr/bin/xmonad
