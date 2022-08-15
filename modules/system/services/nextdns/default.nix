{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.nextdnsc;
in {
  options = {
    services.nextdnsc = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether to enable the NextDNS DNS/53 to DoH Proxy service.";
      };
      arguments = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "-config" "10.0.3.0/24=abcdef" ];
        description = "Additional arguments to be passed to nextdns run.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nextdns = {
      description = "NextDNS DNS/53 to DoH Proxy";
      environment = { SERVICE_RUN_MODE = "1"; };
      startLimitIntervalSec = 5;
      startLimitBurst = 10;
      serviceConfig = {
        EnvironmentFile = "/etc/nixos/.env";
        ExecStart = "${pkgs.nextdns}/bin/nextdns run ${
            escapeShellArgs config.services.nextdns.arguments
          } -config $NEXTDNS_CONFIG_ID";
        RestartSec = 120;
        LimitMEMLOCK = "infinity";
      };
      after = [ "network.target" ];
      before = [ "nss-lookup.target" ];
      wants = [ "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
