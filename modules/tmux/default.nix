{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.tmux;

  defaultPlugins = with pkgs; [
    {
      plugin = tmuxPlugins.continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '60'
      '';
    }
    tmuxPlugins.yank
  ];

  allPlugins = defaultPlugins ++ cfg.plugins;
in {
  options.modules.tmux = {
    enable = mkEnableOption "tmux";
    plugins = mkOption {
      type = with types; listOf package;
      default = [ ];
      example = literalExpression ''
        with pkgs.tmuxPlugins; [ resurrect ]
      '';
      description = "List of tmux plugins to install";
    };
    gcalcli = mkOption {
      type = types.bool;
      default = false;
      description =
        "If enabled, the next event from `gcalcli agenda` will be displayed in the status line";
    };
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      plugins = allPlugins;
      extraConfig = ''
        set -g mouse off 

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        set-option -g status-interval 60
        ${optionalString (cfg.gcalcli)
        "set-option -g status-left '#[fg=black]#(gcalcli agenda --nostarted --nodeclined | head -2 | tail -1)#[default]'"}
      '';
    };
  };
}
