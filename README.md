# dotfiles

It uses [home-manager](https://github.com/nix-community/home-manager) to install and create programs configurations based off the `home.nix` file.

![Current desk screenshot](./other/screenshot.png)

[Home Manager Manual](https://nix-community.github.io/home-manager/)


### Debian + Nix as package manager(?)

For my non-nixos machines I'm currently using debian `apt` strictly for the base system, and Nix for all userspace apps.

### Usage

Macs use [nix-darwin](https://github.com/nix-darwin/nix-darwin) for the
system (Homebrew, macOS defaults, fonts, Touch ID sudo), with home-manager
running as a nix-darwin module, so one command applies both. Linux hosts use
standalone home-manager.

| Host | Kind | Apply with |
|-|-|-|
| boris | macOS, aarch64 | `sudo darwin-rebuild switch --flake .#boris` |
| zaza | macOS, x86_64 | `home-manager switch --flake .#zaza` |
| jorel, klong, juju | Linux | `home-manager switch --flake .#<host>` |

New Mac:

1. Install Nix with the [Determinate installer](https://determinate.systems/nix-installer/)
   (nix-darwin is configured with `nix.enable = false` to leave Nix to it).
2. Install [Homebrew](https://brew.sh).
3. Clone this repo to `~/www/portothree/dotfiles`.
4. Add `hosts/<host>/darwin.nix` and `profiles/<host>/home.nix` (copy boris),
   and a `darwinConfigurations.<host>` entry in `flake.nix`.
5. First run: `sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#<host>`.
   Afterwards, `sudo darwin-rebuild switch --flake .#<host>`.

On the first switch, nix-darwin refuses to overwrite `/etc` files it doesn't
own (for example `/etc/zshrc` or `/etc/bashrc`); rename them to
`*.before-nix-darwin` as it asks. Files home-manager finds in `$HOME` are
moved aside with the same suffix.

Homebrew never uninstalls anything here (`onActivation.cleanup` stays
`"none"`), so packages missing from the list are left alone.

Apps installed by hand before they were added as casks make `brew bundle`
fail on the first switch. Hand them over to Homebrew once:

```
$ brew install --cask --adopt arduino-ide chatgpt claude jamie ledger-wallet \
    microsoft-teams notion notion-calendar obsidian openvpn-connect raycast \
    steam telegram vlc zed zen
```

App Store apps (`masApps`) need you to be signed in to the App Store.

#### Not managed here

No Nix option or Homebrew cask covers these; install them by hand.

- Setapp (the `setapp` cask installs the client): CleanMyMac, CleanShot X,
  JoyCast, Lungo, Proxyman, TablePlus, TripMode, Tripsy
- Direct downloads: Delta (Zed), Intelbras SIMPlay, IBKR Desktop
- `npm -g`: `@google/gemini-cli` (nixpkgs lags far behind), and
  `ledger-reports`/`ynab-to-ledger` linked from the memex repo
- `cargo install`: `abtop`, `portogrrs`; `go install`: `aperture`
- `~/.local/bin`: `claude` and `basic-memory` from their own installers,
  `camo-studio`

### Homelab

`homelab/` is the former [portothree/homelab](https://github.com/portothree/homelab)
repo, imported with its history (minus an old uptime-kuma provisioning file
and work VPN scripts). It's kept as-is for reference and isn't wired into
this flake yet: NixOS hosts, the k3s/Flux cluster and the microvm setup.

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
