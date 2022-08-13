{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix ];
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = { kernelModules = [ "amdgpu" ]; };
    kernelParams = [
      "video=eDP-1:1920x1080@60"
      "video=HDMI-A-1:1920x1080@60"
      "video=DP-2:1920x1080@60"
    ];
  };
  networking = {
    useDHCP = false;
    interfaces = { wlp1s0 = { useDHCP = true; }; };
    nameservers = [ "208.67.222.222" "208.67.220.220" ];
  };
  services = {
    openssh = { enable = true; };
    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = [ "amdgpu" ];
      libinput = {
        enable = true;
        mouse = { accelProfile = "flat"; };
        touchpad = { accelProfile = "flat"; };
      };
      displayManager = { gdm = { enable = true; }; };
      desktopManager = { gnome = { enable = true; }; };
    };
    blueman.enable = true;
  };
  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;
    opengl = {
      driSupport = true;
      extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime amdvlk ];
    };
    bluetooth.enable = true;
  };
  users = {
    groups = { plugdev = { }; };

    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "plugdev" "dialout" "docker" ];
      };
    };
  };
  environment.systemPackages = with pkgs; [ git wget curl ];
  virtualisation = { docker = { enable = true; }; };
  fonts.fonts = with pkgs; [ fira-code siji ];
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "porto" ];
  };
  system.stateVersion = "21.11";
}

