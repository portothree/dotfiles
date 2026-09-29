{
  pkgs,
  self,
  inputs,
}:

pkgs.testers.runNixOSTest {
  name = "home-modules";

  nodes.machine = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    users.users.alice = {
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
        shellScriptPkgs = inputs.scripts.packages.${pkgs.stdenv.hostPlatform.system};
      };
      users.alice = {
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
    machine.wait_for_unit("home-manager-alice.service")

    with subtest("agent skills and Claude config"):
        machine.succeed("test -f /home/alice/.claude/skills/memory-notes/SKILL.md")
        machine.succeed("test -f /home/alice/.agents/skills/memory-notes/SKILL.md")
        machine.succeed("test -f /home/alice/.claude/CLAUDE.md")
        machine.succeed("test -d /home/alice/.claude/agents")
        machine.succeed("jq -e .permissions /home/alice/.claude/settings.json")
        machine.succeed("jq -e . /home/alice/.config/opencode/opencode.json")

    with subtest("git"):
        machine.succeed("su - alice -c 'git config user.name' | grep -qx 'Gustavo Porto'")

    with subtest("shell and editors start"):
        machine.succeed("su - alice -c 'zsh -ic exit'")
        machine.succeed("su - alice -c 'nvim --headless +qa'")
        machine.succeed("su - alice -c 'tmux -V'")
  '';
}
