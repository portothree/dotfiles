{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ git ];
    darwinConfig =
      "$HOME/www/portothree/homelab/hosts/zaza/darwin-configuration.nix";
  };
  users.users.gustavoporto = {
    name = "porto";
    home = "/Users/porto";
  };
  homebrew = {
    enable = true;
    global = { lockfiles = true; };
    brews = [ "pyqt@6" "python@3.10" ];
    casks = [ "docker" "google-chrome" ];
  };
  fonts = {
    fontDir = { enable = true; };
    fonts = with pkgs; [ fira-code ];
  };
  services = {
    nix-daemon = { enable = true; };
    karabiner-elements = { enable = false; };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = 4;
}
