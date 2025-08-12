#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dry run support: pass --dry-run/-n or set DRY_RUN=1
DRY_RUN=${DRY_RUN:-0}
if [[ ${1:-} == "--dry-run" || ${1:-} == "-n" ]]; then
	DRY_RUN=1
	shift || true
fi

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
		brew bundle --file="$BREWFILE"
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
link .ghci .ghci || true

link .config/sketchybar .config/sketchybar
link .config/kitty/kitty.conf .config/kitty/kitty.conf
link .config/kitty/theme-light.conf .config/kitty/theme-light.conf
link .config/kitty/theme-dark.conf .config/kitty/theme-dark.conf
link .config/starship.toml .config/starship.toml
link .config/karabiner/karabiner.json .config/karabiner/karabiner.json || true
link .config/nvim .config/nvim

# Theme watcher files
link scripts/apply_theme.sh scripts/apply_theme.sh

# Install LaunchAgent plist (validated)
install_launchd() {
  src="$THIS_DIR/launchd/local.theme-watcher.plist"
  dst="$HOME/Library/LaunchAgents/local.theme-watcher.plist"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "+ mkdir -p $(dirname "$dst")"
    echo "+ cp \"$src\" \"$dst\""
    echo "+ chmod 644 \"$dst\""
    echo "+ plutil -lint \"$dst\""
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    chmod 644 "$dst" || true
    plutil -lint "$dst"
  fi
}
install_launchd

# 6) Start services
title "Starting services"
if command -v yabai >/dev/null 2>&1; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ yabai --stop-service || true"
		echo "+ yabai --start-service"
	else
		yabai --stop-service >/dev/null 2>&1 || true
		yabai --start-service || true
	fi
fi
if command -v skhd >/dev/null 2>&1; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ skhd --stop-service || true"
		echo "+ skhd --start-service"
	else
		skhd --stop-service >/dev/null 2>&1 || true
		skhd --start-service || true
	fi
fi
if command -v sketchybar >/dev/null 2>&1; then
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "+ brew services start sketchybar"
		echo "+ sketchybar --reload"
	else
		brew services start sketchybar || true
		sketchybar --reload || true
	fi
fi

# 6b) Theme watcher (Light/Dark auto)
title "Configuring theme watcher"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "+ chmod +x \"$HOME/scripts/apply_theme.sh\""
  echo "+ launchctl bootout gui/$(id -u) local.theme-watcher || true"
  echo "+ launchctl bootstrap gui/$(id -u) \"$HOME/Library/LaunchAgents/local.theme-watcher.plist\""
  echo "+ launchctl enable gui/$(id -u)/local.theme-watcher"
  echo "+ launchctl kickstart -k gui/$(id -u)/local.theme-watcher"
  echo "+ zsh -lc \"$HOME/scripts/apply_theme.sh\""
else
  chmod +x "$HOME/scripts/apply_theme.sh" || true
  launchctl bootout gui/"$(id -u)" local.theme-watcher >/dev/null 2>&1 || true
  if ! launchctl bootstrap gui/"$(id -u)" "$HOME/Library/LaunchAgents/local.theme-watcher.plist"; then
    # Fallback for older macOS
    launchctl unload -wF "$HOME/Library/LaunchAgents/local.theme-watcher.plist" >/dev/null 2>&1 || true
    launchctl load -wF "$HOME/Library/LaunchAgents/local.theme-watcher.plist" || true
  else
    launchctl enable gui/"$(id -u)"/local.theme-watcher || true
    launchctl kickstart -k gui/"$(id -u)"/local.theme-watcher || true
  fi
  zsh -lc "$HOME/scripts/apply_theme.sh" || true
fi

# 7) Post-install notes
title "Post-install steps"
cat <<'EOS'
- Grant Accessibility to yabai, skhd, and sketchybar:
  System Settings → Privacy & Security → Accessibility → enable these apps
- If you want full yabai features, follow SIP notes:
  https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection
- Create Mission Control spaces as you like (we label them α β γ δ ε ζ η θ ι)
- Hide Menu Bar and Dock (System Settings) for a clean look
- Set your terminal font to “JetBrainsMono Nerd Font”

- Automatic Light/Dark theme:
  - The theme watcher writes the current mode to ~/.theme and notifies apps
  - Kitty theme switching looks for:
    - ~/.config/kitty/theme-light.conf
    - ~/.config/kitty/theme-dark.conf

Tip: Kitty is installed. Launch with: open -na "Kitty" (or ⌥ + enter as configured by skhd)
EOS

echo "Done. Restart your session or re-run apps if needed."
