{ pkgs, shellScriptPkgs, ... }:

{
  imports = [
    ../../home-manager
    ../../modules
    ../../config/git.nix
    ../../config/ranger.nix
    ../../config/keynav.nix
    ../../config/rofi.nix
  ];
  home = {
    stateVersion = "22.11";
    username = "porto";
    homeDirectory = "/home/porto";
    packages = with pkgs; [
      st
      k9s
      kubectl
      cava
      astyle
      glow
      pgcli
      mycli
      tasksh
      vit
      pulsemixer
      nudoku
      playerctl
      spotify-tui
      nvtop
      mutt
      mpv
      gh
      ffmpeg
      distrobox
      bitwarden-cli
      v4l-utils
      nextdns
      llama
      awscli2
    ];
    sessionVariables = { EDITOR = "nvim"; };
    file = {
      bugwarrior = {
        target = ".config/bugwarrior/bugwarriorrc";
        text = ''
          [general]
          taskrc = ~/.config/task/taskrc
          targets = github_portothree
          shorten = False
          inline_links = False
          annotation_links = True
          annotation_comments = True
          legacy_matching = False
          log.level = DEBUG
          annotation_length = 45

          [github_portothree]
          service = github
          github.default_priority = H
          github.add_tags = open_source
          github.username = portothree 
          github.exclude_pull_requests = True
          github.include_repos = dotfiles,memex,homelab,plain-text-anything,spaced-repetition
          github.login = portothree 
          github.token = @oracle:eval:pass GitHub/portothree
        '';
      };
      vit = {
        target = ".vit/config.ini";
        text = ''
          [taskwarrior]
          taskrc = ~/.config/task/taskrc

          [vit]
          default_keybindings = vi
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
  xsession = {
    enable = true;
    windowManager = { };
  };
  services = {
    mpris-proxy.enable = true;
    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };
    keynav = { enable = true; };
    unclutter = {
      enable = true;
      timeout = 1;
      extraOptions = [ "root" ];
    };
  };
  programs = {
    autorandr = {
      enable = true;
      profiles = {
        "normal-dual" = {
          fingerprint = {
            "DP-0" =
              "00ffffffffffff0009d1e77845540000191e0104a5351e783a0565a756529c270f5054a56b80d1c0b300a9c08180810081c001010101023a801871382d40582c45000f282100001e000000ff004b364c30313837323031510a20000000fd00324c1e5311010a202020202020000000fc0042656e51204757323438300a20016702031cf14f901f041303120211011406071516052309070783010000023a801871382d40582c45000f282100001f011d8018711c1620582c25000f282100009f011d007251d01e206e2855000f282100001e8c0ad08a20e02d10103e96000f28210000180000000000000000000000000000000000000000000000000000008d";
            "HDMI-0" =
              "00ffffffffffff0009d1e778455400002a1f010380351e782e0565a756529c270f5054a56b80d1c0b300a9c08180810081c001010101023a801871382d40582c45000f282100001e000000ff0050414d30313138363031510a20000000fd00324c1e5311000a202020202020000000fc0042656e51204757323438300a200179020322f14f901f04130312021101140607151605230907078301000065030c001000023a801871382d40582c45000f282100001f011d8018711c1620582c25000f282100009f011d007251d01e206e2855000f282100001e8c0ad08a20e02d10103e96000f282100001800000000000000000000000000000000000000000003";
          };
          config = {
            "DP-0" = {
              enable = true;
              primary = false;
              position = "0x0";
              mode = "1920x1080";
              rotate = "normal";
            };
            "HDMI-0" = {
              enable = true;
              primary = true;
              position = "1920x0";
              mode = "1920x1080";
              rotate = "normal";
            };
          };
        };
      };
    };
    htop = { enable = true; };
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
      dataLocation = "/home/porto/www/portothree/memex/trails/tasks/.task";
    };
    qutebrowser = {
      enable = true;
      loadAutoconfig = true;
      extraConfig = ''
        start_page = "https://github.com/search"
        c.url.default_page = start_page 
        c.url.start_pages = [ start_page ]
      '';
    };
  };
  modules = {
    anki.enable = true;
    androidTools.enable = true;
    bun.enable = true;
    dunst.enable = true;
    xinit = {
      enable = true;
      autorandr = true;
      sxhkd = true;
      bspwm = true;
    };
    tmux.enable = true;
    alacritty.enable = true;
    bspwm = {
      enable = true;
      bar = true;
      extraConfig = ''
        bspc monitor "DP-0" -d I II III
        bspc monitor "HDMI-0" -d IV V VI VII VIII IX X
      '';
    };
    sxhkd = {
      enable = true;
      terminal = "alacritty";
      rofi = true;
      dunst = true;
    };
    spotify = { enable = true; };
    nodejs.enable = true;
    neovim.enable = true;
    gcalcli.enable = true;
    timewarrior.enable = true;
    dockerTools.enable = true;
    jrnl = {
      enable = true;
      journalPath = builtins.toString
        /home/porto/www/portothree/memex/trails/jrnl/journal.txt;
      editor = "nvim";
    };
    wally.enable = true;
    weechat = {
      enable = true;
      scripts = with pkgs.weechatScripts; [
        wee-slack
        url_hint
        weechat-autosort
        weechat-go
      ];
    };
    xournalpp.enable = true;
    zsh.enable = true;
  };
}
