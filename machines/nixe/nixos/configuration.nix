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
  # The secrets.nix file is just a simple set like this:
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
  ];

  programs.nixvim = {
    enable = true;

    extraConfigLua = ''
      -- init transparent.nvim

      require('transparent').setup()
      require('transparent').clear_prefix('BufferLine')
      require('transparent').clear_prefix('NeoTree')
      -- require('transparent').clear_prefix('lualine')

      -- pet helpers
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      function Bird()
        local birds = { '🦆', '🪿', '🐧', '🐤', '🦢' }
        local bird_speed = {
          ['🦆'] = '5',
          ['🪿'] = '5',
          ['🐧'] = '3',
          ['🐤'] = '1',
          ['🦢'] = '3',
        }
        local birdIndex = math.random(1, #birds) -- or short math.random(#birds)
        local bird = birds[birdIndex]
        require('duck').hatch(bird, bird_speed[bird])
      end

      function Pet()
        local pets = { '🦆', '🪿', '🐧', '🐤', '🦢', '🐈', '🐌', '🐢', '🦑', '🦐', '🦀', '🐟', '🦔', '🦋', '🐞', '🪳', '🐜' }
        local speed_for = {
          ['🐌'] = '2',
          ['🐢'] = '5',
          ['🦋'] = '7',
          ['🐜'] = '15',
          ['🪳'] = '20',
          ['🦔'] = '30',
        }

        require('telescope.pickers').new({}, {
          prompt_title = 'Select Pet',
          finder = require('telescope.finders').new_table({
            results = pets,
          }),
          sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              -- Defer the number input to ensure the environment is ready
              vim.defer_fn(function()
                local speed = speed_for[selection[1]]

                if speed == nil then
                  local input_opts = {
                    prompt = 'Choose speed: ',
                    default = '7',
                  }

                  vim.ui.input(input_opts, function(input)
                    local number = tonumber(input) or 7.0
                    require('duck').hatch(selection[1], number)
                  end)
                else
                  require('duck').hatch(selection[1], speed)
                end
              end, 100)
            end)
            return true
          end
        }):find()
      end
    '';

    extraConfigVim = ''
      colorscheme pywal
    '';

    keymaps = [

      # sfx
      {
        key = "<leader>fml";
        action = "<CMD>CellularAutomaton make_it_rain<CR>";
        options.desc = "Let it rain";
      }
      {
        key = "<leader>brb";
        action = "<CMD>CellularAutomaton game_of_life<CR>";
        options.desc = "Game Of Life";
      }

      # pets
      {
        key = "<leader>pb";
        action = "<CMD>lua Bird()<CR>";
        options.desc = "Spawn bird :⁾";
      }
      {
        key = "<leader>ps";
        action = "<CMD>lua Pet()<CR>";
        options.desc = "Spawn pet :⁾";
      }
      {
        key = "<leader>pk";
        action = "<CMD>lua require('duck').cook_all()<CR>";
        options.desc = "Kill pets :⁽";
      }

    ];

    opts = {
      number = true; # show line numbers
      numberwidth = 3; # width of line number column
    };

    plugins = {
      bufferline.enable = true; # tabs

      # formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            bash = [ "shellcheck" ];
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];
            python = [
              "isort"
              "ruff_fix"
              "ruff_format"
            ];
            javascript = [
              [
                "prettierd"
                "prettier"
              ]
            ];
            typescript = [
              [
                "prettierd"
                "prettier"
              ]
            ];
            typst = [ "typstfmt" ];
            cs = [
              [
                "uncrustify"
                "csharpier"
              ]
            ];
            html = [ "htmlbeautifier" ];
            css = [ "stylelint" ];
            _ = "trim_whitespace";
          };
          formatters = {
            shellcheck = {
              command = lib.getExe pkgs.shellcheck;
            };
          };
        };
      };

      direnv.enable = true;
      gitsigns.enable = true; # git markers

      # markdown renderer
      glow = {
        enable = true;
        settings = {
          border = "rounded";
          height = 1000;
          width = 1000;
          height_ratio = 1.0;
          width_ratio = 1.0;
        };
      };

      # indentation hints
      indent-blankline = {
        enable = true;
        settings.indent.char = "¦";
        # settings.indent.char = "░";
      };

      lint.enable = true; # lint support
      lsp.enable = true; # lsp server
      lualine.enable = true; # bottom status line

      # file explorer
      neo-tree = {
        enable = true;
        addBlankLineAtTop = true;
        closeIfLastWindow = true;
        filesystem.filteredItems.hideDotfiles = false;
      };

      # notifications
      notify = {
        enable = true;
        render = "minimal";
        stages = "slide";
        timeout = 4000;
        topDown = true;
        fps = 60;
      };

      # icons
      mini = {
        enable = true;
        mockDevIcons = true;
        modules = {
          icons = { };
          # clue = { };
          # map = {
          #   symbols = {
          #     scroll_line = "█";
          #     scroll_view = "┃";
          #   };
          #   window = {
          #     focusable = false;
          #     side = "right";
          #     show_integration_count = true;
          #     width = 10;
          #     winblend = 25;
          #     zindex = 10;
          #   };
          # };
        };
      };

      # file explorer
      oil = {
        enable = true;
        settings = {
          default_file_explorer = false;
        };
      };

      overseer.enable = true; # task runner
      telescope.enable = true; # fuzzy finder

      todo-comments.enable = true; # highlight TODO and similar comments

      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          open_mapping = "[[<M-n>]]";
          float_opts.border = "curved";
        };
      };

      transparent.enable = true; # transparency

      # syntax highlighting
      treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          arduino
          astro
          awk
          bash
          c
          css
          csv
          cue
          dockerfile
          gdscript
          git_config
          gitignore
          gomod
          gosum
          javascript
          jq
          jsdoc
          json
          lua
          make
          markdown
          nix
          php
          python
          regex
          scss
          sql
          svelte
          toml
          tsx
          typescript
          vim
          vimdoc
          vue
          xml
          yaml
        ];

        settings.highlight.enable = true;
      };

      typescript-tools.enable = true; # something with typescript
      which-key.enable = true; # key hints
    };

    extraPlugins = with pkgs.vimPlugins; [
      pywal-nvim # dynamic color scheme

      # gremlins
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "vim-unicode-homoglyphs";
            src = pkgs.fetchFromGitHub {
              owner = "Konfekt";
              repo = name;
              rev = "c52e957edd1dcc679d221903b7e623ba15b155fb";
              hash = "sha256-zOQ1uAu3EJ8O+WSRtODGkC1WTlOOh13Dmkjg5IkkLqE=";
            };
          }
        );
      }

      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "vim-troll-stopper";
            src = pkgs.fetchFromGitHub {
              owner = "vim-utils";
              repo = name;
              rev = "24a9db129cd2e3aa2dcd79742b6cb82a53afef6c";
              hash = "sha256-5Fa/zK5f6CtRL+adQj8x41GnwmPWPV1+nCQta8djfqs=";
            };
          }
        );
      }

      # pets
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "duck.nvim";
            src = pkgs.fetchFromGitHub {
              owner = "tamton-aquib";
              repo = name;
              rev = "d8a6b08af440e5a0e2b3b357e2f78bb1883272cd";
              hash = "sha256-97QSkZHpHLq1XyLNhPz88i9VuWy6ux7ZFNJx/g44K2A=";
            };
          }
        );
      }

      # sfx
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "cellular-automaton.nvim";
            src = pkgs.fetchFromGitHub {
              owner = "Eandrju";
              repo = name;
              rev = "11aea08aa084f9d523b0142c2cd9441b8ede09ed";
              hash = "sha256-nIv7ISRk0+yWd1lGEwAV6u1U7EFQj/T9F8pU6O0Wf0s=";
            };
          }
        );
      }

      # requires nvim compiled with +sound
      # {
      #   plugin = (
      #     pkgs.vimUtils.buildVimPlugin rec {
      #       name = "typewriter.vim";
      #       src = pkgs.fetchFromGitHub {
      #         owner = "AndrewRadev";
      #         repo = name;
      #         rev = "514eeb4df6d9ff8926dd535afa8ca3b9514f36f0";
      #         hash = "sha256-nsqFSG7qel1FM+s7CDceG4IhWgPpnWM1jm/jar0ywiw=";
      #       };
      #     }
      #   );
      # }

      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    ];

  };

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

  fileSystems."/home/${username}/Remote/NAS" = {
    device = "//siren/nas";
    fsType = "cifs";

    options = [
      # this line prevents hanging on network split
      # automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      "user,uid=1000,gid=100,username=${secrets.nas-username},password=${secrets.nas-password},x-systemd.automount,noauto"
    ];
  };

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

  # Enable ollama to run LLMs
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    acceleration = "rocm";
  };

  # Enable web GUI for ollama
  services.open-webui = {
    enable = true;
    # port = 8080;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_AUTH = "False";
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
  hardware.pulseaudio.enable = false;
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
      appflowy
      arduino # code hardware things
      ascii-draw # draw diagrams etc in ASCII
      # bisq-desktop
      audacity
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
      # gossip # nostr client
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
      mediathekview # downloader for German public broadcasts
      milkytracker # music tracker
      nwg-look # GUI to theme GTK apps
      # obsidian # personal knowledge base
      opensnitch-ui # GUI for opensnitch application firewall
      orca # screen reader
      # openxcom
      pablodraw # ANSI/ASCII art drawing
      pika-backup # a backup thing
      prismlauncher # Minecraft launcher
      protonup-qt # GUI too to manage Steam compatibility tools
      qsynth # small gui for fluidsynth
      retroarch # multi system emulator
      rhythmbox # music player
      rosegarden
      scummvm # emulates old adventure games
      signal-desktop # messenger
      # simplex-chat-desktop # messenger
      sonic-pi # code music
      soundfont-fluid
      soundfont-ydp-grand
      soundfont-generaluser
      sparrow
      theforceengine # dark forces source port
      tor-browser-bundle-bin # browser for the evil dark web
      # ungoogled-chromium # chrome without google
      vlc # media player
      vscode # code editor
      wasabiwallet
      wtype # fake keypresses in wayland (bookmarks mgmt)
      yoshimi # software synthesizer
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
    # blueman # gtk based bluetooth manager
    brightnessctl # control screen brightness
    cifs-utils # mount samba shares
    clinfo
    cliphist # clipboard history
    door-knocker # check availability of portals
    drawing # basic image editor, similar to MS Paint
    easyeffects # effects for pipewire apps
    exfat # tools for ExFAT formatted disks
    exiftool # read & write exif data - integrates with digikam
    fuzzel # wayland app launcher
    gparted # drive partition manager
    grimblast # screenshot tool
    helvum # patchbay for PipeWire
    home-manager # manage user configurations
    htop # like top, but better
    hyprcursor # xcursor replacement
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
    # nh # shortcuts for common NixOS/home-manager commands
    # nix-output-monitor # nom nom nom
    # nvd # nix version diff
    oculante # fast image viewer
    pamixer # terminal volume control
    pavucontrol # GUI volume conrol
    peazip # archive utility - build is broken at the moment
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
    satty # screenshot annotation tool
    slurp # select region on screen (used in screen recording script)
    spice # VM stuff
    spice-gtk # VM stuff
    spice-protocol # VM stuff
    swayimg # image viewer
    swaynotificationcenter # wayland notifications
    swww # wayland background image daemon
    system-config-printer # printer configuration UI
    usbutils # provides lsusb
    # virtiofsd # enables shared folders between host and Windows VM
    virt-viewer # VM management GUI
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

  # AMD GPU HIP fix
  systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
}
