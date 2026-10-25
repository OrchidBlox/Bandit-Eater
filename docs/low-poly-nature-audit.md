# Low-poly nature rollout — approval checkpoint 1

2026-10-24. User-authorized order: audit and briefs -> ONE cliffs/rocks mesh set -> owner approval -> finish/upload and arena placement -> phone/readability review -> other sets -> lobby. Only the first mesh set is authorized for construction in this pass.

## Current environment (live server, version 12)

| Area | Existing content | Implication |
| --- | --- | --- |
| Arena | 624 x 380 floor, Y=180; 959 BaseParts, 0 MeshParts, 952 stud-topped parts | Current appearance is block/stud geometry, not the selected faceted nature style |
| Arena perimeter | 41 WeatheredCliff faces, 41 grass caps, 5 continuous cores, 4 corners | Replace decorative faces only later; keep structural island edges, cores and every InvisibleBounds |
| Arena cover | Nine rock clusters, each three stones; current visual tops about 2.9–3.6 studs | Three low reusable rock templates, instanced at current nine placements; no taller obstacles |
| Arena greenery | Five GrasslandOak trees (roughly 23–27 wide, 26–30 tall), 330 grass-blade parts | Three tree silhouettes and small bushes can reduce part count; keep lanes open |
| Lobby | 156 x 112 floor at Y=240, center (-20,240,12000); 1,794 BaseParts, 0 MeshParts; 513 paving tiles | Preserve footprint and roomier-lobby composition adapted to the approved compact layout |
| Lobby decor | Four trees, six rock clusters, ten planters, six benches, 48 fence posts and 8 rails | Reuse arena natural props later; do not restore cosmetics shop |
| Functional lobby | Two live board models; small cyan gate; spawn 28.2 studs from pad | Keep all named boards, rows, signs and teleport/spawn anchors |
| Lighting | ClockTime 14, Brightness 2.2; Atmosphere Density .23 / Haze .7 | Golden-hour values remain deferred until the first arena area is approved for placement |

Full baseline: [protected-anchor snapshot](reference/low-poly-nature/anchor-audit-before.json). No source or Studio environment changes made by this restyle checkpoint.

Detailed [protected-part baseline](reference/low-poly-nature/protected-parts-before.json): all 52 protected parts were rechecked unchanged after the first mesh set was built.

## First mesh set delivered for approval

Source: [BE_Nature_CliffsRocks_mesh.blend](../blender/BE_Nature_CliffsRocks_mesh.blend). [Composite review](../blender/review/BE_Nature_CliffsRocks_mesh.png) includes the arena concept, cliff lineup, rock lineup, a yellow five-stud scale gauge and an A-B-A wall join. This is a Blender mesh review, not an installed arena screenshot.

Measured triangles: StraightA 128/600, StraightB 128/600, Corner 76/600, End 52/600, SmallRock 46/80, MediumRock 58/160, LargeRock 64/250. All seven have exact brief dimensions, base-centred origins, applied transforms, flat shading, two materials, closed manifold geometry and no degenerate faces. Straight A/B end sections match with zero gap at 48-stud spacing. See the [validation report](../blender/review/BE_Nature_CliffsRocks_mesh.validation.json).

These technical checks do not establish visual approval. Finish/export, Roblox import scale/orientation, palette retention, collision, golden-hour lighting, phone screenshots and bandit/VFX readability remain untested and deferred. No other prop set has been constructed.

## Prop schedule and budgets

All dimensions W x H x D, in studs. Budget is triangles per template, not per area. Arena first; lobby reuse later. Current layout wins over illustration layout: no new raised bandit platforms, no move of paths, bounds or spawns.

| Set / template | Size | Triangle cap | Palette | Area / placement intent |
| --- | --- | ---: | --- | --- |
| CliffStraightA | 48 x 28 x 12 | 600 | #8A8F99 / #5F6672 | Arena outer decorative facade, compatible flat end interfaces |
| CliffStraightB | 48 x 24 x 12 | 600 | same | Lower terrace variation, same modular width |
| CliffCorner | 26 x 30 x 26 | 600 | same | Four corners, dress existing core without changing it |
| CliffEnd | 12 x 24 x 12 | 600 | same | Terminations near viewing opening; never block its sightline |
| RockSmall | 12 x 3.0 x 8 | 80 | same | Existing cover / later scaled lobby planters |
| RockMedium | 16 x 3.3 x 11 | 160 | same | Existing cover |
| RockLarge | 20 x 3.6 x 13 | 250 | same | Existing cover, broad low silhouette |
| TreeRoundA | 22 x 27 x 20 | 200 | #6FAE4A / #4C8A3A, #7A5236 trunk | Existing arena trees; broad asymmetric canopy |
| TreeRoundB | 20 x 25 x 18 | 200 | same | Leaning split crown; lobby reuse at .7–.8 scale |
| TreeRoundC | 24 x 29 x 22 | 200 | same | Taller irregular crown; no cone-pine substitution for reference oaks |
| BushA / BushB | 4 x 2 x 3 / 5 x 2.4 x 4 | 60 each | grass pair | Existing planting beds and perimeter only |
| FlowerClump | 2 x 1.2 x 2 | 60 | dark grass + restrained cream | Sparse, outside gameplay lanes |
| StairCheek | 0.8 x 4 x 10 | 100 | rock pair | Decorative stair side; only if an existing perimeter transition needs it |
| StairRiserTrim | 10 x 0.7 x 0.3 | 40 | rock pair | Future decorative facing; actual steps/treads remain plain Parts |
| FenceSection | 12 x 4 x 1 | 120 | #7A5236 / #5B3D29 | Existing lobby fence line after arena approval |
| FencePost | 1 x 4 x 1 | 40 | same | Repeated ends/corners |

Only cliffs + rocks are being built now. Stair trims do not authorize new routes or raised floors. Three rock templates do not reduce the current nine cover placements.

## References and exceptions

- Arena: `docs/reference/concepts-v1-2026-10-24/grassland-arena-v2.png`: broad fractured cliff planes, shallow ledge-like rocks, grouped foliage, muted ground, legible yellow bandits.
- Lobby: `lobby-spacious-v2.png` for the open-plaza composition; `lobby-two-leaderboards-v3.png` is authoritative for two board areas and no cosmetics.
- The newer explicit low-poly-nature style overrides old workflow text saying blocky simulator. Budget caps from the style override generic 800/4000 or 1500–4000 suggestions.
- Keep the cyan sci-fi gate as the deliberate accent. No new neon nature props.
- Ground has native studs/Plastic in the current build; the concept's textured grass is not yet a matching mapped grass texture. In the later placement pass, preserve plain gameplay floors and use separately approved low-contrast decorative grass dressing without altering protected floor anchors. No heavy/noisy prop textures.

## Protected contracts

Do not modify, rename, reparent or delete: ArenaFloor, BanditClearings (including marker positions), LobbyFloor, PilotLobbySpawn, ArenaTeleportPad, Leaderboard, KOLeaderboard, every InvisibleBounds and its six collider parts. Keep Elevation=180 and LobbyLift=60. Floors, paths, spawn plates, island edge/collision structure stay plain Parts. Current floor sizes, positions and teleport distance are not a restyle target.

## Later approved placement procedure

1. Save the Studio place before any mutations. No place mutation is required at this mesh checkpoint.
2. Finish only approved meshes. Read the asset-pipeline skill when available and `docs/asset-pipeline.md`; export/upload static assets, test one orientation/scale/pivot first. Material colours do not survive FBX reliably: use two palette-separated mesh components with Roblox Color, or the approved pipeline's tiny palette atlas if required (no noisy texture). Resolve this at finish, not mesh stage.
3. Store masters in ServerStorage.MapProps. One arena-local placement script and one ChangeHistoryService recording; move replaced decoration into ServerStorage.PolishOld/Arena_<revision>, never delete it. Lobby receives its own later recording and backup.
4. Preserve existing collision support while replacing render decoration; no double collision or new lane blockers. Give installed decoration SourceAssetId/template metadata. Update code's environment builder to reattach approved decor on subsequent rebuilds without touching anchors; do not use an environment rebuild that replaces protected instances for a decorative restyle.
5. Apply the style values: ClockTime 16.5, Brightness 2.5, Ambient #7D8FA0, OutdoorAmbient #A0B0C0; Atmosphere Density .3/Haze 1/Color #D6E8F0; Bloom .3, Contrast .05; ShadowMap if supported by the running engine. Existing cloud sky stays unless readability review calls for a separately approved change.
6. Screenshot approach and combat view at desktop and phone landscape/portrait. Compare yellow bandit outline, cyan portal, bubble shield, telegraphs, star spit and chunky-cartoon VFX against muted ground. Reduce excessive bloom after review if it erases these shapes; no gameplay hitbox changes.
7. Recompare the anchor snapshot, test walk-on teleport and collision, then request area approval before lobby rollout.

## Skill availability

The local `ai-map-building` and `map-style` skills were read. A standalone `asset-pipeline/SKILL.md` and `codex-workflow/SKILL.md` were not found in the checked repository/user skill locations; their repository workflow documents are present and read. Upload is outside this checkpoint; resolve the missing pipeline skill before that step rather than silently claiming it was used.
