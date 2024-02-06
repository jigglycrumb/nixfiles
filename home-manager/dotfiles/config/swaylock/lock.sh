#!/usr/bin/env sh

# import pywal colors
source "$HOME/.cache/wal/colors.sh"

swaylock \
  --font-size 40 \
  --inside-color 00000000 \
  --inside-clear-color 00000000 \
  --inside-ver-color 00000000 \
  --inside-wrong-color 00000000 \
  --key-hl-color "$color6" \
  --bs-hl-color "$color2" \
  --ring-color "$color1" \
  --ring-clear-color "$color2" \
  --ring-wrong-color "$color5" \
  --ring-ver-color "$color2" \
  --line-uses-ring \
  --line-color 00000000 \
  --text-color "$foreground" \
  --text-clear-color "$color2" \
  --text-wrong-color "$color5" \
  --text-ver-color "$color4" \
  --separator-color 00000000
