# Nix OS config for a filesharing and media server
# Proxmox VM: 2 CPUs, 16GB RAM, 256GB HDD

# Installation notes
# Setting up an external HDD as NAS storage

# 1. Proxmox settings
#   1. Connect HDD to Proxmox host, open the settings of the VM
#   2. Go to Hardware tab, choose Add -> USB Device
#   3. In the dialog, choose "Use USB Vendor/Device ID", select the device and save
#   4. Boot VM

# 2. Inside the VM
#   1. Check if you can see the external HDD listed as a device now - likely `/dev/sdb`
#   2. Create a directory to mount the drive to - I used `/mnt/nas`
#   3. As root, mount drive: `mount /dev/sdb1 /mnt/nas`
#   4. Run `nixos-generate-config` - this will add the mounted drive to `/etc/nixos/hardware-configuation.nix`
#   5. Reboot VM and check if the drive gets mounted on boot
#   6. Optional: Adjust permissions on the mount point/files to give your user access

# 3. Samba setup
# When samba is running, you still have to add your user to be able to access shares
# As root, run `smbpasswd - a <username>`, then enter & confirm a samba password

{ config, pkgs, ... }:

let
  hostname = "siren";
  username = "jigglycrumb";
  locale = "de_DE.UTF-8";
  keymap = "de";
  timezone = "Europe/Berlin";
  secrets-samba = import ./secret/samba.nix;
  secrets-syncthing = import ./secret/syncthing.nix;
  nextcloud-admin-pass = import ./secret/nextcloud-admin-pass.nix;
in
{
  # COMMON - DEFAULT CONFIG FOR ALL VMS

  imports = [];

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # programs.zsh.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # shell = pkgs.zsh;
    packages = with pkgs; [
      mame-tools
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
    btop
    htop
    mc
    micro
    ncdu
  ];

  # SERVICES

  environment.etc."nextcloud-admin-pass".text = nextcloud-admin-pass;

  services.nextcloud = {
    enable = true;
    hostName = "${hostname}";
    package = pkgs.nextcloud31;

    config.adminpassFile = "/etc/nextcloud-admin-pass";
    config.dbtype = "sqlite";
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "${hostname}";
        "netbios name" = "${hostname}";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        security = "user";
      };
    };

    shares = secrets-samba.shares."${hostname}";
  };

  # this service allows windows hosts to see the shares
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "${username}";
    group = "users";
    dataDir = "/home/${username}/jellyfin";
  };

  systemd.timers."jellyfin-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Description = "Daily backup of the Jellyfin database";
      OnCalendar = "*-*-* 7:00:00"; # run every day at 7am
      Persistent = true; # run job if timer was missed, e.g. due to power off
      Unit = "jellyfin-backup.service";
    };
  };

  systemd.services."jellyfin-backup" = {
    script = ''
      set -eu # exit on error and undefined variables
      ${pkgs.rsync}/bin/rsync -Pav --delete /home/${username}/jellyfin/ /mnt/nas/Machine/siren/jellyfin
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "${username}";
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/${username}/.config/syncthing";
    user = "${username}";
    group = "users";
    guiAddress = "0.0.0.0:8384";

    cert = "/home/${username}/siren/secret/syncthing/cert.pem";
    key = "/home/${username}/siren/secret/syncthing/key.pem";

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    settings = {
      options = {
        urAccepted = -1; # disable telemetry
      };

      devices = {
        driftwood = secrets-syncthing.devices.driftwood;
        knulli = secrets-syncthing.devices.knulli;
        megabox = secrets-syncthing.devices.megabox;
        nixe = secrets-syncthing.devices.nixe;
        phone = secrets-syncthing.devices.phone;
        steamdeck = secrets-syncthing.devices.steamdeck;
        superbox = secrets-syncthing.devices.superbox;
      };

      folders = secrets-syncthing.folders."${hostname}";
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      80 # nextcloud
      8384 # syncthing
    ];
  };
}
