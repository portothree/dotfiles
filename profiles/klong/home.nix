{ pkgs, ... }:

{
  imports = [
    ../../modules
    ../../home-manager
    ../../config/git.nix
    ../../config/ranger.nix
    ../../config/keynav.nix
    ../../config/conky.nix
    ../../config/rofi.nix
  ];
  home = {
    stateVersion = "22.11";
    username = "porto";
    homeDirectory = "/home/porto";
    packages = with pkgs; [
      bitwarden-cli
      k9s
      kubectl
      glow
      pgcli
      mycli
      ledger
      tasksh
      vit
      pulsemixer
      nudoku
      dijo
      mutt
      mpv
      powertop
      acpi
      brightnessctl
      ledger-live-desktop
      monero-gui
      monero-cli
      nextdns
      llama
      openconnect
      auth0-cli
      ngrok
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
  services = {
    mpris-proxy.enable = true;
    keynav = { enable = true; };
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
    htop = { enable = true; };
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
  };
  modules = {
    anki.enable = true;
    bun.enable = true;
    dunst.enable = true;
    dockerTools.enable = true;
    xinit = {
      enable = true;
      autorandr = true;
      sxhkd = true;
      bspwm = true;
    };
    bspwm = {
      enable = true;
      bar = true;
      extraConfig = ''
        bspc monitor "eDP-1" -d I II III
        bspc monitor "DP-2" -d IV V VI VII VIII IX X
      '';
    };
    sxhkd = {
      enable = true;
      terminal = "alacritty";
      rofi = true;
    };
    alacritty.enable = true;
    tmux = {
      enable = true;
      gcalcli = false;
    };
    timewarrior.enable = true;
    neovim.enable = true;
    nodejs.enable = true;
    rust.enable = true;
    gcalcli = {
      enable = true;
      enableNotifications = true;
    };
    gcloud.enable = true;
    gptcommit.enable = true;
    qutebrowser.enable = true;
    weechat = {
      enable = true;
      additionalScripts = with pkgs.weechatScripts; [ wee-slack ];
    };
    xournalpp.enable = true;
    zsh.enable = true;
  };
}
