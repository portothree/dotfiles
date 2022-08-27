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
    ./alacritty
    ./gcalcli
    ./jrnl
    ./xinit
    ./xournalpp
    ./zsh
  ];
}
