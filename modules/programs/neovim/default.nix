{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.neovim;
in
{
  options.modules.neovim = {
    enable = mkEnableOption "neovim";
  };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      # Keep the pre-26.05 defaults
      withPython3 = true;
      withRuby = true;
      withNodeJs = true;
      plugins = with pkgs.vimPlugins; [
        vim-polyglot
        editorconfig-vim
        copilot-vim
        ale
        onedarkpro-nvim
        nvim-treesitter
        vimwiki
        telescope-nvim
        vim-wakatime
      ];
      extraConfig = builtins.concatStringsSep "\n" [
        ''
          lua << EOF
          ${lib.strings.fileContents ../../../config/editors/neovim/init.lua}
          ${lib.strings.fileContents ../../../config/editors/neovim/utils.lua}
          ${lib.strings.fileContents ../../../config/editors/neovim/settings.lua}
          ${lib.strings.fileContents ../../../config/editors/neovim/maps.lua}
          EOF
        ''
      ];
    };
  };
}
