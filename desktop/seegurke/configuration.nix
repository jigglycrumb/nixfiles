# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.exfat-nofuse # enable ExFAT support
  # ];

  boot.initrd.kernelModules = [
    "amdgpu" # AMD graphics drivers
    # "xpad" # Gamepad support
  ];

  # Enable Vulkan for 32 bit applications
  hardware.graphics.enable32Bit = true;

  networking.firewall = {
    allowedTCPPorts = [
    ];
    allowedUDPPorts = [
    ];
  };

  # TODO: review
  # nixpkgs.config.permittedInsecurePackages = [
  #   "dotnet-runtime-7.0.20"
  #   "dotnet-sdk-7.0.410"
  #   "dotnet-runtime-6.0.36"
  #   "dotnet-sdk-6.0.428"
  # ];

  # Enable OpenSnitch application firewall
  # services.opensnitch.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # programs.thunar = {
  #   enable = true;
  #   plugins = with pkgs.xfce; [
  #     tumbler # thumbnail previews
  #     thunar-volman # removable device management
  #     thunar-archive-plugin # archive creation and extraction
  #     thunar-media-tags-plugin # view/edit ID3/OGG tags
  #   ];
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    extraGroups = [
      "docker"
      "libvirtd"
    ];
    packages = with pkgs; [
      angryipscanner # network scanner
      ascii-draw # draw diagrams etc in ASCII
      blanket # ambient sounds
      cool-retro-term # terminal emulator
      devilutionx # Diablo
      drawing # basic image editor, similar to MS Paint
      fallout-ce # port of Fallout for modern systems
      cheese # webcam fun
      evince # document viewer
      # keeperrl # roguelike
      letterpress # convert images to ascii art
      nwg-look # GUI to theme GTK apps
      oculante # fast image viewer
      # opensnitch-ui # GUI for opensnitch application firewall
      pablodraw # ANSI/ASCII art drawing
      sonic-pi # code music
      wargus # Warcraft 2 port
    ];
  };

  services.hypridle.enable = true; # enable hyprland idle daemon
  programs.hyprlock.enable = true; # enable hyprland screen lock

  # Enable keyd to remap keyboard keys
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          home = "pageup";
          end = "pagedown";
          pageup = "home";
          pagedown = "end";
        };
        # leftalt = {
        #   home = "pageup";
        #   end = "pagedown";
        # };
      };
    };

  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    slurp # select region on screen (used in screen recording script)
  ];

  # Automatically upgrade the system
  # system.autoUpgrade = {
  #   enable = true;
  #   dates = "daily";
  #   allowReboot = false;
  # };

  # Automatically clean up old generations
  # nix.settings.auto-optimise-store = true;
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 7d";
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
