{ config, pkgs, ... }:

{
  nixpkgs = { config = { allowUnfree = true; }; };
  xdg = { enable = true; };
  programs = { home-manager = { enable = true; }; };
}
