{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.sxhkd;
in {
  options.modules.sxhkd = {
    enable = mkEnableOption "sxhkd";

    terminal = mkOption {
      type = types.str;
      description =
        "Name of terminal emulator to be called with 'super + Return'";
      default = "alacritty";
    };
    rofi = mkOption {
      type = types.bool;
      description = "Enable rofi integration";
      default = false;
    };
    dunst = mkOption {
      type = types.bool;
      description = "Enable dunst integration";
      default = false;
    };
  };
  config = mkIf cfg.enable {
    services.sxhkd = {
      enable = true;
      extraConfig = ''
        super + Return
          ${cfg.terminal}

        ${optionalString (cfg.rofi) ''
          super + @space
            rofi -show drun
          alt + Tab
              rofi -show window
        ''}

        ${optionalString (cfg.dunst) ''
          super + ctrl + @space
            dunstcl close
        ''}

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
}
