{ pkgs, lib, ... }:
let
  pluginGitHub = ref: repo:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        ref = ref;
      };
    };
in {
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      coc = {
        enable = true;
        package = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "coc.nvim";
          version = "2022-05-21";
          src = pkgs.fetchFromGitHub {
            owner = "neoclide";
            repo = "coc.nvim";
            rev = "791c9f673b882768486450e73d8bda10e391401d";
            sha256 = "sha256-MobgwhFQ1Ld7pFknsurSFAsN5v+vGbEFojTAYD/kI9c=";
          };
          meta.homepage = "https://github.com/neoclide/coc.nvim/";
        };
        settings = {
          eslint = {
            enable = true;
            run = "onType";
            alwaysShowStatus = true;
            autoFixOnSave = true;
            format = { enable = true; };
          };
        };
      };
      plugins = with pkgs.vimPlugins; [
        vim-nix
        coc-eslint
        coc-prettier
        editorconfig-vim
      ];
      extraConfig = builtins.concatStringsSep "\n" [''
        lua << EOF
        ${lib.strings.fileContents ./neovim/init.lua}
        ${lib.strings.fileContents ./neovim/utils.lua}
        ${lib.strings.fileContents ./neovim/settings.lua}
        ${lib.strings.fileContents ./neovim/maps.lua}
        EOF
      ''];
    };
  };
}

