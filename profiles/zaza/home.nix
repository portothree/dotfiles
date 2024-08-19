{ pkgs, lib, ... }:

let
  homeDirectory = "/Users/porto";
  username = "porto";
in {
  imports = [
    ../../modules
    ../../config/git.nix
    ../../config/ranger.nix
    ../../config/tig.nix
  ];
  home = {
    inherit homeDirectory username;
    stateVersion = "22.11";
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
      asdf-vm
    ];
    sessionVariables = { EDITOR = "nvim"; };
    file = { };
  };
  programs = {
    home-manager = { enable = true; };
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
      installPkgFromNixpkgs = false;
      installPkgFromHomeManager = false;
    };
    bun.enable = true;
    dockerTools.enable = true;
    tmux.enable = true;
    nodejs.enable = false;
    rust.enable = true;
    neovim.enable = true;
    nixTools.enable = true;
    zsh = {
      enable = true;
      loadAsdf = true;
    };
  };
}
