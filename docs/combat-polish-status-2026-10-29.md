# Combat polish status - 2026-10-29

Single place for what was built in the combat visual audit and polish pass, what was tested, and what still needs the owner's eyes. Companion docs: [fire-polish.md](fire-polish.md) (per-move notes), [pvp-audit.md](pvp-audit.md), [animations.md](animations.md). Nothing here is committed or pushed.

## Built

- **Audit and polish standard:** Fire Q (owner: "looks great"), base Q moves (owner: "a lot better"), base E and R (12 modules in `src/client/Vfx/Effects/Ground/`), sword fusion E and R (rising slash tinted per fusion, blade ring for Wind and Water, forward cleave wave for Earth, Fire and Master, falling crescent for Shadow).
- **Codex Blender meshes** (briefs in `blender/briefs/BE_Fx*.md` and `BE_Held*.md`, generator scripts `scripts/make_fx_briefs.py`, `scripts/make_sword_briefs.py`): TornadoBands, VortexSpiral (unused for now), GustCurl, GroundCrack, WhirlpoolBasin, TidalWave, FlameBlob, FlameGeyser, BladeChunky, ChunkyCrescent, RibbonLoop, RingStack. StoneTall was built by hand (`blender/build_fx_stone.py`) after two Codex attempts came out as a flat slab. All installed under `ReplicatedStorage.Assets.PowerMoves`; finish and export through `blender/finish_power_mesh.py`.
- **Swords:** Wind, Earth, Water, Fire, Shadow and Master Sword meshes (Codex), plus the base Sword. All share one grip and blade length and are installed under `ReplicatedStorage.Assets.Swords`. One two-handed animation set (`blender/anims/build_sword_rig.py`) serves every sword power; grip comes from Blender (`blender/review/BE_SwordRig_Sword_grip.json`). `SwordController` welds the right sword by `ActivePower`.
- **FFA:** the match, results, intermission and timer cycle is gone. Combat is always on, the lobby pad joins, KOs pay coins, a death or reset respawns in the lobby, and the HUD shows no queue, timer or results.
- **Inhale:** reach 28 studs, wider cone, 0.35 s capture, 2 s cooldown. Verified: a star 13 studs away was captured in 0.48 s.
- **Power Stars:** client presentation in `StarController.luau` (bounce with squash and stretch, landing puffs and ring, layered glow, halo, light, sparkles, pull stretch).
- **GUI:** the HUD follows Codex's concept (`docs/reference/gui-concepts-v1-2026-10-29/`). Kit of 16 icons and 13 frames cut from Codex sheets, uploaded (`src/shared/Config/HudAssets.luau`), HUD in `src/client/Hud/PilotHud.luau`. Images are locked to their art's aspect ratio and sliced frames scale their corners with the displayed size, so nothing stretches.
- **PvP tuning:** see [pvp-audit.md](pvp-audit.md).

## Tested in Studio

Real inputs through the game's remotes: M1 chain, Q/E/R casts with cooldown overlays, inhale to swallow to swap to fuse button, reset to lobby. Every Q, E and R and all fusion E/R effects were driven through the real client modules with zero errors and zero mesh fallbacks. HUD screenshots at roughly 1918x1022.

## Not verified (needs the owner or a second client)

- **Visual look in 3D.** The Studio window used for testing rendered the 3D view white, so none of the effects, stars, held swords or the fusion waves were seen by me this session. Please check them.
- Real keyboard and mouse presses (the test tool's mouse click did not register as M1), two real clients, mobile and gamepad layouts.
- Moving and airborne cast variants, interruptions (dash, jump, hit), how other players see the sword.
- Q casts for Earth, Wind, Sword and the fusion Qs were never seen in flight.
- Gust curl and the Ribbon loop are the weakest meshes; Tidal wave and Stone are acceptable, not great.

## Still to do

- Per-element sword animations and the slash look were deferred by the owner to a later rework. (The 21 sword casts were redone for the two-handed grip on 2026-10-29; see animations.md.)
- Sound for every move and the HUD (skipped on purpose).
- Save the Studio place so `Assets.Swords` and the new `PowerMoves` templates persist (`Assets` is not synced from the repo). `BotFill` is 0 (bots paused); set it back to 4 for combat tests.

## Sword E dash-slashes - 2026-10-29

- All seven sword E moves are now a new `Dash` kind (server: `PowerMoveService.Cast`): the caster lunges Range studs over DashTime, brief invulnerability, sweeping everyone within Radius of the path once (damage, Lift/Push/Pull as before). Names and numbers: Flash Step 14, Gale Rush 17, Tremor Charge 12, Tide Slide 15, Blaze Lunge 15, Umbra Step 18, Crown Rush 16 studs; damage and cooldowns unchanged. Windups shortened (Tremor 0.55 to 0.35, Umbra 0.65 to 0.35, Crown 0.4 to 0.3) and the two-pulse Branding/Echo hits became one hit.
- Client: `Ground/SwordDash.luau`, one module with a trail style per power (silver ghosts, wind helix and leaves, thrown stones and cracked ridge, water wake and droplets, flame comet and scorch prints, shadow clones, golden crown stars) and a finishing cut. Concept: `docs/reference/sword-dash-concepts-v1-2026-10-29/` (Codex). No cloud puffs.
- Tested: all seven build with 0 mesh fallbacks; a server fixture cast of Blaze Lunge moved 15 studs and hit once. Not seen in 3D, not tested with real input.
- Power Stars: the landing dust puff is gone and the outer rim (1.32x to 1.15x) and glow (9.5 to 6.5) are smaller.

## Sword M1 slash trails - 2026-10-29

`Vfx/Effects/SwordSlash.luau`: each sword hit now leaves its own cut instead of the fist puff (hit 1 rising diagonal, hit 2 flat backhand sweep, hit 3 overhead chop), in the active power's colours (crescent rim, body, white edge, two afterimages, four speed streaks, a glint). Fired on the animation's Strike marker from `CombatAnimationController.drawSlash`. Ran for all three hits in Sword, Sword_Fire and Sword_Shadow with no errors; not seen in 3D, and the timing against the swing (sweep 0.14 s from the strike frame) is unchecked.

## Anime-slick redo and PvP kit - 2026-10-30

- Direction: every move is being redone in an anime-slick look (sharp tapered shapes, thin speed bars, dark outlines, windup hit-area telegraph, impact stars). Codex concept sheets per power: `docs/reference/move-concepts-v2-anime-slick-2026-10-30/<Power>.png` (older takes kept as `.v1.png`). Bandit Eater builds its own shapes and code; nothing is taken from Clover Ascension beyond the style references in `docs/reference/anime-slick-style-refs/`.
- PvP roles: move 1 poke (fast projectile, unchanged), move 2 control or engage (sword powers dash), move 3 finisher with its own shape. E and R reach and radius were enlarged; damage and cooldowns unchanged.
- Third moves are no longer all areas: Wind R Roaming Cyclone (wave that rolls forward and pulls), Fire R Meteor Strike (big projectile with a launching blast), Shadow R Umbral Blink (dash), Sword_Wind R Skywheel (projectile disc). Others stay areas or waves.
- Built so far (Fire pilot): `Ground/Slick.luau` toolkit, new `FireFlameField` (E), `FireballQ` restyled (Q and the bigger R Meteor), Shadow R reuses the sword dash module, Wind R travels. Old Fire Eruption module removed. Not yet checked in 3D beyond a windup frame.

### Fire pilot, 2026-10-30 (later)
- Codex Blender meshes installed under `Assets.PowerMoves`: FlameCluster (108413603664925), CometTail (135477774612489), MeteorCore (124012555482368), EmberShard (140075801868489). The single FlameTongue failed twice in Codex (a leftover empty scene in the live Blender) and is not needed yet.
- E Flame Field: ring of FlameCluster layers (red, orange, hot core) with one hard Highlight outline, turning ring, spiral bars, shards, pulse ring, exact-circle windup. Seen in Studio on a dark floor: reads as sharp anime flames.
- Q Fireball and R Meteor (`FireballQ.luau`): CometTail layers behind a small hot head, outline, speed streaks, windup lane (R also a blast circle), impact lines, MeteorCore and EmberShard debris on R. Q seen in flight and reads as a sleek comet. R Meteor not verified on screen (the viewport went white in the last capture).
- Known gaps: the comet tail is smoother than the sheet's separate tongues, the head is a flat yellow ball, impact for both is not seen yet, Fire R animation timing unchanged.

### Bigger moves - 2026-10-30
Owner: make all moves bigger in general except the first projectile. Every E and R got 1.3x reach and radius on top of the earlier PvP enlargement (projectile R moves keep their travel distance and grow their blast radius). Move 1 untouched. Visuals scale with the hit area: Flame Field height, Meteor size and lane width, sword dash finishing cut; other powers' effects follow `ctx.radius` where they already used it. Checked through the real server path for Fire only (Move 2 and 3 run, no errors); other powers' effects were not looked at at the new size.

### Anime-slick rebuild for every other power - 2026-10-30
- 19 more Codex Blender meshes queued (`.codex-tmp/run_all_meshes.sh`, briefs `blender/briefs/BE_Fx*.md`, sheets in `docs/reference/move-concepts-v2-anime-slick-2026-10-30/`): WindCrescent, AirfrontFan, CycloneColumn, BoulderShot, StoneSpikes, QuakePillars, WaterLance, WhirlpoolDisc, TidalCrest, SlashCrescent, FloatBlade, SkywheelDisc, ShadowArrow, SnareTendrils, DarkCrescent, CrownStar, SplitterRidge, EclipseDisc, GoldWave. Roughly 8 minutes each, one after another. Progress: `.codex-tmp/allmesh.status`.
- Generic modules built so each move only needs its mesh plus a config: `SlickQ.luau` (projectiles incl. Skywheel), `Ground/SlickGround.luau` (fields, areas, discs, orbiting blades), `Ground/SlickWave.luau` (fans, walls, rows, travelling columns), toolkit `Ground/Slick.luau`. `GroundMove.luau` holds the per-move configs and falls back to the older effect while a mesh is not installed in the place.
- Tooling: `python scripts/finish_fx_batch.py FxName ...` finishes, uploads and prints the asset ids; they are then installed into `Assets.PowerMoves` from Studio (clone of the loaded MeshPart, Size and PivotOffset / 100).
- Installed and seen so far: WindCrescent (Wind Q reads as a sharp crescent with outline and speed streaks). Everything else waits for its mesh.

### Batch 1 installed - 2026-10-30
Installed and run through the real server path: Wind Q/E/R (WindCrescent, AirfrontFan, CycloneColumn), Earth Q/E/R (BoulderShot, StoneSpikes, QuakePillars), Water Q/E (WaterLance, WhirlpoolDisc), Sword Q (SlashCrescent), ShadowArrow built but not yet installed. Wind E seen on screen: wide fan of sharp crescents with outline and speed bars. Still waiting on meshes: TidalCrest, FloatBlade, SkywheelDisc (Codex failed while Blender was down; retry queued), then the Shadow, Master and fusion finishers. Sword E dashes still use the older trail parts.
