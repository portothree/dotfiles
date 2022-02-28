{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
    };
  };
  networking.hostName = "nixos.main";
  time.timeZone = "Europe/Lisbon";
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  sercices = {
    openssh = { enable = true; };
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
    };
  };
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  users.users.porto = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  environment.systemPackages = with pkgs; [ wget ];
  system.stateVersion = "21.11";
}

