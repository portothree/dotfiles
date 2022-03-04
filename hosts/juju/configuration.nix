{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  time.timeZone = "Europe/Lisbon";
  networking = {
    useDHCP = false;
    interfaces = {
      wlp1s0 = {
        useDHCP = true;
      };
    };
    hostName = "juju";
    wireless = {
      enable = true;
      userControlled.enable = true;
      environmentFile = "/etc/nixos/.env";
      networks = {
        "@WIRELESS_SSID_HOME@" = {
          hidden = true;
          pskRaw = "@WIRELESS_PSKRAW_HOME@";
        };
        "@WIRELESS_SSID_WOO@" = {
          pskRaw = "@WIRELESS_PSKRAW_WOO@";
        };
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
      };
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
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  users.users.porto = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  environment.systemPackages = with pkgs; [ wget ];
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "21.11";
}
