{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix <home-manager/nixos> ];
  boot = {
    loader = {
      systemd-boot = { enable = true; };
      efi = { canTouchEfiVariables = true; };
    };
  };
  networking = {
    hostName = "danubio";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
    extraHosts = ''
      192.168.1.100 pve
    '';
    nameservers = [ "208.67.222.222" "208.67.220.220" ];
    firewall = {
      allowedTCPPorts = [ 22 80 3000 8081 ];
      allowedUDPPorts = [ ];
    };
  };
  services = { openssh = { enable = true; }; };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
      };
    };
  };
  environment = { systemPackages = with pkgs; [ wget ]; };
  virtualization = { docker = { enable = true; }; };
  home-manager = {
    users = { porto = import ./home.nix { inherit config pkgs; }; };
  };
  system = { stateVersion = "21.11"; };
}
