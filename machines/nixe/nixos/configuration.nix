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

  hostname = "nixe";
  username = "jigglycrumb";
  secrets = import ./secrets.nix;
  secrets-syncthing = import ../../../common/secret/syncthing.nix;
  secrets-wireguard = import ../../../common/secret/wireguard.nix;
in
{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    nixvim.nixosModules.nixvim
    (import ./nixvim.nix { inherit username; })
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50; # limit boot loader to the last 50 generations
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.extraModulePackages = [
  #   config.boot.kernelPackages.exfat-nofuse # enable ExFAT support
  # ];

  boot.initrd.kernelModules = [
    "amdgpu" # AMD graphics driver
    "sg" # generic SCSI for external DVD/BluRay drive support
    # "xpad"
  ];

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

  # enable ledger udev rules
  hardware.ledger.enable = true;

  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      50000 # rtorrent
    ];
    allowedUDPPorts = [
      50000 # rtorrent
      secrets-wireguard.port # wireguard
    ];
  };

  # Enable WireGuard
  # systemd.services.wireguard-wg0.wantedBy = [ ]; # lib.mkForce [ ]; # dont connect automatically # TODO doesnt seem to work, investigate

  # networking.wireguard.interfaces = {
  #   # "wg0" is the network interface name. You can name the interface arbitrarily.
  #   wg0 = {
  #     # Determines the IP address and subnet of the client's end of the tunnel interface.
  #     ips = secrets-wireguard.hosts.${hostname}.ips;

  #     listenPort = secrets-wireguard.port; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

  #     # Path to the private key file.
  #     #
  #     # Note: The private key can also be included inline via the privateKey option,
  #     # but this makes the private key world-readable; thus, using privateKeyFile is
  #     # recommended.
  #     privateKeyFile = "/home/${username}/.wireguard-keys/${hostname}-wireguard.private";

  #     peers = secrets-wireguard.hosts.${hostname}.peers;
  #   };
  # };

  networking.wg-quick.interfaces = {
    home = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      address = secrets-wireguard.hosts.${hostname}.ips;
      autostart = false;

      listenPort = secrets-wireguard.port; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/home/${username}/.wireguard-keys/${hostname}-wireguard.private";

      peers = secrets-wireguard.hosts.${hostname}.peers;
    };
  };

  networking.extraHosts = "192.168.100.1 home"; # add wireguard endpoint to hosts file

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
    "dotnet-runtime-wrapped-7.0.20"
    "dotnet-sdk-7.0.410"
    "dotnet-sdk-wrapped-7.0.410"
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.excludePackages = [ pkgs.xterm ]; # don't install xterm

  # Enable automatic discovery of remote drives
  services.gvfs.enable = true;

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
    xwayland.enable = true;
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
    # wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # fileSystems."/home/${username}/Remote/NAS" = {
  #   device = "//siren/nas";
  #   fsType = "cifs";

  #   options = [
  #     # this line prevents hanging on network split
  #     # automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
  #     "user,uid=1000,gid=100,username=${secrets.nas-username},password=${secrets.nas-password},x-systemd.automount,noauto"
  #   ];
  # };

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
    package = pkgs.ollama-rocm;
    acceleration = "rocm";
  };

  # Enable web GUI for ollama
  services.open-webui = {
    enable = true;
    port = 4141; # 8080;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      # WEBUI_AUTH = "False";
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    configDir = "/home/${username}/.config/syncthing";
    user = "${username}";
    group = "users";

    cert = "/home/${username}/nixfiles/machines/${hostname}/nixos/secret/syncthing/cert.pem";
    key = "/home/${username}/nixfiles/machines/${hostname}/nixos/secret/syncthing/key.pem";

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    settings = {
      options = {
        urAccepted = -1; # disable telemetry
      };

      devices = {
        siren = secrets-syncthing.devices.siren;
      };

      folders = secrets-syncthing.folders."${hostname}";
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

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

  # Enable Virt-manager
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      # runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMFFull.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
      vhostUserPackages = [ pkgs.virtiofsd ];
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
      appflowy
      arduino # code hardware things
      ascii-draw # draw diagrams etc in ASCII
      audacity # audio recorder/editor
      blanket # ambient sounds
      brave # web browser
      bruno # API client/tester/explorer
      celestia # spaaaaaaaaaaace
      nemo-with-extensions # file manager
      clipgrab # youtube downloader
      cool-retro-term # terminal emulator
      czkawka # remove useless files
      cryptomator # file encryption
      # davinci-resolve # video editor
      devilutionx # Diablo
      devour # devours your current terminal
      digikam # photo manager
      discord # (voice)chat
      distrobox # run others distros in containers
      door-knocker # check availability of portals
      dosbox-staging # emulates DOS software
      drawing # basic image editor, similar to MS Paint
      easyeffects # effects for pipewire apps
      easytag # edit mp3 tags
      fallout-ce # port of Fallout for modern systems
      ffmpeg # needed for mediathekview
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
      helvum # patchbay for PipeWire
      heroic # GUI for GOG & Epic Games
      hydrogen # drum machine
      ioquake3 # Quake 3 Arena source port
      jstest-gtk # simple joystick testing GUI
      kdenlive # video editor
      # keeperrl # roguelike
      krita # painting software
      kstars # spaaaaaaaaaaace
      letterpress # convert images to ascii art
      libreoffice # office suite
      # lmms # DAW similar to FL Studio
      # lmstudio # desktop app to run LLMs
      losslesscut-bin # cut video fast
      lutris # play games
      makemkv # DVD & Blu-Ray ripper
      # mattermost-desktop
      mediathekview # downloader for German public broadcasts
      milkytracker # music tracker
      networkmanagerapplet # tray app for network management
      nwg-look # GUI to theme GTK apps
      # obsidian # personal knowledge base
      oculante # fast image viewer
      # oh-my-git # a learning game about git
      # opensnitch-ui # GUI for opensnitch application firewall
      orca # screen reader
      # openxcom # xcom source port
      pablodraw # ANSI/ASCII art drawing
      pavucontrol # GUI volume conrol
      peazip # archive utility
      pika-backup # a backup thing
      prismlauncher # Minecraft launcher
      protonup-qt # GUI too to manage Steam compatibility tools
      qsynth # small gui for fluidsynth
      retroarch # multi system emulator
      rhythmbox # music player
      # rosegarden
      scummvm # emulates old adventure games
      signal-desktop # messenger
      slack # chat thing
      # simplex-chat-desktop # messenger
      sonic-pi # code music
      sparrow
      teamspeak_client # voice chat
      theforceengine # dark forces source port
      tor-browser-bundle-bin # browser for the evil dark web
      # ungoogled-chromium # chrome without google
      virt-viewer # VM management GUI
      vlc # media player
      wargus # Warcraft 2 port
      wtype # fake keypresses in wayland (bookmarks mgmt)
      yoshimi # software synthesizer
      zed-editor # editor
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

  # alternative
  # services.udev.packages = with pkgs; [
  #   ledger-udev-rules
  #   trezor-udev-rules
  #   # potentially even more if you need them
  # ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run # runs appimage apps
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    clinfo
    cliphist # clipboard history
    exfat # tools for ExFAT formatted disks
    exiftool # read & write exif data - integrates with digikam
    fuzzel # wayland app launcher
    gparted # drive partition manager
    grimblast # screenshot tool (used in screenshot script)
    home-manager # manage user configurations
    hyprcursor # xcursor replacement
    hyprkeys # print hyprland key bindings
    hyprpicker # pick colors from the screen
    kitty # terminal
    libnotify # notification basics, includes notify-send
    libsForQt5.ark # KDE archive utility
    linuxKernel.packages.linux_libre.cpupower # switch CPU governors
    lxqt.lxqt-policykit
    micro # terminal editor

    # nh # shortcuts for common NixOS/home-manager commands
    # nix-output-monitor # nom nom nom
    # nvd # nix version diff

    powertop # power monitor
    pulseaudio # pactl

    (python3.withPackages (
      ps: with ps; [
        requests # needed for waybar weather script
      ]
    ))

    radeontop
    rocmPackages.rocminfo

    samba # de janeiro! *da da da da, dadada, dada*
    # satty # screenshot annotation tool
    slurp # select region on screen (used in screen recording script)
    spice # VM stuff
    spice-gtk # VM stuff
    spice-protocol # VM stuff
    swayimg # image viewer
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    system-config-printer # printer configuration UI
    usbutils # provides lsusb
    virtiofsd # enables shared folders between host and VM - add <binary path="/run/current-system/sw/bin/virtiofsd"/> to filesystem XML if virtiofsd can't be found
    wf-recorder # screen recording
    wl-clipboard # wayland clipboard management
    wlogout # wayland logout,lock,etc screen
    wlsunset # day/night gamma adjustments
    waybar # wayland menu bar

    # wayland bar
    # (waybar.overrideAttrs (oldAttrs: {
    #   mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    # }))
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

  # Hardware specific stuff --------------------------------------------------

  # Game controller settings

  # We don't need this, it's enabled via the steam module
  # hardware.steam-hardware.enable = true;

  # Udev rules to start or stop systemd service when controller is connected or disconnected
  services.udev.extraRules = ''
    # Make 8Bitdo Ultimate Controller work as XBox 360 gamepad
    # May vary depending on your controller model, find product id using 'lsusb'
    SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3106", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl start 8bitdo-ultimate-xinput@2dc8:3106"
    # This device (2dc8:3016) is "connected" when the above device disconnects
    SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3016", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl stop 8bitdo-ultimate-xinput@2dc8:3106"

    # Make Jade Wallet work with Blockstream Green
    KERNEL=="ttyUSB*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="jade%n"
    KERNEL=="ttyACM*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="jade%n"
  '';

  # AMD GPU HIP fix
  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
}
