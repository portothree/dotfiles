{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./anki
    ./androidTools
    ./dunst
    ./dockerTools
    ./zsh
    ./tmux
    ./bspwm
    ./sxhkd
    ./nodejs
    ./alacritty
    ./gcalcli
    ./xinit
  ];
}
