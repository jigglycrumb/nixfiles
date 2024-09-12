## NixOS configurations for Proxmox VMs

See the individual configs for details.

On the VMs, the config files are located in `~/nixos/configuration.nix` and symlinked to `/etc/nixos/configuraion.nix`.  
This enables copying updated configs to the VM over SSH with normal user permissions.  
Note: Setting up the `~/nixos/` folder and symlinking the system config is currently still a manual step.

VMs:

- `anker`: Nginx server/proxy
- `driftwood`: Playground server for miscellaneous things
- `kraken`: AdGuard Home server
- `siren`: Media and filesharing server
