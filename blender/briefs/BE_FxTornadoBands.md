# BE_FxTornadoBands - mesh-stage brief

Template: `TornadoBands` (will live at `ReplicatedStorage.Assets.PowerMoves.TornadoBands`). Source: `blender/BE_FxTornadoBands.blend`.
Move: Wind R Cyclone: tornado bands.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/wind.png (row R CYCLONE, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **9 x 11 x 9**.
- Triangle budget: **target 1400, max 2200**.
- Shape: One tall, plump tornado made of THREE thick intertwined spiral bands wound around a vertical axis (about 1.3 turns each), narrower at the bottom and broad at the top like the concept. Each band is a fat rounded ribbon (about 1.6 studs thick, 2.4 wide) with blunt rounded ends, and clear gaps between the bands so the three-band spiral reads. No funnel skin, no needle tips, no debris. The spin axis is Roblox Y, exactly centred so runtime can rotate it around Y.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxTornadoBands` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxTornadoBands.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxTornadoBands_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
