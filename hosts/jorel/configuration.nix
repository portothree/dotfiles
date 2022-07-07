{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../common.nix ];
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
        startx = { enable = true; };
        defaultSession = "none+bspwm";
      };
      windowManager = { bspwm = { enable = true; }; };
    };
  };
  sound = { enable = true; };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "docker" ];
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget ];
    variables = { EDITOR = "nvim"; };
  };
  virtualisation = { docker = { enable = true; }; };
  fonts = { fonts = with pkgs; [ fira-code siji ]; };
  sound = { enable = true; };
  hardware = { pulseaudio = { enable = true; }; };
  nixpkgs = { config = { pulseaudio = true; }; };
  system = { stateVersion = "22.05"; };
}
