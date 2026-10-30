# BE_FxRingStack - mesh-stage brief

Template: `RingStack` (will live at `ReplicatedStorage.Assets.PowerMoves.RingStack`). Source: `blender/BE_FxRingStack.blend`.
Move: Shadow E Snare: coiled ring stack.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/shadow.png (row E SHADOW SNARE, IMPACT panel)

- Final size (Roblox X x Y x Z studs): **4.6 x 2.8 x 4.6**.
- Triangle budget: **target 450, max 800**.
- Shape: Three fat donut rings stacked like a soft coil around a hole in the middle (a 1.4 stud opening), widest at the bottom (4.6) and narrower toward the top (3.4), each ring about 0.95 stud thick, slightly overlapping so they read as one wound stack. Centred on X and Z so a character can stand in the opening.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxRingStack` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxRingStack.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxRingStack_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
