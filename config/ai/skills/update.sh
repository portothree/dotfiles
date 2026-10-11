#!/usr/bin/env bash
# Sync vendored agent skills with their upstream repos (see sources.json).
# A skill's recorded rev only moves when its files actually changed.
# Usage: config/ai/skills/update.sh [skill...]   (default: all)
set -euo pipefail
cd "$(dirname "$0")"

sources=sources.json
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ $# -eq 0 ]; then
	# shellcheck disable=SC2046 # skill names have no spaces
	set -- $(jq -r 'keys[]' "$sources")
fi

# Download each repo once, at its default branch head.
fetch() {
	local repo=$1 dir="$tmp/${1//\//_}"
	if [ ! -d "$dir" ]; then
		mkdir -p "$dir"
		git ls-remote "https://github.com/$repo" HEAD | cut -f1 >"$dir.rev"
		curl -fsSL "https://codeload.github.com/$repo/tar.gz/$(cat "$dir.rev")" |
			tar -xz -C "$dir" --strip-components=1
	fi
	echo "$dir"
}

for name in "$@"; do
	repo=$(jq -r --arg n "$name" '.[$n].repo' "$sources")
	path=$(jq -r --arg n "$name" '.[$n].path' "$sources")
	dir=$(fetch "$repo")
	if [ ! -f "$dir/$path/SKILL.md" ]; then
		echo "$name: $repo has no $path/SKILL.md anymore" >&2
		exit 1
	fi
	rm -rf "$name"
	cp -R "$dir/$path" "$name"
	if git diff --quiet -- "$name" && [ -z "$(git ls-files --others -- "$name")" ]; then
		echo "$name: unchanged"
	else
		rev=$(cat "$dir.rev")
		jq --arg n "$name" --arg r "$rev" '.[$n].rev = $r' "$sources" >"$tmp/s" && mv "$tmp/s" "$sources"
		echo "$name: updated to $repo@${rev:0:7}"
	fi
done
