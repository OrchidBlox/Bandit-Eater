---
name: codex-workflow
description: Hand work to ChatGPT Codex. Use when writing a spec for Codex, starting a Codex run (code or Blender), choosing its model or reasoning, keeping Codex credit use down, or reviewing the diff and results of a Codex run.
---

# Codex workflow

The full guide is [docs/codex-workflow.md](../../../docs/codex-workflow.md). It has the run commands, both spec templates and the review checklist; read it before writing a spec.

## Do this

1. Decide who builds it. Big code changes and Blender models go to Codex; small fixes (a few lines up to a couple of files) Claude makes directly.
2. Write the spec to a file from the matching template in the guide (code or Blender) and run `scripts/codex-run.sh <spec> [model] [reasoning] [code|blender|studio]`. Codex is not on PATH; the script finds it.
3. Use the cheaper default model unless the owner asks for a stronger one. Don't edit `~/.codex/config.toml`.
4. Keep credits down: one job per run, point at exact files, ask for short printouts, cap retries (stop after the same step fails twice and report), reuse `blender/model_tools.py` instead of rewriting the bake and export, and review the first model of a batch before queueing the next.
5. `code` runs check with `rojo build` and never use the Studio MCP. Claude does the Studio testing. Only `studio` runs keep the automatic reviewer.
6. Review the whole diff with the guide's checklist, fix small problems directly, send big ones back as a focused follow-up spec, then run `rojo build` and playtest.

## Watch for

- Blender runs build in two stages (mesh, then finish) and the owner approves the mesh unless they are away. Never let a run open or switch Blender files.
- Every spec lists the files Codex must not touch.
