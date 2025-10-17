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
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50; # limit boot loader to the last 50 generations
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.exfat-nofuse # enable ExFAT support
  # ];

  networking.firewall = {
    allowedTCPPorts = [
    ];
    allowedUDPPorts = [
    ];
  };

  # Allow broken packages
  # nixpkgs.config.allowBroken = true; 
  
  # nixpkgs.config.permittedInsecurePackages = [];

  # Enable OpenSnitch application firewall
  # services.opensnitch.enable = true;

  # Enable ollama to run LLMs
  services.ollama = {
    enable = true;
  };

  # Enable web GUI for ollama
  # services.open-webui = {
  #   enable = true;
  #   port = 4141; # 8080;
  #   environment = {
  #     ANONYMIZED_TELEMETRY = "False";
  #     DO_NOT_TRACK = "True";
  #     SCARF_NO_ANALYTICS = "True";
  #     # WEBUI_AUTH = "False";
  #   };
  #   # Temporary fix
  #   package = pkgs.open-webui.overridePythonAttrs (old: {
  #     dependencies = old.dependencies ++ [
  #       pkgs.python3Packages.itsdangerous
  #     ];
  #   });
  # };

  # Enable Docker
  virtualisation.docker.enable = true;

  # programs.thunar = {
  #   enable = true;
  #   plugins = with pkgs.xfce; [
  #     tumbler # thumbnail previews
  #     thunar-volman # removable device management
  #     thunar-archive-plugin # archive creation and extraction
  #     thunar-media-tags-plugin # view/edit ID3/OGG tags
  #   ];
  # };

  users.groups = {
    plugdev = { };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    extraGroups = [
      "docker"
      "libvirtd"
      "plugdev"
    ];
    packages = with pkgs; [
      ascii-draw # draw diagrams etc in ASCII
      blanket # ambient sounds
      evince # document viewer
      gimp # image manipulation
      krita # painting software
      letterpress # convert images to ascii art
      libreoffice # office suite
      oculante # fast image viewer
      orca # screen reader
      overskride # bluetooth management GUI
      slacky # chat thing
      teams-for-linux # ms teams
      zed-editor # editor
    ];
  };

  # File previews for nautilus
  services.gnome.sushi.enable = true;

  programs.wshowkeys.enable = true; # show keypresses on screen

  # Enable keyd to remap keyboard keys
  # services.keyd = {
  #   enable = true;
  #   keyboards.default = {
  #     ids = [ "*" ];
  #     settings = {
  #       main = {
  #         home = "pageup";
  #         end = "pagedown";
  #         pageup = "home";
  #         pagedown = "end";
  #       };
  #       # leftalt = {
  #       #   home = "pageup";
  #       #   end = "pagedown";
  #       # };
  #     };
  #   };
  #
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    abduco # detachable terminal sessions
    clinfo # shows info about OpenCL (GPU things) - TODO I don't recall why this is here, check if it's still needed and remove
    exfat # tools for ExFAT formatted disks
    pass-wayland # local password manager
    powertop # power monitor
    slurp # select region on screen (used in screen recording script)
    system-config-printer # printer configuration UI
    virtiofsd # enables shared folders between host and VM - add <binary path="/run/current-system/sw/bin/virtiofsd"/> to filesystem XML if virtiofsd can't be found
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
