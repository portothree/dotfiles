{ config, pkgs, ... }:

{
  imports = [ ../../modules ../common.nix ./hardware-configuration.nix ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
         canTouchEfiVariables = true;
      };
    };
  };
  fileSystems."/home/" = {
	device = "/dev/pool/home";
	fsType = "ext4";
  };
  networking = {
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
  system = { stateVersion = "22.05"; copySystemConfiguration = true; };
  modules = { tmux = { enable = true; }; };
}
