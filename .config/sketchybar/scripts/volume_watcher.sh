#!/usr/bin/env sh

get_state() {
  VOL=$(osascript -e 'output volume of (get volume settings)')
  MUTED=$(osascript -e 'output muted of (get volume settings)')
  printf "%s:%s" "$VOL" "$MUTED"
}

LAST=""
while true; do
  CUR=$(get_state)
  if [ "$CUR" != "$LAST" ]; then
    sketchybar --trigger volume_change
    LAST="$CUR"
  fi
  sleep 0.3
done


