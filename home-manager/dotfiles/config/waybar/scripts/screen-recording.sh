#!/usr/bin/env bash

# Shows a little indicator in waybar while screen recording is active

if [ ! -z $(pgrep wf-recorder) ]; then
  echo '{"text":"","tooltip":"Screen recording active"}'
else
  echo '{"text":"","class":"hidden"}'
fi
