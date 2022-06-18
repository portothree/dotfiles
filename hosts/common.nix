{ pkgs, ... }:

{
  time = { timeZone = "Europe/Lisbon"; };
  networking = {
    extraHosts = ''
      192.168.1.100 pve.homelab
      192.168.1.106 lara.homelab
      192.168.1.200 pi.hole
      192.168.1.200 uptime.kuma
    '';
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };
  console = {
    font = "FiraCode";
    keyMap = "us";
  };
  fonts = {
    fontDir = { enable = true; };
    enableGhostscriptFonts = true;
    fonts = with pkgs; [ fira-code ];
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d --max-freed $((64 * 1024**3))";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}
