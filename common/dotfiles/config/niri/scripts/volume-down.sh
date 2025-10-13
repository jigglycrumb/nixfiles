#!/bin/sh

pamixer -d 5
notify-send "Speakers" "Volume: $(pamixer --get-volume-human)" --icon=dialog-information
