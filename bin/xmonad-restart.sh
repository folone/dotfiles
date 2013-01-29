#!/bin/sh
xmonad --recompile &&
xmonad --restart &&
for pid in `pgrep taffybar`; do kill $pid; done &&
taffybar &
