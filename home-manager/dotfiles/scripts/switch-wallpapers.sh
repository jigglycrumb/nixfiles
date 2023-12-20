#!/usr/bin/env bash

if [ -z "$2" ]; then
  echo "interval not set, defaulting"
  INTERVAL=60
# TODO: if interval is set, check if it is actually a number
else
  INTERVAL=$2
fi

echo "INTERVAL: $INTERVAL"

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

RC_FILE=$HOME/.wallpaperrc

# read wallpaper folder from config file
WALLPAPER_DIR=$(cat $RC_FILE | cut -d ":" -f 1)
# echo "folder: $WALLPAPER_DIR"

WALLPAPER=$(find $WALLPAPER_DIR -type f | shuf -n 1)
# echo "new paper: $WALLPAPER"

swww img "$WALLPAPER" >/dev/null 2>&1 # set wallpaper
wal -i "$WALLPAPER" >/dev/null 2>&1   # create color scheme
kill -9 $(pidof waybar)               # kill waybar
waybar >/dev/null 2>&1 &              # start waybar
kill -9 $(pidof swaync)               # kill notification center
swaync >/dev/null 2>&1 &              # start notification center

exit 0
