{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.nodejs;
in {
  options.modules.nodejs = { enable = mkEnableOption "nodejs"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      node2nix
      yarn2nix
      nodePackages.npm
      nodePackages.node-gyp
      nodePackages.node-pre-gyp
      nodePackages.node-gyp-build
      yarn
    ];
  };
}
