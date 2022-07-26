{ inputs, pkgs, ... }:

{
  imports = [
    ../../modules
    ../../home-manager
    ../../home-manager/nodejs.nix
    ../../config/xinit.nix
    ../../config/git.nix
    ../../config/neovim.nix
    ../../config/ranger.nix
    ../../config/keynav.nix
    ../../config/gcalcli.nix
    ../../config/conky.nix
  ];
  home = {
    stateVersion = "22.05";
    packages = with pkgs; [
      sysz
      ranger
      pass
      bitwarden-cli
      tig
      k9s
      kubectl
      ripgrep
      xclip
      xsel
      xdotool
      lemonbar
      rofi
      nixfmt
      python3
      python2
      postgresql
      gnumake
      gcc
      glow
      weechat
      pgcli
      mycli
      wuzz
      websocat
      ledger
      tasksh
      vit
      timewarrior
      weechat
      pulsemixer
      nudoku
      s-tui
      dijo
      mutt
      powertop
      acpi
      brightnessctl
      ledger-live-desktop
      lazydocker
      platformio
      nextdns
      yank
      jq
      yq
      cachix
    ];
    sessionVariables = { EDITOR = "nvim"; };
    file = {
      crontab = {
        target = ".crontab";
        text = "";
      };
      dijo = {
        target = ".config/dijo/config.toml";
        text = ''
          [look]
          true_chr = "."
          false_chr = "."
          future_chr = "."

          [colors]
          reached = "cyan"
          todo = "magenta"
          inactive = "light black"
        '';
      };
    };
  };
  xsession = {
    enable = true;
    windowManager = {
      bspwm = {
        enable = true;
        extraConfig = ''
          bspc monitor "eDP-1" -d I II III
          bspc monitor "DP-2" -d IV V VI VII VIII IX X
          bspc config border_width 0.5
          bspc config window_gap 2
          bspc config split_ratio 0.52
          bspc config bordeless_monocle true
          bspc config gapless_monocle true

          xdotool mousemove 999999 999999
        '';
      };
    };
  };
  services = {
    keynav = { enable = true; };
    sxhkd = {
      enable = true;
      extraConfig = ''
        super + Return
          alacritty
        super + @space
          rofi -show drun
        alt + Tab
          rofi -show window
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
    unclutter = {
      enable = true;
      timeout = 1;
      extraOptions = [ "root" ];
    };
    spotifyd = { enable = true; };
  };
  programs = {
    autorandr = {
      enable = true;
      profiles = {
        "normal-dual" = {
          fingerprint = {
            "eDP-1" =
              "00ffffffffffff000dae0113000000002c1d0104a51c1178eaee95a3544c99260f5054000000010101010101010101010101010101015046702c804611501010810018af100000185023702c804611501010810018af10000018000000fe00434d4e0a202020202020200113000000fe00503130315a465a2d424832202000e1";
            "DP-2" =
              "00ffffffffffff0004727f05d34a5010051f010380351e78ee0565a756529c270f5054b30c00714f818081c081009500b300d1c001012a4480a070382740302035000f282100001a023a801871382d40582c45000f282100001e000000fd00304c1f5412000a202020202020000000fc005341323430590a202020202020011302031fb14b900102030405111213141f65030c001000681a00000101304be6023a801871382d40582c45000f282100001e011d007251d01e206e2855000f282100001e8c0ad08a20e02d10103e96000f28210000182a4480a070382740302035000f282100001a000000000000000000000000000000000000000000000000e1";

          };
          config = {
            "eDP-1" = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "1920x1200";
              rotate = "normal";
            };
            "DP-2" = {
              enable = true;
              primary = false;
              position = "1920x0";
              mode = "1920x1080";
              rotate = "normal";
            };
          };
        };
      };
    };
    alacritty = {
      enable = true;
      settings = {
        env = { "WINIT_X11_SCALE_FACTOR" = "1.2"; };
        colors = {
          primary = {
            background = "0x000000";
            foreground = "0xabb2bf";
            bright_foreground = "0xe6efff";
          };
          cursor = {
            text = "0xd8d8d8";
            cursor = "0xd8d8d8";
          };
          normal = {
            black = "0x1e2127";
            red = "0xe06c75";
            green = "0x98c379";
            yellow = "0xd19a66";
            blue = "0x61afef";
            magenta = "0xc678dd";
            cyan = "0x56b6c2";
            white = "0x828791";
          };
          bright = {
            black = "0x5c6370";
            red = "0xe06c75";
            green = "0x98c379";
            yellow = "0xd19a66";
            blue = "0x61afef";
            magenta = "0xc678dd";
            cyan = "0x56b6c2";
            white = "0xe6efff";
          };
          dim = {
            black = "0x1e2127";
            red = "0xe06c75";
            green = "0x98c379";
            yellow = "0xd19a66";
            blue = "0x61afef";
            magenta = "0xc678dd";
            cyan = "0x56b6c2";
            white = "0x828791";
          };
        };
      };
    };
    htop = { enable = true; };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      sessionVariables = {
        PROMPT = "%(?.%F{green}.%F{red})λ%f %B%F{cyan}%~%f%b ";
        VISUAL = "nvim";
        EDITOR = "nvim";
        HISTTIMEFORMAT = "%F %T ";
        PATH =
          "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/nix/var/nix/profiles/default/bin:/home/porto/nix-profile/bin";
        NIX_PATH =
          "/home/porto/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
        LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
      };
      localVariables = { MEMEX = "/home/porto/www/memex"; };
      shellAliases = {
        r = "ranger";
        qutebrowser = "QT_XCB_GL_INTEGRATION=none qutebrowser";
        rgf = "rg --files | rg";
        ksns =
          "kubectl api-resources --verbs=list --namespaced -o name | xargs -n1 kubectl get '$@' --show-kind --ignore-not-found";
        krns =
          "kubectl api-resources --namespaced=true --verbs=delete -o name | tr '' ',' | sed -e 's/,$//''";
        kdns = "kubectl delete '$(krns)' --all";
      };
      initExtraFirst = ''
        [[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

        # Load crontab from .crontab file
        if test -z $CRONTABCMD; then
          export CRONTABCMD=$(which crontab)

          crontab() {
              if [[ $@ == "-e" ]]; then
                  vim "$HOME/.crontab" && $CRONTABCMD "$HOME/.crontab"
              else
                  $CRONTABCMD $@
              fi
           }
         
          $CRONTABCMD "$HOME/.crontab"
        fi
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "git-auto-fetch" ];
        theme = "robbyrussell";
      };
    };
    gh = {
      enable = true;
      settings = {
        git_protocol = "https";
        editor = "vim";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        browser = "qutebrowser";
      };
    };
    direnv = {
      enable = true;
      nix-direnv = { enable = true; };
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      defaultCommand = "rg --files | fzf";
      enableZshIntegration = true;
    };
    bat = {
      enable = true;
      config = {
        theme = "Github";
        italic-text = "always";
      };
    };
    zathura = {
      enable = true;
      options = {
        window-height = 1000;
        window-width = 1000;
      };
      extraConfig = ''
        map <C-i> recolor
      '';
    };
    taskwarrior = {
      enable = true;
      dataLocation = "/home/porto/www/memex/trails/tasks/.task";
    };
    qutebrowser = {
      enable = true;
      loadAutoconfig = true;
      extraConfig = ''
        home_page = "/home/porto/www/memex/packages/web/index.html"

        c.url.default_page = home_page
        c.url.start_pages = [ home_page ]
      '';
    };
  };
  modules = {
    tmux = {
      enable = true;
      gcalcli = true;
    };
    nodejs.enable = true;
  };
}
