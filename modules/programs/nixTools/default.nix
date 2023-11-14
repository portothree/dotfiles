{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.nixTools;
in {
  options.modules.nixTools = { enable = mkEnableOption "nixTools"; };
  config = mkIf cfg.enable { home.packages = with pkgs; [ nixfmt ]; };
}
