#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="$HOME/Library/Logs/theme-watcher.log"
mkdir -p "$(dirname "$LOG_FILE")"

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

is_dark() {
	# Prefer AppleScript for reliable detection on modern macOS
	if osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode' \
		2>/dev/null | grep -qi true; then
		return 0
	fi
	# Fallback to defaults key
	defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi "Dark"
}

# Allow overriding theme with first argument: 'light' or 'dark'
THEME_OVERRIDE=${1:-}
case "$THEME_OVERRIDE" in
	light | dark)
		THEME="$THEME_OVERRIDE"
		;;
	*)
		if is_dark; then
			THEME="dark"
		else
			THEME="light"
		fi
		;;
esac

# Ensure PATH includes Homebrew bin for launchd context
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Determine kitty theme file paths
KITTY_THEME_LIGHT="$HOME/.config/kitty/theme-light.conf"
KITTY_THEME_DARK="$HOME/.config/kitty/theme-dark.conf"
KITTY_THEME_LINK="$HOME/.config/kitty/theme.conf"

# Ensure the kitty startup include points to the current theme
if [ "$THEME" = "dark" ] && [ -f "$KITTY_THEME_DARK" ]; then
	ln -sf "$KITTY_THEME_DARK" "$KITTY_THEME_LINK"
elif [ "$THEME" = "light" ] && [ -f "$KITTY_THEME_LIGHT" ]; then
	ln -sf "$KITTY_THEME_LIGHT" "$KITTY_THEME_LINK"
fi

PREV_THEME=""
if [ -f "$HOME/.theme" ]; then
	PREV_THEME=$(cat "$HOME/.theme" 2>/dev/null || true)
fi

if [ "$THEME" != "$PREV_THEME" ]; then
	echo "$(timestamp) Theme detected: $THEME" >>"$LOG_FILE"
	echo "$THEME" >"$HOME/.theme"
fi

# Notify sketchybar if available
if command -v sketchybar >/dev/null 2>&1; then
	if pgrep -x sketchybar >/dev/null 2>&1; then
		# Try to trigger a custom event first; fall back to reload
		sketchybar --trigger theme_change THEME="$THEME" >/dev/null 2>&1 ||
			sketchybar --reload >/dev/null 2>&1 || true
	fi
fi

# Try to update kitty colors if remote control is available and theme files exist
if command -v kitty >/dev/null 2>&1; then
	# Prefer fixed socket if configured to avoid controlling-terminal limitations
	if [ -S /tmp/kitty ]; then
		KITTYCTL=(kitty @ --to unix:/tmp/kitty)
	else
		KITTYCTL=(kitty @)
	fi
	# Apply to all running kitty windows regardless of change to enforce state
	if [ "$THEME" = "dark" ] && [ -f "$KITTY_THEME_DARK" ]; then
		"${KITTYCTL[@]}" set-colors --all --configured "$KITTY_THEME_DARK" >/dev/null 2>&1 || true
	elif [ "$THEME" = "light" ] && [ -f "$KITTY_THEME_LIGHT" ]; then
		"${KITTYCTL[@]}" set-colors --all --configured "$KITTY_THEME_LIGHT" >/dev/null 2>&1 || true
	fi
fi

# Optional user hook for further customization
if [ -x "$HOME/scripts/on_theme_change.sh" ]; then
	"$HOME/scripts/on_theme_change.sh" "$THEME" >>"$LOG_FILE" 2>&1 || true
fi

exit 0
