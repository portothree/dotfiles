{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.wakatime;
in {
  options.modules.wakatime = {
    enable = mkEnableOption "wakatime";
    installPkg = mkOption {
      description = "If enabled wakatime will be installed from nixpkgs";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = mkIf cfg.installPkg [ pkgs.wakatime ];
      file.wakatime = {
        target = ".wakatime.cfg";
        text = lib.strings.fileContents ../../../config/wakatime/.wakatime.cfg;
      };
    };
  };
}
