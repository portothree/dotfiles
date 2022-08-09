{ pkgs, lib, ... }:
let
  pluginGitHub =  repo: version: rev:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      inherit version;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        inherit rev;
      };
    };
  vim-copilot = pluginGitHub "github/copilot.vim" "release" "6c5abda66350773ae2f8fade2e931b3beb51843f";
in {
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      plugins = with pkgs.vimPlugins;
        [
          vim-polyglot
          vim-fugitive
          vim-prettier
          editorconfig-vim
          YouCompleteMe
          ale
        ] ++ [ vim-copilot ];
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

