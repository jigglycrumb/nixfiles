
{
  config = {
    home.file = {
      "Pictures/digiKam/digikamrc.template".source = ./digikamrc.template;
      ".config/digikam/scripts/digikamctl".source = ./digikamctl;
    };
    
    programs.zsh.initContent = ''
      export PATH="$PATH:$HOME/.config/digikam/scripts"
    '';
  };
}
