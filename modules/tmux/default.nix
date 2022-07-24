{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.tmux;
in {
  options.modules.tmux = {
    enable = mkEnableOption "tmux";
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
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '60'
          '';
        }
        tmuxPlugins.yank
      ];
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
