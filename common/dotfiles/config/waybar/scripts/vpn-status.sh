#!/usr/bin/env bash

TARGET_HOST=home
TIMEOUT=1

ping -q -w $TIMEOUT -c 1 $TARGET_HOST >/dev/null
UP=$?

if [ "$1" = "--toggle" ]; then
  if [ "$UP" = "0" ]; then
    sudo -A systemctl stop wg-quick-home.service
  else
    sudo -A systemctl start wg-quick-home.service
  fi
fi

if [ "$UP" = "0" ]; then
  echo '{"tooltip":"VPN connected","class":"connected","percentage":100}'
else
  echo '{"tooltip":"VPN disconnected","class":"disconnected","percentage":0}'
fi
