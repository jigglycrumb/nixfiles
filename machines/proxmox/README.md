This folder contains NixOS configurations for different Proxmox VMs.

See the individual configs for details.

The configs are located in `~/nixos/configuration.nix` on the VM and symlinked to `/etc/nixos/configuraion.nix`.  
This enables copying new configs to the VM over SSH with normal user permissions.  
Note to self: Setting up the `~/nixos/` folder and symlinking the system config is currently still a manual step.

VMs:

- `anker`: Nginx server/proxy
- `driftwood`: Playground server for miscellaneous things
- `kraken`: AdGuard Home server
- `siren`: Media and filesharing server
