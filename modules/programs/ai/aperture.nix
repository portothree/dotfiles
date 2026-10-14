{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.ai.aperture;
  # Source comes from the ts-plug flake input, bumped by Renovate's lock file
  # maintenance. When a bump changes go.sum, the build fails with the new
  # vendorHash ("got: sha256-…"); paste it here.
  ts-unplug = pkgs.buildGoModule {
    pname = "ts-unplug";
    version = "0-unstable-${inputs.ts-plug.lastModifiedDate}";
    src = inputs.ts-plug;
    vendorHash = "sha256-jDncA3HPjndfQ5dd/Qv1Etxk5qyS79YfBicNYzohHAc=";
    subPackages = [ "cmd/ts-unplug" ];
    meta.mainProgram = "ts-unplug";
  };
  stateDir = "${config.xdg.stateHome}/ts-unplug";
in
{
  options.modules.ai.aperture = {
    enable = mkEnableOption "a local proxy to the Aperture gateway that keeps its own tailnet login";
    gateway = mkOption {
      type = types.str;
      default = "p8s.tailea386.ts.net";
      description = "Aperture gateway hostname on the personal tailnet.";
    };
    port = mkOption {
      type = types.port;
      default = 8787;
      description = "localhost port the agents use as their Aperture base URL.";
    };
  };
  # ts-unplug joins the personal tailnet as its own node (tsnet), so the agents
  # reach Aperture whichever tailnet the Tailscale app is signed in to.
  config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    home.packages = [ ts-unplug ];
    launchd.agents.ts-unplug = {
      enable = true;
      config = {
        ProgramArguments = [
          (getExe ts-unplug)
          "-dir"
          stateDir
          "-hostname"
          "ts-unplug-${config.home.username}"
          "-port"
          (toString cfg.port)
          cfg.gateway
        ];
        RunAtLoad = true;
        KeepAlive = true;
        # The first run logs the tailnet login URL here
        StandardOutPath = "${stateDir}/ts-unplug.log";
        StandardErrorPath = "${stateDir}/ts-unplug.log";
      };
    };
    home.activation.tsUnplugStateDir = hm.dag.entryBefore [ "setupLaunchAgents" ] ''
      run mkdir -p ${escapeShellArg stateDir}
    '';
  };
}
