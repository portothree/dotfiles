{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.lemonbar;
in {
  options.modules.lemonbar = { enable = mkEnableOption "lemonbar" };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ lemonbar xdo ];
  };
}
