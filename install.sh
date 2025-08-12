#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

title() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
note() { printf "\033[0;33m[!] %s\033[0m\n" "$*"; }

# 1) Command Line Tools
title "Checking Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  note "Installing Xcode Command Line Tools (follow the on-screen dialog)"
  xcode-select --install || true
else
  echo "Command Line Tools already installed"
fi

# 2) Homebrew
title "Installing Homebrew (if missing)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$([ -f /opt/homebrew/bin/brew ] && echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"')"
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
  brew update
  brew bundle --file="$BREWFILE"
fi

# 4) Oh-My-Zsh (optional)
title "Installing oh-my-zsh (if missing)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh present"
fi

# 5) Symlink configs from this repo (if running from a dotfiles directory)
title "Linking configuration files"
link() {
  src="$THIS_DIR/$1"; dst="$HOME/$2";
  mkdir -p "$(dirname "$dst")"
  ln -snf "$src" "$dst"
  echo "Linked $dst -> $src"
}

link .yabairc .yabairc
link .skhdrc .skhdrc
link .zshrc .zshrc
link .gitconfig .gitconfig
link .ghci .ghci || true

link .config/sketchybar .config/sketchybar
link .config/kitty/kitty.conf .config/kitty/kitty.conf
link .config/starship.toml .config/starship.toml
link .config/karabiner/karabiner.json .config/karabiner/karabiner.json || true
link .config/nvim .config/nvim

# 6) Start services
title "Starting services"
if command -v yabai >/dev/null 2>&1; then
  yabai --stop-service >/dev/null 2>&1 || true
  yabai --start-service || true
fi
if command -v skhd >/dev/null 2>&1; then
  skhd --stop-service >/dev/null 2>&1 || true
  skhd --start-service || true
fi
if command -v sketchybar >/dev/null 2>&1; then
  brew services start sketchybar || true
  sketchybar --reload || true
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

Tip: Kitty is installed. Launch with: open -na "Kitty" (or ⌥ + enter as configured by skhd)
EOS

echo "Done. Restart your session or re-run apps if needed."
