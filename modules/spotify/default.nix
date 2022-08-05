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

  tomlFormat = pkgs.format.toml { };

  configFile = tomlFormat.generate "spotifyd.conf" defaultSpotifydSettings
    // cfg.extraSpotifydSettings;

  pkg = pkgs.spotifyd;
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
    home.packages = with pkgs; [ spotify-tui ];
    systemd.user.services.spotifyd = {
      Unit = { Description = "spotify deamon"; };
      Install.WantedBy = [ "default.target" ];
      Service = {
        EnvironmentFile = "/etc/nixos/.env";
        ExecStart =
          "${pkg}/bin/spotifyd --no-daemon --config-path ${configFile}";
        Restart = "always";
        RestartSec = 12;
      };
    };
  };
}
