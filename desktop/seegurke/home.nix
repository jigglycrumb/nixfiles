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
    ../../common/modules/picotron/picotron.nix
  ];

  modules.pico-8.username = username;
  modules.pico-8.cart-path = "Projects/Github/Private/pico8-carts";

  modules.picotron.username = username;

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
    # angband # lotr terminal roguelike
    asciicam # webcam in the terminal
    atac # a terminal api client (like postman)
    bluetuith # terminal bluetooth manager
    browsh # terminal web browser
    caligula # burn/flash images to SD cards from the terminal
    castero # terminal podcast client
    cava # terminal audio visualizer
    chess-tui # terminal chess
    confetty # 🎊
    # crawl # roguelike
    # daktilo # typewriter sounds for the keyboard
    devd # on-demand webserver
    doge # much wow
    dooit # todo tui
    epy # terminal ebook reader
    eza # ls replacement
    fast-ssh # ssh connection manager
    frotz # infocom game interpreter
    gifgen # jen jifs from video files
    gitui # git tui
    glow # markdown reader
    go # go programming language
    gum # various little helpers
    hollywood # hacking...
    jp2a # convert jpg and png to ascii art
    lazygit # git tui
    lynx # terminal web browser, can be scripted for tasks
    md-tui # markdown renderer
    minesweep-rs # terminal minesweeper
    mprocs # run multiple processes at the same time
    mpv # video player
    nms # decrypting...
    nixfmt-rfc-style # formatter for nix code, used in VSCode
    npm-check-updates # tool to check package.json for npm-check-updates
    nsxiv
    nyancat # nyan nyan nyan
    ponysay # like cowsay, but 20% cooler
    # pywalfox-native # style firefox with pywal
    scope-tui # terminal oscilloscope
    solitaire-tui # terminal card game
    speedread # read text fast
    sshpass # use ssh password auth within scripts - used for deploying proxmox VM configs
    sshs # ssh connection manager
    tasktimer # task timer
    tealdeer # man but short
    terminal-parrot # party parrot
    termpdfpy # graphical pdf/ebook reader for kitty
    tui-journal # terminal journal app
    tuifeed # terminal feed reader
    # ventoy # create multi-boot usb sticks
    vitetris # terminal tetris
    wavemon # Wifi monitoring
    wiki-tui # terminal wikipedia

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
    ".config/niri/config.kdl".source = ./dotfiles/config/niri/config.kdl;
    ".config/waybar".source = ./dotfiles/config/waybar;
    ".local/share/applications/appimage".source = ./dotfiles/local/share/applications/appimage;
  };
}
