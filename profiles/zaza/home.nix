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
    activation = {
      # TODO: Move to a shared/common file
      rsync-home-manager-applications =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
          apps_source="$genProfilePath/home-path/Applications"
          moniker="Home Manager Trampolines"
          app_target_base="${homeDirectory}/Applications"
          app_target="$app_target_base/$moniker"
          mkdir -p "$app_target"
          ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target"
        '';
    };
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
      shell = "$HOME/.nix-profile/bin/fish";
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
