#!/bin/sh

pamixer --default-source --toggle-mute
notify-send "Microphone" "$([ \"$(pamixer --default-source --get-mute)\" = \"true\" ] && (echo "Muted") || (echo "Unmuted"))" --icon=dialog-information
