
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # the _actual_ applied config
  cfg = config.modules.infocom;
in
{
  options.modules.infocom = {
    games-path = lib.mkOption {
      description = "The path relative to ~ where your Infocom games will be installed";
      type = lib.types.str;
      default = "Games/Infocom/Games";
    };
  };

  config = {
    home.file = {
      "${cfg.games-path}/README.md".text = ''
        # Infocom games folder      
        Put your games here, launch cool-retro-term and type `infocom`.
      '';

      ".config/frotz/scripts/infocom".source = ./infocom;
    };
    
    home.packages = with pkgs; [
      cool-retro-term # terminal emulator
      gum # various little helpers
      frotz # Infocom games interpreter
    ];

    programs.zsh.initContent = ''
      export PATH="$PATH:$HOME/.config/frotz/scripts"
    '';
  };
}
