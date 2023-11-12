{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.karabiner-elements;
in {
  options.modules.karabiner-elements = {
    enable = mkEnableOption "karabiner-elements";
    installPkg = mkOption {
      description =
        "If enabled karabiner-elements will be installed from nixpkgs";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = mkIf cfg.installPkg [ pkgs.karabiner-elements ];
      file.karabiner-elements = {
        target = ".config/karabiner/karabiner.json";
        text = lib.strings.fileContents
          ../../../config/karabiner-elements/karabiner.json;
      };
    };
  };
}
