{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.spotify;
  defaultSettings = {
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
    extraSettings = mkOption {
      type = types.submodule {
        freeformType = with types; attrsOf (attrsOf eitherStrBoolIntList);
      };
      description =
        "Additional configuration to be added to spotifyd.conf file";
      default = {};
    };
  };
  config = mkIf cfg.enable {
    services.spotifyd = {
      enable = true;
      settings = defaultSettings // cfg.extraSettings;
    };
    home.packages = with pkgs; [ spotify-tui ];
  };
}
