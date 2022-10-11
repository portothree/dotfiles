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
      file.".weechat".source = pkgs.writeText "weechat.conf" ''
        /set relay.network.ssl on
        /set relay.network.ssl_verify off
        /set relay.network.ipv6 off
        /set relay.network.bind_address
        /set relay.network.port 9001
        /set weechat.bar.buflist.size 30
        /set plugins.var.python.urlserver.http_port "60211"
        /set plugins.var.python.slack.files_download_location = "~/Downloads/"
        /set weechat.completion.default_template "%(nicks)|%(irc_channels)|%(emoji)"
      '';
    };
  };
}
