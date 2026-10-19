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
  codexDir = ../../../config/ai/codex/.codex;
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.modules.ai.dotfilesPath}/${path}";
  skillsDir = ../../../config/ai/agents/.agents/skills;
  # The i-have-adhd skill body (frontmatter stripped) is always on in every
  # agent, so the weekly skill updates reach them too.
  adhdRules = pkgs.runCommand "adhd-rules.md" { } ''
    awk 'seen >= 2 { print; next } /^---$/ { seen++ }' ${skillsDir}/i-have-adhd/SKILL.md > $out
  '';
  # Claude Code: as an output style.
  adhdOutputStyle = pkgs.runCommand "adhd-output-style.md" { } ''
    {
      printf -- '---\nname: ADHD\ndescription: %s\nkeep-coding-instructions: true\n---\n' \
        "Lead with the next action, number steps, restate state, cap lists, no preamble or recaps"
      cat ${adhdRules}
    } > $out
  '';
  # Files read outside this repo name the default checkout; make it this machine's.
  realCheckout = "sed 's|~/www/portothree/dotfiles|${config.modules.ai.dotfilesPath}|g'";
  # Every ~/*/AGENTS.md: the shared file with the rules appended, for tools
  # without output styles (Codex, Zed, Antigravity).
  agentsWithAdhd = pkgs.runCommand "AGENTS.md" { } ''
    {
      ${realCheckout} ${../../../config/ai/AGENTS.md}
      echo
      cat ${adhdRules}
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
      # Includes the plain AGENTS.md from the checkout, since the output style
      # already has the rules.
      context = replaceStrings [ "~/www/portothree/dotfiles" ] [ config.modules.ai.dotfilesPath ] (
        readFile (claudeDir + "/CLAUDE.md")
      );
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
            ".gemini/AGENTS.md"
          ]
          (_: {
            source = agentsWithAdhd;
          })
      // {
        # Store copy, so tools can't save memories into it
        ".gemini/GEMINI.md".source = ../../../config/ai/gemini/.gemini/GEMINI.md;
        ".claude/settings.json".source = link "config/ai/claude/.claude/settings.json";
        ".claude/output-styles/adhd.md".source = adhdOutputStyle;
        ".claude/hooks/basic-memory-health.sh".source = claudeDir + "/hooks/basic-memory-health.sh";
        ".local/bin/claude-aperture".source = ../../../config/ai/claude/.local/bin/claude-aperture;
      };
    # Written as a real file, not a link, since the ChatGPT app adds its own
    # entries to it.
    home.activation.codexConfig = hm.dag.entryAfter [ "writeBoundary" ] (
      config.lib.secrets.render (codexDir + "/config.toml") ".codex/config.toml"
    );
  };
}
