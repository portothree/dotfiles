{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./anki
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
