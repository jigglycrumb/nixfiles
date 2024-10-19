# Nix OS config for an nginx (proxy) annd wireguard vpn server
# Proxmox VM: 1 CPU, 2GB RAM, 16GB HDD

# To create a wireguard keypair run these commands
# and replace `key.private` and `key.public` with descriptive names,
# e.g. the hostname

# nix-shell -p wireguard-tools
# umask 077
# wg genkey > key.private
# wg pubkey < key.private > key.public

{ config, pkgs, ... }:

let
  hostname = "anker";
  username = "jigglycrumb";
  locale = "de_DE.UTF-8";
  keymap = "de";
  timezone = "Europe/Berlin";
  domain = "mina.kiwi";
  email = "mina@${domain}";
  secrets-wireguard = import ./secret/wireguard.nix;
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
    btop
    htop
    micro
  ];

  # SERVICES

  # Proxy
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

      "sofa.${domain}" = {
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

  # SSL certs
  security.acme = {
    acceptTerms = true;
    defaults.email = "${email}";
  };

  # VPN

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = secrets-wireguard.hosts.${hostname}.ips;

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = secrets-wireguard.port;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${secrets-wireguard.subnet} -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${secrets-wireguard.subnet} -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/home/${username}/nixos/secret/wireguard-keys/${hostname}-wireguard.private";

      peers = secrets-wireguard.hosts.${hostname}.peers;
    };
  };

  # enable NAT for Wireguard
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      80 # nginx
      443 # nginx
    ];
    allowedUDPPorts = [
      secrets-wireguard.port # Wireguard
    ];
  };
}
