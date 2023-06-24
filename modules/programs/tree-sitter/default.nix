{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.tree-sitter;
in {
  options.modules.tree-sitter = { enable = mkEnableOption "tree-sitter"; };
  config =
    mkIf cfg.enable { home = { packages = with pkgs; [ tree-sitter ]; }; };
}
