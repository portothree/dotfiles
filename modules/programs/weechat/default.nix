{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.weechat;
  scripts = cfg.scripts;
  defaultScripts = with pkgs.weechatScripts; [
    weechat-autosort
    weechat-go
    url_hint
    edit
    highmon
  ];
in {
  options.modules.weechat = {
    enable = mkEnableOption "weechat";
    additionalScripts = mkOption {
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
            scripts = cfg.additionalScripts ++ defaultScripts;
            init = ''
              /set irc.look.server_buffer independent
              /set buflist.format.buffer ''${format_number}''${indent}''${cut:20,...,}''${format_nick_prefix}''${color_hotlist}''${format_name}

              /set plugins.var.python.urlserver.http_port "60211"
              /set plugins.var.python.slack.files_download_location "~/Downloads/weeslack"
              /set plugins.var.python.slack.auto_open_threads true
              /set plugins.var.python.slack.never_away false
              /set plugins.var.python.slack.render_emoji_as_string true



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
