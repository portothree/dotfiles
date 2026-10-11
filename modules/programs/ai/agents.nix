{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.ai.agents;
  claudeDir = ../../../config/ai/claude/.claude;
  opencodeDir = "config/ai/opencode/.config/opencode";
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.modules.ai.dotfilesPath}/${path}";
  skillsDir = ../../../config/ai/agents/.agents/skills;
  skills = mapAttrs (name: _: skillsDir + "/${name}") (
    filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)
  );
in
{
  options.modules.ai.agents = {
    enable = mkEnableOption "coding agent config";
  };
  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      package = null;
      context = claudeDir + "/CLAUDE.md";
      inherit skills;
    };
    home.file = {
      ".agents/skills".source = pkgs.linkFarm "agent-skills" skills;
      ".claude/settings.json".source = link "config/ai/claude/.claude/settings.json";
      ".config/opencode/opencode.json".source = link "${opencodeDir}/opencode.json";
    };
  };
}
