# Nix OS config for an Adguard Home server
# Proxmox VM: 1 CPU, 4GB RAM, 16GB HDD

{ config, pkgs, ... }:

let
  hostname = "kraken";
  username = "adguard";
  locale = "de_DE.UTF-8";
  keymap = "de";
  timezone = "Europe/Berlin";
in
{
  # COMMON - DEFAULT CONFIG FOR ALL VMS

  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;

  time.timeZone = "${timezone}";

  i18n.defaultLocale = "${locale}";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${locale}";
    LC_IDENTIFICATION = "${locale}";
    LC_MEASUREMENT = "${locale}";
    LC_MONETARY = "${locale}";
    LC_NAME = "${locale}";
    LC_NUMERIC = "${locale}";
    LC_PAPER = "${locale}";
    LC_TELEPHONE = "${locale}";
    LC_TIME = "${locale}";
  };

  console.keyMap = "${keymap}";

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services.openssh.enable = true;

  services.kmscon = {
    enable = true;
    hwRender = true;
    autologinUser = "${username}";
    fonts = [
      {
        name = "Hack";
        package = pkgs.hack-font;
      }
    ];
    extraConfig = ''
      font-size=14
      xkb-layout=de
    '';
  };

  system.stateVersion = "24.05";

  environment.shellAliases = {
    c = "clear";
  };

  environment.sessionVariables = {
    EDITOR = "micro";
    TERM = "xterm"; # prevent problems when SSHing in with kitty
  };

  # SOFTWARE

  environment.systemPackages = with pkgs; [
    bat
    micro
  ];

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
