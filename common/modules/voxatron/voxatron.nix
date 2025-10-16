
{
  config,
  lib,
  ...
}:
let
  # the _actual_ applied config
  cfg = config.modules.voxatron;
in
{
  options.modules.voxatron = {
    username = lib.mkOption {
      description = "The user voxatron should be installed for";
      type = lib.types.str;
      default = "";
    };

    app-path = lib.mkOption {
      description = "The path relative to ~ where voxatron is installed";
      type = lib.types.str;
      default = "Applications/voxatron";
    };

    # cart-path = lib.mkOption {
    #   description = "The path relative to ~ where voxatron carts are stored";
    #   type = lib.types.str;
    #   default = ".lexaloffle/voxatron/carts";
    # };
  };

  config = {
    home.file = {
      "${cfg.app-path}/README.md".text = ''
        # Welcome to voxatron with home-manager!

        Download voxatron from the Lexaloffle website and extract the zip file into this folder.

        Then, run voxatron using your app launcher or by typing `voxatron` in your terminal.
      '';

      "${cfg.app-path}/voxatron.nix".text = ''
        { pkgs ? import <nixpkgs> { } }:
        let
          fhs = pkgs.buildFHSEnv {
            name = "voxatron";
            targetPkgs = pkgs: (with pkgs; [
              udev
              libGL
            ]);
            runScript = "bash -c ./vox";
          };
        in
        pkgs.stdenv.mkDerivation {
          name = "voxatron-shell";
          nativeBuildInputs = [ fhs ];
          shellHook = "export LD_LIBRARY_PATH=\".:$LD_LIBRARY_PATH\"; exec voxatron";
        }
      '';

      "${cfg.app-path}/run.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          nix-shell voxatron.nix
        '';
      };
  
      ".icons/voxatron.png".source = ./voxatron.png;
      ".local/share/applications/voxatron.desktop".text = ''
        [Desktop Entry]
        Name=Voxatron
        Comment=Fantasy Console
        Exec=bash run.sh
        Path=/home/${cfg.username}/${cfg.app-path}
        Icon=voxatron
        Terminal=false
        Type=Application
        Categories=Development;
      '';
    };

    programs.zsh.shellAliases = {
      voxatron = "(cd ~/${cfg.app-path} && ./run.sh)";
    }; 
  };
}
