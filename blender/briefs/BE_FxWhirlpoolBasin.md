# BE_FxWhirlpoolBasin - mesh-stage brief

Template: `WhirlpoolBasin` (will live at `ReplicatedStorage.Assets.PowerMoves.WhirlpoolBasin`). Source: `blender/BE_FxWhirlpoolBasin.blend`.
Move: Water E Whirlpool: swirling basin.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/water.png (row E WHIRLPOOL, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **10 x 0.9 x 10**.
- Triangle budget: **target 1300, max 2000**.
- Shape: A shallow broad basin: a thick raised rounded lip around the edge, a slightly dipped interior carved with three thick spiral swirl arms turning inward (rounded raised ridges 0.2 high), and a small dip at the centre, like the concept blue pool with white swirl arms. Flat bottom. The spin axis is Roblox Y (centred). Two material slots: `Water` (basin and arms) and `Foam` (rim lip).

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxWhirlpoolBasin` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxWhirlpoolBasin.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxWhirlpoolBasin_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
