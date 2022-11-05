{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.bun;
in {
  options.modules.bun = { enable = mkEnableOption "bun"; };
  config = mkIf cfg.enable { home.packages = with pkgs; [ bun ]; };
}
