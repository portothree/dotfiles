{ inputs, pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.ai.agents;
  claudeDir = ../../../config/ai/claude/.claude;
  opencodeDir = "config/ai/opencode/.config/opencode";
  link = path:
    config.lib.file.mkOutOfStoreSymlink
    "${config.modules.ai.dotfilesPath}/${path}";
  fromRepo = src: names: genAttrs names (n: "${src}/skills/${n}");
  skills = fromRepo inputs.basic-memory [
    "memory-capture"
    "memory-ci-capture"
    "memory-continue"
    "memory-curate"
    "memory-defrag"
    "memory-ingest"
    "memory-lifecycle"
    "memory-literary-analysis"
    "memory-metadata-search"
    "memory-notes"
    "memory-onboarding"
    "memory-reflect"
    "memory-research"
    "memory-schema"
    "memory-tasks"
  ];
in {
  options.modules.ai.agents = {
    enable = mkEnableOption "coding agent config";
  };
  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      package = null;
      context = claudeDir + "/CLAUDE.md";
      agentsDir = claudeDir + "/agents";
      inherit skills;
    };
    home.file = {
      ".agents/skills".source = pkgs.linkFarm "agent-skills" skills;
      ".claude/settings.json".source =
        link "config/ai/claude/.claude/settings.json";
      ".config/opencode/opencode.json".source =
        link "${opencodeDir}/opencode.json";
      ".config/opencode/agents".source = link "${opencodeDir}/agents";
    };
  };
}
