{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.androidTools;
in
{
  options.modules.androidTools = {
    enable = mkEnableOption "androidTools";
  };
  config = mkIf cfg.enable { home.packages = with pkgs; [ android-tools ]; };
}
