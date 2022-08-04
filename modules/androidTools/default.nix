{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.androidTools;
in {
  options.modules.androidTools = { enable = mkEnableOption "androidTools"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ androidenv.androidPkgs_9_0.platform-tools ];
    services.udev.packages = with pkgs; [ android-udev-rules ];
  };
}
