# dotfiles

One Nix flake for all my machines: macOS system config with
[nix-darwin](https://github.com/nix-darwin/nix-darwin), user config with
[home-manager](https://github.com/nix-community/home-manager), NixOS hosts,
and the homelab cluster manifests.

![Current desk screenshot](./other/screenshot.png)

## Usage

```
$ ./setup [--update] [host]
```

`host` defaults to the machine's short hostname. `--update` bumps every flake
input first. The script picks the right tool for the host:

| Host | Kind | Applied with |
|-|-|-|
| boris | macOS, aarch64 | nix-darwin, with home-manager as a module |
| zaza | macOS, x86_64 | standalone home-manager |
| jorel, klong | Linux | standalone home-manager |

On a Mac, one run applies the system (Homebrew, macOS defaults, fonts, Touch
ID sudo) and the home-manager config together.

### New Mac

1. Install Nix with the [Determinate installer](https://determinate.systems/nix-installer/)
   (nix-darwin is configured with `nix.enable = false` to leave Nix to it).
2. Install [Homebrew](https://brew.sh).
3. Clone this repo to `~/www/portothree/dotfiles`.
4. Add `hosts/<host>/darwin.nix` and `profiles/<host>/home.nix` (copy boris),
   and a `darwinConfigurations.<host>` entry in `flake.nix`.
5. Run `./setup <host>`. It bootstraps nix-darwin on the first run and sets
   the machine's hostname, so later runs need no argument.

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

### Not managed here

No Nix option or Homebrew cask covers these; install them by hand.

- Setapp (the `setapp` cask installs the client): CleanMyMac, CleanShot X,
  JoyCast, Lungo, Proxyman, TablePlus, TripMode, Tripsy
- Direct downloads: Delta (Zed), Intelbras SIMPlay, IBKR Desktop
- `npm -g`: `@google/gemini-cli` (nixpkgs lags far behind), and
  `ledger-reports`/`ynab-to-ledger` linked from the memex repo
- `cargo install`: `abtop`, `portogrrs`; `go install`: `aperture`
- `~/.local/bin`: `claude` and `basic-memory` from their own installers,
  `camo-studio`

## Host names

Machines are named after characters from the Brazilian animated series
[Irmão do Jorel](https://irmaodojorel.fandom.com/pt-br/wiki/Irm%C3%A3o_do_Jorel_Wiki).
New machines, VMs and test fixtures follow the same scheme, using a
character not taken yet from the [character list](https://irmaodojorel.fandom.com/pt-br/wiki/Categoria:Personagens).

| Host | Character | Machine |
|-|-|-|
| boris | [Bóris](https://irmaodojorel.fandom.com/pt-br/wiki/B%C3%B3ris) | MacBook Pro M3 (2023) |
| zaza | [Zazá](https://irmaodojorel.fandom.com/pt-br/wiki/Zaz%C3%A1) | MacBook Pro i5 (2020), work |
| jorel | [Jorel](https://irmaodojorel.fandom.com/pt-br/wiki/Jorel) | Main workstation, NixOS (`jorel-wsl`: WSL on it) |
| klong | [Klong](https://irmaodojorel.fandom.com/pt-br/wiki/Klong) | ThinkPad X1 Nano, NixOS |
| juju | [Vovó Juju](https://irmaodojorel.fandom.com/pt-br/wiki/Vov%C3%B3_Juju) | Huawei Matebook D14, NixOS |
| lara | [Lara](https://irmaodojorel.fandom.com/pt-br/wiki/Lara) | NixOS VM on Proxmox (k3s) |
| yuki | [Yuki](https://irmaodojorel.fandom.com/pt-br/wiki/Yuki) | Nothing Phone (1) |
| syd | [Syd Vinicius](https://irmaodojorel.fandom.com/pt-br/wiki/Syd_Vinicius) | Mac (home-manager only) |
| oraculo | [Oráculo](https://irmaodojorel.fandom.com/pt-br/wiki/Or%C3%A1culo) | microvm in `infrastructure/staging` |
| gesonel | [Gesonel](https://irmaodojorel.fandom.com/pt-br/wiki/Gesonel) | NixOS VM in the `home-vm` test (user `nico`, after [Nico](https://irmaodojorel.fandom.com/pt-br/wiki/Nico)) |

## Tests and CI

`nix flake check` runs everything for the current system:

| Check | What it does |
|-|-|
| `pre-commit-check` | nixfmt, statix, deadnix and shellcheck (also installed as a git hook by `nix develop`) |
| `darwin-boris` (aarch64-darwin) | Builds the full boris system |
| `home-jorel`, `home-klong` (x86_64-linux) | Build the Linux home configs |
| `home-vm` (x86_64-linux) | Boots a NixOS VM, applies the home-manager modules (agents, zsh, neovim, tmux, git) for the test user `nico` and checks the result |

macOS has no VM test, so CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml))
switches a throwaway macOS runner to `darwinConfigurations.ci` (boris for
the runner user, without Homebrew and App Store installs) and runs
`tests/darwin-smoke.sh`. `tests/brew-check.sh` checks that every tap,
formula and cask still exists; run it before a switch after upstream
renames. Renovate's `flake.lock` update PRs go through the same CI.

## Layout

| Path | What |
|-|-|
| `flake.nix` | Every machine's entry point |
| `hosts/<host>/` | System config: `darwin.nix` (nix-darwin) or `configuration.nix` + `hardware-configuration.nix` (NixOS) |
| `hosts/*.nix` | Shared NixOS modules (`common.nix`, `zsa.nix`, `platformio.nix`) |
| `profiles/<host>/home.nix` | home-manager config per host |
| `modules/programs/` | home-manager modules (`modules.<name>.enable`) |
| `modules/nixos/` | NixOS modules |
| `config/` | Dotfile sources, grouped by category: `ai`, `comms`, `desktop`, `dev`, `editors`, `media`, `system`, `terminal` |
| `cluster/` | k3s cluster manifests, applied by Flux from git |
| `infrastructure/` | microvm definitions |
| `docs/homelab.md` | Homelab notes and network diagram |

The NixOS hosts (jorel, klong, juju, lara), juju's incomplete home profile, `hosts/zaza/darwin.nix`, the
cluster and the microvms came from the former
[portothree/homelab](https://github.com/portothree/homelab) repo, with its
history. They date from nixpkgs 24.05 and aren't wired into the flake yet;
they'll need updating when those machines come back.

# AI (coding agents, skills, subagents, harness config)

This repo is the source of truth for coding agent config, deployed by the
`ai.agents` home-manager module (`modules/programs/ai/agents.nix`) through
home-manager's [`programs.claude-code`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.enable):

| Source | Deployed to |
|-|-|
| `config/ai/agents/.agents/skills/<name>/` (vendored) | `~/.claude/skills/<name>`, `~/.agents/skills/<name>` (one link per skill, so other skills can sit next to them) |
| `config/ai/AGENTS.md` (shared instructions) | `~/.agents/AGENTS.md`, Zed `~/.config/zed/AGENTS.md`, Codex `~/.codex/AGENTS.md`, OpenCode `~/.config/opencode/AGENTS.md` (live links) |
| `config/ai/claude/.claude/CLAUDE.md` (imports the shared file, plus Claude-only rules) | `~/.claude/CLAUDE.md` (store copy) |
| `config/ai/claude/.claude/settings.json` | `~/.claude/settings.json` (live link) |
| `config/ai/opencode/.config/opencode/opencode.json` | `~/.config/opencode/opencode.json` (live link) |
| `config/ai/aperture/config.json` | Not deployed; pasted into the Aperture admin UI (see [Aperture](#aperture)) |

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

### Basic Memory

Notes live in [Basic Memory](https://basicmemory.com) (MCP server
`basic-memory`). A `SessionStart` hook in `settings.json` tells Claude to run
the `memory-continue` skill before its first reply, so each session starts
with the relevant notes loaded. Writing follows the `memory-capture` and
`memory-notes` skills: search first, then update an existing note instead of
adding a new one. Read and write tools are pre-approved in `settings.json`.

A second `SessionStart` hook, `config/ai/claude/.claude/hooks/basic-memory-health.sh`,
checks the default Basic Memory project (from `~/.basic-memory/config.json`).
When it finds 5 or more transcript-style notes, a ticket split across 8 or
more notes, or 35 or more top-level folders, it prints a one-line hint and
Claude suggests running `memory-curate`. It stays silent otherwise.

### Aperture

[Tailscale Aperture](https://tailscale.com/docs/aperture) is an LLM gateway
on the tailnet (`tailea386.ts.net`). It logs every model request under the
caller's Tailscale identity, which gives one view of usage across tools. It
runs in [passthrough mode](https://tailscale.com/docs/aperture/how-to/use-passthrough-mode/claude-subscriptions):
Claude Code signs in to the Claude Max subscription and Aperture forwards that
OAuth token to Anthropic unchanged. No API key is stored in Aperture or here.

Aperture is hosted by Tailscale, so its config lives in its admin UI, not on
disk. `config/ai/aperture/config.json` is the copy kept in git; paste it into
**Admin > Configuration** after changing it.

Setup:

1. Sign up at [aperture.tailscale.com](https://aperture.tailscale.com) and
   note the gateway hostname, for example `<aperture-host>.tailea386.ts.net`.
2. Paste `config/ai/aperture/config.json` into **Admin > Configuration**
   (it hot-reloads) and grant yourself access to the Anthropic models.
3. In Claude Code, run `/login` with the Max account.
4. Add the gateway to `config/ai/claude/.claude/settings.json`:

   ```json
   "env": { "ANTHROPIC_BASE_URL": "http://<aperture-host>.tailea386.ts.net" }
   ```

5. Run `claude -p hi`; the request shows up at
   `http://<aperture-host>.tailea386.ts.net/sessions`.

Only inference (`/v1/messages`) goes through Aperture; sign-in and token
refresh go straight to `api.anthropic.com`. Don't set `ANTHROPIC_API_KEY` or
`ANTHROPIC_AUTH_TOKEN`: either replaces the OAuth token and Aperture returns
`401`. Aperture's own chat UI can't use a passthrough-only provider; it needs
an `apikey` added to the provider, which this setup skips. Costs and budgets
don't apply to a flat-rate subscription.

When the tailnet is unreachable, Claude Code can't reach the model. Remove
the `env` entry to go direct again.

### Skills

Skills are managed with the [skills](https://github.com/vercel-labs/skills)
CLI at project scope in `config/ai/agents/`. It keeps real copies in
`config/ai/agents/.agents/skills/<name>/` and records each skill's source and
content hash in `config/ai/agents/skills-lock.json`. Every folder there is
deployed; the per-agent symlink folders the CLI also creates are gitignored.

```
$ cd config/ai/agents
$ export DISABLE_TELEMETRY=1
$ npx skills add <owner/repo/folder> --skill '*' -a codex   # add every skill in a folder; read them before switching
$ npx skills remove <name>                              # remove
$ npx skills update -p                                  # pull upstream changes to installed skills
```

`-a codex` installs only the shared `.agents/skills` copy (Codex reads that
folder directly), without extra per-agent folders. Then run `./setup`.

The CLI works on the folder it runs from: it reads `./skills-lock.json`,
compares each skill's recorded hash with upstream, and rewrites
`./.agents/skills/<name>/` when they differ. That's why the skills live under
an `.agents/` folder and the commands must run in `config/ai/agents`.

**The skill files are read-only.** `update` overwrites hand edits, so a
pre-commit hook (installed by `nix develop`) rejects commits that change
skill files without changing `skills-lock.json`, which only the CLI does. To
change a skill's behaviour, write your own skill instead. Hand-written skills
need their own folder added to `modules/programs/ai/agents.nix`, since this
one is reserved for the CLI.

Each source is tracked as a whole: every skill it publishes is installed.
The [Update agent skills](.github/workflows/update-skills.yml) workflow
re-runs `npx skills add <source> --skill '*'` for every source in the lock
file every Monday, so new skills get added and existing ones updated, and
opens a PR when anything changed. Skills run with full agent permissions, so read those diffs before
merging. CI doesn't start on PRs opened by a workflow; close and reopen the
PR to run it.

Installed:

- `memory-*` ([basicmachines-co/basic-memory](https://github.com/basicmachines-co/basic-memory/tree/main/skills)):
  every skill in `skills/`, the published pack: capture, ci-capture, comark,
  continue, curate, defrag, ingest, lifecycle, literary-analysis,
  metadata-search, notes, onboarding, reflect, research, schema, tasks. The
  repo's other skills (`bm-*` from its Claude Code plugin, and its own dev
  skills like `code-review`) aren't part of it.
- `i-have-adhd` ([ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd)):
  ADHD-friendly output (next action first, numbered steps, restated state).
  Only runs when invoked with `/i-have-adhd`; "stop adhd mode" turns it off.

# Shell scripts

Handful collection of shell scripts inspired by https://github.com/salman-abedin/alfred


# FAQ

Home manager and flakes with Non-NixOS systems
- https://dee.underscore.world/blog/home-manager-flakes/
- https://gvolpe.com/blog/nix-flakes/
