{ inputs, pkgs, config, ... }:

{
  imports = [ ./zsh ./tmux ./bspwm ./sxhkd ./nodejs ./alacritty ./gcalcli ];
}
