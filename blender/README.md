# Blender + Codex (MCP) workflow

This folder holds the 3D models for this game, built by ChatGPT Codex in Blender through the Blender MCP.

- `<Name>.blend`: the Blender source file for each model
- `export/`: the FBX files you import into Roblox Studio
- `design/`: design references (design sheets or concept art for each model)

Codex's job here is **models only**: meshes, rigs, animations, and exports. Game code, Studio edits, and docs belong to Claude.

## 1. MCP setup (template)

Add the Blender MCP server to Codex's config at `%USERPROFILE%\.codex\config.toml`:

```toml
[mcp_servers.blender]
command = 'C:\Users\<you>\.local\bin\uvx.exe'   # path to uvx (install uv first)
args = ["--python", "3.11", "mcp-for-blender"]
startup_timeout_sec = 60
```

In Blender:

1. Install and enable the MCP addon that matches the server (Edit → Preferences → Add-ons → Install from Disk).
2. In the 3D Viewport sidebar (press N), open the MCP tab and click **Connect** or **Start Server**.
3. Keep Blender open while Codex runs. If Codex reports that it can't reach Blender, reconnect the addon and run again.

Check the connection with `codex mcp list`. `blender` should be listed.

## 2. Running Codex

Codex ships inside the ChatGPT VS Code extension. The version folder changes when the extension updates:

```
%USERPROFILE%\.vscode\extensions\openai.chatgpt-<version>-win32-x64\bin\windows-x86_64\codex.exe
```

Run a spec file from the repo root:

```bash
codex.exe exec -m <model> -c model_reasoning_effort="medium" -s workspace-write -c 'mcp_servers.blender.default_tools_approval_mode="approve"' -C . - < spec.txt
```

- `mcp_servers.blender.default_tools_approval_mode="approve"`: required. A non-interactive run has no way to approve tool calls, so without this setting every Blender MCP call fails with "requires approval, but approval policy is never".

- `-m`: pick the model per run (for example `gpt-5.6-sol`, or `gpt-6-astra` for heavy model work). Don't change the default in `config.toml`.
- `-s workspace-write`: Codex can write files in the repo only. The old `--full-auto` flag no longer exists.
- `- < spec.txt`: the prompt is read from a file. Build the file from the template below.
- Or use `scripts/codex-run.sh <spec> gpt-6-astra medium blender`, which runs exactly this and logs to `.codex-tmp/logs/`.

## 3. Keeping Codex usage down (owner's rules, 2026-09-28)

Codex re-sends everything in the run so far (every tool output and every image) on every tool call. A long run with many screenshots and printouts costs more with each step. On an earlier project, one run that built three large models used about 2.8M input tokens for 16k tokens of output, and runs ran out of credits partway through. These rules keep runs small:

1. **No automatic reviewer.** Don't pass `--approve-for-me` for Blender runs. Its reviewer is a second model that re-reads the whole run on every tool call and bills the same credits (it roughly doubled Blender run costs). The Blender MCP approval setting above is all a Blender run needs.
2. **One model per run.** A spec builds one model. The next model gets its own spec after Claude reviews the first.
3. **Two stages per model.** Stage `mesh`: build the mesh only, then stop with one check image beside the design sheet, so the owner can approve the look before anything is rigged. Stage `finish`: a fresh run rigs, animates, bakes, exports and reports the approved mesh. A wrong design is then thrown away after a short run instead of after a full one, and the second run starts with an empty context. **Owner away (AFK, asleep):** use stage `full` instead: Codex builds the mesh, compares it with the design sheet itself, fixes what differs, and carries on to the finish in the same run. Claude picks `full` only when the owner says they'll be away.
4. **One composite image per check.** Render the front, side and 3/4 views (or the action frames) into one tiled PNG about 800px wide (numpy is bundled with Blender) and view that once, instead of viewing separate screenshots. Keep the total to what the checks need.
5. **Short printouts.** Scripts print only a summary line and any failures. No scene dumps, no printing whole files or long vertex lists: every printed line stays in the context for the rest of the run.
6. **One short brief per model.** Each model gets its own brief in `blender/briefs/<Model>.md`: the shared style rules condensed, plus that model's description, size, bones and animations. Don't point Codex at a long brief that covers many models.
7. **Cap the retries (2026-10-10).** If the same bake, build or export step fails twice, Codex stops, leaves the .blend saved, and reports the step, the error and what it tried. It never rebuilds from scratch to fix a failure.
8. **Reuse the shared helper.** When models share a base file, `blender/model_tools.py` does the repeated steps: snapshot the base, recolour, bake (Color + OpenGL Normal), export the FBX, validate that nothing the animations depend on changed, and render one review composite. Codex writes only a short per-model script that calls it (colours and details). On an earlier project this cut a run from about 71k to about 47k tokens. Fix bugs in the helper, not per model; run it headless once on a scratch copy after any change to it.
9. **Check the first model before queueing more.** Run one model, review it, then run the next. Don't chain runs with a script that starts the next on its own: a problem repeats for every model in the queue.

## 4. Spec template

Put a scope block at the top of every spec, then the model brief:

```
TASK SCOPE (strictly enforced):
- Your ONLY job: <model name and forms> in Blender using the Blender MCP tools. One model only.
- STAGE: mesh | finish | full
  - mesh: build the mesh only, then stop and report with one composite check image (front, side, 3/4) beside the design sheet. Do not rig or animate.
  - finish: the mesh is approved; do not reshape it. Rig, animate, bake, export, check and report.
  - full: the owner is away; build the mesh, compare it with the design sheet yourself and fix what differs, then do the finish in the same run.
- Do NOT edit src/, docs/, default.project.json, or any Roblox/Studio files. Do NOT use the Roblox_Studio MCP. Do not write Luau.
- Write files only under blender/: save the source to blender/<Name>.blend and exports to blender/export/.
- Brief: blender/briefs/<Model>.md. Visual reference: blender/design/<file>. Match its shapes, proportions, and colours.
- RETRY CAP (credits): if the same bake, build or export step fails twice, STOP. Leave the .blend saved as it is and report exactly which step failed, the error message and what you tried. Never rebuild from scratch to fix a failure.
- USE THE SHARED HELPER (when the model comes from a shared base): blender/model_tools.py does the base snapshot, recolour, bake, export, validation and review images. Read its docstring and write only a short per-model script that calls it; do not rewrite those steps.
- Keep usage down: one composite image per check (about 800px, views tiled into one PNG), scripts print only a summary and failures, no scene dumps or whole-file reads, short messages.
- Final report: objects, triangle count per form, bones, actions, export paths, and what to check by eye.
```

## 5. Build rules for Codex

These rules apply to every asset. Roblox and the game code depend on them.

**Scale and placement**
- 1 Blender unit = 1 Roblox stud.
- The model stands on Z = 0, centred on X = 0, Y = 0, and faces −Y.
- The object origin is at the bottom centre between the feet. Apply all transforms before export.

**Geometry**
- Low-poly Roblox style: flat colours from simple Principled BSDF materials, no image textures.
- Aim for 1,500–4,000 triangles per form, and never more than 10,000 (Roblox's mesh limit per part).
- Build from simple primitives, join them into one mesh per form, and apply every modifier.
- No n-gons with holes. Triangulating on export is fine.
- Glowing parts use emission in the same colour as the base, strength 2–3.

**Naming**
- Meshes are named `<Model>_<Variant>` (for example `Knight_Base`, `Knight_Armored`).
- Variants of one model share one armature: same bone names, same hierarchy, same rest pose.
- Action names match the names the game code uses exactly (for example `Idle`, `Attack`, `Hit`).

**Rigging and animation**
- Keep the bone count small and fixed per model family. Rigid parts (eyes, head pieces) get weight 1.0 on their bone.
- 30 fps. Looping actions start and end on the same pose.
- Only `Root` moves. Every other bone only rotates or scales.

**Scripts and safety**
- Every script can be run again: first delete the objects it made earlier, by name.
- Work in small steps and check each step visually before the next, with one composite image per check (section 3).
- Save the `.blend` often. Never overwrite exports from another model.

**Export (FBX)**
- Selected Objects only (the mesh plus its armature). Apply Scalings: FBX All. Forward: −Y. Up: Z. Apply Unit on.
- Add Leaf Bones off. Bake Animation on with All Actions on. NLA Strips off. Key All Bones on.
- File names: `<Model>_<Variant>.fbx`, plus one `<Model>_<Action>.fbx` per animation if Roblox needs them separately.

## 6. After Codex finishes

1. Claude reviews the report and the exports: triangle counts, names, facing, and scale.
2. Claude uploads them with `scripts/upload_assets.py`, inserts them through the Studio MCP, checks the orientation, and places them where the code expects (for example `ReplicatedStorage.Assets.<Kind>.<Model>.<Form>`). Manual Import 3D still works as a fallback.
3. Claude converts and uploads the animations with `scripts/export_animations.py`, then connects the IDs in the game. See `docs/asset-pipeline.md`.

Keep a list of every asset the game expects, and the names it needs, in the repo docs.
