#!/usr/bin/env sh

PMSET=$(pmset -g batt)
# Prefer SketchyBar event info when available for immediate updates
if [ "${SENDER:-}" = "power_source_change" ] && [ -n "${INFO:-}" ]; then
	RAW_SOURCE="$INFO"
else
	RAW_SOURCE=$(echo "$PMSET" | sed -nE "s/Now drawing from '([^']+)'.*/\1/p")
fi
BAT_LINE=$(echo "$PMSET" | awk 'NR==2')
# Extract percentage robustly
PERCENT=$(echo "$BAT_LINE" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
STATE=$(echo "$BAT_LINE" | sed -nE 's/.*;\s*([^;]+);.*/\1/p' | tr '[:upper:]' '[:lower:]' | awk '{print $1}')

# Normalize power source to AC/Battery
SOURCE="Battery"
case "$RAW_SOURCE" in
	AC* | "Power Adapter"* | "External Power"*) SOURCE="AC" ;;
	*) SOURCE="Battery" ;;
esac

# Determine icon based on percentage
P=${PERCENT:-0}
ICON="" # empty
if [ "$P" -ge 90 ]; then ICON=""; fi
if [ "$P" -ge 70 ] && [ "$P" -lt 90 ]; then ICON=""; fi
if [ "$P" -ge 50 ] && [ "$P" -lt 70 ]; then ICON=""; fi
if [ "$P" -ge 20 ] && [ "$P" -lt 50 ]; then ICON=""; fi

ICON_COLOR="0xffcdd6f4" # default foreground
LABEL="${P}%"

# Charging detection (exact match), or on AC
if [ "$STATE" = "charging" ] || [ "$SOURCE" = "AC" ]; then
	ICON=""                # bolt when charging
	ICON_COLOR="0xffa6e3a1" # green
elif [ "$P" -le 20 ]; then
	ICON_COLOR="0xfff38ba8" # red on low battery
fi
TARGET_ITEM=${NAME:-battery}
sketchybar --set "$TARGET_ITEM" icon="$ICON" icon.color="$ICON_COLOR" label="$LABEL"
