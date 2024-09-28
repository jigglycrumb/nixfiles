#!/usr/bin/env bash

# shows the current keyboard layout

layout=$(hyprctl getoption input:kb_layout | grep str | awk '{ print $2 }')

if [ "$layout" = "de" ]; then
  flag="🇩🇪"
elif [ "$layout" = "us" ]; then
  flag="🇺🇸"
fi

echo "{\"text\":\"$flag\",\"tooltip\":\"Keyboard: $layout\"}"
