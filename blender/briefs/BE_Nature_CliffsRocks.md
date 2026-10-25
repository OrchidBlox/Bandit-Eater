# BE Nature — cliffs and rocks

STAGE: **mesh**. NOW: this is the ONE approved build set. Stop with a review image for owner approval. Do not start foliage, stairs, fence, lobby, finishing, uploading or placement.

Reference: `docs/reference/concepts-v1-2026-10-24/grassland-arena-v2.png`. Study the broad fractured vertical cliff faces and low, broad terrace-shaped rocks. This is a stylized geological facade, not rounded pebbles, an icosphere pile, a regular cuboid or spiky mountain noise.

| Mesh (prefix BE_Nature_) | W x H x D studs | Max tris |
| --- | --- | ---: |
| CliffStraightA | 48 x 28 x 12 | 600 |
| CliffStraightB | 48 x 24 x 12 | 600 |
| CliffCorner | 26 x 30 x 26 | 600 |
| CliffEnd | 12 x 24 x 12 | 600 |
| RockSmall | 12 x 3 x 8 | 80 |
| RockMedium | 16 x 3.3 x 11 | 160 |
| RockLarge | 20 x 3.6 x 13 | 250 |

Cliffs: large angled face plates, a few shallow fracture channels and uneven/chamfered upper silhouette. Keep left/right joining interfaces planar and compatible, exact 48-stud module width, closed back/bottom. A/B need visibly different profiles; demonstrate A-B-A joining without an open crack. Corner wraps the same language over two exposed sides. End is a narrower termination. Grass caps remain separate existing plain parts; do not bake grass onto these stone assets.

Rocks: three distinct irregular broad silhouettes with flattened foot and readable upper planes, not just uniform resizes of one sphere. Use rock #8A8F99 plus shadow #5F6672 only. Maximum height 3.6 studs protects jumpability and sightlines. Do not add tall pinnacles.

Deliver `blender/BE_Nature_CliffsRocks_mesh.blend`, reproducible script under `blender/scripts/`, `blender/review/BE_Nature_CliffsRocks_mesh.png` (one compact composite with lineup, tiled A-B-A join detail and reference inset), and JSON/report with per-mesh tris, actual bounds, applied transforms, origin-at-base and topology checks. Include a 5-stud yellow scale marker as a clearly labeled review-only object, excluded from asset validation. Save a backup of the preexisting live Blender scene first. No FBX export. The first image must clearly show shape, not hide it behind dramatic lighting.

## Shared build contract
- Follow `.claude/skills/map-style/styles/low-poly-nature.md`. Faceted flat-shaded natural silhouettes, two-tone surfaces, Plastic/SmoothPlastic in Roblox. No bevel soup, studs on new props, noisy textures, neon, rigs or animation.
- Palette: grass #6FAE4A / dark grass #4C8A3A; rock #8A8F99 / #5F6672; trunk #7A5236; path #B58A5A; optional single autumn accent #E0883A; water #4FA3C7; sky #CFE6F0. Use only the relevant pair on each mesh. No image textures at mesh stage.
- Future scene lighting (NOT applied at mesh stage): ShadowMap where supported; ClockTime 16.5, Brightness 2.5, Ambient #7D8FA0, OutdoorAmbient #A0B0C0; Atmosphere Density .3, Haze 1, Color #D6E8F0; Bloom .3; ColorCorrection Contrast .05. Preserve cyan portal and low-contrast textured-grass concept exception.
- Sizes below are Roblox W x H x D in studs. Blender 1 unit = 1 stud, Z up, face -Y. Origin at base center, Z minimum 0, unit scale and applied rotation. Separate named mesh per reusable variant. Flat normals, closed clean solids, no loose/degenerate geometry.
- Mesh stage only: save source + one composite preview + measured triangle/dimension report. No FBX, upload, baking, placement or other sets until approval. Preserve the current Blender scene in a separate saved backup/new scene; never clear someone else's scene.
- Read `blender/README.md`. The shared `model_tools.py` is for approved-base finishing; these are new static meshes, so do not call its bake/export pipeline now. Stop after the same step fails twice; preserve progress, do not rebuild from scratch.
