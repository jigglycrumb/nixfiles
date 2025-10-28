{
  pkgs,
  ...
}:

{
  config = {
    home.file = {
      "Pictures/digiKam/digikamrc.template".source = ./digikamrc.template;
      ".config/digikam/scripts/digikamctl".source = ./digikamctl;
    };
    
    home.packages = with pkgs; [
      digikam # photo manager
      exiftool # read & write exif data - integrates with digikam
    ];

    programs.zsh.initContent = ''
      export PATH="$PATH:$HOME/.config/digikam/scripts"
    '';
  };
}
