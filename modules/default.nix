{ inputs, pkgs, config, ... }:

{
  imports = [ ./tmux ./bspwm ./sxhkd ./nodejs ./alacritty ];
}
