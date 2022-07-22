{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [ gcalcli ];
    file.gcalcli = {
      target = ".gcalclirc";
      text = ''
        --lineart=ascii
      '';
    };
  };
}
