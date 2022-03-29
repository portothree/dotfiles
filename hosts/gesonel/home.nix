{ config, pkgs, ... }:

let
  unstable =
    import (builtins.fetchTarball "https://nixos.org/channels/nixos-unstable")
    { };
  nixgl = import (builtins.fetchTarball
    "https://github.com/guibou/nixGL/archive/main.tar.gz") { };
  nixglPkgs = with nixgl; [ auto.nixGLNvidia ];
in {
  imports = [
    ../../config/home-manager/common.nix
    ../../config/home-manager/sxhkd.nix
  ];
  home = {
    stateVersion = "22.05";
    username = "porto";
    homeDirectory = "/home/porto";
    packages = with pkgs;
      [
        (st.overrideAttrs (oldAttrs: rec {
          src = builtins.fetchTarball {
            url =
              "https://github.com/portothree/st/archive/refs/tags/v0.8.5-beta.7.tar.gz";
          };
          buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
        }))
        xpra
        sysz
        ranger
        bitwarden-cli
        ripgrep
        nixfmt
        xclip
        xdotool
        sysz
        tig
        rofi
        glow
        tasksh
        vit
        timewarrior
        s-tui
        dijo
      ] ++ nixglPkgs;
    sessionVariables = { EDITOR = "vim"; };
    file = {
      crontab = {
        target = ".crontab";
        text = ''
          @reboot nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }" > ~/crontab.log 2>&1
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
    picom = { enable = true; };
    keynav = { enable = true; };
    unclutter = {
      enable = true;
      timeout = 1;
      extraOptions = [ "root" ];
    };
  };
  programs = {
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
}
