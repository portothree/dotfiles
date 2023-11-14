{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.rust;
in {
  options.modules.rust = { enable = mkEnableOption "rust"; };
  config =
    mkIf cfg.enable { home.packages = with pkgs; [ rustc cargo rustfmt ]; };
}
