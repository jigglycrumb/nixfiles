
{
  config,
  lib,
  ...
}:
let
  # the _actual_ applied config
  cfg = config.modules.picocad;
in
{
  options.modules.picocad = {
    username = lib.mkOption {
      description = "The user picoCAD should be installed for";
      type = lib.types.str;
      default = "";
    };

    app-path = lib.mkOption {
      description = "The path relative to ~ where picoCAD is installed";
      type = lib.types.str;
      default = "Applications/picocad";
    };

    # cart-path = lib.mkOption {
    #   description = "The path relative to ~ where picocad carts are stored";
    #   type = lib.types.str;
    #   default = ".lexaloffle/picocad/carts";
    # };
  };

  config = {
    home.file = {
      "${cfg.app-path}/README.md".text = ''
        # Welcome to picoCAD!

        Download picoCAD from the picocad.net and extract the zip file into this folder.

        Then, run picoCAD using your app launcher or by typing `picocad` in your terminal.
        Or run the picoCAD Toolbox - again using your app launcher or by typing `picocad-toolbox` in your terminal.
      '';

      "${cfg.app-path}/picocad.nix".text = ''
        { pkgs ? import <nixpkgs> { } }:
        let
          fhs = pkgs.buildFHSEnv {
            name = "picocad";
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
              SDL2
            ]);
            runScript = "bash -c ./picocad";
          };
        in
        pkgs.stdenv.mkDerivation {
          name = "picocad-shell";
          nativeBuildInputs = [ fhs ];
          shellHook = "exec picocad";
        }
      '';

      "${cfg.app-path}/picocad-toolbox.nix".text = ''
        { pkgs ? import <nixpkgs> { } }:
        let
          fhs = pkgs.buildFHSEnv {
            name = "picocad-toolbox";
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
              SDL2
            ]);
            runScript = "bash -c ./toolbox/toolbox";
          };
        in
        pkgs.stdenv.mkDerivation {
          name = "picocad-toolbox-shell";
          nativeBuildInputs = [ fhs ];
          shellHook = "exec picocad-toolbox";
        }
      '';

      "${cfg.app-path}/run.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          nix-shell picocad.nix
        '';
      };
  
      "${cfg.app-path}/run-toolbox.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          nix-shell picocad-toolbox.nix
        '';
      };

      ".icons/picocad.png".source = ./picocad.png;
      ".icons/picocad-toolbox.png".source = ./picocad-toolbox.png;

      ".local/share/applications/picocad.desktop".text = ''
        [Desktop Entry]
        Name=picoCAD
        Comment=A tiny modeler for tiny models
        Exec=bash run.sh
        Path=/home/${cfg.username}/${cfg.app-path}
        Icon=picocad
        Terminal=false
        Type=Application
        Categories=Development;
      '';
      
      ".local/share/applications/picocad-toolbox.desktop".text = ''
        [Desktop Entry]
        Name=picoCAD Toolbox
        Comment=A tiny modeler for tiny models
        Exec=bash run-toolbox.sh
        Path=/home/${cfg.username}/${cfg.app-path}
        Icon=picocad-toolbox
        Terminal=false
        Type=Application
        Categories=Development;
      '';
    };

    programs.zsh.shellAliases = {
      picocad = "(cd ~/${cfg.app-path} && ./run.sh)";
      picocad-toolbox = "(cd ~/${cfg.app-path} && ./run-toolbox.sh)";
    }; 
  };
}
