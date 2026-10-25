---
name: ai-map-building
description: Build or polish map scenery. Codex builds props in Blender, Claude uploads them and places them with one script per area. Use when decorating an area, adding props like gates, lanterns, fences, rocks or trees, replacing placeholder scenery, or laying out repeated plots.
---

# AI map building

The full guide is [docs/ai-map-building-workflow.md](../../../docs/ai-map-building-workflow.md). Props come from Codex in Blender, not from Studio generators.

## Do this

0. **Use the game's map style, and ask if there isn't one.** Follow Step 0 of the `map-style` skill: if `CLAUDE.md` has no `Map style:` line, ask the owner before listing props or writing a brief, and record the answer. Then read the style's file and copy its palette, materials, lighting values and prop budgets into every brief.
1. Save the place first so any step can be undone.
2. List the props with sizes in studs and 2 to 3 main colours, then write one Blender brief per prop set in `blender/briefs/`, using the owner's final concept image as the reference.
3. Run Codex on one set at a time (the `codex-workflow` skill) and have the owner approve the first set before queueing the rest.
4. Upload and place templates through the `asset-pipeline` skill, keeping them in `ServerStorage.MapProps`.
5. Place props with one short `execute_luau` script per area, relative to the area's pivot, inside one ChangeHistoryService recording.
6. Screenshot from the player's approach angle, adjust, and have the owner review each area.

## Rules

- Never move, rename or delete the anchors listed in docs/asset-checklist.md, and keep decoration off gameplay floors and paths.
- Ground, floors, island edges and bridges stay plain parts.
- Park replaced decoration in `ServerStorage.<Area>OldDecor_<Name>`, never delete it.
