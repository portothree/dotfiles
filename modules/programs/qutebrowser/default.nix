{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.qutebrowser;
in {
  options.modules.qutebrowser = { enable = mkEnableOption "qutebrowser"; };
  config = mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;
      loadAutoconfig = true;
      extraConfig = ''
        start_page = "https://github.com/search"
        c.url.default_page = start_page 
        c.url.start_pages = [ start_page ]
        c.colors.webpage.darkmode.enabled = True
      '';
    };
  };
}
