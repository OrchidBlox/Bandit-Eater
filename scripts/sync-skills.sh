#!/usr/bin/env bash
# Copies the Claude skills into the folder Codex reads, so both AIs use the same skills.
#
#   bash scripts/sync-skills.sh
#
# .claude/skills is the source of truth (Claude Code reads it). Codex reads
# .agents/skills, so this makes a plain copy (no symlinks, which are unreliable on
# Windows). Edit skills under .claude/skills, run this, and commit both folders.
# Relative links inside skills (../../../docs/...) work from either folder.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/.claude/skills"
dst="$root/.agents/skills"

if [ ! -d "$src" ]; then
	echo "no skills found at $src" >&2
	exit 1
fi

rm -rf "$dst"
mkdir -p "$dst"
cp -r "$src"/. "$dst"/
echo "Synced $(find "$dst" -name SKILL.md | wc -l) skills to .agents/skills"
