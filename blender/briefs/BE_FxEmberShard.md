# FxEmberShard - mesh-stage brief

Template: `EmberShard` (will live at `ReplicatedStorage.Assets.PowerMoves.EmberShard`). Source: `blender/FxEmberShard.blend`.
Move: Fire impacts: flung dark rock and ember shards.
Reference image (approved anime-slick concept; match its flame shapes, sharp tapered tips and proportions, ignore the text and UI): docs/reference/move-concepts-v2-anime-slick-2026-10-30/Fire.png

- Final size (Roblox X x Y x Z studs): **1 x 1.8 x 0.7**.
- Triangle budget: **target 40, max 80**.
- Shape: A single sharp irregular shard: a flat angular splinter with a pointed tip, three or four facets, slightly bent. Simple and crisp, reads as a flung chunk of cracked rock.

## Mesh-stage contract (all models)
- Style: anime-slick, NOT chunky cartoon: sharp tapered silhouettes with needle tips, hard planar facets, crisp edges, flat shading. Nothing soft, round or blobby unless the shape says so. It must still read at phone size.
- One joined static mesh, neutral white (one material). No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxEmberShard` with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: BLENDER 5.2.2 CRASH TRAP), work only there, and save the finished mesh with `bpy.data.libraries.write('blender/FxEmberShard.blend', {obj}, fake_user=True)` (the object only, never the scene). No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/FxEmberShard_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
