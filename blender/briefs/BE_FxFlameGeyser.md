# BE_FxFlameGeyser - mesh-stage brief

Template: `FlameGeyser` (will live at `ReplicatedStorage.Assets.PowerMoves.FlameGeyser`). Source: `blender/BE_FxFlameGeyser.blend`.
Move: Fire R Eruption: flame geyser.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/fire.png (row R ERUPTION, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **7 x 12 x 6**.
- Triangle budget: **target 1300, max 2000**.
- Shape: A single big rounded flame geyser: a wide stable base, one tall central column with a plump rounded top, and four to six fat rounded side lobes of different heights fused to it (like the concept), blunt soft tips, no thin spikes, no smoke. Slightly flattened front to back (Roblox Z). Flat bottom. Centred on X and Z so runtime can scale it up from the ground. REWORK NOTE (owner review 2026-10-29): the first build was too faceted and crystal-like. Build it from smooth rounded forms: sculpt with a Subdivision Surface modifier (level 1 or 2), shade smooth, then APPLY the modifier and decimate to the triangle budget. Silhouette must be soft, plump and toy-like, like inflated foam, with no flat crystal facets, no sharp ridges and no spikes. Think of a cluster of fat rounded flame lobes, like inflated candy, with a smooth bulbous base.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxFlameGeyser`, work only there, save to `blender/BE_FxFlameGeyser.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxFlameGeyser_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
