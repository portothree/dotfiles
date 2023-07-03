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
              /set irc.look.server_buffer independent

              /set plugins.var.python.urlserver.http_port "60211"
              /set plugins.var.python.slack.files_download_location "~/Downloads/weeslack"

              /alias add open_url /url_hint_replace /exec -bg xdg-open {url$1}
              /key bind meta2-11~ /open_url 1
              /key bind meta2-12~ /open_url 2
              /key bind meta-! /buffer close
            '';
          };
        })
      ];
      file.".config/weechat/weechat.conf".source =
        ../../../config/weechat/weechat.conf;
    };
  };
}
