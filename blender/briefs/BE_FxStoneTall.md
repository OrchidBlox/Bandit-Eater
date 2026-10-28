# BE_FxStoneTall - mesh-stage brief

Template: `StoneTall` (will live at `ReplicatedStorage.Assets.PowerMoves.StoneTall`). Source: `blender/BE_FxStoneTall.blend`.
Move: Earth E Stone Field: tall chunky stone.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/earth.png (row E STONE FIELD, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **3.4 x 5 x 3.2**.
- Triangle budget: **target 280, max 450**.
- Shape: One chunky faceted stone like the tall boulders in the concept: wide at the base, slightly tapering, a lumpy flat-ish top, big flat facets (8 to 12), rounded bevelled edges, a little asymmetry. It sits as if half buried: the bottom is flat. No cracks, moss or pebbles.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxStoneTall`, work only there, save to `blender/BE_FxStoneTall.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxStoneTall_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
