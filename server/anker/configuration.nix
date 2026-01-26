# Nix OS config for an nginx (proxy) and wireguard vpn server
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
  domain = import ./secret/domain.nix; # contains just a string, like "example.com"
  email = import ./secret/email.nix { inherit domain; };
  secrets-wireguard = import ./secret/wireguard.nix;
  nginx-virtualHosts = import ./secret/nginx-virtualHosts.nix;
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

  # Proxy
  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override { openssl = pkgs.libressl; };

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = nginx-virtualHosts { inherit hostname; inherit domain; };
  };

  # SSL certs
  security.acme = {
    acceptTerms = true;
    defaults.email = "${email}";
  };

  # VPN
  # networking.wireguard.interfaces = {
  #   # "wg0" is the network interface name. You can name the interface arbitrarily.
  #   wg0 = {
  #     # Determines the IP address and subnet of the server's end of the tunnel interface.
  #     ips = secrets-wireguard.hosts.${hostname}.ips;
  #
  #     # The port that WireGuard listens to. Must be accessible by the client.
  #     listenPort = secrets-wireguard.port;
  #
  #     # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
  #     # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
  #     postSetup = ''
  #       ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${secrets-wireguard.subnet} -o eth0 -j MASQUERADE
  #     '';
  #
  #     # This undoes the above command
  #     postShutdown = ''
  #       ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${secrets-wireguard.subnet} -o eth0 -j MASQUERADE
  #     '';
  #
  #     # Path to the private key file.
  #     #
  #     # Note: The private key can also be included inline via the privateKey option,
  #     # but this makes the private key world-readable; thus, using privateKeyFile is
  #     # recommended.
  #     privateKeyFile = "/home/${username}/nixos/secret/wireguard-keys/${hostname}-wireguard.private";
  #
  #     peers = secrets-wireguard.hosts.${hostname}.peers;
  #   };
  # };

  # enable NAT for Wireguard
  # networking.nat.enable = true;
  # networking.nat.externalInterface = "eth0";
  # networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      80 # nginx
      443 # nginx
    ];
    allowedUDPPorts = [
      # secrets-wireguard.port # Wireguard
    ];
  };
}
