#!/usr/bin/env bash

# VM setup script for hafen
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
