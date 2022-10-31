{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../config/platformio.nix
    ../../modules/system
  ];
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
    nameservers = [ "192.168.1.106" "208.67.222.222" "208.67.220.220" ];
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
      checkReversePath = false;
    };
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
  environment = {
    systemPackages = with pkgs; [ wget curl xsecurelock tailscale ];
    variables = { EDITOR = "nvim"; };
    pathsToLink = [ "/share/icons" "/share/mime" "/share/zsh" ];
  };
  services = {
    openssh.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      libinput = {
        enable = true;
        mouse = { accelProfile = "flat"; };
        touchpad = { accelProfile = "flat"; };
      };
      displayManager = { startx = { enable = true; }; };
    };
    nextdnsc.enable = true;
    tailscale.enable = true;
    blueman.enable = true;
  };
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
    bluetooth.enable = true;
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
        shell = pkgs.zsh;
      };
    };
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

