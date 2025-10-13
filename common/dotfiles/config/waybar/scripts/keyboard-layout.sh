#!/usr/bin/env bash

# shows the current keyboard layout

layout=$(hyprctl getoption input:kb_layout | grep str | awk '{ print $2 }')

if [ "$1" = "--toggle" ]; then
  if [ "$layout" = "de" ]; then
    hyprctl keyword input:kb_layout us
  else
    hyprctl keyword input:kb_layout de
  fi
fi

if [ "$layout" = "de" ]; then
  flag="🇩🇪"
elif [ "$layout" = "us" ]; then
  flag="🇺🇸"
fi

echo "{\"text\":\"$flag\",\"tooltip\":\"Keyboard: $layout\"}"
