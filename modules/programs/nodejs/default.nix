{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.nodejs;
in
{
  options.modules.nodejs = {
    enable = mkEnableOption "nodejs";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_24
      node-gyp
      node-pre-gyp
      node-gyp-build
      pnpm
      prisma
      prettier
      yarn
    ];
  };
}
