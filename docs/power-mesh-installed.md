# Approved move meshes installed - 2026-10-26

All ten templates are installed in `ReplicatedStorage.Assets.PowerMoves`. The owner approved the original WindFront and all seven new shapes. Rock and Slash reuse approved geometry. Imports are upright, centered, noncolliding MeshParts. The seven new FBX imports were normalized from 100x scale. Sword, MasterSword, Wave and ShadowOrb retain palette textures.

| Template | Uploaded model | Triangles |
| --- | --- | --- |
| Droplet | 131415644286650 | 528 |
| Flame | 102251088549327 | 1250 |
| Leaf | 102739312973688 | 528 |
| MasterSword | 123850029359018 | 1548 |
| ShadowOrb | 95185057003645 | 924 |
| Sword | 113097489818221 | 308 |
| Wave | 117701836399171 | 1396 |
| WindFront | 127594192425058 | See Blender source |
| Rock | 136137335673078 | Reused approved rock |
| Slash | 93454476544369 | 1080; reused inhale crescent |

Leaf and MasterSword exceed their initial brief estimates (300 and 1500 triangles); actual counts above replace those estimates. Finished sources: `blender/finished/BE_PowerMesh_*.blend`; FBX and palette exports: `blender/export/`; measured export reports: `blender/review/BE_PowerMesh_*_export.json`. Uploaded IDs and content hashes are recorded in `scripts/asset_ids.json`.

Fresh Studio Play exercised all 36 effects with the installed library: zero missing-mesh fallbacks, zero errors, peak 31 parts and successful cleanup. All 72 V2 standing/moving animation tracks loaded. These checks do not replace owner visual review or a two-client playtest.
