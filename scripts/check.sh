#!/usr/bin/env bash
set -euo pipefail

export HOMEBREW_NO_AUTO_UPDATE=1

have() { command -v "$1" >/dev/null 2>&1; }

if ! have shellcheck; then brew install shellcheck; fi
if ! have shfmt; then brew install shfmt; fi
if ! have jq; then brew install jq; fi
if ! have stylua; then brew install stylua; fi

echo '==> Shell lint'
if ls .config/sketchybar/scripts/*.sh >/dev/null 2>&1; then
  shellcheck -S error install.sh .config/sketchybar/scripts/*.sh
else
  shellcheck -S error install.sh
fi

echo '==> Shell formatting check'
files=( )
[ -f install.sh ] && files+=( install.sh )
if ls .config/sketchybar/scripts/*.sh >/dev/null 2>&1; then
  files+=( .config/sketchybar/scripts/*.sh )
fi
if [ ${#files[@]} -gt 0 ]; then
  shfmt -d -s -ci "${files[@]}"
fi

echo '==> JSON validation (Karabiner)'
if [ -f .config/karabiner/karabiner.json ]; then
  jq -e . .config/karabiner/karabiner.json >/dev/null
fi

echo '==> Stylua check (Neovim)'
if [ -d .config/nvim ]; then
  stylua --check .config/nvim
fi

echo '==> Brewfile check'
if [ -f Brewfile ]; then
  brew bundle check --file=Brewfile || true
fi

echo '==> Installer dry-run'
chmod +x install.sh
./install.sh --dry-run

echo 'All checks passed.'


