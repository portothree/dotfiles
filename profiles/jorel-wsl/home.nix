{ pkgs, shellScriptPkgs, ... }:

{
  imports = [
    ../../home-manager
    ../../modules
    ../../config/git.nix
    ../../config/ranger.nix
    ../../config/keynav.nix
    ../../config/rofi.nix
    ../../config/tig.nix
  ];
  home = {
    stateVersion = "22.11";
    username = "porto";
    homeDirectory = "/home/porto";
    packages = with pkgs; [
      st
      cava
      astyle
      glow
      pgcli
      mycli
      tasksh
      vit
      pulsemixer
      nudoku
      playerctl
      spotify-tui
      nvtop
      mutt
      mpv
      gh
      ffmpeg
      distrobox
      bitwarden-cli
      v4l-utils
      nextdns
      llama
      awscli2
      chromium
      openconnect
      openshift
      k9s
      kubectl
      kubernetes-helm
      telepresence2
      auth0-cli
      bandwhich
      diskonaut
      ngrok
      postgresql_15
      libpqxx
      flyctl
      azure-cli
      azure-functions-core-tools
    ];
    sessionVariables = { EDITOR = "nvim"; };
  };
  programs = {
    atuin.enable = true;
    htop = { enable = true; };
    gh = {
      enable = true;
      settings = {
        git_protocol = "https";
        editor = "vim";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        browser = "qutebrowser";
      };
    };
    direnv = {
      enable = true;
      nix-direnv = { enable = true; };
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
  modules = {
    anki.enable = true;
    androidTools.enable = true;
    bun.enable = true;
    conky.enable = true;
    dunst.enable = true;
    xinit = {
      enable = true;
      autorandr = true;
      sxhkd = true;
      bspwm = true;
    };
    tmux.enable = true;
    alacritty.enable = true;
    spotify.enable = true;
    nodejs.enable = true;
    rust.enable = true;
    neovim.enable = true;
    gcalcli.enable = true;
    gptcommit.enable = false;
    gcloud.enable = true;
    timewarrior.enable = true;
    dockerTools.enable = true;
    qutebrowser.enable = true;
    wally.enable = true;
    weechat = {
      enable = true;
      additionalScripts = with pkgs.weechatScripts; [ wee-slack ];
    };
    xournalpp.enable = true;
    zsh.enable = true;
  };
}
