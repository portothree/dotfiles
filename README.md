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

# AI (coding agents, skills, subagents, harness config)

This repo is the source of truth for coding agent config. The `ai.agents`
home-manager module (`modules/programs/ai/agents.nix`) symlinks it into `$HOME`:

| Repo path | Linked to |
|-|-|
| `.agents/skills/` | `~/.agents/skills`, `~/.claude/skills` |
| `config/claude/.claude/{CLAUDE.md,settings.json,agents}` | `~/.claude/...` |
| `config/opencode/.config/opencode/{opencode.json,agents}` | `~/.config/opencode/...` |

Links are out-of-store (`mkOutOfStoreSymlink`) so they point at this checkout:
edits apply immediately, and changes Claude Code makes to `settings.json`
show up as a git diff.

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

Installed with [skills](https://github.com/vercel-labs/skills) at **project
scope from the repo root** (not `-g`), tracked in `skills-lock.json`:

```
$ npx skills add basicmachines-co/basic-memory/skills   # add
$ npx skills update -p                                  # update
$ npx skills remove <name>                              # remove
$ npx skills experimental_install                       # restore from lock file
```

The CLI also creates per-agent symlink dirs (e.g. `skills/`); only
`.agents/skills/` is linked into `$HOME`.

Installed:

- `memory-*` (`basicmachines-co/basic-memory`): Basic Memory workflows:
  capture, continue, curate, defrag, ingest, lifecycle, metadata-search,
  notes, onboarding, reflect, research, schema, tasks, literary-analysis,
  ci-capture

# Shell scripts

Handful collection of shell scripts inspired by https://github.com/salman-abedin/alfred


# FAQ

Home manager and flakes with Non-NixOS systems
- https://dee.underscore.world/blog/home-manager-flakes/
- https://gvolpe.com/blog/nix-flakes/
