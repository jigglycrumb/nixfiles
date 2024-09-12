# Nix OS config for an nginx (proxy) server
# Proxmox VM: 1 CPU, 4GB RAM, 16GB HDD

{ config, pkgs, ... }:

let
  hostname = "anker";
  username = "jigglycrumb";
  locale = "de_DE.UTF-8";
  keymap = "de";
  timezone = "Europe/Berlin";
  domain = "mina.kiwi";
  email = "mina@${domain}";
in
{
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

  environment.systemPackages = with pkgs; [
    bat
    micro
  ];

  environment.sessionVariables = {
    EDITOR = "micro";
    TERM = "xterm"; # prevent problems when SSHing in with kitty
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

  # SERVICES

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override { openssl = pkgs.libressl; };

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "${hostname}" = {
        root = "/www/${domain}";
      };

      "${domain}" = {
        root = "/www/${domain}";
        forceSSL = true;
        enableACME = true;
      };

      "flox.${domain}" = {
        locations."/".proxyPass = "http://siren:8096";
        forceSSL = true;
        enableACME = true;
      };

      "wiki.${domain}" = {
        locations."/".proxyPass = "http://driftwood:8080";
        forceSSL = true;
        enableACME = true;
        # To create the auth file, SSH into VM, then:
        # nix-shell -p apacheHttpd
        # sudo htpasswd - c /www/htpasswd-credentials <username>
        basicAuthFile = /www/htpasswd-credentials;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "${email}";
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      80 # nginx
      443 # nginx
    ];
  };
}
