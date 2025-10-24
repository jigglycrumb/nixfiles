{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import secrets
  #
  # !!! WARNING !!!
  # This approach is far from ideal since the secrets will end up in the locally readable /nix/store
  # It is however, an easy way until I've learned enough nix to implement a better solution
  # The secrets.nix file is just a simple set like this:
  #
  # {
  #   github-token = "<token>";
  #   weather-location = "<city>";
  # }

  secrets = import ../secret/home.nix;
in
{
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  # Enable atuin for shell history
  programs.atuin.enable = true;

  # Enable starship shell prompt
  programs.starship.enable = true;

  # Enable zoxide for cd
  programs.zoxide.enable = true;
  programs.zoxide.options = [ "--cmd cd" ];

  programs.qutebrowser = {
    enable = true;
    # TODO configure
  };

  # Enable gnome keyring
  services.gnome-keyring.enable = true;
  services.gnome-keyring.components = [
    "pkcs11"
    "secrets"
    "ssh"
  ];

  # Setup dotfiles
  home.file = {
    ".cache/weather-location".text = ''
      ${secrets.weather-location}
    '';

    ".config/atuin/config.toml".source = ../dotfiles/config/atuin/config.toml;
    ".config/direnv/direnv.toml".source = ../dotfiles/config/direnv/direnv.toml;
    ".config/fuzzel/scripts".source = ../dotfiles/config/fuzzel/scripts;
    ".config/hypr".source = ../dotfiles/config/hypr;
    ".config/kitty".source = ../dotfiles/config/kitty;
    ".config/niri/scripts".source = ../dotfiles/config/niri/scripts;
    ".config/raffi".source = ../dotfiles/config/raffi;
    ".config/starship.toml".source = ../dotfiles/config/starship.toml;
    ".config/sunsetr".source = ../dotfiles/config/sunsetr;
    ".config/swaync".source = ../dotfiles/config/swaync;
    ".config/Thunar/uca.xml".source = ../dotfiles/config/Thunar/uca.xml;
    ".config/wal/templates".source = ../dotfiles/config/wal/templates;
    ".config/waybar/scripts".source = ../dotfiles/config/waybar/scripts;
    ".config/waybar/style.css".source = ../dotfiles/config/waybar/style.css;

    ".functions".source = ../dotfiles/functions;
    ".scripts".source = ../dotfiles/scripts;
    ".sounds".source = ../dotfiles/sounds;

    ".rtorrent.rc".source = ../dotfiles/rtorrent.rc;
    ".screenrc".source = ../dotfiles/screenrc;
    ".wgetrc".source = ../dotfiles/wgetrc;
  };

  # Install Nix packages into user environment
  home.packages = with pkgs; [
    alsa-utils # aplay
    asciiquarium # a fishy app
    bat # fancy `cat` replacement
    bashmount # helps mounting USB drives
    bitwarden-cli # password manager
    btop # like top, but better
    cbonsai # terminal tree
    cfonts # ansi fonts
    clolcat # 🌈
    cmatrix # there is no spoon
    cowsay # moo
    ddate # discordian date
    delta # git diffs done right
    dysk # shows info for mounted drives - a better 'df'
    fastfetch # I use nix btw
    fd # a better find
    file # identify file types
    font-awesome # icons for waybar (does not work in environment.systemPackages)
    fortune # mmh cookies
    fzf # fuzzy finder (zoxide)
    htop # process monitor
    iftop # network monitoring
    inetutils # telnet
    jq # query JSON
    killall # Gotta kill 'em all!
    lsd # ls with icons
    mc # dual pane terminal file manager
    meld # merge tool
    ncdu # show disk usage
    nix-tree # browse the dependency graph of nix configs
    nodejs
    pamixer # terminal volume control
    pipes # terminal screensaver
    pywal16 # color schemes from images
    ripgrep # rg, a better grep
    screen # detachable sessions
    sl # choo choo
    tmux # terminal multiplexer
    trash-cli # use trash can in the terminal
    unzip # extract zip files
    wget # download stuff
    yazi # terminal file manager
    yt-dlp # terminal downloader for Youtube etc
  ];

  # Define environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Set the cursor
  home.pointerCursor = {
    gtk.enable = true;

    package = pkgs.bibata-cursors;
    # name = "Bibata-Modern-Classic";
    name = "Bibata-Modern-Ice";

    # package = pkgs.banana-cursor;
    # name = "Banana";
    size = 22;
  };

  # Configure GTK
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

  # Enable GPG
  programs.gpg.enable = true;
  services.gpg-agent.enable = true;

  # Enable direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable pay-respects (type 'f' to correct the last shell command)
  programs.pay-respects.enable = true;

  # Configure git
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

  # Configure ZSH
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
      l = "lsd -la";
      ll = "lsd -l";

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

      # NixOS specific things
      boot-mode = "[ -d /sys/firmware/efi/efivars ] && echo \"UEFI\" || echo \"Legacy\"";
      # nixos-cleanup = "home-manager expire-generations \"-7 days\" && sudo nix-collect-garbage --delete-older-than 7d"; 
      nixos-cleanup = "sudo nix-collect-garbage --delete-older-than 7d"; 
      nixos-update = "(cd ~/nixfiles/desktop/$(hostname) && nix flake update)";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixfiles/desktop/$(hostname) --impure";

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

  # Do not create ~/Public & ~/Templates
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };
}
