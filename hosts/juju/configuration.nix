{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Lisbon";

  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

  services.xserver.enable = true;

  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.libinput.enable = true;

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

  networking = {
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
      };
    };
  };
}
