{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ git ];

  environment.darwinConfig =
    "$HOME/www/portothree/homelab/hosts/boris/darwin-configuration.nix";

  users.users.gustavoporto = {
    name = "gustavoporto";
    home = "/Users/gustavoporto";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
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
