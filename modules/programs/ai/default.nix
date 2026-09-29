{ lib, config, ... }:

with lib;
{
  imports = [ ./agents.nix ];

  options.modules.ai = {
    dotfilesPath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/www/portothree/dotfiles";
      description = "Absolute path of the dotfiles checkout on this machine.";
    };
  };
}
