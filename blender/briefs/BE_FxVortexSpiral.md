# BE_FxVortexSpiral - mesh-stage brief

Template: `VortexSpiral` (will live at `ReplicatedStorage.Assets.PowerMoves.VortexSpiral`). Source: `blender/BE_FxVortexSpiral.blend`.
Move: Wind E Vortex: ground spiral.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/wind.png (row E VORTEX, RELEASE and IMPACT panels)

- Final size (Roblox X x Y x Z studs): **8 x 3.2 x 8**.
- Triangle budget: **target 900, max 1500**.
- Shape: A small low ground spiral: two thick rounded ribbons winding inward and rising slightly toward the centre, like a shallow funnel, with a clear outer rim ring. Ribbons about 1.2 studs wide and 0.7 thick, blunt rounded ends. The spin axis is Roblox Y.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxVortexSpiral` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxVortexSpiral.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxVortexSpiral_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
