{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix <home-manager/nixos> ];
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
    };
  };
  networking = {
    hostName = "jorel";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
  };
  services = {
    openssh = { enable = true; };
    xserver = {
      enable = true;
      layout = "us";
      displayManager = {
        defaultSession = "none+bspwm";
      };
      windowManager = {
        bspwm = {
          enable = true;
        };
      };
    };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" ];
      };
    };
  };
  environment = { systemPackages = with pkgs; [ wget ]; };
  sound = { enable = true; };
  hardware = { pulseaudio = { enable = true; }; };
  nixpkgs = {
    config = {
      pulseaudio = true;
    };
  };
  home-manager = {
    users = { porto = import ./home.nix { inherit config pkgs; }; };
  };
  system = { stateVersion = "21.11"; };
}
