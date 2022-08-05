{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.spotify;

  eitherStrBoolIntList = with types;
    either str (either bool (either int (listOf str)));

  defaultSpotifydSettings = {
    global = {
      backend = "pulseaudio";
      bitrate = 320;
      initial_volume = "90";
      device_type = "computer";
    };
  };
in {
  options.modules.spotify = {
    enable = mkEnableOption "spotify";
    extraSpotifydSettings = mkOption {
      type = types.submodule {
        freeformType = with types; attrsOf (attrsOf eitherStrBoolIntList);
      };
      description =
        "Additional configuration to be added to spotifyd.conf file";
      default = { };
    };
  };
  config = mkIf cfg.enable {
    services.spotifyd = {
      enable = true;
      settings = defaultSpotifydSettings // cfg.extraSpotifydSettings;
    };
    home.packages = with pkgs; [ spotify-tui ];
  };
}
