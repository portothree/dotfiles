{ config, pkgs, ... }:

{
  nixpkgs = { config = { allowUnfree = true; }; };
  xdg = { enable = true; };
  services = {
    picom = { enable = true; };
    keynav = { enable = true; };
  };
  programs = { home-manager = { enable = true; }; };
}
