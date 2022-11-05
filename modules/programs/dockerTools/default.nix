{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.dockerTools;
in {
  options.modules.dockerTools = { enable = mkEnableOption "dockerTools"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ docker-compose arion lazydocker ];
  };
}
