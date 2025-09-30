#!/usr/bin/env bash

# Script to update NixOS configs on VMS

# Usage:
# deploy.sh <hostname>          # copy config and rebuild
# deploy.sh <hostname> --copy   # copy config

# Dependencies: sshpass

function deploy_target() {
  target=$1

  if [ ! -d $target ]; then
    echo "Target not found: $target"
    exit 1
  fi

  user=$(whoami)

  if [ $target = "kraken" ]; then
    user="adguard"
  fi

  target_folder=/home/$user/nixfiles

  echo "--------------------------------------------------"
  echo "Updating $target"
  echo "--------------------------------------------------"
  
  echo ""
  echo "User: $user"

  read -s -p "Password: " pass

  echo ""
  echo ""

  # Copy config to target host
  echo "Copying system configuration"
  sshpass -p $pass scp -r flake.* $user@$target:$target_folder
  sshpass -p $pass scp -r vm-base.nix $user@$target:$target_folder
  sshpass -p $pass scp -r $target/* $user@$target:$target_folder/$target

  if [ "$2" != "--copy" ]; then
    # Rebuild system
    echo "Rebuilding system"
    sshpass -p $pass ssh -t $user@$target "echo $pass | sudo -p '' -S nixos-rebuild switch --impure --flake $target_folder" # TODO impure needed for anker /www absolute path
  fi

  echo ""
}

if [ "$1" = "--all" ]; then
  for f in *; do
    if [ -d $f ]; then
      deploy_target $f
    fi
  done
else
  deploy_target $1
fi
