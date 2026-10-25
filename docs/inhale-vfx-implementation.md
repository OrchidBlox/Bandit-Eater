# Inhale VFX implementation

Owner request: implement the approved inhale concept using Blender and VFX images, with player animation deferred. Reference: [concept](reference/inhale-vfx-v1.png). Chunky-cartoon VFX style applies.

Scope: client-only open mint crescent rings, white puff/rounded-star image sprites moving inward, small capture pop; server-authoritative Start/Stop signals tied to existing inhale. Preserve hold-F, 19-stud range, facing and line-of-sight checks, pull motion, .7-second minimum capture, 2-second maximum hold, 3-second cooldown, swallow/spit separation. No player animation or avatar/mouth edits. No arena/lobby changes.

Implementation target: at most 4 hero rings with optional shade shells, 16 small sprite carriers, 2 ribbon beams, 0 lights; total <40 parts and <12 beams per caster. Shared kit + chunky-cartoon helpers; client cleanup on stop, death, removal, timeout, and controller teardown; distance culling and concurrency cap. All VFX parts anchored, noncolliding, nonqueryable and non-touchable. Server ignores client attempts to fire the presentation remote. Client validates payloads. Assets group-owned, imported templates in ReplicatedStorage.Assets.Vfx.Inhale; config stores image IDs.

Test: lint/build, real hold/release/capture input, observe inward movement, runtime part budget and cleanup, all assets load, phone read, protected map unchanged. Missing assets fail quietly with no gameplay dependency. Commit only owned changes, preserving other sessions' hunks; no push.

## Current status - 2026-10-24

Owner approved the mesh; finish/export/upload/import and full-effect Studio checks are complete. [Mesh preview](../blender/review/BE_Inhale_mesh.png), [Blender source](../blender/BE_Inhale_mesh.blend), and [validation](../blender/review/BE_Inhale_mesh.validation.json).

- Crescent: 4 x 4 x 0.52 studs, 1,080 triangles, one neutral-white material, smooth shaded, closed manifold, centered pivot; no rig or animation. Runtime template installed at `ReplicatedStorage.Assets.Vfx.Inhale.Crescent`; original import retained in `ServerStorage.VfxImports.BE_Inhale_Crescent`.
- Puff image: `rbxassetid://71229989533127`; star image: `rbxassetid://70777146536244`. Both owned by Orcano Studios group 683974855, Open Cloud reports Approved/Active, and both rendered (`ImageLabel.IsLoaded = true`) in fresh Studio Play.
- PNG sources: `blender/export/textures/BE_Inhale_Puff.png` and `BE_Inhale_Star.png`. [Generation prompts](../blender/briefs/BE_Inhale_textures.md). 1254 x 1254 RGBA; original generated transparency retained.
- Inhale uses 4 crescent bodies + 4 shade shells + 14 sprite carriers = 22 parts when the mesh is installed, 0 beams/emitters/lights. Max 6 simultaneous casters within 180 studs; hard 2.4-second lifetime.
- Without the mesh template, the image-only fallback works (14 parts). No fallback changes to gameplay.

### Validation completed before mesh import

Selene: 0 errors/warnings/parse errors using cached Roblox API. Rojo build passed. Fresh Studio Play confirmed normal controller startup (4 shared connections), portal entry, actual F press/release producing server Start/Stop with matching tokens, and a yellow Water bandit captured from about 10 studs with `Captured=true`. No avatar animation was added.

Runtime fallback checks: release, 0.28-second capture pop, 2.4-second timeout, death, character removal, and stop-before-start handling all cleaned to 0 active effects and 0 parts. Controller teardown reduced connections from 4 to 0; restart restored 4 without per-cast connections. Peak observed parts was 14 because the mesh is not imported yet. Image preloading uses ImageLabel instances: generic asset-ID string preloads reported Failure despite the same images rendering successfully.

Existing Studio API-save warnings and asset 203785492 type mismatch are unrelated.


### Approved full-effect validation

- Model asset `93454476544369`, contained mesh `rbxassetid://86147450968995`, uploaded to group 683974855. [Finished source](../blender/BE_Inhale.blend), [FBX](../blender/export/BE_Inhale_Crescent.fbx), [export validation](../blender/review/BE_Inhale_export.validation.json).
- Studio import measured 4 x 4 x 0.52 studs, plane XY/depth Z. Authored ring origin is -0.308546543 studs on imported local X from the box center. Template PivotOffset is this translation; the effect scales the offset with each ring to prevent off-center spin. Import's PackageLink removed; no imported scripts. Parts are anchored, noncolliding, nontouchable, nonqueryable, and cast no shadow.
- Neon mint body with a smooth-plastic teal shade shell; all fourteen PNG sprites loaded in the full scene. A staged three-quarter preview in the actual grass arena confirmed chunky crescents, white puffs/stars, and yellow bandits remain distinct. Preview uses an existing avatar pose only; no new animation was made.
- Fresh Play + actual F input produced matching server Start/Stop tokens and `Captured=true` on a real bandit. Measured 22 parts per cast, 6 during capture pop, then 0. No beams or emitters. Release, capture, timeout, death and removal cleanup passed with meshes installed.
- Six simultaneous casters measured 132 total parts; a seventh was culled. Killing/removing two reduced active effects from 6 to 4 and parts from 132 to 88. Controller teardown returned 0 parts/0 connections; restart restored exactly 4 shared connections. No VFX errors in Output. Selene and Rojo passed after the pivot/material changes.
- Protected arena/lobby snapshot unchanged. Temporary review characters, camera scripts and test hooks existed only in Play and were removed by stopping Play. Studio returned to Edit and the save shortcut completed after asset installation.
- Phone-specific emulation remains unverified: desktop automation reported intervening user input twice while opening the device picker, so it was not forced. Desktop visual inspection passed; mobile performance/visual tuning should be checked on device.

### Restore the Studio-only template in another place

`ReplicatedStorage.Assets` is intentionally not Rojo-managed. Insert model 93454476544369 into ServerStorage.VfxImports, remove its PackageLink, clone the contained MeshPart to `ReplicatedStorage.Assets.Vfx.Inhale.Crescent`, and set Size=(4,4,.52), CFrame=identity, PivotOffset=CFrame.new(-.308546543,0,0), TextureID="", Color=white. Set Anchored=true and CanCollide/CanTouch/CanQuery/CastShadow=false. Set SourceAssetId=93454476544369. The client applies color/material and position. Keep the original imported model in ServerStorage for provenance. Without this template, sprites still work and gameplay is unaffected.
