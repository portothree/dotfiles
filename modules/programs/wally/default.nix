{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.wally;
in {
  options.modules.wally = { enable = mkEnableOption "wally"; };
  config = mkIf cfg.enable { home.packages = with pkgs; [ wally-cli ]; };
}
