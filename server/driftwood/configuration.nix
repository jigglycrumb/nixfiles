# Nix OS config for a misc use Home server
# Proxmox VM: 2 CPUs, 6GB RAM, 128GB HDD

{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostname = "driftwood";
  username = "jigglycrumb";
  timezone = "Europe/Berlin";
  homepage-public = import ./secret/homepage-public.nix;
  secrets-syncthing = import ./secret/syncthing.nix;
  secrets-minecraft = import ./secret/minecraft.nix;
  mealie-url = import ./secret/mealie-url.nix;
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

  # SOFTWARE

  environment.systemPackages = with pkgs; [
    git
  ];

  # SERVICES

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = "*";
    services = [
      {
        "Services" = [
          {
            "SearXNG" = {
              description = "Search Engine";
              href = "http://driftwood:8888";
            };
          }
          {
            "NetAlertX" = {
              description = "Network Alerts";
              href = "http://hafen:20211";
            };
          }
          {
            "AdGuard Home" = {
              description = "Ad Blocker";
              href = "http://kraken";
            };
          }
          {
            "Home Assistant" = {
              description = "Home Automation";
              href = "http://nautilus:8123";
            };
          }
          {
            "Nextcloud" = {
              description = "Cloud Service";
              href = "http://siren";
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
        "Public" = homepage-public; 
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
  # systemd.services.homepage-dashboard.serviceConfig.AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

  # wiki
  services.gollum = {
    enable = true;
    user = "${username}";
    port = 8080;
  };

  # syncthing for wiki backup
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/${username}/.config/syncthing";
    user = "${username}";
    group = "users";
    guiAddress = "0.0.0.0:8384";

    cert = "/home/${username}/nixfiles/${hostname}/secret/syncthing/cert.pem";
    key = "/home/${username}/nixfiles/${hostname}/secret/syncthing/key.pem";

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

  # Minecraft server

  # since there is no http(s) involved here, access is handled by opening the port on the router
  # and setting up a SRV record on the domain which forwards to the domain and port

  nixpkgs.config.allowUnfree = true;

  services.minecraft-server = {
    enable = true;
    eula = true;
    jvmOpts = "-Xms4096M -Xmx4096M";
    openFirewall = true;
    declarative = true;
    serverProperties = {
      max-players = 8;
      motd = secrets-minecraft.motd;
      pvp = false;
      white-list = true;
    };

    whitelist = secrets-minecraft.whitelist;
  };

  services.mealie = {
    enable = true;
    # port = 9000;
    settings = {
      BASE_URL = mealie-url;
      TZ = "${timezone}";
    };
  };

  # services.teamspeak3 = {
  #   enable = true;
  #   openFirewall = true;

    # defaultVoicePort = 9987; # UDP
    # fileTransferPort = 30033; # TCP
  # };

  # automatically accept teamspeak license
  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "teamspeak-server" ];

  # services.quake3-server = {
  #   enable = true;
  #   # port = 27960;
  #   openFirewall = true;
  #   baseq3 = "/home/${username}/nixos/secret/quake3";
    # extraConfig = ''
    #   seta rconPassword "superSecret"      // sets RCON password for remote console
    #   seta sv_hostname "My Quake 3 server"      // name that appears in server list
    # '';
  # };

  # services.mattermost = {
  #   enable = true;
  #   # listenAddress = ":8065";
  #   plugins = [ ];
  #   # siteName = "Mattermost";
  #   siteUrl = "https://chat.example.com";
  # };

  # services.invidious = {
  #   enable = true;
  #   # port = 3000;
  # };

  # services.freshrss = {
  #   enable = true;
  #   baseUrl = "https://freshrss.example.com";
  # };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings = {
      server = {
        bind_address = "0.0.0.0";
        port = 8888;
        secret_key = "secret key";
      };
    };
  };

  # services.searx.settings.search.formats = ["html" "json" "rss"];

  networking.firewall.allowedTCPPorts = [
    # 80 # homepage-dashboard
    # 3000 # invidious
    # 8065 # mattermost
    8080 # gollum
    8082 # homepage-dashboard
    8384 # syncthing
    8888 # SearXNG
    9000 # mealie
    # 25565 # minecraft server
    # 27960 # quake 3 server
    # 30033 # teamspeak file transfers
  ];

  networking.firewall.allowedUDPPorts = [
    # 9987 # teamspeak voice chat
  ];
}
