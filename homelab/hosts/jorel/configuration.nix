{ config, pkgs, ... }:

{
  imports = [
    ../../modules
    ../platformio.nix
    ../zsa.nix
    ../common.nix
    ./hardware-configuration.nix
  ];
  boot = {
    loader = {
      systemd-boot = { enable = true; };
      efi = { canTouchEfiVariables = true; };
    };
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
    kernelModules = [ "v4l2loopback" "snd-aloop" ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };
  fileSystems."/home" = {
    device = "/dev/pool/home";
    fsType = "ext4";
  };
  time.hardwareClockInLocalTime = true;
  networking = {
    useDHCP = false;
    interfaces = { wlp35s0 = { useDHCP = true; }; };
    nameservers = [ "100.100.100.100" ];
    search = [ "tailea386.ts.net" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = false;
    };
    wireless = {
      enable = true;
      userControlled.enable = true;
      environmentFile = "/etc/nixos/.env";
      networks = {
        "@WIRELESS_SSID_OFFICE@" = { psk = "@WIRELESS_PSK_OFFICE@"; };
      };
    };
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
      settings = { PermitRootLogin = "no"; };
    };
    blueman = { enable = true; };
    udev = { packages = with pkgs; [ ledger-udev-rules android-udev-rules ]; };
    tailscale = {
      enable = true;
      port = 41641;
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
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = { trusted-users = [ "root" "porto" ]; };
  };
  system = {
    stateVersion = "22.05";
  };
}
