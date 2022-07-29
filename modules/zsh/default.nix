{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.zsh;
in {
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      sessionVariables = {
        VISUAL = "nvim";
        EDITOR = "nvim";
        HISTTIMEFORMAT = "%F %T ";
      };
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      localVariables = {
        LAMBDA = "λ";
        MEMEX_PATH = "/home/porto/www/memex";
      };
      shellAliases = {
        r = "ranger";
        rgf = "rg --files | rg";
        ksns =
          "kubectl api-resources --verbs=list --namespaced -o name | xargs -n1 kubectl get '$@' --show-kind --ignore-not-found";
        krns =
          "kubectl api-resources --namespaced=true --verbs=delete -o name | tr '' ',' | sed -e 's/,$//''";
        kdns = "kubectl delete '$(krns)' --all";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "git-auto-fetch" ];
        theme = "robbyrussell";
      };
    };
  };
}
