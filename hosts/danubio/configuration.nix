{ config, pkgs, ... }:

{
  imports = [ ../../modules ../common.nix ./hardware-configuration.nix ];
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
  virtualisation = { docker = { enable = true; }; };
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "porto" ];
  };
  system = { stateVersion = "21.11"; };
  modules = { tmux = { enable = true; }; };
}
