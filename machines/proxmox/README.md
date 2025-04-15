## NixOS configurations for Proxmox VMs

See the individual configs for details.

On the VMs, the config files are located in `~/nixos/configuration.nix` and symlinked to `/etc/nixos/configuraion.nix`.  
This enables copying updated configs to the VM over SSH with normal user permissions.

To spin up a new VM:

1. Create VM in Promox and install NixOS
2. After first boot: Login via Proxmox, enable SSH and change hostname
3. Run `./deploy.sh <hostname> --copy` to copy the config files to the VM
4. Connect via SSH and run `./nixos/setup.sh` and `sudo nixos-rebuild switch`

For further deployments, run `./deploy.sh <hostname>`

VMs:

- `anker`: Nginx server/proxy and Wireguard VPN endpoint
- `driftwood`: Playground server for miscellaneous things
- `hafen`: Docker server
- `kraken`: AdGuard Home server
- `nautilus`: Home Assistant server
- `siren`: Media and filesharing server
