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
      localVariables = with pkgs; {
        LAMBDA = "λ";
        MEMEX_PATH = "/home/porto/www/memex";
        PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING = 1;
        PRISMA_MIGRATION_ENGINE_BINARY =
          "${prisma-engines}/bin/migration-engine";
        PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
        PRISMA_QUERY_ENGINE_LIBRARY =
          "${prisma-engines}/lib/libquery_engine.node";
        PRISMA_INTROSPECTION_ENGINE_BINARY =
          "${prisma-engines}/bin/introspection-engine";
        PRISMA_FMT_BINARY = "${prisma-engines}/bin/prisma-fmt";
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
