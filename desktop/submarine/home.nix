{
  config,
  pkgs,
  # inputs,
  username,
  ...
}:

{
  imports = [
    ../../common/modules/home-base.nix
    ../../common/modules/pico-8/pico-8.nix
  ];

  modules.pico-8.username = username;
  # modules.pico-8.cart-path = "Projects/Github/Private/pico8-carts";

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
    asciicam # webcam in the terminal
    asciinema # record terminal sessions
    asciinema-agg # .. and convert them to gif
    astroterm # watch the sky from your terminal
    atac # a terminal api client (like postman)
    aws-sso-cli # work related
    awscli2 # work related
    bluetuith # terminal bluetooth manager
    browsh # terminal web browser
    castero # terminal podcast client
    cava # terminal audio visualizer
    chess-tui # terminal chess
    claude-code # work related
    confetty # 🎊
    crawl # roguelike
    devd # on-demand webserver
    distrobox # run other distros in containers
    distrobox-tui # tui for distrobox
    doge # much wow
    dooit # todo tui
    epy # terminal ebook reader
    eza # ls replacement
    fast-ssh # ssh connection manager
    gh # github cli
    gifgen # jen jifs from video files
    gitui # git tui
    glow # markdown reader
    grex # generate regular expressions
    go # go programming language
    gum # various little helpers
    gurk-rs # terminal client for Signal messenger
    hollywood # hacking...
    jp2a # convert jpg and png to ascii art
    lazydocker # docker tui
    lazygit # git tui
    lynx # terminal web browser, can be scripted for tasks
    md-tui # markdown renderer
    minesweep-rs # terminal minesweeper
    mprocs # run multiple processes at the same time
    mpv # video player
    nms # decrypting...
    nixfmt-rfc-style # formatter for nix code, used in VSCode
    npm-check-updates # tool to check package.json for updates
    nsxiv # new suckless X image viewer
    nyancat # nyan nyan nyan
    nvtopPackages.amd # GPU monitoring
    oterm # ollama terminal client
    oxker # docker container management tui
    pastel # terminal color palette tool
    ponysay # like cowsay, but 20% cooler
    posting # terminal HTTP API client
    # pywalfox-native # style firefox with pywal
    scope-tui # terminal oscilloscope
    slack-term # terminal slack client
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
    termshark # wireshark for the terminal
    tui-journal # terminal journal app
    vitetris # terminal tetris
    wavemon # Wifi monitoring
    wiki-tui # terminal wikipedia
    wikiman # offline reader for arch wiki

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

    ".claude/settings.json".text = ''
      {
        "env": {
          "CLAUDE_CODE_USE_BEDROCK": "1",
          "AWS_REGION": "eu-central-1",
          "ANTHROPIC_MODEL": "eu.anthropic.claude-3-7-sonnet-20250219-v1:0",
          "ANTHROPIC_SMALL_FAST_MODEL": "eu.anthropic.claude-3-5-haiku-20241022-v1:0"
        }
      }
    '';

    ".config/niri/config.kdl".source = ./dotfiles/config/niri/config.kdl;
    ".config/waybar/config".source = ./dotfiles/config/waybar/config;
  };

  programs.jrnl.enable = true; # cli journaling

  programs.zsh.shellAliases = {
    p = "pnpm";
    vibe = "aws-sso exec -p ai-coding.tools -- claude";
  };
}
