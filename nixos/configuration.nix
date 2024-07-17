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
  imports = [
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
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

  # networking.firewall.trustedInterfaces = [ "virbr0" ];

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

  # Enable automatic discovery of remote drives
  services.gvfs.enable = true;

  # TODO: review this
  services.cockpit.enable = true;

  # TODO: finish this: enable tuigreet from wlogout, disable autologin
  services.greetd = {
    enable = true;
    package = pkgs.greetd.tuigreet;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "${username}";
      };
      default_session = initial_session;
    };
  };

  #environment.etc."greetd/environments".text = ''
  #  Hyprland
  #'';

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "de";
      variant = "";
    };

    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-theme='Arc-Dark'
  '';

  services.openssh.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # fix lag in Brave & other Chromium-based browsers - EDIT: disabled again, does not fix lag
  };

  environment.sessionVariables = {
    # NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "x11";
    MOZ_ENABLE_WAYLAND = "1";
    # QT_QPA_PLATFORM = "wayland";
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true; # enable portal for wayland
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable OpenSnitch application firewall
  services.opensnitch.enable = true;

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
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
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

  # Enable Virt-manager
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;
  programs.virt-manager.enable = true;

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
      affine # workspace / knowledge space
      angryipscanner # network scanner
      appeditor # gui to edit app launcher entries (.desktop files)
      arduino # code hardware things
      ascii-draw # draw diagrams etc in ASCII
      # bisq-desktop
      audacity
      blanket # ambient sounds
      brave # web browser
      bruno # API client/tester/explorer
      celestia # spaaaaaaaaaaace
      cinnamon.nemo-with-extensions # file manager
      clipgrab # youtube downloader
      cool-retro-term # terminal emulator
      czkawka # remove useless files
      cryptomator # file encryption
      devilutionx # Diablo
      devour # devours your current terminal
      digikam # photo manager
      discord # (voice)chat
      dosbox-staging # emulates DOS software
      easytag # edit mp3 tags
      # electrum
      # ffmpeg # needed for mediathekview
      firefox # web browser
      furnace # multi-system chiptune tracker
      gimp # image manipulation
      cheese # webcam fun
      evince # document viewer
      seahorse # keyring manager
      simple-scan # scan documents
      godot_4 # game engine
      gossip # nostr client
      grandorgue # virtual pipe organ
      handbrake # video encoding
      heroic # GUI for GOG & Epic Games
      hydrogen # drum machine
      jstest-gtk # simple joystick testing GUI
      kdenlive # video editor
      keeperrl # roguelike
      krita # painting software
      kstars # spaaaaaaaaaaace
      letterpress # convert images to ascii art
      lmms # DAW similar to FL Studio
      localsend # like Airdrop
      losslesscut-bin # cut video fast
      lutris # play games
      makemkv # DVD & Blu-Ray ripper
      # mattermost-desktop
      # mediathekview # downloader for German public broadcasts
      milkytracker # music tracker
      # obsidian # personal knowledge base
      opensnitch-ui # GUI for opensnitch application firewall
      # openxcom
      pika-backup # a backup thing
      protonup-qt # GUI too to manage Steam compatibility tools
      qsynth # small gui for fluidsynth
      retroarch # multi system emulator
      rhythmbox # music player
      rosegarden
      scummvm # emulates old adventure games
      signal-desktop # messenger
      simplex-chat-desktop # messenger
      sonic-pi # code music
      sparrow
      theforceengine # dark forces source port
      tor-browser-bundle-bin # browser for the evil dark web
      # ungoogled-chromium # chrome without google
      vlc # media player
      vscode # code editor
      wasabiwallet
      wtype # fake keypresses in wayland (bookmarks mgmt)
      zed-editor # code editor
    ];
  };

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable AppImages to run directly
  programs.appimage.binfmt = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "${username}";

  services.hypridle.enable = true; # enable hyprland idle daemon
  programs.hyprlock.enable = true; # enable hyprland screen lock

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
    extraConfig = "font-size=18\nxkb-layout=de";
  };

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

  # enable ledger udev rules
  hardware.ledger.enable = true;

  # alternative
  # services.udev.packages = with pkgs; [
  #   ledger-udev-rules
  #   trezor-udev-rules
  #   # potentially even more if you need them
  # ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run # runs appimage apps
    # blueman # gtk based bluetooth manager
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    clinfo
    cliphist # clipboard history
    door-knocker # check availability of portals
    drawing # basic image editor, similar to MS Paint
    # egl-wayland
    easyeffects # effects for pipewire apps
    exiftool # read & write exif data - integrates with digikam
    fuzzel # wayland app launcher
    adwaita-icon-theme # VM stuff
    gparted # drive partition manager
    gpu-viewer # gui for GPU info
    gpuvis # gpu trace visualizer
    grimblast # screenshot tool
    helvum # patchbay for PipeWire
    home-manager # manage user configurations
    htop # like top, but better
    hyprkeys # print hyprland key bindings
    hyprpicker # pick colors from the screen
    inetutils # telnet
    jq # query JSON
    killall # Gotta kill 'em all! Currently used in screen recorder script
    kitty # terminal
    libreoffice # office suite
    libnotify # notification basics, includes notify-send
    libsForQt5.ark # KDE archive utility
    linuxKernel.packages.linux_libre.cpupower # switch CPU governors
    lxqt.lxqt-policykit
    mc # dual pane terminal file manager
    micro # terminal editor
    neofetch # I use nix btw
    networkmanagerapplet # tray app for network management
    nh # shortcuts for comomon NixOS/home-manager commands
    nix-output-monitor # nom nom nom
    nvd # nix version diff
    oculante # fast image viewer
    pamixer # terminal volume control
    pavucontrol # GUI volume conrol
    # peazip # archive utility - build is broken at the moment
    powertop # power monitor
    pulseaudio # pactl

    (python3.withPackages (ps: with ps; [ requests ])) # needed for waybar weather script

    radeontop
    rocmPackages.rocminfo

    samba # de janeiro! *da da da da, dadada, dadada*
    satty # screenshot annotation tool
    slurp # select region on screen (used in screen recording script)
    spice # VM stuff
    spice-gtk # VM stuff
    spice-protocol # VM stuff
    swayimg # image viewer
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    usbutils # provides lsusb
    virtiofsd # enables shared folders between host and Windows VM
    virt-viewer # VM stuff
    wget # download stuff
    wf-recorder # screen recording
    wl-clipboard # wayland clipboard management
    wlogout # wayland logout,lock,etc screen
    wlsunset # day/night gamma adjustments
    xboxdrv # X-Box gamepad support, I think

    # wayland bar
    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
  ];

  fileSystems."/home/${username}/Remote/NAS" = {
    device = "//wopr/nas";
    fsType = "cifs";

    options = [
      # this line prevents hanging on network split
      # automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      "user,uid=1000,gid=100,username=${secrets.nas-username},password=${secrets.nas-password},x-systemd.automount,noauto"
    ];
  };

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 34113 ];
    # allowedUDPPortRanges = [
    #   { from = 4000; to = 4007; }
    #   { from = 8000; to = 8010; }
    # ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Hardware specific stuff --------------------------------------------------

  # Game controller settings

  # We don't need this, it's enabled via the steam module
  # hardware.steam-hardware.enable = true;

  # Make 8Bitdo Ultimate Controller work as XBox 360 gamepad
  # Udev rules to start or stop systemd service when controller is connected or disconnected
  services.udev.extraRules = ''
    # May vary depending on your controller model, find product id using 'lsusb'
    SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3106", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl start 8bitdo-ultimate-xinput@2dc8:3106"
    # This device (2dc8:3016) is "connected" when the above device disconnects
    SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3016", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl stop 8bitdo-ultimate-xinput@2dc8:3106"
  '';

  # Systemd service which starts xboxdrv in xbox360 mode
  systemd.services."8bitdo-ultimate-xinput@" = {
    unitConfig.Description = "8BitDo Ultimate Controller XInput mode xboxdrv daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xboxdrv}/bin/xboxdrv --mimic-xpad --silent --type xbox360 --device-by-id %I --force-feedback";
    };
  };

  boot.initrd.kernelModules = [
    "amdgpu"
    "sg"
    # "xpad"
  ];

  # AMD GPU HIP fix
  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.powerOnBoot = true;reboot

  # Enable Vulkan
  hardware.graphics.enable = true;
  # For 32 bit applications
  hardware.graphics.enable32Bit = true;

  # Enable amdvlk driver - apps choose between mesa and this one
  # amdvlk is not needed for basic vulkan support but nice to have I guess
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
    # rocmPackages
    rocmPackages.clr.icd
    rocmPackages.rocm-runtime
    rocmPackages.rocm-smi
    # rocm-opencl-icd
    # rocm-runtime-ext
  ];

  # For 32 bit applications
  # Only available on unstable
  hardware.graphics.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];

}
