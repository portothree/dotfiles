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
      plugins = [ (pluginGitHub "HEAD" "portothree/promet.vim") ];
      extraConfig = builtins.concatStringsSep "\n" [''
        lua << EOF
        ${lib.strings.fileContents ./neovim/init.lua}
        ${lib.strings.fileContents ./neovim/lua/settings.lua}
        ${lib.strings.fileContents ./neovim/lua/maps.lua}
        ${lib.strings.fileContents ./neovim/lua/statusline.lua}
        EOF
      ''];
    };
  };
}

