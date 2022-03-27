{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ./ledger.nix
    <home-manager/nixos>
  ];
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = { kernelModules = [ "amdgpu" ]; };
  };
  time.timeZone = "Europe/Lisbon";
  networking = {
    useDHCP = false;
    interfaces = { wlp1s0 = { useDHCP = true; }; };
    hostName = "juju";
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
      };
    };
  };
  services = {
    openssh = { enable = true; };
    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = [ "amdgpu" ];
      libinput = { enable = true; };
      displayManager = { defaultSession = "none+bspwm"; };
      windowManager = { bspwm = { enable = true; }; };
    };
  };
  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;
    opengl = {
      driSupport = true;
      extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime amdvlk ];
    };
  };
  users = {
    groups = { plugdev = { }; };

    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "plugdev" ];
      };
    };
  };
  environment.systemPackages = with pkgs; [ wget curl ];
  fonts.fonts = with pkgs; [ fira-code siji unicode ];
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  home-manager = {
    users = { porto = import ./home.nix { inherit config pkgs; }; };
  };
  system.stateVersion = "21.11";
}

