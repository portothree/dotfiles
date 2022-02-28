{ config, pkgs, ... }:

{
  home = {
    stateVersion = "22.05";
  };
  nixpkgs = { config = { allowUnfree = true; }; };
  xdg = { enable = true; };
  services = {
    picom = { enable = true; };
    keynav = { enable = true; };
  };
  programs = { home-manager = { enable = true; }; };
}
