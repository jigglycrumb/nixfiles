#!/usr/bin/env bash

# Shows an icon when the microphone is muted

if [ "$(pamixer --default-source --get-mute)" = "true" ]; then
  echo '{"text":"","tooltip":"Microphone is muted"}'
else
  echo '{"text":"","class":"hidden"}'
fi
