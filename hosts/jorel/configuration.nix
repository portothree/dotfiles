{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix ];
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
    interfaces = { enp34s0 = { useDHCP = true; }; };
    useNetworkd = true;
    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "eth0";
      internalInterfaces = [ "microvm" ];
    };
  };
  services = {
    openssh = { enable = true; };
    blueman = { enable = true; };
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
      netdevs = {
        "10-microvm" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "microvm";
          };
        };
      };
      networks = {
        "10-microvm" = {
          matchConfig.Name = "microvm";
          networkConfig = {
            DHCPServer = true;
            IPv6SendRA = true;
          };
        };
        "11-microvm" = {
          matchConfig.Name = "vm-*";
          networkConfig = { Bridge = "microvm"; };
        };
      };
    };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "docker" ];
        shell = pkgs.zsh;
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget curl ];
    variables = { EDITOR = "nvim"; };
  };
  virtualisation = { docker = { enable = true; }; };
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
  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio = true;
    };
  };
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
