{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.ghostty;
in {
  options.modules.ghostty = {
    enable = mkEnableOption "ghostty";
    installPkgFromNixpkgs = mkOption {
      description = "If enabled ghostty will be installed from nixpkgs";
      type = types.bool;
      default = false;
    };
    shell = mkOption {
      description = "Select a custom shell to use with ghostty";
      type = types.lines;
      default = "zsh";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = mkIf cfg.installPkgFromNixpkgs [ pkgs.ghostty ];
      file.ghostty = {
        target = ".config/ghostty/config";
        text = ''
          ${lib.strings.fileContents ../../../config/ghostty/config}
          shell-integration = ${cfg.shell}
        '';
      };
    };
  };
}
