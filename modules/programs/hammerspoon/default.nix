{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.hammerspoon;
in {
  options.modules.hammerspoon = { enable = mkEnableOption "hammerspoon"; };
  config = mkIf cfg.enable {
    home = {
      file.hammerspoon = {
        target = "./.hammerspoon/init.lua";
        text = lib.strings.fileContents ../../../config/hammerspoon/init.lua;
      };
    };
  };
}
