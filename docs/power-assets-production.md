# Power asset production — 2026-10-26

Completed rollout: power identities, Power Stars, swallow and all 36 base/fusion moves. References: `reference/move-concepts-v1-2026-10-26/`.

## Produced

- Twelve transparent 512px emblem PNGs: `blender/export/textures/BE_PowerIcons_*.png`. Published IDs are in `Shared.Config.PowerVisuals` and `scripts/asset_ids.json`. These are power identity icons, not individual Q/E/R move icons.
- Power Star mesh: `blender/BE_PowerStar_Bubbly.blend`, 1,120 triangles, owner-approved. FBX uploaded as model `76772447924708`, mesh `113197235191944`. Imported FBX has 100x scale; normalize to 2.8748038 x 2.7506738 x 1.14 studs and identity rotation. `Shared.PowerStarVisual` creates six base-power variants with front/back emblems and optional bounce/spin pose. `scripts/install_power_stars.luau` installs the library in Edit mode; installed in Edit mode at ReplicatedStorage.Assets.PowerStars. Six upright variants and both emblem faces were checked; a Studio screenshot confirmed the visible front icons. Temporary review objects were removed.
- Swallow animation: `blender/anims/BE_PowerSwallow.blend`; canonical MrXen0 source unchanged. Standing `134771684679502`, moving upper-body `99253369218549`. Both 0.8 seconds, nonlooping Action priority, neutral start/end and 0.08/0.12-second fades.
- Markers: Gulp 8/30, PowerPop 12/30, Equip 18/30. Moving variant mutes lower-body poses to preserve locomotion. Review PNG/GIF and numerical validation under `blender/review/BE_PowerSwallow*`.
- `PowerSwallow.luau`: client-only emblem, compact halo, white puff and star effect; maximum 11 noncolliding parts, late-arrival support, distance culling, cleanup. No damage, shield, slot mutation or movement lock.

## Integration and verification

PowerStarService and PilotService now handle random roaming Power Stars, capture, automatic active/bench replacement and respawn. PowerSwallowController handles the successful swallow event. PowerMoveService and PowerMovesController implement all 36 Q/E/R moves; every Q is inhaleable. Shield/parry and Blade Guard are removed. Legacy rounds/economy remain separate scope.

36 generated move icons and 72 V2 animation clips are uploaded and registered in Shared.Config.MoveIcons and PowerAnimations. Canonical MrXen0 rig retained; ten choreography archetypes have per-move timing and pose variations. Standing and moving variants use server release timing.

The ten-template move library is installed. See [mesh manifest](power-mesh-installed.md) and [gameplay checks](power-loop-validation.md). The final assets passed 36 effect lifecycle tests with zero fallbacks/errors and peak 31 parts. All 72 V2 animation tracks loaded; all 36 move icons loaded in actual ImageLabels.

Projectile windup follows the caster. Release samples the current server character position/direction, checks the muzzle against walls and sends an explicit Release event. This fixes stale cast-start origins while running. Stronger windups, reach, stretch and larger signature effects are implemented; owner visual acceptance, two-client catch races and physical-device testing remain pending.
