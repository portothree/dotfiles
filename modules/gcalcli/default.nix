{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gcalcli;
in {
  options.modules.gcalcli = { enable = mkEnableOption "gcalcli"; };
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

    systemd.user.services.gcalcli-remind = {
      serviceConfig = {
        ExecStart = "${pkgs.gcalcli}/bin/gcacli remind";
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}
