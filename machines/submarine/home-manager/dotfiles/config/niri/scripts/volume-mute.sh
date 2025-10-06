#!/bin/sh

pamixer -t
notify-send "Speakers" "$([ \"$(pamixer --get-mute)\" = \"true\" ] && (echo "Muted") || (echo "Volume: $(pamixer --get-volume-human)"))" --icon=dialog-information
