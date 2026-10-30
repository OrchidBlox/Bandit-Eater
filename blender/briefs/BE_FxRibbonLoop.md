# BE_FxRibbonLoop - mesh-stage brief

Template: `RibbonLoop` (will live at `ReplicatedStorage.Assets.PowerMoves.RibbonLoop`). Source: `blender/BE_FxRibbonLoop.blend`.
Move: Shadow E Snare: looping ribbon.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/shadow.png (row E SHADOW SNARE, RELEASE panel)

- Final size (Roblox X x Y x Z studs): **6 x 8 x 4**.
- Triangle budget: **target 1100, max 1800**.
- Shape: REDO (v1 came out as a plain S-tube, reject that). One thick rounded ribbon tube (round cross-section about 1.0 stud thick, built from a bevelled Bezier curve, smooth shading) that rises from a small rounded base, makes a clearly open FIGURE-EIGHT: a large loop on the left, a crossing in the middle where the tube passes over itself with a visible gap between the two strands, a second loop on the right, then finishes in a soft curl with a rounded end cap. Both loops read from the front view with open holes you can see through. Plump, glossy, no flat tape, no thin ends.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxRibbonLoop` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/BE_FxRibbonLoop.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxRibbonLoop_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
