#!/usr/bin/env bash

# VM setup script for anker
# Run from user account

echo "Running setup script for $(hostname)"

if [ ! -d ~/nixos ]; then
  mkdir ~/nixos
fi

# link system config to home folder if no config is found there
if [ ! -f ~/nixos/configuration.nix ]; then
  echo "No config found in home folder, setting things up..."
  sudo cp /etc/nixos/configuration.nix ~/nixos
  sudo chown $(whoami):users ~/nixos/configuration.nix
  sudo rm -f /etc/nixos/configuration.nix
  sudo ln -s ~/nixos/configuration.nix /etc/nixos/configuration.nix
else
  echo "✅ Config found in home folder"
fi

# create webserver root folder
if [ ! -d /www ]; then
  sudo mkdir /www
  sudo chown $(whoami):users /www
fi

# link webserver root to user home for convenience
if [ ! -L ~/www ]; then
  ln -s /www ~
fi

# copy default files to webserver root
if [ ! -d /www/mina.kiwi ]; then
  cp -R ~/nixos/www/* ~/www
fi

if [ ! -f /www/htpasswd-credentials ]; then
  cp ~/nixos/secret/htpasswd-credentials ~/www
fi
