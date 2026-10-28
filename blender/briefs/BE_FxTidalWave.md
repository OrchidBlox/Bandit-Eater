# BE_FxTidalWave - mesh-stage brief

Template: `TidalWave` (will live at `ReplicatedStorage.Assets.PowerMoves.TidalWave`). Source: `blender/BE_FxTidalWave.blend`.
Move: Water R Tidal Wave: curling wave.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/water.png (row R TIDAL WAVE, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **12 x 7 x 6**.
- Triangle budget: **target 1800, max 2600**.
- Shape: One broad plump curling wave, wider than tall: a gentle sloping back (toward Roblox +Z), a tall rounded crest that curls OVER toward the travel direction (-Z) with a hollow barrel underneath, a row of thick rounded foam scallops along the crest lip and chunky foam blobs along the base. The ends taper into rounded points. Flat base. Two material slots: `Water` (body) and `Foam` (scallops and blobs). Keep the barrel open (see-through from the side).

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxTidalWave`, work only there, save to `blender/BE_FxTidalWave.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxTidalWave_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
