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
      coc = { enable = true; };
      plugins = [ pkgs.vimPlugins.onedark-nvim ];
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

