#!/usr/bin/env bash

INTERVAL=$($HOME/.scripts/wallpaper-interval)
LOOP_COUNT=0

echo "starting endless wallpaper loop, interval is at $INTERVAL"

update_wallpaper() {
  echo "updating wallpaper"
  INTERVAL=$($HOME/.scripts/wallpaper-interval) # update interval
  $HOME/.scripts/random-wallpaper               # set new random wallpaper
  LOOP_COUNT=0
}

trap 'update_wallpaper' SIGUSR1

while true; do
  echo "running loop $LOOP_COUNT"
  LOOP_COUNT=$((LOOP_COUNT + 1))
  if [[ $LOOP_COUNT -eq $INTERVAL ]]; then
    update_wallpaper
  fi
  sleep 1
done
