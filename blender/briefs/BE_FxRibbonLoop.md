# BE_FxRibbonLoop - mesh-stage brief

Template: `RibbonLoop` (will live at `ReplicatedStorage.Assets.PowerMoves.RibbonLoop`). Source: `blender/BE_FxRibbonLoop.blend`.
Move: Shadow E Snare: looping ribbon.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/shadow.png (row E SHADOW SNARE, RELEASE panel)

- Final size (Roblox X x Y x Z studs): **6 x 8 x 4**.
- Triangle budget: **target 1100, max 1800**.
- Shape: One thick glossy rounded ribbon tube (diameter about 1.0 stud, round cross-section) that rises from a small base, curls into a figure-eight style double loop and finishes in a soft rounded end, like the purple ribbon in the concept. Smooth and plump, no flat tape, no thin ends: end caps are rounded. One continuous tube.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxRibbonLoop`, work only there, save to `blender/BE_FxRibbonLoop.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxRibbonLoop_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
