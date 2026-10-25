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
