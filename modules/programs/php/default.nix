{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.php;
in {
  options.modules.php = { enable = mkEnableOption "php"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ php83 php83Packages.composer ];
  };
}
