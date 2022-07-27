{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gcalcli;
in {
  options.modules.gcalcli = {
    enable = mkEnableOption "gcalcli";
  };
  config = mkIf cfg.enable = {
    home.packages = with pkgs; [ gcalcli ];
    file.gcalclirc = {
      target = ".gcalclirc";
      text = ''
        --lineart=ascii
      '';
    };
  };
}
