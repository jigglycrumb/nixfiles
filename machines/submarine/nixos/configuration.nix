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

  # Import secrets
  #
  # !!! WARNING !!!
  # This approach is far from ideal since the secrets will end up in the locally readable /nix/store
  # It is however, an easy way for keeping the secrets out of the repo until I've learned enough nix to implement a better solution
  # The secrets.nix file is just a simple set lik e this:
  #
  # {
  #   github-token = "<insert token here>";
  # }

  hostname = "submarine";
  username = "jigglycrumb";
  locale = "en_US.UTF-8";
in
{
  imports = [
    # Include the results of the hardware scan.
    # /etc/nixos/hardware-configuration.nix
    nixvim.nixosModules.nixvim
    (import ../../../common/modules/nixvim.nix { inherit username; })
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50; # limit boot loader to the last 50 generations
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.exfat-nofuse # enable ExFAT support
  # ];

  boot.initrd.kernelModules = [
    "sg" # generic SCSI for external DVD/BluRay drive support
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable Vulkan
  hardware.graphics.enable = true;

  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
    ];
    allowedUDPPorts = [
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Configure console keymap
  console.keyMap = "us";

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow broken packages
  # nixpkgs.config.allowBroken = true; 
  
  # nixpkgs.config.permittedInsecurePackages = [];

  # Enable automatic discovery of remote drives
  services.gvfs.enable = true;

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

  services.below.enable = true;

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

  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-theme='Arc-Dark'
  '';

  services.openssh.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland"; 
    # XDG_DESKTOP_PORTAL = "xdg-desktop-portal-xapp";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    CLUTTER_BACKEND = "wayland";
    # SDL_VIDEODRIVER = "x11";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # DISPLAY = ":0";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # xdgOpenUsePortal = true;
    extraPortals = [
      # pkgs.xdg-desktop-portal-xapp
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-hyprland
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

  # Enable OpenSnitch application firewall
  # services.opensnitch.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # enable Blueman to manage bluetooth devices
  services.blueman.enable = true;

  # Automatically discover network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

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

  # Enable Docker
  virtualisation.docker.enable = true;

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

  users.groups = {
    plugdev = { };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "docker"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "wheel" # enables sudo
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      ascii-draw # draw diagrams etc in ASCII
      blanket # ambient sounds
      brave # web browser
      cheese # webcam fun
      door-knocker # check availability of portals
      evince # document viewer
      gimp # image manipulation
      krita # painting software
      letterpress # convert images to ascii art
      libreoffice # office suite
      nemo-with-extensions # file manager
      networkmanagerapplet # tray app for network management
      oculante # fast image viewer
      orca # screen reader
      overskride # bluetooth management GUI
      pavucontrol # GUI volume conrol
      peazip # archive utility
      qutebrowser # keyboard focused web browser
      seahorse # keyring manager
      signal-desktop # messenger
      simple-scan # scan documents
      slacky # chat thing
      teams-for-linux # ms teams
      zed-editor # editor
    ];
  };

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable AppImages to run directly
  programs.appimage.binfmt = true;

  # programs.hyprlock.enable = true; # enable hyprland screen lock

  programs.niri.enable = true; # a scrolling window manager

  # File previews for nautilus
  services.gnome.sushi.enable = true;

  programs.wshowkeys.enable = true; # show keypresses on screen

  security.soteria.enable = true;

  # better ttys
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
    appimage-run # runs appimage apps
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    clinfo # shows info about OpenCL (GPU things) - TODO I don't recall why this is here, check if it's still needed and remove
    cliphist # clipboard history
    exfat # tools for ExFAT formatted disks
    exiftool # read & write exif data - integrates with digikam
    fuzzel # wayland app launcher
    git
    git-crypt # transparent file encryption for git
    gparted # drive partition manager
    home-manager # manage user configurations
    hyprcursor # xcursor replacement
    hyprpicker # pick colors from the screen
    isd # TUI for systemd services
    kitty # terminal
    libnotify # notification basics, includes notify-send
    micro # simple terminal editor
    nautilus # GNOME file manager, needed for niri file picker portal
    pass-wayland # local password manager
    powertop # power monitor
    pulseaudio # pactl

    (python3.withPackages (
      ps: with ps; [
        requests # needed for waybar weather script
      ]
    ))

    raffi
    samba # de janeiro! *da da da da, dadada, dada*
    slurp # select region on screen (used in screen recording script)
    sunsetr # blue light filter for wayland
    swayimg # image viewer
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    system-config-printer # printer configuration UI
    usbutils # provides lsusb
    virtiofsd # enables shared folders between host and VM - add <binary path="/run/current-system/sw/bin/virtiofsd"/> to filesystem XML if virtiofsd can't be found
    wf-recorder # screen recording
    wl-clipboard # wayland clipboard management
    waybar # wayland menu bar
    xwayland-satellite # runs X apps on wayland
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
