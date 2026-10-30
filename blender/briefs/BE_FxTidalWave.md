# BE_FxTidalWave - mesh-stage brief

Template: `TidalWave` (will live at `ReplicatedStorage.Assets.PowerMoves.TidalWave`). Source: `blender/BE_FxTidalWave.blend`.
Move: Water R Tidal Wave: curling wave.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/water.png (row R TIDAL WAVE, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **12 x 7 x 6**.
- Triangle budget: **target 1800, max 2600**.
- Shape: One broad plump curling wave, wider than tall: a gentle sloping back (toward Roblox +Z), a tall rounded crest that curls OVER toward the travel direction (-Z) with a hollow barrel underneath, a row of thick rounded foam scallops along the crest lip and chunky foam blobs along the base. The ends taper into rounded points. Flat base. Two material slots: `Water` (body) and `Foam` (scallops and blobs). Keep the barrel open (see-through from the side). REWORK NOTE: the first build read as an open scoop with a row of ball-shaped teeth. Make it ONE plump wave: a thick rounded back that rises into a fat curling crest, a deep but clearly closed-in barrel, and the foam as 5 to 7 BIG fat cloud-like scallops fused into the crest lip and a thick foam band along the base, merged with the body (no separate floating spheres, no row of teeth). Smooth, inflated look. REWORK NOTE (owner review 2026-10-29): the first build was too faceted and crystal-like. Build it from smooth rounded forms: sculpt with a Subdivision Surface modifier (level 1 or 2), shade smooth, then APPLY the modifier and decimate to the triangle budget. Silhouette must be soft, plump and toy-like, like inflated foam, with no flat crystal facets, no sharp ridges and no spikes.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxTidalWave` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxTidalWave.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxTidalWave_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
