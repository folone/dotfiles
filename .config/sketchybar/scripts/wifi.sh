#!/usr/bin/env sh

SSID=$(networksetup -getairportnetwork en0 2>/dev/null | sed 's/^Current Wi-Fi Network: //')
sketchybar --set "${NAME:-wifi}" label=""


