# Nix OS config for an Adguard Home server
# Proxmox VM: 1 CPU, 4GB RAM, 16GB HDD

{ config, pkgs, ... }:

let
  hostname = "kraken";
  username = "adguard";
in
{
  networking.hostName = "${hostname}";

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services.kmscon.autologinUser = "${username}";

  # SERVICES

  services.adguardhome = {
    # the openFirewall option only opens the port for the admin interface
    # so we skip it and open all needed ports manually
    enable = true;
    port = 80;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      53 # DNS
      80 # adguard admin interface
      853 # DNS over TLS
    ];
    allowedUDPPorts = [
      53 # DNS
    ];
  };
}
