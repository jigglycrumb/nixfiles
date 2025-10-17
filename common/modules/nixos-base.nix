
{
  config,
  lib,
  pkgs,
  hostname,
  username,
  ...
}:
let
  locale = "en_US.UTF-8";
  timezone = "Europe/Berlin";
in
{
 
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50; # limit boot loader to the last 50 generations
  boot.loader.efi.canTouchEfiVariables = true;

  # Set hostname
  networking.hostName = hostname;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set time zone
  time.timeZone = timezone;

  # Set locale
  i18n.defaultLocale = locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };

  # Configure console keymap
  console.keyMap = "us";
  
  # Enable vulkan graphics
  hardware.graphics.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-theme='Arc-Dark'
  '';

  # Enable SSH server
  services.openssh.enable = true;

  # Enable below system monitoring
  services.below.enable = true;

  # Enable greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu
        '';
        user = "${username}";
      };
    };
  };

  # Configure greetd to start late to prevent boot text artifacts
  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOuput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYHangup = true;
      TTYVTDisallocate = true;
    };
  };

  # Configure the environment
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland"; 
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # Configure desktop portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    # config = {
      # niri = {
      #   "org.freedesktop.impl.portal.FileChooser" = "gtk";
      # };
      # niri = {
      #   default = [
      #     "wlr"
      #     "gtk"
      #   ];
      #   "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      #   "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      #   "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      #};
      # gnome = {
      #   default = [
      #     "gnome"
      #     "gtk"
      #   ];
      #   "org.freedesktop.impl.portal.Secret" = [
      #     "gnome-keyring"
      #   ];
      #   "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      # };  
    #};
  };


  # Enable automatic discovery of remote drives
  services.gvfs.enable = true;

  # Enable Blueman to manage bluetooth devices
  services.blueman.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Automatically discover network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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

  # Enable polkit
  security.polkit.enable = true;

  # security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  security.soteria.enable = true;

  # Enable Gnome disk manager
  programs.gnome-disks.enable = true;

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable AppImages to run directly
  programs.appimage.binfmt = true;

  # Enable niri window manager
  programs.niri.enable = true;

  # Better TTYs
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
      font-size=18
      xkb-layout=us
    '';
  };

  # Configure QT
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Install fonts
  fonts.packages = with pkgs; [
    hack-font
    victor-mono
  ];

  # Install system-wide packages
  environment.systemPackages = with pkgs; [
    appimage-run # runs appimage apps
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    cliphist # clipboard history
    exfat # tools for ExFAT formatted disks
    isd # TUI for systemd services
    fuzzel # wayland app launcher
    git
    git-crypt # transparent file encryption for git
    gparted # drive partition manager
    home-manager # manage user configurations
    kitty # terminal
    libnotify # notification basics, includes notify-send
    nautilus # GNOME file manager, needed for niri file picker portal
    pulseaudio # pactl
    (python3.withPackages (
      ps: with ps; [
        requests # needed for waybar weather script
      ]
    ))
    raffi
    samba # de janeiro! *da da da da, dadada, dada*
    sunsetr # blue light filter for wayland
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    usbutils # provides lsusb
    wf-recorder # screen recording
    wl-clipboard # wayland clipboard management
    waybar # wayland menu bar
    xwayland-satellite # runs X apps on wayland
  ];

  # Configure the main user account
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel" # enables sudo
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      brave # web browser
      door-knocker # check availability of portals
      nemo-with-extensions # file manager
      networkmanagerapplet # tray app for network management
      pavucontrol # GUI volume conrol
      peazip # archive utility
      qutebrowser # keyboard focused web browser
      seahorse # keyring manager
      signal-desktop # messenger
      vlc # media player
    ];
  };
}

