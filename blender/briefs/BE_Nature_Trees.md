# BE Nature — trees (APPROVED)

2026-10-24: owner approved the mesh preview ("actually i like the new trees"). RoundA/B/C are each 194 triangles; all three exports pass and are uploaded for arena placement. The original mesh-stage scope below records the first build checkpoint.

STAGE: mesh, only after cliffs/rocks approval. Do not run now.
Reference: `docs/reference/concepts-v1-2026-10-24/grassland-arena-v2.png`; latest lobby reference `lobby-two-leaderboards-v3.png` for smaller garden usage. Match oak-like broad clustered crowns and branching trunks; no imported old rejected tree or perfectly round ball canopy.

Three whole-tree templates (trunk + canopy total budget): RoundA 22 x 27 x 20, RoundB 20 x 25 x 18, RoundC 24 x 29 x 22 studs; **200 triangles each**. Broad, lean/split, and tall asymmetrical silhouettes respectively. Faceted connected crown clusters; two foliage tones #6FAE4A/#4C8A3A, trunk #7A5236 with a restrained darker trunk face. Random placement rotations/scales later; no regular grid and no new trees through combat paths. Keep all five arena placements until an approved area pass; lobby is later.

Deliver own .blend, script, one reference comparison composite and measured report. No rig/animation/export at mesh stage.

## Shared build contract
- Follow `.claude/skills/map-style/styles/low-poly-nature.md`. Faceted flat-shaded natural silhouettes, two-tone surfaces, Plastic/SmoothPlastic in Roblox. No bevel soup, studs on new props, noisy textures, neon, rigs or animation.
- Palette: grass #6FAE4A / dark grass #4C8A3A; rock #8A8F99 / #5F6672; trunk #7A5236; path #B58A5A; optional single autumn accent #E0883A; water #4FA3C7; sky #CFE6F0. Use only the relevant pair on each mesh. No image textures at mesh stage.
- Future scene lighting (NOT applied at mesh stage): ShadowMap where supported; ClockTime 16.5, Brightness 2.5, Ambient #7D8FA0, OutdoorAmbient #A0B0C0; Atmosphere Density .3, Haze 1, Color #D6E8F0; Bloom .3; ColorCorrection Contrast .05. Preserve cyan portal and low-contrast textured-grass concept exception.
- Sizes below are Roblox W x H x D in studs. Blender 1 unit = 1 stud, Z up, face -Y. Origin at base center, Z minimum 0, unit scale and applied rotation. Separate named mesh per reusable variant. Flat normals, closed clean solids, no loose/degenerate geometry.
- Mesh stage only: save source + one composite preview + measured triangle/dimension report. No FBX, upload, baking, placement or other sets until approval. Preserve the current Blender scene in a separate saved backup/new scene; never clear someone else's scene.
- Read `blender/README.md`. The shared `model_tools.py` is for approved-base finishing; these are new static meshes, so do not call its bake/export pipeline now. Stop after the same step fails twice; preserve progress, do not rebuild from scratch.
