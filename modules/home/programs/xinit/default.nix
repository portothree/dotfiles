{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.xinit;
in {
  options.modules.xinit = {
    enable = mkEnableOption "xinit";
    autorandr = mkOption {
      type = types.bool;
      default = false;
    };
    sxhkd = mkOption {
      type = types.bool;
      default = false;
    };
    bspwm = mkOption {
      type = types.bool;
      default = false;
    };
    extraConfig = mkOption {
      type = types.lines;
      description = "Additional configuration to be added to .xinitrc";
      default = "";
    };
  };
  config = mkIf cfg.enable {
    home.file.xinitrc = {
      target = ".xinitrc";
      text = ''
          [ -f ~/.xprofile ] && . ~/.xprofile
          [ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

          if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
              eval $(dbus-launch --exit-with-session --sh-syntax)
          fi

          systemctl --user import-environment DISPLAY XAUTHORITY

          if command -v dbus-update-activation-environment >/dev/null 2>&1; then
        	  dbus-update-activation-environment DISPLAY XAUTHORITY
          fi

          systemctl --user start graphical-session.target

          ${cfg.extraConfig}

          ${
            optionalString (cfg.autorandr)
            "${pkgs.autorandr}/bin/autorandr --change"
          }
          ${optionalString (cfg.sxhkd) "${pkgs.sxhkd}/bin/sxhkd &"}
          ${optionalString (cfg.bspwm) "exec ${pkgs.bspwm}/bin/bspwm"}
      '';
    };
  };
}
