# Nix OS config for a Home Assistant server
# Proxmox VM: 2 CPUs, 4GB RAM, 64GB HDD

{ config, pkgs, ... }:

let
  hostname = "nautilus";
  username = "jigglycrumb";
  timezone = "Europe/Berlin";
  secrets-home-assistant = import ./secret/home-assistant.nix;
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

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    # http.server_port = 8123;
    config.homeassistant = {
      name = "Home";
      latitude = secrets-home-assistant.latitude;
      longitude = secrets-home-assistant.longitude;
      # elevation = secrets-home-assistant.elevation;
      time_zone = timezone;
    };
  };

  # networking.firewall.allowedTCPPorts = [ ];
}
