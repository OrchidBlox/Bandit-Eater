# BE_FxFlameBlob - mesh-stage brief

Template: `FlameBlob` (will live at `ReplicatedStorage.Assets.PowerMoves.FlameBlob`). Source: `blender/BE_FxFlameBlob.blend`.
Move: Fire E Flame Field: squat flame blob.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/fire.png (row E FLAME FIELD, RELEASE panel); docs/reference/move-concepts-v1-2026-10-26/fusion-arcane.png (Fire E)

- Final size (Roblox X x Y x Z studs): **2.6 x 2.8 x 2.2**.
- Triangle budget: **target 350, max 600**.
- Shape: A squat, rounded, bouncy flame blob: wide bulbous base, three short fat rounded lobes on top (tallest in the middle), a soft hump, no thin tongues. Cute and friendly like the small flames in the concept. Flat bottom, base 2.6 wide. REWORK NOTE (owner review 2026-10-29): the first build was too faceted and crystal-like. Build it from smooth rounded forms: sculpt with a Subdivision Surface modifier (level 1 or 2), shade smooth, then APPLY the modifier and decimate to the triangle budget. Silhouette must be soft, plump and toy-like, like inflated foam, with no flat crystal facets, no sharp ridges and no spikes. Think of three overlapping soft jelly bulbs, not a gem.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxFlameBlob`, work only there, save to `blender/BE_FxFlameBlob.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxFlameBlob_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
