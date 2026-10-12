{
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
    # Each skill is linked on its own so skills installed outside this repo
    # (by Zed, a plugin or by hand) can live next to them in ~/.agents/skills.
    home.file =
      mapAttrs' (name: path: nameValuePair ".agents/skills/${name}" { source = path; }) skills
      //
        genAttrs
          [
            ".agents/AGENTS.md"
            ".config/zed/AGENTS.md"
            ".codex/AGENTS.md"
            ".config/opencode/AGENTS.md"
          ]
          (_: {
            source = link "config/ai/AGENTS.md";
          })
      // {
        ".claude/settings.json".source = link "config/ai/claude/.claude/settings.json";
        ".claude/hooks/basic-memory-health.sh".source = claudeDir + "/hooks/basic-memory-health.sh";
        ".config/opencode/opencode.json".source = link "${opencodeDir}/opencode.json";
      };
  };
}
