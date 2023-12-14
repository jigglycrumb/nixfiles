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
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jigglycrumb";
  home.homeDirectory = "/home/jigglycrumb";

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
    asciiquarium
    bat # fancy `cat` replacement
    cmatrix # there is no spoon
    cool-retro-term # a terminal that's cool and retro
    cowsay # moo
    ddate # discordian date
    delta # git diffs done right
    devd # on-demand webserver
    eza # ls replacement
    font-awesome # icons for waybar (does not work in environment.systemPackages)
    fortune # mmh cookies
    # killall
    lolcat # 🌈

    # mate.mate-polkit
    meld # merge tool
    nixpkgs-fmt # formatter for nix code, used in VSCode
    nodejs_20
    ponysay # like cowsay, but 20% cooler

    pywal # color schemes from images
    ranger
    screen
    sl # choo choo
    tmux
    unzip

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

    # ".config/hypr".source = dotfiles/config/hypr;

    ".config/swaylock".source = dotfiles/config/swaylock;

    # ".config/waybar".source = dotfiles/config/waybar;
    ".config/wlogout".source = dotfiles/config/wlogout;

    ".functions".source = dotfiles/functions;
    ".sounds".source = dotfiles/sounds;
    ".ssh".source = dotfiles/ssh;
    ".wgetrc".source = dotfiles/wgetrc;
    ".local/share/applications/appimage".source = dotfiles/local/share/applications/appimage;
    ".local/share/applications/other".source = dotfiles/local/share/applications/other;
    ".local/share/applications/secret".source = dotfiles/local/share/applications/secret;


    # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".screenrc".text = ''
      # Disable the startup message
      startup_message off
    '';
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
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
  #   gtk3.extraConfig = {
  #     # Settings = ''
  #     gtk-application-prefer-dark-theme = true;
  #     # '';
  #   };
  #   gtk4.extraConfig = {
  #     # Settings = ''
  #     gtk-application-prefer-dark-theme = true;
  #     # '';
  #   };
  # };

  programs.gpg.enable = true;

  services.gpg-agent.enable = true;



  # programs.ssh.enable = true;

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
    history = {
      ignoreAllDups = true;
      ignorePatterns = [ "ls" "pwd" "date" "* --help" "man" ];
    };
    oh-my-zsh = {
      enable = true;
      theme = "cloud";
      plugins = [ "git" "thefuck" ];
    };
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

      # Bind some keys
      bindkey "^[^[[C" forward-word
      bindkey "^[^[[D" backward-word

      COMPLETION_WAITING_DOTS=true

      # thefuck integration
      # eval $(thefuck --alias)

      cowsay "$(fortune)" | lolcat
    '';
    shellAliases = {
      c = "clear";
      # cat = "bat";
      g = "git";

      "c." = "code .";
      pico8 = "cd ~/Applications/pico-8 && ./run.sh";

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
      gbc = "git branch create";
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

      # OSX debris

      # Recursively delete OSX `.DS_Store` files
      clean-ds_store = "find . -type f -name '*.DS_Store' -ls -delete";
      # Recursively delete OSX resource forks
      clean-osx-shitfiles = "find . -type f -name '._*' -ls -delete";

      # fun
      sl = "aplay ~/.sounds/train.wav & sl";
      space-opera = "telnet towel.blinkenlights.nl";
    };
  };

  services.syncthing.enable = true;
  # services.syncthing.tray.enable = true;

  # do not create ~/Public & ~/Templates
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    publicShare = null;
    templates = null;
  };
}
