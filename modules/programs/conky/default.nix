{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.conky;
in {
  options.modules.conky = { enable = mkEnableOption "conky"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ conky ];
    home.file.conky = {
      target = ".conkyrc";
      text = lib.strings.fileContents ../../../config/conky/config.lua;
    };
  };
}
