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
    vim = {
      enable = true;
      plugins = [ vim-promet ];
      settings = {
        background = "dark";
        number = true;
        tabstop = 4;
        shiftwidth = 4;
      };
      extraConfig = ''
        colorscheme promet
        set clipboard=unnamedplus
        set t_Co=256
        set autoindent
        set nocp
        filetype plugin indent on
        syntax on 
      '';
    };
  };
}

