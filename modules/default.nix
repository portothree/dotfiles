{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports = [
    ./zsh
    ./tmux
    ./bspwm
    ./dunst
    ./sxhkd
    ./nodejs
    ./alacritty
    ./gcalcli
    ./xinit
  ];
}
