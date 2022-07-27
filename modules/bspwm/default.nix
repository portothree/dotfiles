{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.bspwm;
in {
  options.modules.bspwm = {
    enable = mkEnableOption "bspwm";
    extraConfig = mkOption {
      type = types.lines;
      description = "Additional configuration to be added to bspwmrc file";
      default = "";
    };
  };
  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          extraConfig = ''
            bspc config border_width 0.5
            bspc config window_gap 2
            bspc config split_ratio 0.52
            bspc config borderless_monocle true
            bspc config gapless_monocle true
            ${cfg.extraConfig}
          '';
        };
      };
    };
  };
}
