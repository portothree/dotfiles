{ pkgs, lib, ... }:

{
  imports = [
    ../../modules
    ../../config/git.nix
    ../../config/ranger.nix
    ../../config/tig.nix
  ];
  home = {
    stateVersion = "22.11";
    username = "porto";
    homeDirectory = "/Users/porto";
    packages = with pkgs; [
      xcbuild
      python311
      qt6.full
      glow
      ripgrep
      shfmt
      shellcheck
      jq
      yq
      sd
      fd
      difftastic
      jdk11
    ];
    sessionVariables = { EDITOR = "nvim"; };
    file = { };
  };
  programs = {
    home-manager = { enable = true; };
    fish = {
      enable = true;
      shellInit = lib.strings.fileContents ../../config/fish/init.fish;
      shellAliases = {
        g = "git";
        r = "ranger";
        "..." = "cd ../..";
      };
    };
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
    alacritty = {
      enable = true;
      shell = "/usr/local/bin/fish";
    };
    bun.enable = true;
    dockerTools.enable = true;
    tmux.enable = true;
    nodejs.enable = true;
    rust.enable = true;
    neovim.enable = true;
    nixTools.enable = true;
  };
}
