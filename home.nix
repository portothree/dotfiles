{ config, pkgs, ... }:

{
  home = {
    username = "porto";
    stateVersion = "22.05";
    packages = with pkgs; [
      st
      alacritty
      htop
      sysz
      ranger
      tig
      google-cloud-sdk
      k9s
      kubectl
      qutebrowser
      ripgrep
      xclip
      keynav
      xdotool
      bspwm
      sxhkd
      lemonbar
      rofi
      pywal
      mopidy
      mopidy-iris
      cava
      astyle
      shfmt
      nixfmt
      glow
      fira-code
      siji
      unclutter
      dunst
      weechat
      pgcli
      mycli
      wuzz
      websocat
      taskwarrior
      weechat
      pulsemixer
    ];
    homeDirectory = "/home/porto";
    file = {
      crontab = {
        target = ".crontab";
        text = ''
          @reboot nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }" > ~/crontab.log 2>&1
        '';
      };
      bspwm = {
        target = ".config/bspwm/bspwmrc";
        text = ''
          sxhkd &
          keynav &
          autorandr --change

          if [[ $(bspc query -M --names | head -n 1) != "eDP" ]]; then
            bspc monitor "HDMI-0" -d I
            bspc monitor "DP-0" -d II III IV V VI VII VIII IX X
          fi

          bspc config border_width 0.5
          bspc config window_gap 2
          bspc config split_ratio 0.52
          bspc config bordeless_monocle true
          bspc config gapless_monocle true

          unclutter -idle 1 -root
          xdotool mousemove 999999 999999

          picom --config $HOME/.config/picom/picom.conf &
        '';
      };
      sxhkd = {
        target = ".config/sxhkd/sxhkdrc";
        text = ''
          super + Return
            st
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
  nixpkgs = { config = { allowUnfree = true; }; };
  programs = {
    home-manager = { enable = true; };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      sessionVariables = {
        PROMPT = "%(?.%F{green}.%F{red})λ%f %B%F{cyan}%~%f%b ";
        VISUAL = "vim";
        EDITOR = "vim";
        HISTTIMEFORMAT = "%F %T ";
        PATH =
          "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/nix/var/nix/profiles/default/bin:/home/porto/nix-profile/bin";
        NIX_PATH =
          "/home/porto/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
        LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive";
        MEMEX = "/home/porto/www/memex";
        TASKWARRIOR_LOCATION_PATH = "/home/porto/www/memex/trails/tasks/.task";
      };
      shellAliases = {
        r = "ranger";
        krita = "QT_XCB_GL_INTEGRATION=none krita";
        rgf = "rg --files | rg";
        ksns =
          "kubectl api-resources --verbs=list --namespaced -o name | xargs -n1 kubectl get '$@' --show-kind --ignore-not-found";
        krns = ''
          kubectl api-resources --namespaced=true --verbs=delete -o name | tr '
          ' ',' | sed -e 's/,$//''';
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
    vim = {
      enable = true;
      settings = {
        background = "dark";
        number = true;
        tabstop = 4;
        shiftwidth = 4;
      };
      plugins = with pkgs.vimPlugins; [ vimwiki ];
      extraConfig = ''
        set clipboard=unnamedplus
        set t_Co=256
        set autoindent
        set nocp
        filetype plugin indent on
        syntax on 

        au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger
      '';
    };
    git = {
      enable = true;
      userName = "Gustavo Porto";
      userEmail = "gustavoporto@ya.ru";
      extraConfig = {
        core = { editor = "vim"; };
        color = { ui = true; };
        push = { default = "simple"; };
        pull = { ff = "only"; };
        init = { defaultBranch = "master"; };
      };
      delta = {
        enable = true;
        options = {
          enable = true;
          options = {
            navigate = true;
            line-numbers = true;
            syntax-them = "Github";
          };
        };
      };
      ignores = [ "__pycache__" ];
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
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      plugins = with pkgs.tmuxPlugins; [ sensible yank ];
      extraConfig = ''
        set -g mouse off 
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
      '';
    };
    direnv = {
      enable = true;
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
  };
}
