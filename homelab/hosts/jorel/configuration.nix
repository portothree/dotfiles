{ config, pkgs, self, ... }:

let tailscalePort = 41641;
in {
  imports = [
    ../../modules
    ../platformio.nix
    ../zsa.nix
    ../common.nix
    ./hardware-configuration.nix
  ];
  microvm = {
    vms = {
      oraculo = {
        flake = self;
        updateFlake = "microvm";
      };
    };
  };
  boot = {
    loader = {
      systemd-boot = { enable = true; };
      efi = { canTouchEfiVariables = true; };
    };
  };
  fileSystems."/home" = {
    device = "/dev/pool/home";
    fsType = "ext4";
  };
  networking = {
    useDHCP = false;
    useNetworkd = true;
    interfaces = { enp34s0 = { useDHCP = true; }; };
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 tailscalePort ];
      checkReversePath = false;
    };
    nameservers = [ "100.100.100.100" ];
    search = [ "tailea386.ts.net" ];
  };
  location = {
    # Lisbon, Portugal
    latitude = 38.736946;
    longitude = -9.142685;
  };
  services = {
    clight = { enable = false; };
    openssh = {
      enable = true;
      openFirewall = false;
      permitRootLogin = "no";
    };
    blueman = { enable = true; };
    udev = { packages = with pkgs; [ ledger-udev-rules android-udev-rules ]; };
    tailscale = {
      enable = true;
      port = tailscalePort;
    };
    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = [ "nvidia" ];
      displayManager = { startx = { enable = true; }; };
      screenSection = ''
        Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
      '';
    };
  };
  systemd = {
    network = {
      enable = true;
      wait-online = { extraArgs = [ "--any" ]; };
    };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "dialout" "docker" "plugdev" ];
        shell = pkgs.zsh;
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget curl xsecurelock tailscale ];
    variables = { EDITOR = "nvim"; };
    pathsToLink = [ "/share/icons" "/share/mime" "/share/zsh" ];
  };
  virtualisation = {
    docker = {
      enable = true;
      liveRestore = false;
    };
  };
  fonts = { fonts = with pkgs; [ fira-code siji ]; };
  sound = { enable = true; };
  hardware = {
    nvidia = { package = config.boot.kernelPackages.nvidiaPackages.stable; };
    opengl.enable = true;
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
  };
  nixpkgs = { config = { pulseaudio = true; }; };
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "porto" ];
  };
  system = {
    stateVersion = "22.05";
    copySystemConfiguration = true;
  };
}
