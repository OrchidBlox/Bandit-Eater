# BE_FxChunkyCrescent - mesh-stage brief

Template: `ChunkyCrescent` (will live at `ReplicatedStorage.Assets.PowerMoves.ChunkyCrescent`). Source: `blender/BE_FxChunkyCrescent.blend`.
Move: Shadow R Nightfall and slashes: chunky crescent.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/shadow.png (row R NIGHTFALL, RELEASE panel); docs/reference/move-concepts-v1-2026-10-26/sword.png (row Q SLASH, RELEASE panel)

- Final size (Roblox X x Y x Z studs): **6 x 6 x 1.8**.
- Triangle budget: **target 600, max 1000**.
- Shape: A thick plump crescent (a fat C) like the big violet crescent in the Nightfall concept: the arc is about 2 studs wide at the middle, tapering to soft ROUNDED tips, thickness 1.8, smooth rounded cross-section. The crescent lies in the Roblox X-Y plane with the convex outer edge on +X and the opening toward -X; the thin dimension is Roblox Z.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxChunkyCrescent` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxChunkyCrescent.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxChunkyCrescent_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
