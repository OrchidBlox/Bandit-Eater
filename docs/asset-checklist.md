# Asset checklist

Every model, visual, and map object the game uses. Code depends only on the anchors listed here (names and attributes), so assets can be swapped without breaking gameplay. Update this file whenever a feature adds or changes an asset.

`ReplicatedStorage.Assets`, `Workspace.Map`, and Terrain are not managed by Rojo, so anything added there in Studio is kept.

| Asset | Where it goes | What the code needs | Required? | Status |
| --- | --- | --- | --- | --- |
| Arena and cover | `Workspace.BanditEaterPilot.Environment.GrasslandArena` | `ArenaFloor`, `BanditClearings`; cover uses collision on visible stones | V1 | 624 x 380 rectangular arena; width increased 1.2x from 520, depth unchanged; spawn, paths and cover positions follow the footprint; nine low rock formations |
| Sky platforms and bounds | `Workspace.BanditEaterPilot.Environment` | `Elevation = 180`, `LobbyLift = 60`; each region has `InvisibleBounds` | V1 | Arena floor Y=180, lobby floor Y=240. Six overlapping transparent colliders per region stop characters and dash casts; no ground sheet |
| Lobby | `Workspace.BanditEaterPilot.Environment.Lobby` | `LobbyFloor`, `PilotLobbySpawn`; separate from arena | V1 | Compact 156 x 112 sky plaza centered at (-20, 240, 12000), away from arena sightlines; spawn 28.2 studs from pad |
| Arena teleport pad | `Workspace.BanditEaterPilot.Environment.Lobby.ArenaTeleportPad` | Server checks volume above the pad at approximately (-20, 240.7, 11965.8); joins live round or queues between rounds | V1 | Simple smooth-plastic posts, narrow ARENA sign and low rectangular cyan-outlined platform |
| Lobby leaderboards | `Workspace.BanditEaterPilot.Environment.Lobby` | `Leaderboard`, `KOLeaderboard`; five `Row` parts on each, updated by server | V1 | Separate server wins and total server-player KOs; cosmetics kiosk removed and shop HUD hidden for now |
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

## Low-poly nature restyle — arena progress (2026-10-24)

The environment remains version 12. Approved cliffs, rocks and trees are installed in the arena through separate NatureDecor modules; the lobby now reuses the approved trees and rocks. Approved undergrowth is installed in the lobby gardens.

| Deliverable | Status |
| --- | --- |
| [Arena/lobby audit and prop schedule](low-poly-nature-audit.md) | Complete: sizes, triangle caps, palette and protected contracts |
| [Five Blender prop-set briefs](../blender/briefs/) | Cliffs/rocks and trees approved; undergrowth mesh review ready; stair trim and fence deferred |
| [Cliffs/rocks Blender source](../blender/BE_Nature_CliffsRocks_mesh.blend) | Four cliff modules and three rocks; owner approved silhouettes on 2026-10-24 |
| [Mesh review](../blender/review/BE_Nature_CliffsRocks_mesh.png) and [validation](../blender/review/BE_Nature_CliffsRocks_mesh.validation.json) | Seven meshes pass static budgets, dimensions, base origins and manifold checks; straight A/B interfaces match |
| [Protected-part baseline](reference/low-poly-nature/protected-parts-before.json) | All 52 protected parts checked against the original snapshots; no anchor rebuild |
| Roblox finish/export/upload and arena placement | Thirteen approved models uploaded to group 683974855; masters in ServerStorage.MapProps.LowPolyNature; old decoration in ServerStorage.PolishOld/Arena_Nature_v1. IDs/hashes in scripts/asset_ids.json |
| Arena trees | Five instances of three approved 194-triangle variants; two former path overlaps moved clear together with their existing colliders |
| Golden-hour lighting, phone screenshots and yellow-bandit/VFX readability | Applied and inspected on desktop and iPhone 17 Pro landscape/portrait. [Validation and limits](nature-arena-validation.md); prototype HUD clipping remains |
| [Undergrowth mesh review](../blender/review/BE_Nature_Undergrowth_mesh.png) | Two bushes and a flower clump, 60 triangles each; owner approved, exported, uploaded and installed across twelve lobby beds (48 bushes, 96 flower clumps) |
| Lobby restyle | Installed after owner requested the same treatment: six approved trees, six rocks, twelve beds, smooth warm paving and coordinated furniture. Two boards, cyan gate and protected anchors unchanged. [Validation](nature-lobby-validation.md) |

Floors, paths, spawn plates and collision bounds remain plain parts. A noncolliding textured Grass surface sits above the unchanged ArenaFloor. The nine arena cover centres remain the layout baseline. The cyan gate, two lobby boards, Elevation=180 and LobbyLift=60 are preserved.


## Inhale VFX - 2026-10-24

| Asset | Runtime location / ID | Status |
| --- | --- | --- |
| Blender open crescent | `ReplicatedStorage.Assets.Vfx.Inhale.Crescent` | Approved, exported, imported; model 93454476544369 / mesh 86147450968995; 1,080 triangles |
| Rounded puff PNG | `rbxassetid://71229989533127` | Group-owned, approved, rendered in Studio |
| Rounded star PNG | `rbxassetid://70777146536244` | Group-owned, approved, rendered in Studio |
| Client inhale presentation | `Workspace.PilotVfx.Inhale_<token>` | Server-signalled Start/Stop; full mesh + sprites tested: 22 parts/cast, max 6 casts; capture and cleanup pass |

[Implementation, sources and validation](inhale-vfx-implementation.md). Rings and sprites move toward the player; capture pop is separate from swallow/spit. Avatar animation deferred. The crescent uses a ring-center pivot (VFX exception to the character/prop base-pivot rule). Arena/lobby and gameplay values are unchanged.


## Hero Sprint run and footsteps - 2026-10-24

| Asset | Runtime location / ID | Status |
| --- | --- | --- |
| Hero Sprint R15 run | `rbxassetid://116051034967244`; `Shared.Config.Animations.RunId` | Rebuilt on original MrXen0 R15 rig 2026-10-25; Approved V5: 0.8-second loop at normal speed, Movement priority, alternating Footstep markers; live playback and server replication checked |
| Step cloud | Existing `rbxassetid://71229989533127`; client-created `LeftFoot/RightFoot.HeroSprintFootstep.Puff` | Marker-driven Emit(1), max two reused emitters per character; grounded running only |

[Animation registry](animations.md), [current Blender preview](../blender/review/BE_HeroSprint_MrXen0.gif), and [validation/limits](hero-sprint-validation.md). Current replacement checked actual input, marker alternation, server receipt, idle/jump transitions and live visuals. Earlier controller death/respawn/teardown checks are documented separately. Owner visual acceptance is pending. No new player mesh, movement speed, collision or gameplay changes.

## Movement transitions - 2026-10-25

- [x] Start, Stop, Takeoff, LandRun and LandIdle authored on canonical MrXen0 rig; V5 preserved.
- [x] Five group-owned animation assets uploaded and configured; existing white puff reused for grounded landing contacts.
- [x] Fresh Studio keyboard tests, interruption tests, death/respawn and controller cleanup passed.
- [x] Project animation skill and its Codex mirror require applicable transitions; template mirrors updated too.
- [ ] Owner review of transition feel in normal gameplay; multi-client and broad avatar/slope coverage remain.

[Current IDs](animations.md), [motion preview](../blender/review/BE_MovementTransitions.gif), [validation and limits](movement-transitions-validation.md).
