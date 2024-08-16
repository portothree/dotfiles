{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.alacritty;
in {
  options.modules.alacritty = { 
    enable = mkEnableOption "alacritty";
    installPkg = mkOption {
      description = "If enabled alacritty will be installed from nixpkgs";
      type = types.bool;
      default = true;
    };
    shell = mkOption {
      description = "Select a custom shell to use with alacritty";
      type = types.lines;
      default = "zsh";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = mkIf cfg.installPkg [ pkgs.alacritty ];
      file.alacritty = {
        target = ".config/alacritty/alacritty.yml";
        text = ''
          ${lib.strings.fileContents ../../../config/alacritty/alacritty.yml}
          shell:
            program: ${cfg.shell}
          '';
      };
    };
  };
}
