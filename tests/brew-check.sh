#!/usr/bin/env bash
# Fail if any Homebrew tap, formula or cask in a darwin config doesn't exist,
# e.g. after an upstream rename. Needs brew; only taps, installs nothing.
# Usage: tests/brew-check.sh [host]
set -euo pipefail
cd "$(dirname "$0")/.."
host="${1:-boris}"

names() {
	nix eval --json ".#darwinConfigurations.$host.config.homebrew.$1" \
		--apply 'map (x: x.name)' | jq -r '.[]'
}
taps=$(names taps)
brews=$(names brews)
casks=$(names casks)

status=0
missing() {
	echo "missing $1: $2"
	status=1
}
# Casks from third-party taps load only after `brew trust`, but existing
# ones still report that instead of "not found".
exists() {
	local out
	out=$(brew info "--$1" "$2" 2>&1) || grep -q "untrusted tap" <<<"$out"
}

for tap in $taps; do brew tap "$tap" >/dev/null 2>&1 || missing tap "$tap"; done
for formula in $brews; do exists formula "$formula" || missing formula "$formula"; done
for cask in $casks; do exists cask "$cask" || missing cask "$cask"; done
exit "$status"
