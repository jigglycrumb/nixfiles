#!/usr/bin/env bash

# read wallpaperrc
RC_FILE=$HOME/.wallpaperrc

# if file isnt found, fall back to default folder + interval
if [ ! -f "$RC_FILE" ]; then
  echo "no wallpaper config found, enabling safe defaults..."
  $HOME/.scripts/switch-wallpapers.sh safe 60
fi

# read wallpaper interval from config file
INTERVAL=$(cat $RC_FILE | cut -d ":" -f 2)

# if interval isnt found, fall back to default interval
if [ -z $INTERVAL ]; then
  echo "INTERVAL is unset, defaulting..."
  INTERVAL=60
fi

# if interval is not a number, fall back to default interval

echo $INTERVAL # this is the output used by scripts
exit 0
