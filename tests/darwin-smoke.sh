#!/usr/bin/env bash
# Checks that an applied darwin config works. Run after a switch.
set -euo pipefail
# A login shell gets these from nix-darwin's /etc/zshrc; CI steps don't
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

check() {
	if eval "$2" >/dev/null 2>&1; then
		echo "ok   $1"
	else
		echo "FAIL $1"
		failed=1
	fi
}
failed=0

check "darwin-rebuild on PATH" "command -v darwin-rebuild"
check "claude skills" "test -f ~/.claude/skills/memory-notes/SKILL.md"
check "agent skills" "test -f ~/.agents/skills/memory-notes/SKILL.md"
check "claude settings link" "jq -e .permissions ~/.claude/settings.json"
check "claude CLAUDE.md" "test -f ~/.claude/CLAUDE.md"
check "opencode config" "jq -e . ~/.config/opencode/opencode.json"
check "git identity" "test \"\$(git config --global user.name)\" = 'Gustavo Porto'"
check "fish starts" "fish -c true"
check "neovim starts" "nvim --headless +qa"
check "dock tile size" "test \"\$(defaults read com.apple.dock tilesize)\" = 69"
check "dark mode" "test \"\$(defaults read NSGlobalDomain AppleInterfaceStyle)\" = Dark"

exit "$failed"
