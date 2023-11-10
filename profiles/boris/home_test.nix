let home = import ./home.nix; in

assert home.home.stateVersion == "22.11";
assert home.home.username == "gustavoporto";
assert home.home.homeDirectory == "/Users/gustavoporto";
assert home.home.packages == with pkgs; [
  st
  cava
  astyle
  glow
  chromium
];
assert home.home.sessionVariables == { EDITOR = "nvim"; };

assert home.programs.atuin.enable == true;
assert home.programs.htop.enable == true;
assert home.programs.gh.enable == true;
assert home.programs.gh.settings.git_protocol == "https";
assert home.programs.gh.settings.editor == "vim";
assert home.programs.gh.settings.aliases.co == "pr checkout";
assert home.programs.gh.settings.aliases.pv == "pr view";
assert home.programs.gh.settings.browser == "qutebrowser";
assert home.programs.direnv.enable == true;
assert home.programs.direnv.nix-direnv.enable == true;
assert home.programs.direnv.enableZshIntegration == true;
assert home.programs.fzf.enable == true;
assert home.programs.fzf.defaultCommand == "rg --files | fzf";
assert home.programs.fzf.enableZshIntegration == true;
assert home.programs.bat.enable == true;
assert home.programs.bat.config.theme == "Github";
assert home.programs.bat.config.italic-text == "always";
assert home.programs.zathura.enable == true;
assert home.programs.zathura.options.window-height == 1000;
assert home.programs.zathura.options.window-width == 1000;
assert home.programs.zathura.extraConfig == "map <C-i> recolor";

assert home.modules.bun.enable == true;
assert home.modules.tmux.enable == true;
assert home.modules.alacritty.enable == true;
assert home.modules.nodejs.enable == true;
assert home.modules.rust.enable == true;
assert home.modules.neovim.enable == true;
assert home.modules.qutebrowser.enable == true;
assert home.modules.zsh.enable == true;

echo "All tests passed";
