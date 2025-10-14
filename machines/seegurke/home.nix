{
  config,
  pkgs,
  # inputs,
  ...
}:

let

  # Import secrets
  #
  # !!! WARNING !!!
  # This approach is far from ideal since the secrets will end up in the locally readable /nix/store
  # It is however, an easy way for keeping the secrets out of the repo until I've learned enough nix to implement a better solution
  # The secrets.nix file is just a simple set like this:
  #
  # {
  #   github-token = "<token>";
  #   weather-location = "<city>";
  # }

  secrets = import ../../common/secret/home.nix;
  username = "jigglycrumb";
  common = ../../common;

in
{
  # imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  # programs.nixvim = {
  #   enable = true;
  # };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    alsa-utils # aplay
    # angband # lotr terminal roguelike
    asciicam # webcam in the terminal
    asciiquarium # a fishy app
    atac # a terminal api client (like postman)
    bat # fancy `cat` replacement
    bluetuith # terminal bluetooth manager
    browsh # terminal web browser
    btop # like top, but better
    caligula # burn/flash images to SD cards from the terminal
    castero # terminal podcast client
    cava # terminal audio visualizer
    cbonsai # terminal tree
    cfonts # ansi fonts
    chess-tui # terminal chess
    cmatrix # there is no spoon
    confetty # 🎊
    cowsay # moo
    # crawl # roguelike
    # daktilo # typewriter sounds for the keyboard
    ddate # discordian date
    delta # git diffs done right
    devd # on-demand webserver
    doge # much wow
    dooit # todo tui
    dysk # a better 'df'
    epy # terminal ebook reader
    eza # ls replacement
    fast-ssh # ssh connection manager
    file # identify file types
    font-awesome # icons for waybar (does not work in environment.systemPackages)
    fortune # mmh cookies
    frotz # infocom game interpreter
    fzf # fuzzy finder (zoxide)
    gifgen # jen jifs from video files
    gitui # git tui
    glow # markdown reader
    go # go programming language
    gum # various little helpers
    hollywood # hacking...
    htop # process monitor
    hyprland-monitor-attached # run scripts when monitors plug
    hyprshot # screenshot utility
    iftop # network monitoring
    inetutils # telnet
    jp2a # convert jpg and png to ascii art
    jq # query JSON
    killall # Gotta kill 'em all! Currently used in screen recorder script
    lazygit # git tui
    clolcat # 🌈
    lynx # terminal web browser, can be scripted for tasks
    mc # dual pane terminal file manager
    md-tui # markdown renderer
    meld # merge tool
    minesweep-rs # terminal minesweeper
    mprocs # run multiple processes at the same time
    mpv # video player
    # musikcube # cli music player
    ncdu # show disk usage
    neofetch # I use nix btw
    nms # decrypting...
    nixfmt-rfc-style # formatter for nix code, used in VSCode
    nodejs
    npm-check-updates # tool to check package.json for updates
    nyancat # nyan nyan nyan
    pamixer # terminal volume control
    pipes # terminal screensaver
    ponysay # like cowsay, but 20% cooler
    pywal16 # color schemes from images
    # pywalfox-native # style firefox with pywal
    # rtorrent # terminal torrent client
    screen
    scope-tui # terminal oscilloscope
    sl # choo choo
    solitaire-tui # terminal card game
    speedread # read text fast
    sshpass # use ssh password auth within scripts - used for deploying proxmox VM configs
    sshs # ssh connection manager
    tasktimer # task timer
    # textual-paint # terminal ms paint
    tealdeer # man but short
    terminal-parrot # party parrot
    termpdfpy # graphical pdf/ebook reader for kitty
    # termusic # music player - very promising, but crashes a lot currently
    # termshark # wireshark for the terminal
    tmux
    trash-cli # use trash can in the terminal
    tui-journal # terminal journal app
    tuifeed # terminal feed reader
    unzip # extract zip files
    # ventoy # create multi-boot usb sticks
    vitetris # terminal tetris
    wavemon # Wifi monitoring
    wget # download stuff
    wiki-tui # terminal wikipedia
    yazi # terminal file manager
    yt-dlp # terminal downloader for Youtube etc

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    "Applications/pico-8/pico8.nix".source = common + /home/Applications/pico-8/pico8.nix;
    "Applications/pico-8/run.sh".source = common + /home/Applications/pico-8/run.sh;

    ".cache/weather-location".text = ''
      ${secrets.weather-location}
    '';

    ".config/atuin/config.toml".source = common + /dotfiles/config/atuin/config.toml; 
    ".config/direnv/direnv.toml".source = common + /dotfiles/config/direnv/direnv.toml;
    ".config/fuzzel/scripts".source = common + /dotfiles/config/fuzzel/scripts;
    ".config/hypr".source = common + /dotfiles/config/hypr;
    ".config/kitty".source = common + /dotfiles/config/kitty;
    # ".config/niri".source = ./dotfiles/config/niri;
    ".config/raffi".source = common + /dotfiles/config/raffi;
    ".config/starship.toml".source = common + /dotfiles/config/starship.toml;
    ".config/sunsetr".source = common + /dotfiles/config/sunsetr;
    ".config/swaync".source = common + /dotfiles/config/swaync;
    ".config/Thunar/uca.xml".source = common + /dotfiles/config/Thunar/uca.xml;
    ".config/wal/templates".source = common + /dotfiles/config/wal/templates;

    ".config/waybar/config".source = ./dotfiles/config/waybar/config;
    ".config/waybar/scripts".source = common + /dotfiles/config/waybar/scripts;
    ".config/waybar/style.css".source = common + /dotfiles/config/waybar/style.css;

    ".functions".source = common + /dotfiles/functions;
    ".screenrc".source = common + /dotfiles/screenrc;
    ".scripts".source = common + /dotfiles/scripts;
    ".sounds".source = common + /dotfiles/sounds;

    ".rtorrent.rc".source = common + /dotfiles/rtorrent.rc;
    ".wgetrc".source = common + /dotfiles/wgetrc;

    ".local/share/applications/appimage".source = ./dotfiles/local/share/applications/appimage;
    ".local/share/applications/other".source = common + /dotfiles/local/share/applications/other;
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jigglycrumb/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    # name = "Bibata-Modern-Classic";
    name = "Bibata-Modern-Ice";

    # package = pkgs.banana-cursor;
    # name = "Banana";
    size = 22;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable atuin for shell history
  programs.atuin.enable = true;

  # Enable starship shell prompt
  programs.starship = {
    enable = true;
  };

  # Enable zoxide for cd
  programs.zoxide.enable = true;
  programs.zoxide.options = [ "--cmd cd" ];

  # enable gnome keyring
  services.gnome-keyring.enable = true;
  services.gnome-keyring.components = [
    "pkcs11"
    "secrets"
    "ssh"
  ];

  # Let virt-manager connect to KVM
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Use dark theme in GTK apps
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # gtk = {
  #   enable = true;
  #   # iconTheme = {
  #   #   name = "elementary-Xfce-dark";
  #   #   package = pkgs.elementary-xfce-icon-theme;
  #   # };
  #   # theme = {
  #   #   name = "zukitre-dark";
  #   #   package = pkgs.zuki-themes;
  #   # };
  # };

  programs.gpg.enable = true;

  services.gpg-agent.enable = true;

  # services.swaync # todo check

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    attributes = [
      # Automatically normalize line endings for all text-based files
      "* text=auto"
    ];
    delta = {
      enable = true;
      options = {
        features = "line-numbers decorations";
        syntax-theme = "Monokai Extended Bright";
      };
    };
    userEmail = "1476865+jigglycrumb@users.noreply.github.com";
    userName = "jigglycrumb";
    extraConfig = {
      apply = {
        # Detect whitespace errors when applying a patch
        whitespace = "fix";
      };
      branch = {
        # Use `origin` as the default remote on the `main` and `master` branches in all cases
        main = {
          remote = "origin";
          merge = "refs/heads/main";
        };

        master = {
          remote = "origin";
          merge = "refs/heads/master";
        };
      };
      color = {
        # Use colors in Git commands that are capable of colored output when outputting to the terminal
        ui = "auto";

        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };

        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
        };

        status = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
      };
      core = {
        # Treat spaces before tabs, lines that are indented with 8 or more spaces, and all kinds of trailing whitespace as an error
        whitespace = "space-before-tab, indent-with-non-tab, trailing-space";
        autocrlf = false;
      };
      github = {
        user = "jigglycrumb";
        token = secrets.github-token;
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        # Include summaries of merged commits in newly created merge commit messages
        log = true;
        tool = "meld";
      };
      mergetool = {
        keepBackup = false;
        meld = {
          cmd = ''meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'';
        };
      };
      push = {
        default = "simple";
      };
      remote = {
        origin = {
          push = "HEAD";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;

    # test - probably not needed anymore since atuin is used
    # history = {
    #   ignoreAllDups = true;
    #   ignorePatterns = [
    #     "ls"
    #     "pwd"
    #     "date"
    #     "* --help"
    #     "man"
    #     "tldr"
    #   ];
    # };

    oh-my-zsh.enable = true;

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          hash = "sha256-/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
        };
      }
    ];

    initExtra = ''
      autoload -U compinit && compinit
      autoload zmv

      # load functions
      source ~/.functions/git-ls
      source ~/.functions/misc

      COMPLETION_WAITING_DOTS=true

      # add own scripts to PATH
      export PATH="$PATH:$HOME/.scripts"

      # add go binaries to PATH
      # TODO explore $GOPATH and move this folder
      export PATH="$PATH:$HOME/go/bin"

      # this makes kitty use the current pywal colors instantly
      # on launch, not just after refresh
      cat ~/.cache/wal/sequences

      echo ""
      echo " It's $(ddate +'%{%A, the %e of %B%}, %Y. %N%nCelebrate %H ')" | clolcat
      echo ""
      echo " Wise llama says:" | clolcat
      echo ""
      fortune | cowsay -f llama | clolcat
      echo ""
    '';

    shellAliases = {
      c = "clear";
      "c." = "code .";

      "n" = "nvim";
      "nn" = "nvim .";

      # cat = "bat";
      g = "git";
      icat = "kitty +kitten icat";
      pico8 = "cd ~/Applications/pico-8 && ./run.sh";
      lolcat = "clolcat";


      # Mass rename utility, usage: mmv lolcat_<1-100>.jpg lolcat_*_thumb.jpg
      mmv = "noglob zmv -W";

      # npm shortcuts
      npm-list-global = "npm list -g --depth=0";
      npm-list-here = "npm list --depth=0";
      npm-reset = "rm -rf node_modules package-lock.json && npm i";

      ns = "npm start";
      nr = "npm run";
      nt = "npm test";

      # git shortcuts
      gitlog = "git log --graph --pretty=format:'%C(auto)%h -%d %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";

      ga = "git add";
      gaa = "git add --all";
      gb = "git branch";
      gbc = "git checkout -b";
      gcb = "git checkout -b";
      gbd = "git branch -D";
      gc = "git checkout";
      gco = "git commit";
      gcom = "git commit -m";
      gd = "git diff";
      gm = "git merge";
      gmv = "git mv";
      gp = "git pull";
      gpsh = "git push";
      grm = "git rm";
      gs = "git status";
      save = "git stash";
      load = "git stash apply";

      # Nix the planet
      run-msdos = "WD=$(pwd) && cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#msdos622 && cd $WD";
      run-win311 = "WD=$(pwd) && cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#wfwg311&& cd $WD";
      run-win98 = "WD=$(pwd) && cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#win98 && cd $WD";

      # NixOS specific things
      boot-mode = "[ -d /sys/firmware/efi/efivars ] && echo \"UEFI\" || echo \"Legacy\"";
      nixos-cleanup = "home-manager expire-generations '-7 days' && sudo nix-collect-garbage --delete-older-than 7d"; 
      nixos-update = "(~/nixfiles/machines/$(hostname) && nix flake update)";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixfiles/machines/$(hostname) --impure";

      # VPN
      vpn-up = "sudo systemctl start wg-quick-home.service";
      vpn-down = "sudo systemctl stop wg-quick-home.service";

      # OSX debris

      # Recursively delete OSX `.DS_Store` files
      clean-ds_store = "find . -type f -name '*.DS_Store' -ls -delete";
      # Recursively delete OSX resource forks
      clean-osx-shitfiles = "find . -type f -name '._*' -ls -delete";

      # fun
      decrypt-cookie = "fortune | nms -a | lolcat";
      sl = "aplay -q ~/.sounds/train.wav & sl";
      space-opera = "telnet towel.blinkenlights.nl";

      # games
      diablo = "(cd ~/Games/Diablo && devilutionx) &";
      diablo-hellfire = "(cd ~/Games/Diablo && devilutionx --hellfire) &";

    };
  };

  # wayland.windowManager.hyprland = {
  #   enable = true; # enable Hyprland
  #   plugins = with pkgs.hyprlandPlugins; [
  #     hyprspace
  #     hyprsplit
  #   ];
  # };

  # do not create ~/Public & ~/Templates
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };
}
