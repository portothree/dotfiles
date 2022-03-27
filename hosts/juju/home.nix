{ config, pkgs, ... }:

{
  imports = [ ../../config/home-manager/common.nix ];
  home = {
    stateVersion = "21.11";
    packages = with pkgs; [
      (st.overrideAttrs (oldAttrs: rec {
        src = builtins.fetchTarball {
          url = "https://github.com/portothree/st/archive/refs/tags/v0.8.5-beta.7.tar.gz";
        };
      }))
      sysz
      ranger
      bitwarden-cli
      tig
      k9s
      kubectl
      ripgrep
      xclip
      xdotool
      lemonbar
      rofi
      nixfmt
      glow
      weechat
      pgcli
      mycli
      wuzz
      websocat
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
    ];
    sessionVariables = { EDITOR = "vim"; };
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
          bspc monitor "eDP" -d I II III IV V VI VII VIII IX X
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
    unclutter = {
      enable = true;
      timeout = 1;
      extraOptions = [ "root" ];
    };
    sxhkd = {
      enable = true;
      extraConfig = ''
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
    spotifyd = { enable = true; };
  };
  programs = {
    htop = { enable = true; };
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

        # Colorscheme
        def blood(c, options = {}):
            palette = {
                'background': '#282a36',
                'background-alt': '#282a36', 
                'background-attention': '#181920',
                'border': '#282a36',
                'current-line': '#44475a',
                'selection': '#44475a',
                'foreground': '#f8f8f2',
                'foreground-alt': '#e0e0e0',
                'foreground-attention': '#ffffff',
                'comment': '#6272a4',
                'cyan': '#8be9fd',
                'green': '#50fa7b',
                'orange': '#ffb86c',
                'pink': '#ff79c6',
                'purple': '#bd93f9',
                'red': '#ff5555',
                'yellow': '#f1fa8c'
            }   

            spacing = options.get('spacing', {
                'vertical': 5,
                'horizontal': 5
            })

            padding = options.get('padding', {
                'top': spacing['vertical'],
                'right': spacing['horizontal'],
                'bottom': spacing['vertical'],
                'left': spacing['horizontal']
            })

            ## Background color of the completion widget category headers.
            c.colors.completion.category.bg = palette['background']

            ## Bottom border color of the completion widget category headers.
            c.colors.completion.category.border.bottom = palette['border']

            ## Top border color of the completion widget category headers.
            c.colors.completion.category.border.top = palette['border']

            ## Foreground color of completion widget category headers.
            c.colors.completion.category.fg = palette['foreground']

            ## Background color of the completion widget for even rows.
            c.colors.completion.even.bg = palette['background']

            ## Background color of the completion widget for odd rows.
            c.colors.completion.odd.bg = palette['background-alt']

            ## Text color of the completion widget.
            c.colors.completion.fg = palette['foreground']

            ## Background color of the selected completion item.
            c.colors.completion.item.selected.bg = palette['selection']

            ## Bottom border color of the selected completion item.
            c.colors.completion.item.selected.border.bottom = palette['selection']

            ## Top border color of the completion widget category headers.
            c.colors.completion.item.selected.border.top = palette['selection']

            ## Foreground color of the selected completion item.
            c.colors.completion.item.selected.fg = palette['foreground']

            ## Foreground color of the matched text in the completion.
            c.colors.completion.match.fg = palette['orange']

            ## Color of the scrollbar in completion view
            c.colors.completion.scrollbar.bg = palette['background']

            ## Color of the scrollbar handle in completion view.
            c.colors.completion.scrollbar.fg = palette['foreground']

            ## Background color for the download bar.
            c.colors.downloads.bar.bg = palette['background']

            ## Background color for downloads with errors.
            c.colors.downloads.error.bg = palette['background']

            ## Foreground color for downloads with errors.
            c.colors.downloads.error.fg = palette['red']

            ## Color gradient stop for download backgrounds.
            c.colors.downloads.stop.bg = palette['background']

            ## Color gradient interpolation system for download backgrounds.
            ## Type: ColorSystem
            ## Valid values:
            ##   - rgb: Interpolate in the RGB color system.
            ##   - hsv: Interpolate in the HSV color system.
            ##   - hsl: Interpolate in the HSL color system.
            ##   - none: Don't show a gradient.
            c.colors.downloads.system.bg = 'none'

            ## Background color for hints. Note that you can use a `rgba(...)` value
            ## for transparency.
            c.colors.hints.bg = palette['background']

            ## Font color for hints.
            c.colors.hints.fg = palette['purple']

            ## Hints
            c.hints.border = '1px solid ' + palette['background-alt']

            ## Font color for the matched part of hints.
            c.colors.hints.match.fg = palette['foreground-alt']

            ## Background color of the keyhint widget.
            c.colors.keyhint.bg = palette['background']

            ## Text color for the keyhint widget.
            c.colors.keyhint.fg = palette['purple']

            ## Highlight color for keys to complete the current keychain.
            c.colors.keyhint.suffix.fg = palette['selection']

            ## Background color of an error message.
            c.colors.messages.error.bg = palette['background']

            ## Border color of an error message.
            c.colors.messages.error.border = palette['background-alt']

            ## Foreground color of an error message.
            c.colors.messages.error.fg = palette['red']

            ## Background color of an info message.
            c.colors.messages.info.bg = palette['background']

            ## Border color of an info message.
            c.colors.messages.info.border = palette['background-alt']

            ## Foreground color an info message.
            c.colors.messages.info.fg = palette['comment']

            ## Background color of a warning message.
            c.colors.messages.warning.bg = palette['background']

            ## Border color of a warning message.
            c.colors.messages.warning.border = palette['background-alt']

            ## Foreground color a warning message.
            c.colors.messages.warning.fg = palette['red']

            ## Background color for prompts.
            c.colors.prompts.bg = palette['background']

            # ## Border used around UI elements in prompts.
            c.colors.prompts.border = '1px solid ' + palette['background-alt']

            ## Foreground color for prompts.
            c.colors.prompts.fg = palette['cyan']

            ## Background color for the selected item in filename prompts.
            c.colors.prompts.selected.bg = palette['selection']

            ## Background color of the statusbar in caret mode.
            c.colors.statusbar.caret.bg = palette['background']

            ## Foreground color of the statusbar in caret mode.
            c.colors.statusbar.caret.fg = palette['orange']

            ## Background color of the statusbar in caret mode with a selection.
            c.colors.statusbar.caret.selection.bg = palette['background']

            ## Foreground color of the statusbar in caret mode with a selection.
            c.colors.statusbar.caret.selection.fg = palette['orange']

            ## Background color of the statusbar in command mode.
            c.colors.statusbar.command.bg = palette['background']

            ## Foreground color of the statusbar in command mode.
            c.colors.statusbar.command.fg = palette['pink']

            ## Background color of the statusbar in private browsing + command mode.
            c.colors.statusbar.command.private.bg = palette['background']

            ## Foreground color of the statusbar in private browsing + command mode.
            c.colors.statusbar.command.private.fg = palette['foreground-alt']

            ## Background color of the statusbar in insert mode.
            c.colors.statusbar.insert.bg = palette['background-attention']

            ## Foreground color of the statusbar in insert mode.
            c.colors.statusbar.insert.fg = palette['foreground-attention']

            ## Background color of the statusbar.
            c.colors.statusbar.normal.bg = palette['background']

            ## Foreground color of the statusbar.
            c.colors.statusbar.normal.fg = palette['foreground']

            ## Background color of the statusbar in passthrough mode.
            c.colors.statusbar.passthrough.bg = palette['background']

            ## Foreground color of the statusbar in passthrough mode.
            c.colors.statusbar.passthrough.fg = palette['orange']

            ## Background color of the statusbar in private browsing mode.
            c.colors.statusbar.private.bg = palette['background-alt']

            ## Foreground color of the statusbar in private browsing mode.
            c.colors.statusbar.private.fg = palette['foreground-alt']

            ## Background color of the progress bar.
            c.colors.statusbar.progress.bg = palette['background']

            ## Foreground color of the URL in the statusbar on error.
            c.colors.statusbar.url.error.fg = palette['red']

            ## Default foreground color of the URL in the statusbar.
            c.colors.statusbar.url.fg = palette['foreground']

            ## Foreground color of the URL in the statusbar for hovered links.
            c.colors.statusbar.url.hover.fg = palette['cyan']

            ## Foreground color of the URL in the statusbar on successful load
            c.colors.statusbar.url.success.http.fg = palette['green']

            ## Foreground color of the URL in the statusbar on successful load
            c.colors.statusbar.url.success.https.fg = palette['green']

            ## Foreground color of the URL in the statusbar when there's a warning.
            c.colors.statusbar.url.warn.fg = palette['yellow']

            ## Status bar padding
            c.statusbar.padding = padding

            ## Background color of the tab bar.
            ## Type: QtColor
            c.colors.tabs.bar.bg = palette['selection']

            ## Background color of unselected even tabs.
            ## Type: QtColor
            c.colors.tabs.even.bg = palette['selection']

            ## Foreground color of unselected even tabs.
            ## Type: QtColor
            c.colors.tabs.even.fg = palette['foreground']

            ## Color for the tab indicator on errors.
            ## Type: QtColor
            c.colors.tabs.indicator.error = palette['red']

            ## Color gradient start for the tab indicator.
            ## Type: QtColor
            c.colors.tabs.indicator.start = palette['orange']

            ## Color gradient end for the tab indicator.
            ## Type: QtColor
            c.colors.tabs.indicator.stop = palette['green']

            ## Color gradient interpolation system for the tab indicator.
            ## Type: ColorSystem
            ## Valid values:
            ##   - rgb: Interpolate in the RGB color system.
            ##   - hsv: Interpolate in the HSV color system.
            ##   - hsl: Interpolate in the HSL color system.
            ##   - none: Don't show a gradient.
            c.colors.tabs.indicator.system = 'none'

            ## Background color of unselected odd tabs.
            ## Type: QtColor
            c.colors.tabs.odd.bg = palette['selection']

            ## Foreground color of unselected odd tabs.
            ## Type: QtColor
            c.colors.tabs.odd.fg = palette['foreground']

            # ## Background color of selected even tabs.
            # ## Type: QtColor
            c.colors.tabs.selected.even.bg = palette['background']

            # ## Foreground color of selected even tabs.
            # ## Type: QtColor
            c.colors.tabs.selected.even.fg = palette['foreground']

            # ## Background color of selected odd tabs.
            # ## Type: QtColor
            c.colors.tabs.selected.odd.bg = palette['background']

            # ## Foreground color of selected odd tabs.
            # ## Type: QtColor
            c.colors.tabs.selected.odd.fg = palette['foreground']

            ## Tab padding
            c.tabs.padding = padding
            c.tabs.indicator.width = 1
            c.tabs.favicons.scale = 1

            dracula.draw.blood(c, { "spacing": { "vertical": 6, "horizontal": 8 } })
      '';
    };
  };
}
