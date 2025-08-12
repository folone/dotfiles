## Dotfiles (macOS) – Yabai + skhd + Sketchybar + Kitty + Starship + Neovim

Modern, Hyprland-inspired macOS setup with a tiling WM, menu bar, fast terminal, themed prompt, and a batteries-included Neovim config.

### What’s included

- **Window manager**: [yabai](https://github.com/koekeishiya/yabai) + [skhd](https://github.com/koekeishiya/skhd)
- **Bar**: [sketchybar](https://github.com/FelixKratz/SketchyBar) (spaces with Greek icons, app title, wifi/volume/battery/clock)
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/) (Catppuccin theme, Nerd Font)
- **Prompt**: [Starship](https://starship.rs/) (Catppuccin colors)
- **Editor**: [Neovim](https://neovim.io/) with lazy.nvim, LSP, Treesitter, Telescope, gitsigns, lualine

### Quick start

1) Install Xcode Command Line Tools (the script will prompt if missing) and Homebrew.
2) Clone this repo, then:

```bash
bash ./install.sh
```

Dry-run to preview actions:

```bash
./install.sh --dry-run
```

Notes:
- Approve Accessibility for `yabai`, `skhd`, and `sketchybar` in System Settings → Privacy & Security → Accessibility.
- Set your terminal font to “JetBrainsMono Nerd Font”.
- If you want full yabai features, follow the SIP guidance in the official docs: [Disabling System Integrity Protection](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection).

### Keybindings (skhd)

- Focus windows: Alt+H/J/K/L
- Swap windows: Shift+Alt+H/J/K/L
- Move window to prev/next space (and follow): Ctrl+Alt+H/L
- Focus space 1..9: Cmd+Alt+1..9
- Send window to space 1..9 (and follow): Shift+Cmd+1..9
- Focus displays: Ctrl+Alt+P/N
- Send window to other display: Ctrl+Cmd+P/N
- Toggle split orientation: Alt+Space
- Float/unfloat and center: Alt+T
- Fullscreen: Alt+F
- Launch Kitty: Alt+Return
- Launch VS Code: Alt+E
- Raycast: Alt+R
- Lock screen: Ctrl+Cmd+L

### Bar (sketchybar)

- Spaces labeled with Greek icons: α β γ δ ε ζ η θ ι
- Active space highlighted (white icon)
- Front app next to spaces with additional padding
- Right-side modules: wifi (icon-only), volume (event-driven, mute-aware), battery (charging bolt, low-battery red), clock

Files:
- `~/.config/sketchybar/sketchybarrc`
- `~/.config/sketchybar/scripts/*.sh`

### Terminal (Kitty) + Prompt (Starship)

- Kitty config: `~/.config/kitty/kitty.conf` (Catppuccin colors, Nerd Font)
- Starship prompt: `~/.config/starship.toml` (enabled from `~/.zshrc`)

Kitty shortcuts:
- Tabs: Ctrl+J/K (left/right)
- Splits focus: Ctrl+Shift+H/J/K/L
- Create split: Ctrl+Shift+\ (horizontal), Ctrl+Shift+- (vertical)
- Move split: Ctrl+Shift+Alt+H/J/K/L
- Close split: Ctrl+Shift+W
- Rename tab: Ctrl+Shift+R

### Neovim

- Config: `~/.config/nvim/init.lua` (lazy.nvim, LSP, Treesitter, Telescope, gitsigns, lualine, Catppuccin)
- Common keys:
  - Space+ff: find files
  - Space+fg: live grep
  - Space+fb: buffers
  - Space+fh: help

### CI and local checks

- GitHub Actions workflow: `.github/workflows/ci.yml`
  - Lints shell scripts (shellcheck, shfmt)
  - Validates Karabiner JSON (jq)
  - Checks Neovim Lua format (stylua)
  - Installer dry-run

- Run locally:

```bash
bash scripts/check.sh
```

### Troubleshooting

- Repeated Accessibility prompts for `skhd`/`yabai`:
  1) Stop service: `skhd --stop-service` (and/or `yabai --stop-service`)
  2) Kill lingering process: `pkill -x skhd` / `pkill -x yabai`
  3) Remove and re-add in System Settings → Accessibility (add `/opt/homebrew/bin/skhd` and `/opt/homebrew/bin/yabai`)
  4) Start service: `skhd --start-service`, `yabai --start-service`

- Space icons not updating: ensure `yabai` is running (`yabai --start-service`) and has Accessibility. Switching spaces should trigger updates.

- Volume not updating: the background watcher `volume_watcher.sh` triggers `volume_change` events. If needed, restart sketchybar: `sketchybar --reload`.

### Layout and files

Tracked highlights:
- `~/.yabairc`, `~/.skhdrc`, `~/.zshrc`, `~/.gitconfig`, `~/.ghci`
- `~/.config/sketchybar/**`, `~/.config/kitty/kitty.conf`, `~/.config/starship.toml`, `~/.config/karabiner/karabiner.json`, `~/.config/nvim/**`
- `Brewfile`, `install.sh`, `.github/**`, `scripts/check.sh`

Ignored by default: noisy/sensitive app data under `~/.config/**` (Raycast, Joplin, gh, Copilot, etc.).


