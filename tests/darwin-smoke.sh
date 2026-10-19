#!/usr/bin/env bash
# Checks that an applied darwin config works. Run after a switch.
set -euo pipefail
# A login shell gets these from nix-darwin's /etc/zshrc; CI steps don't
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

check() {
	local out
	if out=$(eval "$2" 2>&1); then
		echo "ok   $1"
	else
		echo "FAIL $1"
		echo "$out"
		failed=1
	fi
}
failed=0

check "darwin-rebuild on PATH" "command -v darwin-rebuild"
check "claude skills" "test -f ~/.claude/skills/memory-notes/SKILL.md"
check "agent skills" "test -f ~/.agents/skills/memory-notes/SKILL.md"
check "claude settings link" "jq -e .permissions ~/.claude/settings.json"
check "claude CLAUDE.md" "test -f ~/.claude/CLAUDE.md"
check "ADHD output style" "grep -qx 'keep-coding-instructions: true' ~/.claude/output-styles/adhd.md"
check "claude auto memory off" "jq -e '.autoMemoryEnabled == false' ~/.claude/settings.json"
check "codex memories off" "grep -qx 'memories = false' ~/.codex/config.toml"
check "shared AGENTS.md" "grep -q 'Lead with the next action' ~/.agents/AGENTS.md"
check "claude includes shared AGENTS.md" "grep -qxF '@~/.agents/AGENTS.md' ~/.claude/CLAUDE.md"
check "codex AGENTS.md has ADHD rules" "grep -q 'Lead with the next action' ~/.codex/AGENTS.md"
check "antigravity AGENTS.md has ADHD rules" "grep -q 'Lead with the next action' ~/.gemini/AGENTS.md"
check "antigravity GEMINI.md managed" "test -L ~/.gemini/GEMINI.md"
check "zed AGENTS.md has ADHD rules" "grep -q 'Lead with the next action' ~/.config/zed/AGENTS.md"
check "memory health hook runs" "\"\$HOME/.claude/hooks/basic-memory-health.sh\""
check "git identity" "git config --file ~/.config/git/config user.name | grep -qx 'Gustavo Porto'"
check "fish starts" "fish -c true"
check "neovim starts" "nvim --headless +qa"
check "dock tile size" "test \"\$(defaults read com.apple.dock tilesize)\" = 69"
check "dark mode" "test \"\$(defaults read NSGlobalDomain AppleInterfaceStyle)\" = Dark"

exit "$failed"
