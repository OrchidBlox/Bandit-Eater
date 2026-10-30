#!/usr/bin/env bash
# Runs ChatGPT Codex non-interactively on a spec file and logs the run.
#
#   scripts/codex-run.sh <spec.md> [model] [reasoning] [code|blender|studio]
#
# - Finds codex.exe inside the ChatGPT VS Code extension (its version folder
#   changes on every extension update, so it is never hard-coded).
# - No automatic reviewer by default (owner, 2026-09-28). `--approve-for-me`
#   starts a second model that re-reads the whole run on every tool call and
#   bills the same credits; it roughly doubled run costs.
#   - code (default): Codex writes code and runs `rojo build`; it does not use
#     the Roblox Studio MCP. Claude does the Studio testing afterwards.
#   - blender: only the Blender MCP tools are pre-approved (nothing else can
#     approve a tool call without the reviewer). One model per run.
#   - studio: keeps --approve-for-me, for runs that must use the Roblox Studio
#     MCP (for example placing generated map props).
# - Files stay limited to the project (workspace-write sandbox) in every mode.
# - Every code spec should link docs/roblox-ui-gotchas.md.
set -euo pipefail

spec="${1:?usage: scripts/codex-run.sh <spec.md> [model] [reasoning] [code|blender|studio]}"
model="${2:-gpt-5.6-sol}"   # code changes; Blender model builds use gpt-6-astra
reasoning="${3:-medium}"
mode="${4:-code}"

root="$(cd "$(dirname "$0")/.." && pwd)"
codex="$(ls -d "$USERPROFILE"/.vscode/extensions/openai.chatgpt-*/bin/windows-x86_64/codex.exe 2>/dev/null | sort -V | tail -1)"
if [ -z "$codex" ]; then
	echo "codex.exe not found - is the ChatGPT VS Code extension installed?" >&2
	exit 1
fi

brief="Print only summaries and failures, never whole files or scene dumps, and keep your messages short."
case "$mode" in
	code)
		approval=(-s workspace-write)
		prompt="Read $spec and implement it. Follow docs/roblox-ui-gotchas.md. Check your work with rojo build; do not use the Roblox Studio MCP (Claude tests in Studio). $brief"
		;;
	blender)
		approval=(-s workspace-write -c 'mcp_servers.blender.default_tools_approval_mode="approve"')
		prompt="Read $spec and do exactly what it says through the Blender MCP. BLENDER 5.2.2 CRASH TRAP (this closes the user's Blender): never write a Scene made with bpy.data.scenes.new to a .blend with bpy.data.libraries.write. Make the working scene with bpy.ops.scene.new(type='EMPTY') and save the finished mesh with bpy.data.libraries.write(path, {obj}, fake_user=True), the OBJECT only, never the scene. Do not open or switch files. $brief"
		;;
	studio)
		approval=(--approve-for-me)
		prompt="Read $spec and implement it. Follow docs/roblox-ui-gotchas.md. You may use the Roblox Studio MCP. $brief"
		;;
	*)
		echo "mode must be code, blender or studio" >&2
		exit 1
		;;
esac

mkdir -p "$root/.codex-tmp/logs"
log="$root/.codex-tmp/logs/$(date +%Y%m%d-%H%M%S)-$(basename "$spec" .md).log"
echo "Codex: $codex"
echo "Model: $model ($reasoning, $mode) - log: $log"

cd "$root"
"$codex" exec -m "$model" -c model_reasoning_effort="$reasoning" "${approval[@]}" \
	"$prompt" \
	</dev/null >"$log" 2>&1
status=$?
tail -40 "$log"
exit $status
