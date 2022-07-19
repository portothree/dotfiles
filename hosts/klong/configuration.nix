{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../common.nix ];
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };
  networking = {
    useDHCP = false;
    interfaces = { wlp0s20f3 = { useDHCP = true; }; };
    hostName = "klong";
    nameservers = [ "192.168.1.106" "208.67.222.222" "208.67.220.220" ];
    wireless = {
      enable = true;
      userControlled.enable = true;
      environmentFile = "/etc/nixos/.env";
      networks = {
        "@WIRELESS_SSID_HOME@" = {
          hidden = true;
          pskRaw = "@WIRELESS_PSKRAW_HOME@";
        };
        "@WIRELESS_SSID_WOO@" = { pskRaw = "@WIRELESS_PSKRAW_WOO@"; };
        "@WIRELESS_SSID_NKOOWOORK@" = { psk = "@WIRELESS_PSK_NKOOWOORK@"; };
      };
    };
  };
  services = {
    openssh = { enable = true; };
    xserver = {
      enable = true;
      layout = "us";
      libinput = {
        enable = true;
        mouse = { accelProfile = "flat"; };
        touchpad = { accelProfile = "flat"; };
      };
      displayManager = {
        startx = { enable = true; };
        defaultSession = "none+bspwm";
      };
      windowManager = { bspwm = { enable = true; }; };
    };
    blueman.enable = true;
  };
  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget curl ];
    variables = { EDITOR = "nvim"; };
  };
  virtualisation = { docker = { enable = true; }; };
  fonts.fonts = with pkgs; [ fira-code siji ];
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "porto" ];
  };
  system.stateVersion = "22.05";
}

