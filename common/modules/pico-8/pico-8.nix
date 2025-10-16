
{
  config,
  lib,
  ...
}:
let
  # the _actual_ applied config
  cfg = config.modules.pico-8;
in
{
  options.modules.pico-8 = {
    username = lib.mkOption {
      description = "The user PICO-8 should be installed for";
      type = lib.types.str;
      default = "";
    };

    app-path = lib.mkOption {
      description = "The path relative to ~ where PICO-8 is installed";
      type = lib.types.str;
      default = "Applications/pico-8";
    };

    cart-path = lib.mkOption {
      description = "The path relative to ~ where PICO-8 carts are stored";
      type = lib.types.str;
      default = ".lexaloffle/pico-8/carts";
    };
  };

  config = {
    home.file = {
      "${cfg.app-path}/README.md".text = ''
        # Welcome to PICO-8!

        Download PICO-8 from the Lexaloffle website and extract the zip file into this folder.

        Then, run PICO-8 using your app launcher or by typing `pico8` in your terminal.
      '';

      "${cfg.app-path}/pico8.nix".text = ''
        { pkgs ? import <nixpkgs> { } }:
        let
          fhs = pkgs.buildFHSEnv {
            name = "pico8";
            targetPkgs = pkgs: (with pkgs; [
              xorg.libX11
              xorg.libXext
              xorg.libXcursor
              xorg.libXinerama
              xorg.libXi
              xorg.libXrandr
              xorg.libXScrnSaver
              xorg.libXxf86vm
              xorg.libxcb
              xorg.libXrender
              xorg.libXfixes
              xorg.libXau
              xorg.libXdmcp
              alsa-lib
              udev
            ]);
            runScript = "bash -c \"./pico8 -root_path /home/${cfg.username}/${cfg.cart-path}\"";
          };
        in
        pkgs.stdenv.mkDerivation {
          name = "pico8-shell";
          nativeBuildInputs = [ fhs ];
          shellHook = "exec pico8";
        }
      '';

      "${cfg.app-path}/run.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          nix-shell pico8.nix
        '';
      };
  
      ".icons/pico-8.png".source = ./pico-8.png;
      ".local/share/applications/Pico-8.desktop".text = ''
        [Desktop Entry]
        Name=PICO-8
        Comment=Fantasy Console
        Exec=bash run.sh
        Path=/home/${cfg.username}/${cfg.app-path}
        Icon=pico-8
        Terminal=false
        Type=Application
        Categories=Development;
      '';
    };

    programs.zsh.shellAliases = {
      pico8 = "(cd ~/${cfg.app-path} && ./run.sh)";
    }; 
  };
}
