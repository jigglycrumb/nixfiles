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
  imports = [
    ../../common/modules/pico-8/pico-8.nix
  ];

  modules.pico-8.username = username;
  modules.pico-8.cart-path = "Projects/Github/Private/pico8-carts";

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
    angband # lotr terminal roguelike
    asciicam # webcam in the terminal
    asciiquarium # a fishy app
    astroterm # watch the sky from your terminal
    atac # a terminal api client (like postman)
    bat # fancy `cat` replacement
    bluetui # terminal bluetooth manager
    bluetuith # terminal bluetooth manager
    browsh # terminal web browser
    btop # like top, but better
    caligula # burn/flash images to SD cards from the terminal
    castero # terminal podcast client
    cava # terminal audio visualizer
    cbonsai # terminal tree
    cfonts # ansi fonts
    chess-tui # terminal chess
    clolcat # 🌈
    cmatrix # there is no spoon
    confetty # 🎊
    cowsay # moo
    crawl # roguelike
    daktilo # typewriter sounds for the keyboard
    ddate # discordian date
    delta # git diffs done right
    devd # on-demand webserver
    distrobox # run other distros in containers
    distrobox-tui # tui for distrobox
    doge # much wow
    dooit # todo tui
    dysk # shows info for mounted drives - a better 'df'
    epy # terminal ebook reader
    eza # ls replacement
    fast-ssh # ssh connection manager
    fd # a better find
    file # identify file types
    fluidsynth # software synthesizer
    font-awesome # icons for waybar (does not work in environment.systemPackages)
    fortune # mmh cookies
    frotz # infocom game interpreter
    fzf # fuzzy finder (zoxide)
    gh # github cli
    gifgen # jen jifs from video files
    gitui # git tui
    glow # markdown reader
    go # go programming language
    # goose-cli # a local AI agent
    gum # various little helpers
    gurk-rs # terminal client for Signal messenger
    hollywood # hacking...
    htop # process monitor
    hyprland-monitor-attached # run scripts when monitors plug
    iftop # network monitoring
    inetutils # telnet
    jp2a # convert jpg and png to ascii art
    jq # query JSON
    killall # Gotta kill 'em all! Currently used in screen recorder script
    lazydocker # docker tui
    lazygit # git tui
    lynx # terminal web browser, can be scripted for tasks
    mame-tools # contains chdman
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
    nix-tree # browse the dependency graph of nix configs
    nodejs
    npm-check-updates # tool to check package.json for updates
    nsxiv # new suckless X image viewer
    nyancat # nyan nyan nyan
    nvtopPackages.amd # GPU monitoring
    oterm # ollama terminal client
    oxker # docker container management tui
    pamixer # terminal volume control
    pastel # terminal color palette tool
    pipes # terminal screensaver
    ponysay # like cowsay, but 20% cooler
    posting # terminal HTTP API client
    pywal16 # color schemes from images
    # pywalfox-native # style firefox with pywal
    ripgrep # rg, a better grep
    rmpc # terminal music player
    rtorrent # terminal torrent client
    screen
    scope-tui # terminal oscilloscope
    sl # choo choo
    sniffnet # GUI to monitor network traffic
    solitaire-tui # terminal card game
    speedread # read text fast
    sshpass # use ssh password auth within scripts - used for deploying proxmox VM configs
    sshs # ssh connection manager
    superfile # terminal file manager
    tasktimer # task timer
    tealdeer # man pages but short
    terminal-parrot # party parrot
    termpdfpy # graphical pdf/ebook reader for kitty
    # termusic # music player - very promising, but crashes a lot currently
    termshark # wireshark for the terminal
    # tickrs # realtime stock tickers in the terminal
    tmux
    trash-cli # use trash can in the terminal
    tui-journal # terminal journal app
    tuifeed # terminal feed reader
    unzip # extract zip files
    # ventoy # create multi-boot usb sticks (unfree license, needs flag)
    vitetris # terminal tetris
    wavemon # Wifi monitoring
    wget # download stuff
    wiki-tui # terminal wikipedia
    wikiman # offline reader for arch wiki
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

    "Applications/picocad/picocad.nix".source = common + /home/Applications/picocad/picocad.nix;
    "Applications/picocad/run.sh".source = common + /home/Applications/picocad/run.sh;

    "Applications/picocad/picocad-toolbox.nix".source = common + /home/Applications/picocad/picocad-toolbox.nix;
    "Applications/picocad/run-toolbox.sh".source = common + /home/Applications/picocad/run-toolbox.sh;
    
    "Applications/picotron/picotron.nix".source = common + /home/Applications/picotron/picotron.nix;
    "Applications/picotron/run.sh".source = common + /home/Applications/picotron/run.sh;
    
    "Applications/voxatron/voxatron.nix".source = common + /home/Applications/voxatron/voxatron.nix;
    "Applications/voxatron/run.sh".source = common + /home/Applications/voxatron/run.sh;
    
    "Pictures/digiKam/digikamrc.template".source = common + /home/Pictures/digiKam/digikamrc.template;

    ".cache/weather-location".text = ''
      ${secrets.weather-location}
    '';

    ".config/atuin/config.toml".source = common + /dotfiles/config/atuin/config.toml;
    ".config/direnv/direnv.toml".source = common + /dotfiles/config/direnv/direnv.toml;
    ".config/fuzzel/scripts".source = common + /dotfiles/config/fuzzel/scripts;
    ".config/hypr".source = common + /dotfiles/config/hypr;
    ".config/kitty".source = common + /dotfiles/config/kitty;

    ".config/niri/config.kdl".source = ./dotfiles/config/niri/config.kdl;
    ".config/niri/scripts".source = common + /dotfiles/config/niri/scripts;

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
    ".scripts".source = common + /dotfiles/scripts;
    ".sounds".source = common + /dotfiles/sounds;

    ".rtorrent.rc".source = common + /dotfiles/rtorrent.rc;
    ".wgetrc".source = common + /dotfiles/wgetrc;

    ".local/share/applications/appimage".source = ./dotfiles/local/share/applications/appimage;
    ".local/share/applications/other".source = common + /dotfiles/local/share/applications/other;
    ".local/share/applications/secret".source = ./dotfiles/local/share/applications/secret;

    ".screenrc".source = common + /dotfiles/screenrc;
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
    # x11.enable = true;

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

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  programs.gpg.enable = true;
  services.gpg-agent.enable = true;

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

    initContent = ''
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
      (cat ~/.cache/wal/sequences &)

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
      gcs = "git-crypt status";

      # Nix the planet
      run-msdos = "(cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#msdos622)";
      run-win311 = "(cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#wfwg311)";
      run-win98 = "(cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#win98)";

      # NixOS specific things
      boot-mode = "[ -d /sys/firmware/efi/efivars ] && echo \"UEFI\" || echo \"Legacy\"";
      nixos-cleanup = "home-manager expire-generations '-7 days' && sudo nix-collect-garbage --delete-older-than 7d"; 
      nixos-update = "(cd ~/nixfiles/desktop/$(hostname) && nix flake update)";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixfiles/desktop/$(hostname) --impure";

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

      # downloads
      download = "yt-dlp -t mp4 --cookies-from-browser brave";
      downloadmp3 = "yt-dlp -t mp3 --cookies-from-browser brave";
    };
  };

  # do not create ~/Public & ~/Templates
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };
}
