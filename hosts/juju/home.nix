{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [ gnome.gnome-tweaks ];
  };
  xdg = { enable = true; };
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
