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
check "shared AGENTS.md" "grep -q 'Instructions for every coding agent' ~/.agents/AGENTS.md"
check "zed uses shared AGENTS.md" "cmp ~/.agents/AGENTS.md ~/.config/zed/AGENTS.md"
check "memory health hook runs" "\"\$HOME/.claude/hooks/basic-memory-health.sh\""
check "git identity" "git config --file ~/.config/git/config user.name | grep -qx 'Gustavo Porto'"
check "fish starts" "fish -c true"
check "neovim starts" "nvim --headless +qa"
check "dock tile size" "test \"\$(defaults read com.apple.dock tilesize)\" = 69"
check "dark mode" "test \"\$(defaults read NSGlobalDomain AppleInterfaceStyle)\" = Dark"

exit "$failed"
