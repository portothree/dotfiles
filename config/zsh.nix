{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    sessionVariables = {
      PROMPT = "%(?.%F{green}.%F{red})λ%f %B%F{cyan}%~%f%b ";
      VISUAL = "vim";
      EDITOR = "vim";
      HISTTIMEFORMAT = "%F %T ";
      PATH =
        "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/nix/var/nix/profiles/default/bin:/home/porto/nix-profile/bin";
      NIX_PATH =
        "/home/porto/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
      LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
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
    initExtraFirst = ''
      [[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "git-auto-fetch" ];
      theme = "robbyrussell";
    };
  };
}
