# BE_FxGustCurl - mesh-stage brief

Template: `GustCurl` (will live at `ReplicatedStorage.Assets.PowerMoves.GustCurl`). Source: `blender/BE_FxGustCurl.blend`.
Move: Wind Q Gust: curled air projectile.
Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): docs/reference/move-concepts-v1-2026-10-26/wind.png (row Q GUST, RELEASE panel)

- Final size (Roblox X x Y x Z studs): **3 x 3 x 3.6**.
- Triangle budget: **target 600, max 1000**.
- Shape: REDO (v1 came out as a faceted lumpy ball, reject that). A clean curled gust: build it from smooth parts, not by displacing a sphere. A plump smooth teardrop core (a UV sphere stretched along travel, subdivision-smoothed, smooth shading) wrapped by TWO thick rounded spiral tubes (bevelled round curves, about 0.55 stud diameter, each making about 1.25 turns around the core and tapering to rounded tips) that sweep back and flow into one short fat curl trailing behind (toward +Z). Clear, elegant spiral lines like a cartoon wind swirl; all surfaces smooth-shaded with soft rounded edges, no flat facets, no spikes, one joined mesh.

## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `FxGustCurl`, work only there, save to `blender/BE_FxGustCurl.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_FxGustCurl_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
