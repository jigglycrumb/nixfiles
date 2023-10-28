#!/usr/bin/env bash

# init wallpaper daemon
swww init &
# set wallpaper
# swww img path-to-image.png &

nm-applet --indicator &

waybar &

dunst
