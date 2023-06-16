{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gcloud;
in {
  options.modules.gcloud = { enable = mkEnableOption "gcloud"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        (google-cloud-sdk.withExtraComponents
          [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      ];
  };
}
