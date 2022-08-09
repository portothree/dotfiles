{ pkgs, lib, ... }:
let
  pluginGitHub = repo: version: rev:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      inherit version;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        inherit rev;
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
      plugins = with pkgs.vimPlugins;
        [
          vim-polyglot
          vim-fugitive
          vim-prettier
          editorconfig-vim
          copilot-vim
          YouCompleteMe
          ale
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

