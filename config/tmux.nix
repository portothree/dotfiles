{ pkgs, ... }:

{
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
      set-option -g status-left "#[fg=black]#(gcalcli agenda --nostarted --nodeclined | head -2 | tail -1)#[default]"
    '';
  };
}
