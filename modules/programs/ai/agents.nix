{ lib, config, ... }:

with lib;
let
  cfg = config.modules.ai.agents;
  link = path:
    config.lib.file.mkOutOfStoreSymlink
    "${config.modules.ai.dotfilesPath}/${path}";
in {
  options.modules.ai.agents = {
    enable = mkEnableOption "coding agent config";
  };
  config = mkIf cfg.enable {
    home.file = {
      ".agents/skills".source = link ".agents/skills";
      ".claude/skills".source = link ".agents/skills";
      ".claude/CLAUDE.md".source = link "config/claude/.claude/CLAUDE.md";
      ".claude/settings.json".source =
        link "config/claude/.claude/settings.json";
      ".claude/agents".source = link "config/claude/.claude/agents";
      ".config/opencode/opencode.json".source =
        link "config/opencode/.config/opencode/opencode.json";
      ".config/opencode/agents".source =
        link "config/opencode/.config/opencode/agents";
    };
  };
}
