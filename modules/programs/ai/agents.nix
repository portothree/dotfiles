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
  # The i-have-adhd skill doubles as Claude Code's output style: same body,
  # output-style frontmatter, so the weekly skill updates reach it too.
  adhdOutputStyle = pkgs.runCommand "adhd-output-style.md" { } ''
    {
      printf -- '---\nname: ADHD\ndescription: %s\nkeep-coding-instructions: true\n---\n' \
        "Lead with the next action, number steps, restate state, cap lists, no preamble or recaps"
      awk 'seen >= 2 { print; next } /^---$/ { seen++ }' ${skillsDir}/i-have-adhd/SKILL.md
    } > $out
  '';
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
        ".claude/output-styles/adhd.md".source = adhdOutputStyle;
        ".claude/hooks/basic-memory-health.sh".source = claudeDir + "/hooks/basic-memory-health.sh";
        ".config/opencode/opencode.json".source = link "${opencodeDir}/opencode.json";
      };
  };
}
