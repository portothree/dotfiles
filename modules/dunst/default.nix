{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dunst;
  defaultSettings = {
    shortcuts = {
      close = "ctrl+space";
      close_all = "ctrl+shift+space";
    };
  };
in {
  options.modules.dunst = {
    enable = mkEnableOption "dunst";
    extraSettings = mkOption {
      type = types.submodule {
        freeformType = with types; attrsOf (attrsOf eitherStrBoolIntList);
      };
      description = "Additional configuration to be added to dunstrc file";
      default = { };
    };
  };
  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = defaultSettings // cfg.extraSettings;
    };
  };
}
