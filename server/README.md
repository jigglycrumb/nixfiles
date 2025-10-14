## NixOS configurations for Proxmox VMs

See the individual configs for details.

The configs are based on the `flake.nix` in this folder.
The `deploy.sh` script copies it over to the VM.
`vm-base.nix` contains common config identical in all VMs.

VMs:

- `anker`: Nginx server/proxy and Wireguard VPN server
- `driftwood`: Playground server for miscellaneous things
- `hafen`: Docker server
- `kraken`: AdGuard Home server
- `nautilus`: Home Assistant server
- `siren`: Media and filesharing server
