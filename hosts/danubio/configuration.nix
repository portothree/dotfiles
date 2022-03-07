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
    hostName = "danubio";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
    firewall = {
      allowedTCPPortRanges = [ { from = 8000; to = 9000;} ];
      allowedUDPPortRanges = [ { from = 8000; to = 9000;} ];
    };
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
