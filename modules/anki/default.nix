{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.anki;
in {
  options.modules.anki = { enable = mkEnableOption "anki"; };
  config = mkIf cfg.enable { home.packages = with pkgs; [ anki ]; };
}
