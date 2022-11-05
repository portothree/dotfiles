{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.jrnl;
in {
  options.modules.jrnl = {
    enable = mkEnableOption "jrnl";
    journalPath = mkOption {
      type = types.str;
      description = "Path to journal file";
      default = "";
    };
    editor = mkOption {
      type = types.str;
      description = "Editor to be used for jrnl";
      default = "nvim";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [ jrnl ];
      file.jrnlrc = {
        target = ".config/jrnl/jrnl.yaml";
        text = ''
          colors:
            body: none
            date: none
            tags: none
            title: none
          default_hour: 9
          default_minute: 0
          editor: ${cfg.editor}
          encrypt: false
          highlight: true
          indent_character: '|'
          journals:
            default: ${cfg.journalPath}
          linewrap: 79
          tagsymbols: '#@'
          template: false
          timeformat: '%Y-%m-%d %H:%M'
          version: v3.0
        '';
      };
    };
  };
}
