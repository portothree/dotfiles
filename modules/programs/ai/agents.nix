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
  # A skill body with its frontmatter stripped. Its relative links to the
  # skill's own files are made absolute, since the body is read from AGENTS.md.
  rules =
    name:
    pkgs.runCommand "${name}-rules.md" { } ''
      awk 'seen >= 2 { print; next } /^---$/ { seen++ }' ${skillsDir}/${name}/SKILL.md \
        | sed 's#`\(references\|examples\|scripts\)/#`~/.agents/skills/${name}/\1/#g' > $out
    '';
  cat =
    name: files:
    pkgs.runCommand name { } ''
      for f in ${concatMapStringsSep " " (f: "${f}") files}; do cat "$f"; echo; done > $out
    '';
  # The shared file names the default checkout; make it this machine's.
  sharedAgents = pkgs.runCommand "shared-agents.md" { } ''
    sed 's|~/www/portothree/dotfiles|${config.modules.ai.dotfilesPath}|g' ${../../../config/ai/AGENTS.md} > $out
  '';
  # The i-have-adhd and asd-ste100 skill bodies are always on in every agent,
  # behind style.md, which says how the two combine. Built from the skills so
  # the weekly skill updates reach the agents too.
  adhdRules = rules "i-have-adhd";
  steRules = rules "asd-ste100";
  styleRules = cat "style-rules.md" [
    ../../../config/ai/style.md
    adhdRules
    steRules
  ];
  # Claude Code: as an output style.
  outputStyle = pkgs.runCommand "adhd-ste.md" { } ''
    {
      printf -- '---\nname: ADHD-STE\ndescription: %s\nkeep-coding-instructions: true\n---\n' \
        "ADHD shape (next action first, numbered steps, no preamble) with ASD-STE100 sentences"
      cat ${styleRules}
    } > $out
  '';
  # Every ~/*/AGENTS.md: the shared file with the rules appended. Claude Code
  # includes it too, on top of the output style, so it gets the rules twice:
  # in the system prompt and in CLAUDE.md.
  agentsWithStyle = cat "AGENTS.md" [
    sharedAgents
    styleRules
  ];
  # Antigravity truncates each rule file at 24,000 bytes, so the STE body is a
  # separate always-on rule in ~/.gemini/config/rules.
  geminiAgents = cat "AGENTS.md" [
    sharedAgents
    ../../../config/ai/style.md
    adhdRules
  ];
  geminiSteRule = pkgs.runCommand "asd-ste100.md" { } ''
    {
      printf -- '---\ntrigger: always_on\n---\n'
      cat ${steRules}
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
          ]
          (_: {
            source = agentsWithStyle;
          })
      // {
        ".gemini/AGENTS.md".source = geminiAgents;
        ".gemini/config/rules/asd-ste100.md".source = geminiSteRule;
        # Store copy, so tools can't save memories into it
        ".gemini/GEMINI.md".source = ../../../config/ai/gemini/.gemini/GEMINI.md;
        ".claude/settings.json".source = link "config/ai/claude/.claude/settings.json";
        ".claude/output-styles/adhd-ste.md".source = outputStyle;
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
