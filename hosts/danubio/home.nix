{ pkgs, ... }:

{
  imports = [
    ../../config/home-manager/common.nix
    ../../config/git.nix
    ../../config/vim.nix
  ];
  home = {
    packages = with pkgs; [
      st
      sysz
      ranger
      tig
      google-cloud-sdk
      k9s
      kubectl
      ripgrep
      astyle
      black
      shfmt
      nixfmt
      glow
      unifont
      fira-code
      siji
      weechat
      pgcli
      mycli
      wuzz
      websocat
      lazydocker
      nodejs
      yarn
      poetry
      docker-compose
    ];
    sessionVariables = { EDITOR = "vim"; };
  };
  programs = {
    htop = { enable = true; };
    zsh = {
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
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "git-auto-fetch" ];
        theme = "robbyrussell";
      };
    };
    gh = {
      enable = true;
      settings = {
        git_protocol = "https";
        editor = "vim";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      plugins = with pkgs.tmuxPlugins; [ sensible yank ];
      extraConfig = ''
        set -g mouse off 
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      defaultCommand = "rg --files | fzf";
      enableZshIntegration = true;
    };
    bat = {
      enable = true;
      config = {
        theme = "Github";
        italic-text = "always";
      };
    };
  };
}
