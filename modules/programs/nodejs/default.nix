{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.nodejs;
in {
  options.modules.nodejs = { enable = mkEnableOption "nodejs"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_20
      nodePackages.node-gyp
      nodePackages.node-pre-gyp
      nodePackages.node-gyp-build
      nodePackages.pnpm
      nodePackages.prisma
      nodePackages.prettier
      yarn
    ];
  };
}
