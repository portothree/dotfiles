# dotfiles

It uses [home-manager](https://github.com/nix-community/home-manager) to install and create programs configurations based off the `home.nix` file.

![Current desk screenshot](./other/screenshot.png)

[Home Manager Manual](https://nix-community.github.io/home-manager/)


### Debian + Nix as package manager(?)

For my non-nixos machines I'm currently using debian `apt` strictly for the base system, and Nix for all userspace apps.

### Usage

Make sure `nix` and `home-manager` is installed.

```
$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
$ nix-channel --update
$ export NIX_PATH = "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
$ nix-shell '<home-manager>' -A install
```

Create a symbolic link of `./config/nixos/hosts/<host>/home.nix` at `$HOME/.config/nixpkgs/home.nix`.

```
$ ln home.nix $HOME/.config/nixpkgs/home/nix
```

Run `home-manager switch`

### Config layout

`config/` is grouped by category: `ai`, `comms`, `desktop`, `dev`, `editors`,
`media`, `system`, `terminal`. Modules in `modules/programs` and host profiles
in `profiles/` reference files from there.

# AI (coding agents, skills, subagents, harness config)

This repo is the source of truth for coding agent config, deployed by the
`ai.agents` home-manager module (`modules/programs/ai/agents.nix`) through
home-manager's [`programs.claude-code`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.enable):

| Source | Deployed to |
|-|-|
| Skills from pinned flake inputs | `~/.claude/skills/<name>`, `~/.agents/skills` |
| `config/ai/claude/.claude/{CLAUDE.md,agents}` | `~/.claude/...` (store copy) |
| `config/ai/claude/.claude/settings.json` | `~/.claude/settings.json` (live link) |
| `config/ai/opencode/.config/opencode/{opencode.json,agents}` | `~/.config/opencode/...` (live link) |

Live links are out-of-store (`mkOutOfStoreSymlink`) and point at this
checkout, so Claude Code can still write `settings.json` (plugins, `/config`)
and those changes show up as a git diff. Everything else needs a
`home-manager switch` to apply. Claude Code itself is installed with its
native installer (`package = null`).

Enable it per profile:

```nix
modules.ai = {
  agents.enable = true;
  # dotfilesPath = "/path/to/dotfiles"; # default: ~/www/portothree/dotfiles
};
```

On a machine that already has these files, move them out of the way on the
first switch: `home-manager switch -b backup --flake .#<host>`.

### Skills

Skills come from GitHub repos pinned as `flake = false` inputs in
`flake.nix`, and are picked by name in `modules/programs/ai/agents.nix`.

- Add a skill: add its name to the list (or a new input + `fromRepo` call for
  a new repo), then `home-manager switch`.
- Remove a skill: delete its name, then `home-manager switch`.
- Update: `nix flake update basic-memory`, review the diff, then switch.

Installed:

- `memory-*` ([basicmachines-co/basic-memory](https://github.com/basicmachines-co/basic-memory/tree/main/skills)):
  Basic Memory workflows: capture, continue, curate, defrag, ingest,
  lifecycle, metadata-search, notes, onboarding, reflect, research, schema,
  tasks, literary-analysis, ci-capture

# Shell scripts

Handful collection of shell scripts inspired by https://github.com/salman-abedin/alfred


# FAQ

Home manager and flakes with Non-NixOS systems
- https://dee.underscore.world/blog/home-manager-flakes/
- https://gvolpe.com/blog/nix-flakes/
