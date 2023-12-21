#!/usr/bin/env bash

# this script writes the wallpaper directory and interval to ~/.wallpaperrc

if [ -z "$2" ]; then
  echo "interval not set, defaulting"
  INTERVAL=60
# TODO: if interval is set, check if it is actually a number
else
  INTERVAL=$2
fi

case $1 in
"all")
  echo "$HOME/Pictures/Wallpapers/Landscape:$INTERVAL" >$HOME/.wallpaperrc
  ;;

"safe" | "sfw")
  echo "$HOME/Pictures/Wallpapers/Landscape/sfw:$INTERVAL" >$HOME/.wallpaperrc
  ;;

"unsafe" | "nsfw")
  echo "$HOME/Pictures/Wallpapers/Landscape/nsfw:$INTERVAL" >$HOME/.wallpaperrc
  ;;

*)
  echo "Usage: $0 <all|safe|unsafe> <refresh interval in seconds>"
  ;;
esac

$HOME/.scripts/set-wallpaper.sh

exit 0
