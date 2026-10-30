# FxCometTail - mesh-stage brief

Template: `CometTail` (will live at `ReplicatedStorage.Assets.PowerMoves.CometTail`). Source: `blender/FxCometTail.blend`.
Move: Fire Q Fireball and R Meteor Strike: the swept flame wake.
Reference image (approved anime-slick concept; match its flame shapes, sharp tapered tips and proportions, ignore the text and UI): docs/reference/move-concepts-v2-anime-slick-2026-10-30/Fire.png

- Final size (Roblox X x Y x Z studs): **3.2 x 3.2 x 10**.
- Triangle budget: **target 600, max 900**.
- Shape: A swept comet flame: a rounded pointed head at the front (travel direction is Roblox -Z) trailing back (+Z) into FIVE long tapered flame streams of different lengths (the longest about 10 studs) that flow and slightly twist like fire streaming in wind, every stream ending in a needle tip. Hard planar facets, sharp, speed-lined silhouette (the opposite of a round fireball). The head interior is hollow-free solid so a ball can sit inside it.

## Mesh-stage contract (all models)
- Style: anime-slick, NOT chunky cartoon: sharp tapered silhouettes with needle tips, hard planar facets, crisp edges, flat shading. Nothing soft, round or blobby unless the shape says so. It must still read at phone size.
- One joined static mesh, neutral white (one material). No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxCometTail`, work only there, save to `blender/FxCometTail.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/FxCometTail_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
