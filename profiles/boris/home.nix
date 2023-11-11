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
    username = "gustavoporto";
    homeDirectory = "/Users/gustavoporto";
    packages = with pkgs; [ python311 ];
    sessionVariables = { EDITOR = "nvim"; };
    file = {};
  };
  programs = {
    home-manager = { enable = true; };
    fish = { 
      enable = true;
      shellInit = lib.strings.fileContents ../../config/fish/init.fish;
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
    zathura = {
      enable = true;
      options = {
        window-height = 1000;
        window-width = 1000;
      };
      extraConfig = ''
        map <C-i> recolor
      '';
    };
  };
  modules = {
    bun.enable = true;
    tmux.enable = true;
    nodejs.enable = true;
    rust.enable = true;
    neovim.enable = true;
  };
}
