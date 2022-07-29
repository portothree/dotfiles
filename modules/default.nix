{ inputs, pkgs, config, shellScriptPkgs, ... }:

{
  imports =
    [ ./zsh ./tmux ./bspwm ./sxhkd ./nodejs ./alacritty ./gcalcli ./xinit ];
}
