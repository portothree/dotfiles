{ inputs, pkgs, lib, ... }:

{
  time = { timeZone = "Europe/Lisbon"; };
  networking = {
    extraHosts = ''
      192.168.1.100 pve.homelab
      192.168.1.106 lara.homelab
      192.168.1.200 pi.hole
      192.168.1.200 uptime.kuma
    '';
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };
  console = { keyMap = "us"; };
  nixpkgs = { config = { allowUnfree = true; }; };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d --max-freed $((64 * 1024**3))";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    settings = {
      substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org"
        "https://portothree.cachix.org"
        "https://microvm.cachix.org"
      ];
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "portothree.cachix.org-1:L4w3V/jrM+5cG0yEAypCPan94GLUxWYm8VFLB774J6I="
        "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      ];
    };
  };
}
