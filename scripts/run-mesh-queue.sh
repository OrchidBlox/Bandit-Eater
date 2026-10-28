#!/usr/bin/env bash
# Runs the Codex mesh-stage queue one model at a time. Skips models whose .blend and review image already exist,
# logs DONE / FAIL / STOP to .codex-tmp/mesh-queue.status, and stops on a usage limit. Re-run to resume.
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
status=.codex-tmp/mesh-queue.status
mkdir -p .codex-tmp/specs
for name in "$@"; do
	if [ -f "blender/BE_$name.blend" ] && [ -f "blender/review/BE_${name}_Review.png" ]; then
		echo "SKIP $name" >> "$status"; continue
	fi
	sed "s/FxTornadoBands/$name/g" .codex-tmp/specs/FxTornadoBands.md > ".codex-tmp/specs/$name.md"
	out=$(bash scripts/codex-run.sh ".codex-tmp/specs/$name.md" gpt-6-astra medium blender 2>&1)
	if echo "$out" | grep -qi "usage limit\|rate limit\|quota"; then
		echo "STOP $name (usage limit)" >> "$status"; exit 1
	fi
	if [ -f "blender/BE_$name.blend" ] && [ -f "blender/review/BE_${name}_Review.png" ]; then
		echo "DONE $name" >> "$status"
	else
		echo "FAIL $name" >> "$status"
	fi
done
echo "QUEUE END" >> "$status"
