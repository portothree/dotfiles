{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.weechat;
  scripts = cfg.scripts;
in {
  options.modules.weechat = {
    enable = mkEnableOption "weechat";
    scripts = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "List of weechat scripts to install.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = [
        (pkgs.weechat.override {
          configure = { availablePlugins, ... }: {
            plugins = with availablePlugins; [
              lua
              perl
              (python.withPackages (p: with p; [ websocket-client ]))
            ];
            scripts = cfg.scripts;
          };
        })
      ];
      file.".config/weechat/weechat.conf".source =
        ../../../../config/weechat/weechat.conf;
      file.".config/weechat/python/theme.py".source =
        ../../../../config/weechat/python/theme.py;
      file.".config/weechat/themes/flashcode.theme".source =
        ../../../../config/weechat/themes/flashcode.theme;
    };
  };
}
