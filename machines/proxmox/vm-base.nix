
{ config, pkgs, ... }:

let
  keymap = "us";
  locale = "de_DE.UTF-8";
  timezone = "Europe/Berlin";
in
{
  # COMMON - DEFAULT CONFIG FOR ALL VMS

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

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

  # TODO: fix for flakes
  # nix.optimise.automatic = true;
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #  options = "--delete-older-than 30d";
  # };

  services.openssh.enable = true;

  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "Hack";
        package = pkgs.hack-font;
      }
    ];
    extraConfig = ''
      font-size=14
      xkb-layout=${keymap}
    '';
  };

  system.stateVersion = "24.05";

  environment.shellAliases = {
    c = "clear";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "rebuild" = "sudo nixos-rebuild switch --impure --flake ~/nixfiles";
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
    TERM = "xterm"; # prevent problems when SSHing in with kitty
  };

  # SOFTWARE

  environment.systemPackages = with pkgs; [
    bat
    btop
    dysk
    htop
    mc
    ncdu
    neovim
  ];
}

