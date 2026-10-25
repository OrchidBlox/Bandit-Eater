# AGENTS.md

Instructions for ChatGPT Codex. Claude Code reads `CLAUDE.md`; this file is the short version for Codex. When the two disagree, `CLAUDE.md` wins.

## What this is

A Roblox + Rojo game (Luau). Server-authoritative: the server decides ownership, rewards, currency and outcomes; the client only displays and requests, and every remote is validated. Rojo syncs `src/client`, `src/server` and `src/shared` as described in `CLAUDE.md`.

## Your job

Claude writes a spec and you implement it. Stay inside the files the spec allows, do one job per run, and never edit docs, `default.project.json` or Studio files unless the spec says so.

- **Code runs:** check with `rojo build -o .codex-tmp/build.rbxlx` and `selene src`. Do not use the Roblox Studio MCP; Claude tests in Studio.
- **Blender runs:** build only what the brief asks for, one model or prop set per run, mesh stage first unless the spec says otherwise. Never open or switch Blender files; build in a new scene and save under `blender/`.
- **Retry cap:** if the same step fails twice, stop, leave the work saved as it is, and report the step, the error and what you tried. Never rebuild from scratch to fix a failure.
- **Output:** print only summaries and failures, keep messages short, and finish with the files changed and a short summary.

## Skills

Skills live in `.agents/skills/` (a generated copy of `.claude/skills/`; edit the `.claude` version and run `bash scripts/sync-skills.sh`). Read the one that matches your spec before you start:

| Skill | Use it when |
| --- | --- |
| `codex-workflow` | Any Codex run: spec templates, retry cap, credit rules |
| `asset-pipeline` | Exporting or uploading Blender models and animations |
| `animation` | Building or tuning animation clips; follow the game's `Animation style:` line in `CLAUDE.md` |
| `map-style` | Building map props or scenery; follow the `Map style:` line |
| `ai-map-building` | Props for an area, placement rules and anchors |
| `vfx-effect` | Small effects; follow the `VFX style:` line |
| `vfx-hero-spell` | Hero spells with meshes, rigs and cast animations |

If a style line in `CLAUDE.md` still says "not chosen yet", do not pick a style yourself: stop and report that the owner has to choose first.

## Safety

- Never commit, push or change git state unless the spec says so.
- Never touch named anchors listed in `docs/asset-checklist.md`.
- Never put API keys or `.env` contents in output, logs or files.
## Required R15 rig (owner decision, 2026-10-25)

- For all future R15 character rigging and R15 animation work, use `C:\Users\Kobe\source\repos\R15 - Blener Model\MrXen0_R15RIG_v1.2.blend` as the canonical source rig unless the owner explicitly requests another rig.
- Reuse this rig instead of generating a replacement R15 armature or choosing another default. Preserve its bone names, hierarchy, rest pose and rig controls when authoring animations.
- Keep the source file unchanged. Copy it into the project's `blender/` folder or append its rig into the working scene, and save project work separately. When a live Blender session is open, preserve unsaved work and append into a new scene rather than switching files.
- If the source file is unavailable, report the missing path and ask for its location; do not silently substitute another rig.
- This rule applies specifically to R15 work. Other asset rigs, including creatures and grimoires, retain their own project instructions. Existing assets are not migrated unless requested.
