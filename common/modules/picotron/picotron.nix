
{
  config,
  lib,
  ...
}:
let
  # the _actual_ applied config
  cfg = config.modules.picotron;
in
{
  options.modules.picotron = {
    username = lib.mkOption {
      description = "The user picotron should be installed for";
      type = lib.types.str;
      default = "";
    };

    app-path = lib.mkOption {
      description = "The path relative to ~ where picotron is installed";
      type = lib.types.str;
      default = "Applications/picotron";
    };

    # cart-path = lib.mkOption {
    #   description = "The path relative to ~ where picotron carts are stored";
    #   type = lib.types.str;
    #   default = ".lexaloffle/picotron/carts";
    # };
  };

  config = {
    home.file = {
      "${cfg.app-path}/README.md".text = ''
        # Welcome to Picotron!

        Download Picotron from the Lexaloffle website and extract the zip file into this folder.

        Then, run Picotron using your app launcher or by typing `picotron` in your terminal.
      '';

      "${cfg.app-path}/picotron.nix".text = ''
        { pkgs ? import <nixpkgs> { } }:
        let
          fhs = pkgs.buildFHSEnv {
            name = "picotron";
            targetPkgs = pkgs: (with pkgs; [
              xorg.libXrandr # for renderer
              libGL # for renderer
              alsa-lib # for audio
              udev # for gamepads
              curl # for cart downloads
            ]);
            runScript = "bash -c ./picotron";
          };
        in
        pkgs.stdenv.mkDerivation {
          name = "picotron-shell";
          nativeBuildInputs = [ fhs ];
          shellHook = "exec picotron";
        }
      '';

      "${cfg.app-path}/run.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          nix-shell picotron.nix
        '';
      };
  
      ".icons/picotron.png".source = ./picotron.png;
      ".local/share/applications/picotron.desktop".text = ''
        [Desktop Entry]
        Name=Picotron
        Comment=Fantasy Workstation
        Exec=bash run.sh
        Path=/home/${cfg.username}/${cfg.app-path}
        Icon=picotron
        Terminal=false
        Type=Application
        Categories=Development;
      '';
    };

    programs.zsh.shellAliases = {
      picotron = "(cd ~/${cfg.app-path} && ./run.sh)";
    }; 
  };
}
