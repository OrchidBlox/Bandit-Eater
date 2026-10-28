# BE_FxBladeChunky - mesh-stage brief

Template: `BladeChunky` (will live at `ReplicatedStorage.Assets.PowerMoves.BladeChunky`). Source: `blender/BE_FxBladeChunky.blend`.
Move: Sword R Blade Storm: chunky blade.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/sword.png (row R BLADE STORM, RELEASE panel)

- Final size (Roblox X x Y x Z studs): **2.2 x 7 x 1.2**.
- Triangle budget: **target 500, max 900**.
- Shape: One fat stylised sword like the white orbiting blades in the concept: thick rounded blade with a soft blunt tip, a short chunky crossguard, a rounded grip and a round pommel. Blade about 1.4 wide and 0.7 thick, guard 2.2 wide. Axis: tip toward Roblox +Y, grip toward -Y. Two material slots: `Blade` and `Hilt`.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxBladeChunky`, work only there, save to `blender/BE_FxBladeChunky.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxBladeChunky_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
