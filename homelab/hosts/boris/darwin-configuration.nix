{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ git ];
    darwinConfig =
      "$HOME/www/portothree/homelab/hosts/boris/darwin-configuration.nix";
  };
  users.users.gustavoporto = {
    name = "gustavoporto";
    home = "/Users/gustavoporto";
  };
  homebrew = {
    enable = true;
    global = { lockfiles = true; };
    brews = [ "pyqt@6" ];
    casks = [ "docker" "google-chrome" ];
  };
  fonts = {
    fontDir = { enable = true; };
    fonts = with pkgs; [ fira-code ];
  };
  services = {
    nix-daemon = { enable = true; };
    karabiner-elements = { enable = true; };
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
