{
  pkgs,
  self,
  inputs,
}:

pkgs.testers.runNixOSTest {
  name = "home-modules";

  nodes.gesonel = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    users.users.nico = {
      isNormalUser = true;
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;
    environment.systemPackages = [ pkgs.jq ];
    virtualisation.memorySize = 2048;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        shellScriptPkgs = inputs.scripts.packages.${pkgs.stdenv.hostPlatform.system} or { };
      };
      users.nico = {
        imports = [
          ../modules
          ../config/dev/git.nix
        ];
        home.stateVersion = "26.05";
        modules = {
          # Live links resolve against a store copy of this repo in the VM
          ai = {
            dotfilesPath = "${self}";
            agents.enable = true;
          };
          zsh.enable = true;
          neovim.enable = true;
          tmux.enable = true;
        };
      };
    };
  };

  testScript = ''
    gesonel.wait_for_unit("home-manager-nico.service")

    with subtest("agent skills and Claude config"):
        gesonel.succeed("test -f /home/nico/.claude/skills/memory-notes/SKILL.md")
        gesonel.succeed("test -f /home/nico/.agents/skills/memory-notes/SKILL.md")
        gesonel.succeed("test -f /home/nico/.claude/skills/i-have-adhd/SKILL.md")
        gesonel.succeed("test -f /home/nico/.claude/CLAUDE.md")
        gesonel.succeed("grep -qx 'keep-coding-instructions: true' /home/nico/.claude/output-styles/adhd-ste.md")
        gesonel.succeed("grep -q 'Lead with the next action' /home/nico/.claude/output-styles/adhd-ste.md")
        gesonel.succeed("grep -q 'Simplified Technical English' /home/nico/.claude/output-styles/adhd-ste.md")
        gesonel.succeed("grep -q 'Instructions for every coding agent' /home/nico/.agents/AGENTS.md")
        gesonel.succeed("grep -q 'Lead with the next action' /home/nico/.codex/AGENTS.md")
        gesonel.succeed("grep -q 'Simplified Technical English' /home/nico/.codex/AGENTS.md")
        # Relative links in the skill body point at the installed skill
        gesonel.succeed("grep -qF '`~/.agents/skills/asd-ste100/scripts/ste-lint.py`' /home/nico/.codex/AGENTS.md")
        gesonel.succeed("test -f /home/nico/.agents/skills/asd-ste100/scripts/ste-lint.py")
        gesonel.succeed("grep -q 'Lead with the next action' /home/nico/.config/zed/AGENTS.md")
        gesonel.succeed("grep -q 'Lead with the next action' /home/nico/.gemini/AGENTS.md")
        # Antigravity truncates a rule file at 24,000 bytes; the STE body is its own rule
        gesonel.succeed("grep -qx 'trigger: always_on' /home/nico/.gemini/config/rules/asd-ste100.md")
        gesonel.succeed("grep -q 'Simplified Technical English' /home/nico/.gemini/config/rules/asd-ste100.md")
        gesonel.succeed("test $(wc -c < /home/nico/.gemini/AGENTS.md) -lt 24000")
        gesonel.succeed("test $(wc -c < /home/nico/.gemini/config/rules/asd-ste100.md) -lt 24000")
        gesonel.succeed("test -L /home/nico/.gemini/GEMINI.md")
        gesonel.succeed("cmp /home/nico/.agents/AGENTS.md /home/nico/.codex/AGENTS.md")
        gesonel.succeed("grep -qxF '@~/.agents/AGENTS.md' /home/nico/.claude/CLAUDE.md")
        # The generated copy names this machine's checkout, not the default
        gesonel.succeed("grep -qF '${self}' /home/nico/.codex/AGENTS.md")
        gesonel.succeed("test ! -L /home/nico/.agents/skills")
        gesonel.succeed("jq -e .permissions /home/nico/.claude/settings.json")
        gesonel.succeed("jq -e '.autoMemoryEnabled == false' /home/nico/.claude/settings.json")
        gesonel.succeed("grep -qx 'memories = false' /home/nico/.codex/config.toml")
        gesonel.succeed("su - nico -c /home/nico/.claude/hooks/basic-memory-health.sh")

    with subtest("git"):
        gesonel.succeed("su - nico -c 'git config user.name' | grep -qx 'Gustavo Porto'")

    with subtest("shell and editors start"):
        gesonel.succeed("su - nico -c 'zsh -ic exit'")
        gesonel.succeed("su - nico -c 'nvim --headless +qa'")
        gesonel.succeed("su - nico -c 'tmux -V'")
  '';
}
