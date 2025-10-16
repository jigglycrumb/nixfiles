{
  config,
  pkgs,
  # inputs,
  ...
}:

let
  username = "jigglycrumb";
  common = ../../common;
in
{
  imports = [
    ../../common/modules/home-base.nix
    ../../common/modules/pico-8/pico-8.nix
    ../../common/modules/picotron/picotron.nix
    ../../common/modules/voxatron/voxatron.nix
    ../../common/modules/picocad/picocad.nix
  ];

  modules.pico-8.username = username;
  modules.pico-8.cart-path = "Projects/Github/Private/pico8-carts";

  modules.picotron.username = username;
  modules.voxatron.username = username;
  modules.picocad.username = username;

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
    angband # lotr terminal roguelike
    asciicam # webcam in the terminal
    astroterm # watch the sky from your terminal
    atac # a terminal api client (like postman)
    bluetui # terminal bluetooth manager
    bluetuith # terminal bluetooth manager
    browsh # terminal web browser
    caligula # burn/flash images to SD cards from the terminal
    castero # terminal podcast client
    cava # terminal audio visualizer
    chess-tui # terminal chess
    confetty # 🎊
    crawl # roguelike
    daktilo # typewriter sounds for the keyboard
    devd # on-demand webserver
    distrobox # run other distros in containers
    distrobox-tui # tui for distrobox
    doge # much wow
    dooit # todo tui
    epy # terminal ebook reader
    eza # ls replacement
    fast-ssh # ssh connection manager
    fluidsynth # software synthesizer
    font-awesome # icons for waybar (does not work in environment.systemPackages)
    frotz # infocom game interpreter
    gh # github cli
    gifgen # jen jifs from video files
    gitui # git tui
    glow # markdown reader
    go # go programming language
    # goose-cli # a local AI agent
    gum # various little helpers
    gurk-rs # terminal client for Signal messenger
    hollywood # hacking...
    # hyprland-monitor-attached # run scripts when monitors plug
    jp2a # convert jpg and png to ascii art
    lazydocker # docker tui
    lazygit # git tui
    lynx # terminal web browser, can be scripted for tasks
    mame-tools # contains chdman
    md-tui # markdown renderer
    minesweep-rs # terminal minesweeper
    mprocs # run multiple processes at the same time
    mpv # video player
    # musikcube # cli music player
    nms # decrypting...
    nixfmt-rfc-style # formatter for nix code, used in VSCode
    nodejs
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
    rmpc # terminal music player
    rtorrent # terminal torrent client
    scope-tui # terminal oscilloscope
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
    tui-journal # terminal journal app
    tuifeed # terminal feed reader
    # ventoy # create multi-boot usb sticks (unfree license, needs flag)
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

    "Pictures/digiKam/digikamrc.template".source = common + /home/Pictures/digiKam/digikamrc.template;

    ".config/niri/config.kdl".source = ./dotfiles/config/niri/config.kdl;
    ".config/waybar/config".source = ./dotfiles/config/waybar/config;

    ".local/share/applications/appimage".source = ./dotfiles/local/share/applications/appimage;
    ".local/share/applications/other".source = common + /dotfiles/local/share/applications/other;
    ".local/share/applications/secret".source = ./dotfiles/local/share/applications/secret;
  };

  # Let virt-manager connect to KVM
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  programs.zsh.shellAliases = {
    # Nix the planet
    run-msdos = "(cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#msdos622)";
    run-win311 = "(cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#wfwg311)";
    run-win98 = "(cd ~/VMs/machines && nix run github:matthewcroughan/NixThePlanet#win98)";

    # VPN
    vpn-up = "sudo systemctl start wg-quick-home.service";
    vpn-down = "sudo systemctl stop wg-quick-home.service";
  };
}
