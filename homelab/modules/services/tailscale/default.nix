{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.tailscalec;
in {
  options = {
    services.tailscalec = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the tailscale service.";
      };
      searchAddress = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      port = 41641;
    };
    environment.systemPackages = [ pkgs.tailscale ];
    networking = {
      nameservers = [ "100.100.100.100" ];
      search = [ cfg.searchAddress ];
      firewall = {
        allowedUDPPorts = [ config.services.tailscale.port ];
        trustedInterfaces = [ "tailscale0" ];
      };
    };
  };
}
