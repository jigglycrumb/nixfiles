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
  domain = "mina.kiwi";
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "${hostname}";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

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

  services.samba = {
    enable = true;
    package = pkgs.sambaFull;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${hostname}
      netbios name = ${hostname}
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      # printer sharing
      load printers = yes
      printing = cups
      printcap name = cups
    '';
    shares = {
      # public = {
      #   path = "/mnt/Shares/Public";
      #   browseable = "yes";
      #   "read only" = "no";
      #   "guest ok" = "yes";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      #   "force user" = "username";
      #   "force group" = "groupname";
      # };

      printers = {
        comment = "All Printers";
        path = "/var/spool/samba";
        public = "yes";
        browseable = "yes";
        # to allow user 'guest account' to print.
        "guest ok" = "yes";
        writable = "no";
        printable = "yes";
        "create mode" = 700;
      };

      NAS = {
        path = "/mnt/nas";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };

      Audio = {
        path = "/mnt/nas/Audio";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };

      DVD = {
        path = "/mnt/nas/DVD";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };

      Other = {
        path = "/mnt/nas/Other";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };

      Photos = {
        path = "/mnt/nas/Photos";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };

      Software = {
        path = "/mnt/nas/Software";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };

      Video = {
        path = "/mnt/nas/Video";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };
    };
  };

  # this service allows windows hosts to see the shares
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # copied from nixos wiki - printer sharing
  systemd.tmpfiles.rules = [ "d /var/spool/samba 1777 root root -" ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "${username}";
    group = "users";
    dataDir = "/home/${username}/jellyfin";
  };

  services.nginx = {
    enable = true;
    # fix heartbleed
    package = pkgs.nginxStable.override { openssl = pkgs.libressl; };

    virtualHosts."${domain}" = {
      addSSL = true;
      enableACME = true;
      root = "/home/${username}/nginx/${domain}";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "mina@${domain}";
  };

  # TODO: Syncthing
}
