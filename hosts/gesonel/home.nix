{ pkgs, ... }:

{
  imports = [
    ../../config/home-manager/common.nix
    ../../config/sxhkd.nix
    ../../config/ranger.nix
    ../../config/rofi.nix
    ../../config/neovim.nix
    ../../config/khal.nix
    ../../config/vdirsyncer.nix
  ];
  home = {
    packages = with pkgs; [
      (st.overrideAttrs (oldAttrs: rec {
        src = builtins.fetchTarball {
          url =
            "https://github.com/portothree/st/archive/refs/tags/v0.8.5-beta.7.tar.gz";
        };
        buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
      }))
      nixgl.auto.nixGLNvidia
      xpra
      sysz
      ranger
      pass
      bitwarden-cli
      ripgrep
      nixfmt
      python3
      xclip
      xdotool
      maim
      sysz
      tig
      glow
      tasksh
      vit
      timewarrior
      s-tui
      dijo
      vdirsyncer
      khal
      nextdns
      gh
      zathura
    ];
    sessionVariables = { EDITOR = "nvim"; };
    file = {
      crontab = {
        target = ".crontab";
        text = ''
          @reboot nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }" > ~/crontab.log 2>&1
        '';
      };
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
    windowManager = {
      bspwm = {
        enable = true;
        extraConfig = ''
          bspc monitor "DP-0" -d I II III
          bspc monitor "HDMI-0" -d IV V VI VII VIII IX X

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
    picom = {
      enable = true;
      package = pkgs.writers.writeBashBin "picom" ''
        ${pkgs.nixgl.auto.nixGLNvidia}/bin/nixGLNvidia-460.91.03 ${pkgs.picom}/bin/picom --xrender-sync-fence "$@"
      '';
      backend = "glx";
      experimentalBackends = true;
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
              primary = true;
              position = "0x0";
              mode = "1920x1080";
              rotate = "normal";
            };
            "HDMI-0" = {
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
    direnv = {
      enable = true;
      nix-direnv = { enable = true; };
    };
    htop = { enable = true; };
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
    fzf = {
      enable = true;
      defaultCommand = "rg --files | fzf";
      enableZshIntegration = true;
    };
    taskwarrior = {
      enable = true;
      dataLocation = "/home/porto/www/memex/trails/tasks/.task";
    };
    qutebrowser = {
      enable = true;
      package = pkgs.writers.writeBashBin "qutebrowser" ''
        ${pkgs.nixgl.auto.nixGLNvidia}/bin/nixGLNvidia-460.91.03 ${pkgs.qutebrowser}/bin/qutebrowser "$@"
      '';
      loadAutoconfig = true;
      extraConfig = ''
        home_page = "/home/porto/www/memex/packages/web/index.html"

        c.url.default_page = home_page
        c.url.start_pages = [ home_page ]
      '';
    };
  };
}
