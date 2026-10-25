# Arena nature integration validation — 2026-10-24

Cliffs/rocks and trees are approved, uploaded and placed. Undergrowth remains a mesh preview. Lobby geometry is untouched; this is not approval of the entire map restyle.

## Installed and preserved

- Ten model assets belong to experience-owner group 683974855. All FBX round trips pass; source mesh shapes and source-blend hashes are unchanged. Studio imports preserve the expected dimensions, upright axes, base pivots and separate flat-colour components.
- Arena: 41 cliff facades, four corner dressings, two end pieces, nine low rocks and five trees. Facade base meshes collide so the visible walls cannot be walked through.
- 98 original roots are archived in ServerStorage.PolishOld/Arena_Nature_v1: 41 old cliff faces, 41 old grass caps, nine rock models, five tree models and two replaced tree colliders.
- Tree variants have 194 triangles each. Two original bases overlapped paths; only those two move, about 5.93 studs, with their corresponding colliders. Five live tree colliders remain. Closest trunk clearance is 3.52 studs from path edges.
- All 52 protected parts match the pre-placement snapshot: floors, spawn, teleport pad, boards, clearing markers and all bounds. Elevation=180 and LobbyLift=60. Current 624 x 380 arena and 156 x 112 lobby dimensions are retained.
- Ground/floors, paths, spawn plates, structural wall cores and grass caps stay plain parts. Textured Grass overlay is noncolliding/nonqueryable and below paths.
- Measurements: [installed validation JSON](reference/low-poly-nature/arena-installed-validation.json).

## Lighting and visual review

ClockTime16.5, Brightness2.5, Ambient#7D8FA0, OutdoorAmbient#A0B0C0, AtmosphereDensity0.3/Haze1/Color#D6E8F0, Bloom0.3 and Contrast0.05. Current Roblox uses LightingStyle.Soft plus PrioritizeLightingQuality=true for the style's older ShadowMap intent ([Roblox unified-lighting announcement](https://devforum.roblox.com/t/let-there-be-unified-light-unified-lighting-is-fully-live/3401512)). The original cloud sky remains.

Desktop and iPhone17Pro landscape/portrait were inspected. Game ScreenOrientation is Sensor. The yellow Fire bandit remains distinct against green grass and grey cliffs. Existing cyan shield, orange pulse and white-hit effect shapes remain visible; samples used the existing Combat.Effect function with temporary 35-second lifetime, not new gameplay effects. They were confined to Play and removed when Play stopped.

- [Landscape phone sample](reference/low-poly-nature/arena-phone-landscape.png)
- [Portrait phone sample](reference/low-poly-nature/arena-phone-portrait.png)
- [Arena with approved trees](reference/low-poly-nature/arena-trees-installed.png)
- [Final trees on phone](reference/low-poly-nature/arena-trees-phone.png)

The prototype HUD clips the long inhale instruction in landscape and consumes much of the portrait view; several portrait labels are very small. No UI redesign was included. Phone effect screenshots were taken before the final tree swap/path adjustment; final tree rendering was inspected separately.

## Functional and build checks

- Selene across src and scripts/studio: zero errors/warnings/parse errors (cached Roblox API used because online API-dump refresh was unavailable).
- Rojo build passed.
- Play reuses the installed decoration; repeated Apply calls do not duplicate trees, archive entries or decor.
- Walk-on teleport-pad volume triggered arena entry in Play. No teleport/spawn anchors changed.
- All nine rock centres raycast onto their visible base mesh, with heights3.0/3.3/3.6studs. No taller new cover.
- ContentProvider preloading returned no failed mesh assets.
- Existing Output issues remain: Studio data saving disabled, and the unrelated existing asset203785492 reports a type mismatch. No new nature-script runtime errors observed.
- Studio device simulation is restored to default after verification. This was a local Studio test, not a published multiplayer acceptance test.

## Reproduction and next review

Source hooks in PilotEnvironment call NatureArenaPolish and NatureArenaTrees without increasing environment version12. Missing templates keep the original environment available. Masters live in ServerStorage.MapProps.LowPolyNature; import IDs are in scripts/asset_ids.json.

Use scripts/studio/normalize_nature_templates.luau and normalize_nature_trees.luau after inserting model assets. scripts/studio/place_nature_arena.luau consolidates final placement into one area recording. Live visual refinements used additional area-wide undo steps; nothing was recorded individually per prop.

Next: approve the [undergrowth meshes](../blender/review/BE_Nature_Undergrowth_mesh.png), finish/place sparse planting, review the arena, then move to the lobby. Fence and optional stair-trim briefs remain deferred. No new stair route is planned. No Git push or game publication was performed.
