# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  ...
}:

let

  nixvim = import (
    builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      # When using a different channel you can use `ref = "nixos-<version>"` to set it here
    }
  );

  hostname = "seegurke";
  username = "jigglycrumb";
in
{
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration.nix
    nixvim.nixosModules.nixvim
    (import ../../common/modules/nixvim.nix { inherit username; })
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.exfat-nofuse # enable ExFAT support
  # ];

  boot.initrd.kernelModules = [
    "amdgpu" # AMD graphics drivers
    "sg" # generic SCSI for external DVD/BluRay drive support
    # "xpad"
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.powerOnBoot = true;

  # Enable Vulkan
  hardware.graphics.enable = true;
  # For 32 bit applications
  hardware.graphics.enable32Bit = true;

  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # 50000 # rtorrent
    ];
    allowedUDPPorts = [
      # 50000 # rtorrent
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow broken packages
  # nixpkgs.config.allowBroken = true;

  # Enabled support for rocm
  # nixpkgs.config.rocmSupport = true;

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
    "dotnet-sdk-7.0.410"
    "dotnet-runtime-6.0.36"
    "dotnet-sdk-6.0.428"
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.excludePackages = [ pkgs.xterm ]; # don't install xterm

  # Enable automatic discovery of remote drives
  services.gvfs.enable = true;

  # TODO: finish this: enable tuigreet from wlogout, disable autologin
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu
        '';
        user = "${username}";
      };
    };
  };

  #environment.etc."greetd/environments".text = ''
  #  Hyprland
  #'';

  # Configure keymap in X11
  # services.xserver = {
  #   xkb = {
  #     layout = "de";
  #     variant = "";
  #   };

  #   displayManager.gdm = {
  #     enable = true;
  #     wayland = true;
  #   };
  # };

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-theme='Arc-Dark'
  '';

  services.openssh.enable = true;

  programs.niri.enable = true;

  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  environment.sessionVariables = {
    # NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    CLUTTER_BACKEND = "wayland";
    # SDL_VIDEODRIVER = "x11";
    MOZ_ENABLE_WAYLAND = "1";
    # QT_QPA_PLATFORM = "wayland";
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Enable OpenSnitch application firewall
  # services.opensnitch.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # enable Blueman to manage bluetooth devices
  services.blueman.enable = true;

  # Automatically discover network printers
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable ZSH
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    setOptions = [ "RM_STAR_WAIT" ];
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "cursor"
      ];
      patterns = {
        "rm -rf *" = "fg=white,bold,bg=red";
      };
    };
    histSize = 10000;
  };

  environment.pathsToLink = [
    "/libexec"
    "/share/zsh"
  ];
  environment.shells = with pkgs; [ zsh ];

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      tumbler # thumbnail previews
      thunar-volman # removable device management
      thunar-archive-plugin # archive creation and extraction
      thunar-media-tags-plugin # view/edit ID3/OGG tags
    ];
  };

  security.polkit.enable = true;

  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Enable Gnome disk manager
  programs.gnome-disks.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "docker"
      "libvirtd"
      "networkmanager"
      "wheel" # enables sudo
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      angryipscanner # network scanner
      appeditor # gui to edit app launcher entries (.desktop files)
      ascii-draw # draw diagrams etc in ASCII
      blanket # ambient sounds
      brave # web browser
      nemo-with-extensions # file manager
      cool-retro-term # terminal emulator
      devilutionx # Diablo
      door-knocker # check availability of portals
      drawing # basic image editor, similar to MS Paint
      fallout-ce # port of Fallout for modern systems
      furnace # multi-system chiptune tracker
      cheese # webcam fun
      evince # document viewer
      seahorse # keyring manager
      # keeperrl # roguelike
      letterpress # convert images to ascii art
      networkmanagerapplet # tray app for network management
      nwg-look # GUI to theme GTK apps
      oculante # fast image viewer
      # opensnitch-ui # GUI for opensnitch application firewall
      pablodraw # ANSI/ASCII art drawing
      pavucontrol # GUI volume conrol
      # peazip # archive utility
      sonic-pi # code music
      wargus # Warcraft 2 port
    ];
  };

  # Enable AppImages to run directly
  programs.appimage.binfmt = true;

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "${username}";

  services.hypridle.enable = true; # enable hyprland idle daemon
  programs.hyprlock.enable = true; # enable hyprland screen lock

  # better ttys
  # services.kmscon = {
  #   enable = true;
  #   hwRender = true;
  #   fonts = [
  #     {
  #       name = "Hack";
  #       package = pkgs.hack-font;
  #     }
  #   ];
  #   extraConfig = ''
  #     font-size=18
  #     xkb-layout=de
  #   '';
  # };

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
    appimage-run # runs appimage apps
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    clinfo
    cliphist # clipboard history
    # exfat # tools for ExFAT formatted disks
    # exiftool # read & write exif data - integrates with digikam
    fuzzel # wayland app launcher
    git
    git-crypt
    gparted # drive partition manager
    grimblast # screenshot tool (used in screenshot script)
    home-manager # manage user configurations
    hyprcursor # xcursor replacement
    hyprkeys # print hyprland key bindings
    hyprpicker # pick colors from the screen
    kitty # terminal
    libnotify # notification basics, includes notify-send
    lxqt.lxqt-policykit
    pulseaudio # pactl

    (python3.withPackages (
      ps: with ps; [
        requests # needed for waybar weather script
      ]
    ))

    samba # de janeiro! *da da da da, dadada, dada*
    # satty # screenshot annotation tool
    slurp # select region on screen (used in screen recording script)
    swayimg # image viewer
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    usbutils # provides lsusb
    vim # editor
    wl-clipboard # wayland clipboard management
    wlogout # wayland logout,lock,etc screen
    waybar # wayland menu bar
  ];

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  fonts.packages = with pkgs; [
    hack-font
    victor-mono
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
