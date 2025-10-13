#!/bin/sh

brightnessctl set 10%-
notify-send "Screen" "Brightness: $(brightnessctl -m|awk -F ',' '{print $4}')" --icon=dialog-information
