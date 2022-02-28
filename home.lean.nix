{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];
  home = {
    packages = with pkgs; [
      sysz
      ranger
      ripgrep
      xclip
      keynav
      xdotool
      bspwm
      unclutter
      pulsemixer
    ];
  };
  xsession = {
    enable = true;
    windowManager = {
      bspwm = {
        enable = true;
        extraConfig = ''
          #!/bin/bash

          home-manager switch

          sxhkd &
          keynav &
          picom &

          xrandr --output "DP-0" --rotate left --left-of "HDMI-0"

          bspc monitor "DP-0" -d I
          bspc monitor "HDMI-0" -d II III IV V VI VII VIII IX X

          bspc config border_width 0.5
          bspc config window_gap 2
          bspc config split_ratio 0.52
          bspc config bordeless_monocle true
          bspc config gapless_monocle true

          unclutter -idle 1 -root
          xdotool mousemove 999999 999999
        '';
      };
    };
  };
  services = {
    picom = { enable = true; };
    sxhkd = {
      enable = true;
      extraConfig = ''
        super + Return
          nixGL alacritty 
        super + Escape
          pkill -USR1 -x sxhkd
        super + alt + {q,r}
          bspc {quit,wm -r}
        super + {_,shift + }w
          bspc node -{c,k}
        super + m
          bspc desktop -l next
        super + y
          bspc node newest.marked.local -n newest.!automatic.local
        super + g
          bspc node -s biggest
        super + {t,shift + t,s,f}
          bspc node -t {tiled,pseudo_tiled,floating,fullscreen}
        super + ctrl + {m,x,y,z}
          bspc node -g {marked,locked,sticky,private}
        super + {_,shift + }{h,j,k,l}
          bspc node -{f,s} {west,south,north,east}
        super + {p,b,comma,period}
          bspc node -f @{parent,brother,first,second}
        super + {_,shift + }c
          bspc node -f {next,prev}.local
        super + bracket{left,right}
          bspc desktop -f {prev,next}.local
        super + {grave,Tab}
          bspc {node,desktop} -f last
        super + {o,i}
          bspc wm -h off; \
          bspc node {older,newer} -f; \
          bspc wm -h on
        super + {_,shift + }{1-9,0}
          bspc {desktop -f,node -d} '^{1-9,10}'
        super + ctrl + {h,j,k,l}
          bspc node -p {west,south,north,east}
        super + ctrl + {1-9}
          bspc node -o 0.{1-9}
        super + ctrl + space
          bspc node -p cancel
        super + ctrl + shift + space
          bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel
        super + alt + {h,j,k,l}
          bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}
        super + alt + shift + {h,j,k,l}
          bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}
        super + {Left,Down,Up,Right}
          bspc node -v {-20 0,0 20,0 -20,20 0}
      '';
    };
  };
  programs = {
    alacritty = { enable = true; };
    htop = { enable = true; };
    vim = {
      enable = true;
      settings = {
        background = "dark";
        number = true;
        tabstop = 4;
        shiftwidth = 4;
      };
      extraConfig = ''
        set clipboard=unnamedplus
        set t_Co=256
        set autoindent
        set nocp
        filetype plugin indent on
        syntax on 
      '';
    };
    git = {
      enable = true;
      extraConfig = {
        core = { editor = "vim"; };
        color = { ui = true; };
        push = { default = "simple"; };
        pull = { ff = "only"; };
        init = { defaultBranch = "master"; };
      };
    };
    fzf = {
      enable = true;
      defaultCommand = "rg --files | fzf";
      enableZshIntegration = true;
    };
  };
}
