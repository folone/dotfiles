#!/usr/bin/env sh

VOL=$(osascript -e 'output volume of (get volume settings)')
sketchybar --set "$NAME" label="${VOL}%"
