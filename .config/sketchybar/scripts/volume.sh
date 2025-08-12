#!/usr/bin/env sh

VOL=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

ICON=
LABEL="${VOL}%"
ICON_COLOR=0xffcdd6f4

if [ "$MUTED" = "true" ] || [ "${VOL}" = "0" ]; then
	ICON=
	LABEL=""
	ICON_COLOR=0xff6c7086 # muted/disabled gray
elif [ "$VOL" -lt 30 ]; then
	ICON=
fi

TARGET_ITEM=${NAME:-volume}
sketchybar --set "$TARGET_ITEM" icon="$ICON" icon.color=$ICON_COLOR label="$LABEL"
