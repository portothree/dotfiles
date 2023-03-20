{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.neovim;
  getPluginFromGithub = repo: version: rev:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      inherit version;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        inherit rev;
      };
    };
in {
  options.modules.neovim = { enable = mkEnableOption "neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      plugins = with pkgs.vimPlugins;
        [
          vim-polyglot
          editorconfig-vim
          copilot-vim
          YouCompleteMe
          ale
          onedarkpro-nvim
          nvim-treesitter
          vimwiki
        ] ++ [
          (getPluginFromGithub "terror/chatgpt.nvim" "1.0.0"
            "e8a8f55250e2d948bb43714c1986a0150711898c")
        ];
      extraConfig = builtins.concatStringsSep "\n" [''
        lua << EOF
        ${lib.strings.fileContents ../../../config/neovim/init.lua}
        ${lib.strings.fileContents ../../../config/neovim/utils.lua}
        ${lib.strings.fileContents ../../../config/neovim/settings.lua}
        ${lib.strings.fileContents ../../../config/neovim/maps.lua}
        EOF
      ''];
    };
  };
}

