{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.tmux;
  pluginName = p: if types.package.check p then p.pname else p.plugin.pname;
  pluginModule = types.submodule {
    options = {
      plugin = mkOption {
        type = types.package;
        description = "Path of the configuration file to include.";
      };
      extraConfig = mkOption {
        type = types.lines;
        description = "Additional configuration for the associated plugin.";
        default = "";
      };
    };
  };
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
  allPluginsAndSubmodules = defaultPlugins ++ cfg.plugins;
  allPlugins = map (p: if types.package.check p then p else p.plugin)
    allPluginsAndSubmodules;
in {
  options.modules.tmux = {
    enable = mkEnableOption "tmux";
    plugins = mkOption {
      type = with types;
        listOf (either package pluginModule) // {
          description = "List of plugin packages or submodules";
        };
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

        ${(concatMapStringsSep "\n" (p: "${p.extraConfig or ""}")
          allPluginsAndSubmodules)}
      '';
    };
  };
}
