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
    ./spotify
    ./nodejs
    ./alacritty
    ./gcalcli
    ./xinit
  ];
}
