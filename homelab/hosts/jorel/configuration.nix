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
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "en_US.UTF-8";
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
        "@WIRELESS_SSID_OFFICE@" = {
          psk = "@WIRELESS_PSK_OFFICE@";
          extraConfig =
            "bssid=@WIRELESS_BSSID_OFFICE@,freq_list=@WIRELESS_FREQ_OFFICE@";
        };
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
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/porto/www";
      configDir = "/home/porto/.config/syncthing";
      user = "porto";
      group = "users";
      guiAddress = "0.0.0.0:8384";
      overrideDevices = true;
      overrideFolders = true;
      devices = {
        "jorel" = {
          id =
            "RTTGM7K-G3ZAONR-HSQFTS7-OA4GLAS-6SXEREI-TWPHTTB-34A4Y44-RY7FJAV";
        };
        "boris" = {
          id =
            "VKQZM3J-NVIBZ23-ZY2SOK5-2XCRZAE-OUPY6MP-A4IT2S6-NFA66BJ-E7LCMAM";
        };
      };
      folders = {
        "www" = {
          path = "/home/porto/www";
          devices = [ "jorel" "boris" ];
        };
      };
    };
    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = [ "nvidia" ];
      displayManager = { startx = { enable = true; }; };
      libinput = {
        enable = true;
        mouse = { accelProfile = "flat"; };
      };
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
  system = { stateVersion = "22.05"; };
}
