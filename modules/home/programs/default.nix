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
    ./spotify
    ./nodejs
    ./alacritty
    ./gcalcli
    ./xinit
  ];
}
