#!/usr/bin/env bash

echo "setting new wallpaper..."

# read wallpaperrc
RC_FILE=$HOME/.wallpaperrc

# if file isnt found, fall back to default folder + interval
if [ ! -f "$RC_FILE" ]; then
  echo "no wallpaper config found, enabling safe defaults..."
  $HOME/.scripts/switch-wallpapers.sh safe 60
fi

# read wallpaper folder from config file
WALLPAPER_DIR=$(cat $RC_FILE | cut -d ":" -f 1)
echo "folder: $WALLPAPER_DIR"

# get wallpaper interval
INTERVAL=$($HOME/.scripts/wallpaper-interval.sh)
echo "interval: $INTERVAL"

# write config file?

WALLPAPER=$(find $WALLPAPER_DIR -type f | shuf -n 1)

# echo "new paper: $WALLPAPER"

# set wallpaper, refresh theme, restart apps
swww img "$WALLPAPER" >/dev/null 2>&1 # set wallpaper
wal -i "$WALLPAPER" >/dev/null 2>&1   # create color scheme
kill -9 $(pidof waybar)               # kill waybar
waybar >/dev/null 2>&1 &              # start waybar
kill -9 $(pidof swaync)               # kill notification center
swaync >/dev/null 2>&1 &              # start notification center

exit 0
