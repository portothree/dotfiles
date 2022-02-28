{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix <home-manager/nixos> ];
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
    };
  };
  time = { timeZone = "Europe/Lisbon"; };
  networking = {
    hostName = "uppercut";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
  };
  services = {
    openssh = { enable = true; };
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
    };
  };
  sound = { enable = true; };
  hardware = { pulseaudio = { enable = true; }; };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
  environment = { systemPackages = with pkgs; [ wget ]; };
  system = { stateVersion = "21.11"; };
  home-manager = {
    users = { porto = import ./home.nix { inherit config pkgs; }; };
  };
}
