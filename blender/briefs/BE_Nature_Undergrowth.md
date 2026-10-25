# BE Nature — undergrowth (APPROVED)

2026-10-24: after the owner approved cliffs/rocks and trees, this set was built at mesh stage. BushA, BushB and FlowerClump are each 60 triangles. See [preview](../review/BE_Nature_Undergrowth_mesh.png); export/placement await owner approval.

2026-10-24 continuation: owner explicitly approved "Yes, use those bushes and flowers" for the lobby gardens. Finish/export the approved shapes without remodeling, then upload and place in the lobby only.

STAGE: finish; mesh review gate passed.
References: `docs/reference/concepts-v1-2026-10-24/grassland-arena-v2.png` and `lobby-two-leaderboards-v3.png`. Sparse grouped planting, not noisy grass covering combat lanes.

BushA 4 x 2 x 3; BushB 5 x 2.4 x 4; FlowerClump 2 x 1.2 x 2 studs. **60 triangles maximum per template**. Bushes use grass pair #6FAE4A/#4C8A3A; clump uses dark green and restrained cream flowers. Broad readable silhouettes; no alpha leaf cards, high-frequency detail or thousands of unique objects. Preserve the ground texture as a separate plain-part surface treatment.

Deliver own .blend, script, one reference composite and measured report. No export at mesh stage.

## Shared build contract
- Follow `.claude/skills/map-style/styles/low-poly-nature.md`. Faceted flat-shaded natural silhouettes, two-tone surfaces, Plastic/SmoothPlastic in Roblox. No bevel soup, studs on new props, noisy textures, neon, rigs or animation.
- Palette: grass #6FAE4A / dark grass #4C8A3A; rock #8A8F99 / #5F6672; trunk #7A5236; path #B58A5A; optional single autumn accent #E0883A; water #4FA3C7; sky #CFE6F0. Use only the relevant pair on each mesh. No image textures at mesh stage.
- Future scene lighting (NOT applied at mesh stage): ShadowMap where supported; ClockTime 16.5, Brightness 2.5, Ambient #7D8FA0, OutdoorAmbient #A0B0C0; Atmosphere Density .3, Haze 1, Color #D6E8F0; Bloom .3; ColorCorrection Contrast .05. Preserve cyan portal and low-contrast textured-grass concept exception.
- Sizes below are Roblox W x H x D in studs. Blender 1 unit = 1 stud, Z up, face -Y. Origin at base center, Z minimum 0, unit scale and applied rotation. Separate named mesh per reusable variant. Flat normals, closed clean solids, no loose/degenerate geometry.
- Mesh stage only: save source + one composite preview + measured triangle/dimension report. No FBX, upload, baking, placement or other sets until approval. Preserve the current Blender scene in a separate saved backup/new scene; never clear someone else's scene.
- Read `blender/README.md`. The shared `model_tools.py` is for approved-base finishing; these are new static meshes, so do not call its bake/export pipeline now. Stop after the same step fails twice; preserve progress, do not rebuild from scratch.
