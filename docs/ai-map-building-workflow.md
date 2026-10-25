# AI map-building workflow (reusable)

How to build polished blocky maps: Codex builds the props in Blender, Claude uploads them and places them with one script per area. Ground, floors, island edges and bridges stay plain parts (flat surfaces, exact collision, code anchors); everything decorative is a Blender prop.

## Who does what

| Step | Tool | Who runs it |
|---|---|---|
| Decide the look (theme, palette, props list) | Concept art / artifact, design doc | Owner, with ChatGPT or Claude |
| Final concept image of each prop set | ChatGPT image generation | Owner |
| One short Blender brief per prop set | `blender/briefs/<Set>.md` | Claude |
| Build the props (gate, lantern, tree, fence section...) | Codex through the Blender MCP | Claude starts the run (see [codex-workflow.md](codex-workflow.md)) |
| Export, upload and place the props | `upload_assets.py` and the Studio MCP ([asset-pipeline.md](asset-pipeline.md)) | Claude |
| Arrange props around an area | One short Luau script per area, run through the Studio MCP (`execute_luau`) | Claude or Codex |
| Review and approve | Screenshots, then playtest | Owner |

## Step by step

1. **Save the place** (Ctrl+S) so any step can be undone.
2. **List the props** the area needs, one object per line, with a size in studs and 2 to 3 main colours. Ask for sections (a fence *section*, a bridge *segment*) and repeat them with the placement script rather than modelling long pieces.
3. **Write one brief per prop set** (a handful of related props: for example gate, lantern, sign). Say the style words every time: blocky low-poly, chunky Roblox simulator shapes, flat colours. Include the final concept image as the reference and a triangle budget (about 800 for repeated pieces like fence sections, about 4000 for one-offs).
4. **Codex builds each set in Blender**, one set per run, mesh first and then finish, and the owner approves the first set before the rest are queued.
5. **Upload and keep the props as templates.** Insert each uploaded model through the Studio MCP, fix its orientation and pivot (see the asset pipeline), and put the templates in `ServerStorage.MapProps`.
6. **Place them with a script**, not by hand: one short `execute_luau` script per area that clones props from `ServerStorage.MapProps` and sets where each goes, its facing and scale. Writing positions relative to the area's pivot lets the same script work on repeated areas (like identical player plots).
7. **Screenshot** from the player's approach angle (`screen_capture` with a camera position) and adjust scale and spacing.
8. **Park, don't delete**, anything you replace: move old decoration into `ServerStorage.<Area>OldDecor_<Name>` so it can come back.

## Rules that keep gameplay safe

- Never move, rename, or delete the parts game code depends on. Each project lists them in [asset-checklist.md](asset-checklist.md) (named anchor parts and attributes).
- Put nothing on floors or paths that gameplay uses.
- Keep decoration in its own Model (e.g. `Decor`) so it can be swapped as one piece.
- Record each ChangeHistoryService step (`TryBeginRecording` / `FinishRecording`) so Ctrl+Z undoes a whole build.
- Map objects built this way live in the place file, not in Rojo; save the place in Studio after each area.
