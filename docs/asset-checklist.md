# Asset checklist

Every model, visual, and map object the game uses. Code depends only on the anchors listed here (names and attributes), so assets can be swapped without breaking gameplay. Update this file whenever a feature adds or changes an asset.

`ReplicatedStorage.Assets`, `Workspace.Map`, and Terrain are not managed by Rojo, so anything added there in Studio is kept.

| Asset | Where it goes | What the code needs | Required? | Status |
| --- | --- | --- | --- | --- |
| Arena and cover | `Workspace.BanditEaterPilot.Environment.GrasslandArena` | `ArenaFloor`, `BanditClearings`; cover uses collision on visible stones | V1 | 546-stud arena, darker studded grass; three rock formations about 2.7-3.3 studs tall |
| Lobby | `Workspace.BanditEaterPilot.Environment.Lobby` | `LobbyFloor`, `PilotLobbySpawn`; separate from arena | V1 | Studded plaza, darker grass gardens, part-built trees |
| Arena teleport pad | `Workspace.BanditEaterPilot.Environment.Lobby.ArenaTeleportPad` | Server checks volume above the pad at (-20, 0.2, 375); joins live round or queues between rounds | V1 | Smooth-plastic frame/base with glass and light accents |
| Lobby stations | `Workspace.BanditEaterPilot.Environment.Lobby` | `CosmeticsKiosk`, `Leaderboard`; board rows updated by server | V1 | Smooth-plastic shop; studded leaderboard |
| Cloud panorama sky | `Lighting.PilotCloudSky` (client) | Six texture IDs in `PilotSkyConfig.luau`; `PilotSkyController` switches after successful preload | V1 | Corrected Roblox face orientation; all 12 cube joins checked. Existing sky stays visible until all textures load. Manifest in `assets/sky/cloud-panorama-v2` |
| Six power bandits | `Workspace.BanditEaterPilot` | Model with `HumanoidRootPart` as PrimaryPart; `PowerId`, `Variant` attributes | V1 | Yellow part dummies with power tells |
| Rare / mystery bandits | `Workspace.BanditEaterPilot` | Same model contract; rare or mystery Variant | V1 | Labeled dummy variants |
| Fill bots | `Workspace.BanditEaterPilot` | Rooted anchored model moved by server | V1 | Part dummies |
| Spit star | `Workspace.BanditEaterPilot.SpitStar` | Server-generated projectile; fixed combat dimensions across colors | V1 | Five-point part effect |
| Shield, swallow, moves and telegraphs | `Workspace.BanditEaterPilot.Effect` | Noncolliding, nonqueryable, short-lived effects | V1 | Colored primitive effects |
| HUD, results and cosmetics | `PlayerGui.PilotHUD` | `PilotState` presentation and `PilotInput` requests | V1 | Plain functional UI, custom replacement planned |

## Imported model rules

- Pivot at the bottom centre between the feet, facing -Z (the pivot's LookVector).
- Set the pivot through `PrimaryPart.PivotOffset`: setting `WorldPivot` and then `PrimaryPart` switches to the part's own pivot.
- FBX imports can arrive rotated 90°; check that the mesh part is upright before fixing the pivot.
- Colours only survive import as a texture (a palette PNG embedded in the FBX), not as Blender material colours.

## Low-poly nature restyle — mesh approval checkpoint (2026-10-24)

The live environment remains version 12. This checkpoint supplies the audit, briefs and first Blender mesh set; it does not mark the map restyle as installed.

| Deliverable | Status |
| --- | --- |
| [Arena/lobby audit and prop schedule](low-poly-nature-audit.md) | Complete: sizes, triangle caps, palette and protected contracts |
| [Five Blender prop-set briefs](../blender/briefs/) | Cliffs/rocks built for review; trees, undergrowth, stair trim and fence deferred |
| [Cliffs/rocks Blender source](../blender/BE_Nature_CliffsRocks_mesh.blend) | Four cliff modules and three rocks; awaiting owner silhouette approval |
| [Mesh review](../blender/review/BE_Nature_CliffsRocks_mesh.png) and [validation](../blender/review/BE_Nature_CliffsRocks_mesh.validation.json) | Seven meshes pass static budgets, dimensions, base origins and manifold checks; straight A/B interfaces match |
| [Protected-part baseline](reference/low-poly-nature/protected-parts-before.json) | All 52 protected parts rechecked unchanged after mesh construction |
| Roblox finish/export/upload and arena placement | Deferred until mesh approval; archive replaced decoration in ServerStorage.PolishOld and use one recording per area |
| Golden-hour lighting, phone screenshots and yellow-bandit/VFX readability | Deferred to installed arena review; Blender preview is not an in-game validation |
| Lobby restyle | Deferred until arena approval; keep two boards, cyan gate, floors and teleport/spawn anchors |

No mesh IDs are assigned yet. Preserve textured-grass intent without replacing plain-part floors. The existing nine arena rock placements remain the cover-layout baseline.
