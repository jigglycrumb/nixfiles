#!/usr/bin/env bash

# Script to update NixOS configs on VMS
# Usage: deploy.sh <hostname>
# Dependencies: sshpass

target=$1

if [ ! -d $target ]; then
  echo "Target not found: $target"
  exit 1
fi

user=$(whoami)

if [ $target = "kraken" ]; then
  user="adguard"
fi

echo "Updating $target"
echo ""
echo "User: $user"

read -s -p "Password: " pass

echo ""
# exit

# Copy config to target host
echo "Copying system configuration"
sshpass -p $pass scp $target/configuration.nix $user@$target:~/nixos

# Rebuild system
echo "Rebuilding system"
sshpass -p $pass ssh -t $user@$target "echo $pass | sudo -p '' -S nixos-rebuild switch"
