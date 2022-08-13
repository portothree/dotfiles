{ pkgs, ... }:

{
  home = { packages = with pkgs; [ ]; };
  xdg = { enable = true; };
  gtk = {
    enable = true;
    theme = { package = pkgs.whitesur-gtk-theme; };
  };
  programs = {
    home-manager = { enable = true; };
    zathura = {
      enable = true;
      options = {
        window-height = 1000;
        window-width = 1000;
      };
      extraConfig = ''
        map <C-i> recolor
      '';
    };
  };
}
