This folder contains NixOS configurations for different Proxmox VMs.

See the individual configs for details.

The configs are located in `~/nixos/configuration.nix` on the VM and then symlinked to `/etc/nixos/configuraion.nix`.  
This enables copying new configs to the VM with normal user permissions.

- `anker`: Nginx server/proxy
- `driftwood`: Playground server used for miscellaneous things
- `kraken`: AdGuard Home server
- `siren`: Media and filesharing server
