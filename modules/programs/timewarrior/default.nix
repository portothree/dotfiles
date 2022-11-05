{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.timewarrior;
in {
  options.modules.timewarrior = { enable = mkEnableOption "timewarrior"; };
  config = mkIf cfg.enable { home.packages = with pkgs; [ timewarrior ]; };
}
