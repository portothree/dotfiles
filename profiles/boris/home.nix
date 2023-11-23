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
    packages = with pkgs; [
      xcbuild
      python311
      qt6.full
      glow
      azure-cli
      azure-functions-core-tools
      vscode
      bitwarden-cli
      teams
      ripgrep
      shfmt
      shellcheck
      jq
      yq
      sd
      fd
      difftastic
      spotify
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
    alacritty = {
      enable = true;
      # Skip installation as Alacritty was installed on this machine
      # with a .dmg image
      installPkg = false;
      shell = "/usr/local/bin/fish";
    };
    bun.enable = true;
    dockerTools.enable = true;
    karabiner-elements = {
      enable = true;
      installPkg = false;
    };
    tmux.enable = true;
    nodejs.enable = true;
    rust.enable = true;
    neovim.enable = true;
    nixTools.enable = true;
  };
}
