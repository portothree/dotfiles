{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./anki
    ./androidTools
    ./dunst
    ./dockerTools
    ./tmux
    ./bspwm
    ./sxhkd
    ./spotify
    ./nodejs
    ./neovim
    ./alacritty
    ./gcalcli
    ./jrnl
    ./xinit
    ./xournalpp
    ./zsh
  ];
}
