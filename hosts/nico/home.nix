{ pkgs, ... }:

{
  imports = [
    ../../config/home-manager/common.nix
    ../../config/git.nix
    ../../config/vim.nix
    ../../config/gh.nix
    ../../config/tmux.nix
  ];
  home = {
    stateVersion = "21.11";
    packages = with pkgs; [
      st
      sysz
      ranger
      tig
      ripgrep
      shfmt
      nixfmt
      glow
      wuzz
      websocat
      nodejs
      lazydocker
    ];
  };
  programs = {
    bash = {
      enable = true;
      sessionVariables = { EDITOR = "vim"; };
    };
    htop = { enable = true; };
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
