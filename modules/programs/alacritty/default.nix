{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.alacritty;
in {
  options.modules.alacritty = {
    enable = mkEnableOption "alacritty";
    installPkgFromNixpkgs = mkOption {
      description = "If enabled alacritty will be installed from nixpkgs";
      type = types.bool;
      default = false;
    };
    installPkgFromHomeManager = mkOption {
      description = "If enabled alacritty will be installed from home-manager";
      type = types.bool;
      default = true;
    };
    shell = mkOption {
      description = "If enabled alacritty will use fish";
      type = types.lines;
      default = "zsh";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = mkIf cfg.installPkgFromNixpkgs [ pkgs.alacritty ];
      file.alacritty = {
        target = ".config/alacritty/alacritty.yml";
        text = ''
          ${lib.strings.fileContents ../../../config/alacritty/alacritty.yml}
          shell:
            program: ${cfg.shell}
        '';
      };
    };
    programs.alacritty = { enable = cfg.installPkgFromHomeManager; };
  };
}
