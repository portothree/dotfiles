{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.xournalpp;
in {
  options.modules.xournalpp = { enable = mkEnableOption "xournalpp"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xournalpp
      # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/163107 is fixed
      gnome.adwaita-icon-theme
      shared-mime-info
    ];
  };
}
