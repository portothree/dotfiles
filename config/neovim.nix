{ pkgs, ... }:

let
  vim-promet = pkgs.vimUtils.buildVimPlugin {
    name = "promet";
    src = pkgs.fetchFromGitHub {
      owner = "portothree";
      repo = "promet.vim";
      rev = "d630dacfefe30996f54efdc33fa442163eb9fea7";
      sha256 = "QC+7EkRU4OGjKEzlWhbbph2pW0g7zcLquq1FrUBCG40=";
    };
  };
in {
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = [
        vim-promet
        pkgs.vimPlugins.vim-prettier
        pkgs.vimPlugins.vim-airline
        pkgs.vimPlugins.YouCompleteMe
        pkgs.vimPlugins.ale
      ];
      extraConfig = builtins.concatStringSep "\n" [''
        lua << EOF
        ${lib.strings.fileContents ./neovim.lua}
        EOF
      ''];
    };
  };
}

