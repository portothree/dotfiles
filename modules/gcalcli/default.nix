{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gcalcli;
in {
  options.modules.gcalcli = {
    enable = mkEnableOption "gcalcli";
    enableNotifications = mkOption {
      description =
        "If enabled a systemd service and timer will be created to send gcalcli remind notifications";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ gcalcli ];
      file.gcalclirc = {
        target = ".gcalclirc";
        text = ''
          --lineart=ascii
        '';
      };
    };

    systemd.user.services.gcalcli-remind = mkIf cfg.enableNotifications {
      Install.WantedBy = [ "graphical-session.target" ];
      Service = { ExecStart = "${pkgs.gcalcli}/bin/gcalcli remind"; };
    };

    systemd.user.timers.gcalcli-remind = mkIf cfg.enableNotifications {
      Timer.OnCalendar = "*:0/5";
      Timer.Unit = "gcalcli-remind.service";
    };
  };
}
