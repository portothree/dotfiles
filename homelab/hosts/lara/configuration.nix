{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix ];
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
  networking = {
    hostName = "lara";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
    extraHosts = ''
      192.168.1.100 pve
    '';
    nameservers = [ "208.67.222.222" "208.67.220.220"];
    firewall = {
      allowedTCPPorts = [ 22 80 443 6443 ];
      allowedUDPPorts = [ ];
    };
  };
  services = {
    openssh = { enable = true; };
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [ "--no-deploy traefik"];
    };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
  environment = { systemPackages = with pkgs; [ git curl k3s k9s kubectl fluxcd fluxctl ]; };
  system = { stateVersion = "21.11"; };
}
