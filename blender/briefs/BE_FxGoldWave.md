# FxGoldWave - mesh-stage brief

Template: `GoldWave` (will live at `ReplicatedStorage.Assets.PowerMoves.GoldWave`). Source: `blender/FxGoldWave.blend`.
Move: Master Sword R Grand Cleave: the wide golden wave.
Reference image (approved anime-slick concept; match its shapes, sharp tapered tips and proportions, ignore the text and UI): docs/reference/move-concepts-v2-anime-slick-2026-10-30/Sword_Sword.png

- Final size (Roblox X x Y x Z studs): **14 x 5 x 7**.
- Triangle budget: **target 500, max 800**.
- Shape: A wide sharp wave of light: a crescent wall about 14 studs wide curving forward at both ends, with a row of THIRTEEN sharp upright blade spikes along its front edge (taller in the middle, about 5 studs), hard planar facets, thin (about 1 stud) body.

## Mesh-stage contract (all models)
- Style: anime-slick, NOT chunky cartoon: sharp tapered silhouettes with needle tips, hard planar facets, crisp edges, flat shading. Nothing soft, round or blobby unless the shape says so. It must still read at phone size.
- One joined static mesh, neutral white (one material). No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments. (Several separate shells joined into one object are fine for fans and clusters.)
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: if a scene with this name already exists, delete only that empty scene and recreate it; otherwise make a NEW scene named `FxGoldWave` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/FxGoldWave.blend', {obj}, fake_user=True)` (the object only, never the scene). If Python `PIL` is missing, make the review composite with Blender render output and numpy instead. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/FxGoldWave_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
