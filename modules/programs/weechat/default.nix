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
      default = with pkgs.weechatScripts; [ weechat-autosort url_hint ];
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
            init = ''
              /set relay.network.ssl on
              /set relay.network.ssl_verify off
              /set relay.network.ipv6 off
              /set relay.network.bind_address
              /set relay.network.port 9001
              /set plugins.var.python.urlserver.http_port "60211"
              /set plugins.var.python.slack.files_download_location = "~/Downloads/"
              /set weechat.bar.buflist.size 30
              /set weechat.completion.default_template "%(nicks)|%(irc_channels)|%(emoji)"

              /alias add open_url /url_hint_replace /exec -bg tmux new-window elinks {url$1}
              /key bind meta2-11~ /open_url 1
              /key bind meta2-12~ /open_url 2

              /script load theme.py
            '';
          };
        })
      ];
      file.".config/weechat/weechat.conf".source =
        ../../../config/weechat/weechat.conf;
      file.".local/share/weechat/python/autoload/theme.py".source =
        ../../../config/weechat/python/theme.py;
      file.".config/weechat/themes/flashcode.theme".source =
        ../../../config/weechat/themes/flashcode.theme;
    };
  };
}
