{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix <home-manager/nixos> ];
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
    hostName = "fabricio";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
    extraHosts = ''
      192.168.1.100 pve
    '';
    nameservers = [ "208.67.222.222" "208.67.220.220"];
  };
  services = {
    openssh = { enable = true; };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
  environment = { systemPackages = with pkgs; [ wget ]; };
  home-manager = {
    users = { porto = import ./home.nix { inherit config pkgs; }; };
  };
  system = { stateVersion = "21.11"; };
}
