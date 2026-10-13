{ lib, config, ... }:

with lib;
let
  cfg = config.modules.zed;
in
{
  options.modules.zed = {
    enable = mkEnableOption "zed config";
  };
  config = mkIf cfg.enable {
    # Templated (MCP tokens come from the secrets file) and written as a real
    # file, since Zed saves UI changes to it. Copy those back to the template.
    home.activation.zedSettings = hm.dag.entryAfter [ "writeBoundary" ] (
      config.lib.secrets.render ../../../config/editors/zed/.config/zed/settings.json ".config/zed/settings.json"
    );
  };
}
