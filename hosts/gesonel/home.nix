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
          xrandr --output "DP-0" --rotate left --left-of "HDMI-0"

          bspc monitor "DP-0" -d I
          bspc monitor "HDMI-0" -d II III IV V VI VII VIII IX X

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
