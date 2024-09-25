# Nix OS config for a misc use Home server
# Proxmox VM: 1 CPU, 4GB RAM, 32GB HDD

{ config, pkgs, ... }:

let
  hostname = "driftwood";
  username = "jigglycrumb";
  locale = "de_DE.UTF-8";
  keymap = "de";
  timezone = "Europe/Berlin";
  secrets-syncthing = import ./secret/syncthing.nix;
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
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  environment.sessionVariables = {
    EDITOR = "micro";
    TERM = "xterm"; # prevent problems when SSHing in with kitty
  };

  # SOFTWARE

  environment.systemPackages = with pkgs; [
    bat
    git
    micro
  ];

  # SERVICES

  services.homepage-dashboard = {
    enable = true;
    listenPort = 80; # 8082;
    openFirewall = true;
    services = [
      {
        "Services" = [
          {
            "AdGuard Home" = {
              description = "Ad Blocker";
              href = "http://kraken";
            };
          }
          {
            "Jellyfin" = {
              description = "Media Server";
              href = "http://siren:8096";
            };
          }
          {
            "Gollum" = {
              description = "Wiki";
              href = "http://driftwood:8080";
            };
          }
          {
            "Syncthing" = {
              description = "driftwood";
              href = "http://driftwood:8384";
            };
          }
          {
            "Syncthing" = {
              description = "siren";
              href = "http://siren:8384";
            };
          }
          {
            "Syncthing" = {
              description = "superbox";
              href = "http://superbox:8384";
            };
          }
          {
            "Syncthing" = {
              description = "megabox";
              href = "http://megabox:8384";
            };
          }
        ];
      }
      {
        "Hosts" = [
          {
            "fritz.box" = {
              description = "Router";
              href = "http://fritz.box";
            };
          }
          {
            "proxmox" = {
              description = "Proxmox Virtual Environment";
              href = "http://proxmox:8006";
            };
          }
          {
            "epaper" = {
              description = "E-ink frame";
              href = "http://epaper";
            };
          }
        ];
      }
    ];
  };

  # allow homepage to run on port 80
  systemd.services.homepage-dashboard.serviceConfig.AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

  services.gollum = {
    enable = true;
    user = "${username}";
    port = 8080;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/${username}/.config/syncthing";
    user = "${username}";
    group = "users";
    guiAddress = "0.0.0.0:8384";

    cert = "/home/${username}/nixos/secret/syncthing/cert.pem";
    key = "/home/${username}/nixos/secret/syncthing/key.pem";

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    settings = {
      options = {
        urAccepted = -1; # disable telemetry
      };

      devices = {
        siren = secrets-syncthing.devices.siren;
      };

      folders = secrets-syncthing.folders."${hostname}";
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

  networking.firewall.allowedTCPPorts = [
    8080 # gollum
    8384 # syncthing
  ];
}
