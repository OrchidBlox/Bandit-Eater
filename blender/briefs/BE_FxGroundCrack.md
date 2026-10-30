# BE_FxGroundCrack - mesh-stage brief

Template: `GroundCrack` (will live at `ReplicatedStorage.Assets.PowerMoves.GroundCrack`). Source: `blender/BE_FxGroundCrack.blend`.
Move: Earth R Quake: ground crack.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/earth.png (row R QUAKE, WINDUP and RELEASE panels)

- Final size (Roblox X x Y x Z studs): **12 x 0.25 x 12**.
- Triangle budget: **target 350, max 600**.
- Shape: A flat jagged crack pattern radiating from the centre: 7 to 9 main cracks, each with a few short branches, about 0.35 stud wide with pointed taper ends, in one flat sheet about 0.25 stud thick. Crack lines only: leave the space between the cracks EMPTY (no disc).

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxGroundCrack` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxGroundCrack.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxGroundCrack_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
