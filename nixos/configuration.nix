# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Import secrets
  #
  # !!! WARNING !!!
  # This approach is far from ideal since the secrets will end up in the locally readable /nix/store
  # It is however, an easy way for keeping the secrets out of the repo until I've learned enough nix to implement a better solution
  # The secrets.nix file is just a simple set like this:
  #
  # {
  #   github-token = "<insert token here>";
  # }

  secrets = import ./secrets.nix;
  username = "jigglycrumb";
in
{
  imports =
    [
      # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50; # limit boot loader to the last 50 generations
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixe"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.excludePackages = [ pkgs.xterm ]; # don't install xterm

  # Enable the Pantheon Desktop Environment.
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.pantheon.enable = true;
  # Fix problem which prevents login after hibernation by enabling the gtk greeter
  # services.xserver.displayManager.lightdm.greeters.pantheon.enable = false;
  # services.xserver.displayManager.lightdm.greeters.gtk.enable = true;

  # services.xserver.desktopManager.pantheon.extraWingpanelIndicators = with pkgs; [
  #   monitor
  #   wingpanel-indicator-ayatana
  # ];
  # services.xserver.desktopManager.pantheon.extraSwitchboardPlugs = [ ];

  # systemd.user.services.indicatorapp = {
  #   description = "indicator-application-gtk3";
  #   wantedBy = [ "graphical-session.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
  #   };
  # };

  # Skip some default pantheon apps
  environment.pantheon.excludePackages = with pkgs.pantheon; [
    appcenter # Software center
    epiphany # Web browser
  ];

  # Enable automatic discovery of remote drives
  services.gvfs.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";

    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

  };

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-theme='Arc-Dark'
  '';


  programs.hyprland = {
    enable = true;
    # xwayland.enable = true; # fix lag in Brave & other Chromium-based browsers - EDIT: disabled again, does not fix lag
  };

  # hint electron apps to use wayland
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";


  # Configure console keymap
  console.keyMap = "de";

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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable ZSH
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    setOptions = [ "RM_STAR_WAIT" ];
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" "pattern" "cursor" ];
      patterns = {
        "rm -rf *" = "fg=white,bold,bg=red";
      };
    };
    histSize = 10000;
  };
  environment.pathsToLink = [ "/libexec" "/share/zsh" ];
  environment.shells = with pkgs; [ zsh ];

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable VirtualBox
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = true;

  # Enable Virt-manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      tumbler # thumbnail previews
      thunar-volman # removable device management
      thunar-archive-plugin # archive creation and extraction
      thunar-media-tags-plugin # view/edit ID3/OGG tags
    ];
  };

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
      "networkmanager"
      "vboxusers"
      "wheel"
      # "libvirtd"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      appeditor # edit panthon app launcher entries
      arduino # code hardware things
      # bottles
      brave # web browser
      clipgrab # youtube downloader
      cryptomator # file encryption
      darktable # photo manager
      digikam # photo manager
      discord # (voice)chat
      dosbox-staging # emulates DOS software
      easytag # edit mp3 tags
      etcher # burn images to SD cards
      firefox # web browser
      flatpak # flatpak support
      gimp # image manipulation
      gnome.gnome-software # needed for flatpak
      gnome.evince # document viewer
      gnome.seahorse # keyring manager
      gnome.simple-scan # scan documents
      godot_4 # game engine
      # gparted # drive partition manager
      handbrake # video encoding
      heroic # GUI for GOG & Epic Games
      jstest-gtk # simple joystick testing GUI
      # logseq
      makemkv # DVD & Blu-Ray ripper
      # mattermost-desktop
      mediathekview # downloader for German public broadcasts
      milkytracker
      nix-info

      # pantheon.elementary-files
      # pantheon.elementary-music
      # pantheon.elementary-photos
      # pantheon.elementary-videos

      pika-backup # a backup thing
      protonup-qt # GUI too to manage Steam compatibility tools
      scummvm # emulates old adventure games
      signal-desktop # private messenger
      sonic-pi # code music
      tor-browser-bundle-bin # browser for the evil dark web
      ungoogled-chromium # chrome without google
      vlc # media player
      vscode # code editor
      # vscodium
      # vscodium-fhs
      # wine
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.1.9"
  ];

  services.flatpak.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "${username}";

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
      };
    };

  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run # runs appimage apps
    # blueman # gtk based bluetooth manager
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    cliphist # clipboard history
    drawing # basic image editor, similar to MS Paint
    egl-wayland
    gparted # drive partition manager
    home-manager # manage user configurations
    htop # like top, but better
    hyprpicker # pick colors from the screen
    hyprkeys # print hyprland key bindings
    # indicator-application-gtk3
    inetutils # telnet
    # input-remapper # maps keys
    # keymapper # maps keys
    # keyd # maps keys
    kitty # terminal
    libreoffice # office suite
    libnotify # notification basics, includes notify-send
    mc # shell file manager
    musikcube # cli music player
    neofetch # I use nix btw
    networkmanagerapplet # tray app for network management
    # oculante # fast image viewer
    ollama # run LLMs locally

    pamixer # volume control in hyprland
    pcmanfm # file manager
    peazip # archive utility
    rofi-wayland # launcher
    rofimoji # emoji picker
    samba # de janeiro! *da da da da, dadada, dadada*
    shotman # screenshot tool
    swayidle
    swayimg # image viewer
    swaylock-effects # screen locker
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    virt-manager # virtual machines
    waybar # wayland bar
    wget
    wl-clipboard # wayland clipboard management
    wlogout # wayland logout,lock,etc screen

    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    })
    )
  ];

  # programs.pantheon-tweaks.enable = true;

  fileSystems."/home/${username}/Remote/NAS" = {
    device = "//wopr/nas";
    fsType = "cifs";

    options = [
      # this line prevents hanging on network split
      # automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      "user,uid=1000,gid=1000,username=${secrets.nas-username},password=${secrets.nas-password},x-systemd.automount,noauto"
    ];
  };


  # fonts.packages = with pkgs; [
  #   noto-fonts
  #   noto-fonts-cjk
  #   noto-fonts-emoji
  #   liberation_ttf
  #   fira-code
  #   fira-code-symbols
  #   mplus-outline-fonts.githubRelease
  #   dina-font
  #   proggyfonts
  # ];

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?


  # Hardware specific stuff --------------------------------------------------

  boot.initrd.kernelModules = [ "amdgpu" ];

  # AMD GPU HIP fix
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.powerOnBoot = true;reboot

  # Enable Vulkan
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

  # Enable amdvlk driver - apps choose between mesa and this one
  # amdvlk is not needed for basic vulkan support but nice to have I guess
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
  ];
  # For 32 bit applications
  # Only available on unstable
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];


}
