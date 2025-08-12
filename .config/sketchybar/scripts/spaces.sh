#!/usr/bin/env sh

# Highlight current space with a white icon, others themed blue
ACTIVE_ICON=0xffffffff   # white
INACTIVE_ICON=0xff89b4fa # blue

if ! yabai -m query --spaces >/dev/null 2>&1; then
	exit 0
fi
current_index=$(yabai -m query --spaces --space | sed -nE 's/.*"index"\s*:\s*([0-9]+).*/\1/p')

for i in 1 2 3 4 5 6 7 8 9; do
	if [ "$i" = "$current_index" ]; then
		sketchybar --set space.$i icon.color=$ACTIVE_ICON \
			background.drawing=off
	else
		sketchybar --set space.$i icon.color=$INACTIVE_ICON \
			background.drawing=off
	fi
done
