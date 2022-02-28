{ config, pkgs, ... }:

{
  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
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
