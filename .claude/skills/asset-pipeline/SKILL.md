---
name: asset-pipeline
description: Get a Blender model or its animations into the Roblox game through Open Cloud uploads, Studio placement and the animation converter, with no manual Import 3D. Use when a Blender model, FBX, rig or animation needs uploading, inserting, orienting or wiring into code, or when animation IDs need registering.
---

# Asset pipeline

The full guide is [docs/asset-pipeline.md](../../../docs/asset-pipeline.md). Read it before you start; it holds the setup, the decision table, the rest-data dump script and the checks that caught real problems.

## Do this

1. Pick the animation path from the table at the top of the guide. Published IDs skip the converter, and Open Cloud imports always need `export_animations.py` because they don't keep animations.
2. Upload with `python scripts/upload_assets.py <Model> --only "*.fbx"`. The API key lives in the git-ignored `.env`; never paste it into chat or commit it.
3. Insert each asset with the Studio MCP `insert_asset`, remove the PackageLink, and check it from the side with a marker at -Z. Open Cloud imports arrive lying on their side: set the MeshPart rotation to identity, rotate the Root bone +90 degrees on X and put Root at the model pivot.
4. Rename the MeshPart to the Blender armature name in every variant, or root-bone motion is silently dropped.
5. Dump the rig's rest data into `scripts/rigs/roblox_rest.json`, run `export_animations.py`, upload the `.rbxmx` files, and register the IDs in the game config and [docs/animations.md](../../../docs/animations.md).
6. Record the asset and its anchors in [docs/asset-checklist.md](../../../docs/asset-checklist.md), then playtest: tracks load, bones move, root motion moves the whole model.

## Watch for

- The asset owner must be the experience owner; re-upload under the group before release.
- Every bone needs vertex weights or Roblox drops it on import.
- The Blender-to-Roblox axis mapping is in docs/vfx-spell-pipeline.md, step 6.
