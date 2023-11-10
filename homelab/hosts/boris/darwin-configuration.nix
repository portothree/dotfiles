{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
     vim
     git
    ];
  # $ darwin-rebuild switch -I darwin-config=./darwin-configuration.nix
  environment.darwinConfig = "$HOME/www/portothree/homelab/hosts/boris/darwin-configuration.nix";
  services.nix-daemon.enable = true;
  programs.zsh.enable = true;
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = 4;
}
