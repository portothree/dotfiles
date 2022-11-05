{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.nodejs;
in {
  options.modules.nodejs = { enable = mkEnableOption "nodejs"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs-16_x
      yarn
      nodePackages.node-gyp
      nodePackages.node-pre-gyp
      nodePackages.node-gyp-build
    ];
  };
}
