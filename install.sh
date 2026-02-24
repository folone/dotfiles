#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Flag support: --dry-run/-n, --skip-services
DRY_RUN=${DRY_RUN:-0}
SKIP_SERVICES=${SKIP_SERVICES:-0}
while [[ $# -gt 0 ]]; do
	case "$1" in
		--dry-run | -n) DRY_RUN=1 ;;
		--skip-services) SKIP_SERVICES=1 ;;
		*)
			echo "Unknown option: $1" >&2
			exit 1
			;;
	esac
	shift
done

title() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
note() { printf "\033[0;33m[!] %s\033[0m\n" "$*"; }

# 1) Command Line Tools
title "Checking Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
	note "Installing Xcode Command Line Tools (follow the on-screen dialog)"
	if [ "$DRY_RUN" -eq 1 ]; then echo "+ xcode-select --install"; else xcode-select --install || true; fi
else
	echo "Command Line Tools already installed"
fi

# 2) Homebrew
title "Installing Homebrew (if missing)"
if ! command -v brew >/dev/null 2>&1; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
	else
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		if [ -f /opt/homebrew/bin/brew ]; then
			eval "$(/opt/homebrew/bin/brew shellenv)"
		fi
	fi
else
	echo "Homebrew present"
fi

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

# 3) Brew bundle
title "Installing packages via Brewfile"
BREWFILE="$THIS_DIR/Brewfile"
if [ ! -f "$BREWFILE" ]; then
	note "No Brewfile found at $BREWFILE; skipping brew bundle"
else
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ brew update"
		echo "+ brew bundle --file=\"$BREWFILE\""
	else
		brew update
		if ! brew bundle --file="$BREWFILE"; then
			note "Some Brewfile packages failed to install (continuing anyway)"
		fi
	fi
fi

# 4) Oh-My-Zsh (optional)
title "Installing oh-my-zsh (if missing)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ RUNZSH=no KEEP_ZSHRC=yes sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
	else
		RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
else
	echo "oh-my-zsh present"
fi

# 5) Symlink configs from this repo (if running from a dotfiles directory)
title "Linking configuration files"
link() {
	src="$THIS_DIR/$1"
	dst="$HOME/$2"
	# If source and destination are identical absolute paths, skip linking
	if [ "$src" = "$dst" ]; then
		echo "Skip linking (source equals destination): $dst"
		return 0
	fi
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ mkdir -p $(dirname "$dst")"
		echo "+ ln -snf $src $dst"
	else
		mkdir -p "$(dirname "$dst")"
		ln -snf "$src" "$dst"
		echo "Linked $dst -> $src"
	fi
}

link .yabairc .yabairc
link .skhdrc .skhdrc
link .zshrc .zshrc
link .gitconfig .gitconfig
link .gitignore_global .gitignore_global
link .ghci .ghci || true
link .vimrc .vimrc || true
link .bash_profile .bash_profile || true

link .config/sketchybar .config/sketchybar
link .config/kitty/kitty.conf .config/kitty/kitty.conf
link .config/kitty/theme-light.conf .config/kitty/theme-light.conf
link .config/kitty/theme-dark.conf .config/kitty/theme-dark.conf
link .config/starship.toml .config/starship.toml
link .config/karabiner/karabiner.json .config/karabiner/karabiner.json || true
link .config/nvim .config/nvim

# Scripts
link scripts/apply_theme.sh scripts/apply_theme.sh
link scripts/check.sh scripts/check.sh
link scripts/transfer.sh scripts/transfer.sh

# Install LaunchAgent plist (substitute __HOME__ placeholder and validate)
install_launchd() {
	src="$THIS_DIR/launchd/local.theme-watcher.plist"
	dst="$HOME/Library/LaunchAgents/local.theme-watcher.plist"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ mkdir -p $(dirname "$dst")"
		echo "+ sed 's|__HOME__|$HOME|g' \"$src\" > \"$dst\""
		echo "+ chmod 644 \"$dst\""
		echo "+ plutil -lint \"$dst\""
	else
		mkdir -p "$(dirname "$dst")"
		# Render template: replace __HOME__ placeholder with actual home path
		sed "s|__HOME__|$HOME|g" "$src" >"$dst"
		chmod 644 "$dst" || true
		plutil -lint "$dst"
	fi
}
install_launchd

# 5b) macOS preferences
title "Configuring macOS preferences"
if [ "$DRY_RUN" -eq 1 ]; then
	echo "+ defaults write (scroll direction, key repeat, menu bar, dock, hot corners ...)"
else
	# Scroll direction: traditional (non-natural)
	defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

	# Fast key repeat (essential for vim)
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	defaults write NSGlobalDomain KeyRepeat -int 2

	# Disable press-and-hold accent picker so keys repeat normally
	defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

	# Auto light/dark mode
	defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

	# Hide menu bar
	defaults write NSGlobalDomain _HIHideMenuBar -bool true

	# Dock: auto-hide, don't rearrange spaces by recent use,
	# don't auto-switch space when activating an app with windows elsewhere
	defaults write com.apple.dock autohide -bool true
	defaults write com.apple.dock mru-spaces -bool false
	defaults write com.apple.dock workspaces-auto-swoosh -bool true

	# Hot corner: top-right = Start Screen Saver (with Cmd modifier)
	defaults write com.apple.dock wvous-tr-corner -int 5
	defaults write com.apple.dock wvous-tr-modifier -int 1048576

	# Disable Spotlight shortcut (⌘+Space) so Raycast can use it
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "64" \
		"<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"

	# Set Raycast hotkey to ⌘+Space
	defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"

	killall Dock 2>/dev/null || true
	echo "macOS preferences applied"
fi

# 5c) Mission Control: Cmd+1..9 to switch spaces
title "Configuring Mission Control shortcuts (⌘+1..9)"

HOTKEY_IDS=(118 119 120 121 122 123 124 125 126)
KEY_CODES=(18 19 20 21 23 22 26 28 25)
CHAR_CODES=(49 50 51 52 53 54 55 56 57)
CMD_MOD=1048576

for idx in $(seq 0 8); do
	hid="${HOTKEY_IDS[$idx]}"
	kc="${KEY_CODES[$idx]}"
	cc="${CHAR_CODES[$idx]}"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add \"$hid\" '... ⌘+$((idx + 1)) → Desktop $((idx + 1))'"
	else
		defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$hid" \
			"<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>$cc</integer><integer>$kc</integer><integer>$CMD_MOD</integer></array><key>type</key><string>standard</string></dict></dict>"
	fi
done

if [ "$DRY_RUN" -eq 0 ]; then
	/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
	echo "Shortcuts set (⌘+1..9 → Desktop 1..9). Log out and back in if they don't take effect immediately."
fi

# 5d) Ensure 9 Mission Control spaces exist
title "Checking Mission Control spaces"
if command -v yabai >/dev/null 2>&1 && [ "$DRY_RUN" -eq 0 ]; then
	space_count=$(yabai -m query --spaces 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
	if [ "$space_count" -lt 9 ]; then
		if ! yabai -m space --create 2>/dev/null; then
			note "Need $((9 - space_count)) more spaces (you have $space_count)."
			echo 'Opening Mission Control – click the "+" button at the top-right to add spaces until you have 9.'
			open -b com.apple.exposelauncher
			echo ""
			printf "Press Enter when done..."
			read -r
			space_count=$(yabai -m query --spaces 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
			echo "Spaces: $space_count"
		else
			for i in $(seq "$((space_count + 2))" 9); do
				yabai -m space --create 2>/dev/null || break
			done
			echo "Spaces created (now $(yabai -m query --spaces | jq 'length'))"
		fi
	else
		echo "Spaces: $space_count (OK)"
	fi
elif [ "$DRY_RUN" -eq 1 ]; then
	echo "+ check/create 9 Mission Control spaces"
fi

# 6) Start services
if [ "$SKIP_SERVICES" -eq 1 ]; then
	title "Skipping services (--skip-services)"
	note "Run install.sh again without --skip-services after granting Accessibility permissions"
else
	title "(Re)starting services"
	if command -v yabai >/dev/null 2>&1; then
		if [ "$DRY_RUN" -eq 1 ]; then
			echo "+ yabai --restart-service"
		else
			yabai --stop-service >/dev/null 2>&1 || true
			yabai --start-service || true
		fi
	fi
	if command -v skhd >/dev/null 2>&1; then
		if [ "$DRY_RUN" -eq 1 ]; then
			echo "+ skhd --restart-service"
		else
			skhd --stop-service >/dev/null 2>&1 || true
			skhd --start-service || true
		fi
	fi
	if command -v sketchybar >/dev/null 2>&1; then
		if [ "$DRY_RUN" -eq 1 ]; then
			echo "+ brew services restart sketchybar"
		else
			brew services restart sketchybar || true
		fi
	fi

	# 6b) Theme watcher (Light/Dark auto)
	title "Configuring theme watcher"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ chmod +x \"$HOME/scripts/\"*.sh"
		echo "+ chmod +x \"$HOME/.config/sketchybar/scripts/\"*.sh"
		echo "+ launchctl bootout gui/$(id -u) local.theme-watcher || true"
		echo "+ launchctl bootstrap gui/$(id -u) \"$HOME/Library/LaunchAgents/local.theme-watcher.plist\""
		echo "+ launchctl enable gui/$(id -u)/local.theme-watcher"
		echo "+ launchctl kickstart -k gui/$(id -u)/local.theme-watcher"
		echo "+ zsh -lc \"$HOME/scripts/apply_theme.sh\""
	else
		chmod +x "$HOME/scripts/"*.sh || true
		chmod +x "$HOME/.config/sketchybar/scripts/"*.sh || true
		chmod +x "$HOME/.config/sketchybar/sketchybarrc" || true
		launchctl bootout gui/"$(id -u)" local.theme-watcher >/dev/null 2>&1 || true
		if ! launchctl bootstrap gui/"$(id -u)" "$HOME/Library/LaunchAgents/local.theme-watcher.plist"; then
			launchctl unload -wF "$HOME/Library/LaunchAgents/local.theme-watcher.plist" >/dev/null 2>&1 || true
			launchctl load -wF "$HOME/Library/LaunchAgents/local.theme-watcher.plist" || true
		else
			launchctl enable gui/"$(id -u)"/local.theme-watcher || true
			launchctl kickstart -k gui/"$(id -u)"/local.theme-watcher || true
		fi
		zsh -lc "$HOME/scripts/apply_theme.sh" || true
	fi
fi

# 7) Post-install verification
title "Verifying environment"
warn_missing() { note "Missing: $1 – $2"; }

[ -f "$HOME/.ssh/id_ed25519" ] && echo "SSH key (ed25519): OK" || warn_missing "~/.ssh/id_ed25519" "run scripts/transfer.sh or copy manually"
[ -f "$HOME/.ssh/config" ] && echo "SSH config: OK" || warn_missing "~/.ssh/config" "run scripts/transfer.sh or copy manually"

if command -v gpg >/dev/null 2>&1; then
	if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q sec; then
		echo "GPG secret key: OK"
	else
		# keyboxd may be caching stale state; restart and retry
		gpgconf --kill all 2>/dev/null || true
		sleep 1
		if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q sec; then
			echo "GPG secret key: OK (after restarting gpg-agent)"
		else
			warn_missing "GPG secret key" "try: gpgconf --kill all && gpg --list-secret-keys"
		fi
	fi
fi

[ -f "$HOME/.aws/config" ] && echo "AWS config: OK" || warn_missing "~/.aws/config" "run scripts/transfer.sh or aws configure"
[ -d "$HOME/workspace/snoodev" ] && echo "Snoodev: OK" || warn_missing "~/workspace/snoodev" "clone or run scripts/transfer.sh"

if command -v brew >/dev/null 2>&1 && [ -f "$THIS_DIR/Brewfile" ]; then
	if brew bundle check --file="$THIS_DIR/Brewfile" >/dev/null 2>&1; then
		echo "Brewfile: all packages installed"
	else
		warn_missing "some Brew packages" "run: brew bundle --file=$THIS_DIR/Brewfile"
	fi
fi

if command -v git-lfs >/dev/null 2>&1; then
	echo "Git LFS: OK"
else
	warn_missing "git-lfs" "run: brew install git-lfs && git lfs install"
fi

# 8) Post-install notes
title "Post-install steps"
cat <<'EOS'
- Grant Accessibility permissions:
  System Settings → Privacy & Security → Accessibility:
    → yabai, skhd, sketchybar
  System Settings → Privacy & Security → Input Monitoring:
    → Karabiner-Elements, karabiner_grabber, karabiner_observer

- Start/restart Karabiner-Elements:
    open -a "Karabiner-Elements"
  (Caps Lock → Right Control is configured automatically)

- Start/restart Raycast:
    open -a "Raycast"
  (Cmd+Space hotkey is configured automatically; Spotlight shortcut is disabled)

- Log out and back in (or restart) to activate:
    → Cmd+1..9 Mission Control shortcuts
    → Spotlight shortcut removal
    → Scroll direction, key repeat, and other system preferences

- Set your terminal font to "JetBrainsMono Nerd Font"

- Automatic Light/Dark theme:
  - The theme watcher writes the current mode to ~/.theme and notifies apps
  - Kitty theme switching looks for:
    - ~/.config/kitty/theme-light.conf
    - ~/.config/kitty/theme-dark.conf

Tip: Kitty is installed. Launch with: open -na "Kitty" (or Alt+Return as configured by skhd)
EOS

echo "Done. Restart your session or re-run apps if needed."
