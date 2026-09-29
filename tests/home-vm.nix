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
        gesonel.succeed("test -f /home/nico/.claude/CLAUDE.md")
        gesonel.succeed("test -d /home/nico/.claude/agents")
        gesonel.succeed("jq -e .permissions /home/nico/.claude/settings.json")
        gesonel.succeed("jq -e . /home/nico/.config/opencode/opencode.json")

    with subtest("git"):
        gesonel.succeed("su - nico -c 'git config user.name' | grep -qx 'Gustavo Porto'")

    with subtest("shell and editors start"):
        gesonel.succeed("su - nico -c 'zsh -ic exit'")
        gesonel.succeed("su - nico -c 'nvim --headless +qa'")
        gesonel.succeed("su - nico -c 'tmux -V'")
  '';
}
