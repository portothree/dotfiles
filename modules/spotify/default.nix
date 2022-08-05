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

  tomlFormat = pkgs.formats.toml { };

  spotifydSettings = (defaultSpotifydSettings // cfg.extraSpotifydSettings);

  configFile = tomlFormat.generate "spotifyd.conf" spotifydSettings;
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
    assertions = [
      (lib.hm.assertions.assertPlatform "services.spotifyd" pkgs
        lib.platforms.linux)
    ];
    home.packages = with pkgs; [ spotify-tui ];
    systemd.user.services.spotifyd = {
      Unit = { Description = "spotify deamon"; };
      Install.WantedBy = [ "default.target" ];
      Service = {
        # Needed to access the BW_SESSION env var in
        # username_cmd and password_cmd with bitwarden-cli
        EnvironmentFile = "/etc/nixos/.env";
        ExecStart =
          "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path ${configFile}";
        Restart = "always";
        RestartSec = 12;
      };
    };
  };
}
