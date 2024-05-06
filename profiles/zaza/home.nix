{ pkgs, lib, ... }:

let homeDirectory = "/Users/porto";

in {
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
    activation = {
      # TODO: Move to a shared/common file
      aliasHomeManagerApplications =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          app_folder="${homeDirectory}/Applications/Home Manager Trampolines"
          rm -rf "$app_folder"
          mkdir -p "$app_folder"
          find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
              app_target="$app_folder/$(basename "$app")"
              real_app="$(readlink "$app")"
              echo "mkalias \"$real_app\" \"$app_target\"" >&2
              $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
          done
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
