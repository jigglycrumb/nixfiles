# Nix OS config for a Docker server
# Proxmox VM: 2 CPUs, 4GB RAM, 128GB HDD

{ config, pkgs, ... }:

let
  hostname = "hafen";
  username = "jigglycrumb";
in
{
  networking.hostName = "${hostname}";

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
  };

  services.kmscon.autologinUser = "${username}";

  # SOFTWARE

  environment.systemPackages = with pkgs; [
    git
    lazydocker
    nodejs
    oxker
    wget
    yarn
  ];

  # SERVICES

  virtualisation.docker.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      3000 # karakeep
      3080 # watcharr
      20211 # netalertx
    ];
    allowedUDPPorts = [
    ];
  };
}
