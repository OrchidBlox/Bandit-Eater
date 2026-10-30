# FxStoneSpikes - mesh-stage brief

Template: `StoneSpikes` (will live at `ReplicatedStorage.Assets.PowerMoves.StoneSpikes`). Source: `blender/FxStoneSpikes.blend`.
Move: Earth E Stone Field: erupting stone spikes.
Reference image (approved anime-slick concept; match its shapes, sharp tapered tips and proportions, ignore the text and UI): docs/reference/move-concepts-v2-anime-slick-2026-10-30/Earth.png

- Final size (Roblox X x Y x Z studs): **6 x 6 x 6**.
- Triangle budget: **target 400, max 650**.
- Shape: A cluster of FIVE sharp angular stone spikes of different heights (about 6, 5, 4, 3.5 and 3 studs) erupting from one rough flat base, each a tall faceted pyramid-like shard leaning slightly outward, with hard planar facets and needle tips. Reads as a burst of rock spikes from the ground.

## Mesh-stage contract (all models)
- Style: anime-slick, NOT chunky cartoon: sharp tapered silhouettes with needle tips, hard planar facets, crisp edges, flat shading. Nothing soft, round or blobby unless the shape says so. It must still read at phone size.
- One joined static mesh, neutral white (one material). No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments. (Several separate shells joined into one object are fine for fans and clusters.)
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: if a scene with this name already exists, delete only that empty scene and recreate it; otherwise make a NEW scene named `FxStoneSpikes`, work only there, save to `blender/FxStoneSpikes.blend`. If Python `PIL` is missing, make the review composite with Blender render output and numpy instead. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/FxStoneSpikes_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
