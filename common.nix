{ config, pkgs, ... }:

{
  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "22.05";
  };
  nixpkgs = { config = { allowUnfree = true; }; };
  xdg = { enable = true; };
  xsession = {
    enable = true;
    windowManager = {
      bspwm = {
        enable = true;
        extraConfig = ''
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
        '';
      };
    };
  };
  services = { picom = { enable = true; }; };
  programs = { home-manager = { enable = true; }; };
}
