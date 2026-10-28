# Fire Q and R visual polish - 2026-10-26

Scope: only base Fire Q/R. Existing approved Blender Flame mesh and existing cast clips reused. Damage, range, cooldown, release timing and other powers are unchanged.

- Q: solid shaded shell, gold core and backward-facing flame plume; compress/gather during windup, 20% release overshoot, flowing white puffs/stars and a 0.42-second dispersing impact burst. Current server release origin remains authoritative while running.
- R: ground-aligned boundary telegraph, inward gathering particles, ten-stud central flame, five supporting flame lobes, an expanding ground wave confined to the field radius and pulsing settle. Geometry is opaque so the silhouette survives bright lighting.
- Small caster-only camera bump, bounded to 0.18 seconds and 0.045 studs. No hitstop or fullscreen flash. Existing animation clips are unchanged; no new sound asset was added in this pass.
- `FireHero.luau` owns presentation, with no per-effect connections. Shared controller retains concurrency/culling and cleanup. Missing Flame template uses the existing generic fallback.

Studio lifecycle checks: six Q/R natural expiry, impact and cancellation cases passed; maximum 25 parts, zero errors. Moving release-origin position assertion passed. Selene: zero errors/warnings using cached Roblox API. Rojo build passed. Owner visual acceptance, mobile and multiplayer review remain pending.

Actual PilotInput Q/R test produced two effects, zero controller failures and zero mesh fallbacks. Preview camera scripts encountered an unloaded arena floor; no final visual screenshot acceptance is claimed.

## Fire Q rework - 2026-10-28 (owner: "looks great so far", Fire Q only)

Replaces the Q branch of the 2026-10-26 polish above (R is unchanged and still not approved).

- **VFX:** `src/client/Vfx/Effects/FireballQ.luau` (FireHero delegates Q to it). Neon core inside a translucent orange shell inside a faint shade rim, a three-lobed flame crown streaming behind, a puff/ember/star wake, a gather at the right hand during the windup, 25 percent release overshoot with stretch, and an impact burst (star, ember and puff emitters plus a flash ring). Visible orb stays inside the 2.5-stud hit radius. 16 parts, 6 emitters, 1 light. No sound (owner: skip for now).
- **Animation:** dedicated clip `blender/anims/build_fire_q.py` (canonical MrXen0 rig, reuses the V2 exporter, separate `BE_FireQ` outputs): coiled weight-back anticipation, planted stride, straight throwing arm, follow-through. Release marker stays 0.18 s, length 0.68 s. Standing 126823225652265, moving 131461487197799. V2 IDs for revert are noted in `PowerAnimations.luau`.
- **Gameplay unchanged:** damage, cooldown, speed, range, release timing.
- **Verified:** Selene and Rojo-synced Studio Play with a scripted real-time loop (stand-still, normal camera distance). **Not yet verified:** real Q input with Fire equipped, the moving/airborne clip, two-client replication, mobile. Owner visual approval of the full cast pending.

## Base Q moves - 2026-10-28 (first pass, awaiting owner review)

Same recipe as Fire Q for Wind, Earth, Water, Sword and Shadow. Fusion Qs (Gale/Stone/Foam/Ember/Dusk Edge, Crown Slash) are NOT done yet.

- **VFX:** `src/client/Vfx/Effects/ProjectileQ.luau`, called from `PowerMoves.Play` for Q on those five powers (Fire keeps `FireballQ`). Silhouettes: Wind = neon orb plus three spinning wind-front bands, Earth = tumbling Rock mesh plus orbiting chips, Water = translucent orb plus teardrop tail and beads, Sword = silver Slash crescent, Shadow = violet ShadowOrb with lilac rim. Palettes from `PowerVisuals`. Wake, gather, release overshoot and impact burst as Fire Q.
- **Animation:** `blender/anims/build_q_casts.py` (canonical MrXen0 rig, separate `BE_QCasts` outputs): Wind two-hand shove, Earth overhead heave, Water scoop-and-push, Sword diagonal slash, Shadow backhand flick. Release stays 0.18 s, length 0.68 s. IDs in `PowerAnimations.luau` (V2 IDs kept in comments for revert). Authored poses were checked only on Blender renders plus a few Studio frames.
- **Verified in Studio:** real Q input with Water (orb, droplet tail), server-fired packets through the real client controller for Shadow (orb, wake, stars). **Not yet seen in flight:** Earth, Wind and Sword after the bloom fix. Moving/airborne variants, two-client replication and mobile not tested.
- **Bots paused:** `PilotConfig.BotFill = 0` (was 4), to restore combat set it back to 4.

## Base E and R moves - 2026-10-28 (first pass, awaiting owner review)

Each of the 12 base E/R moves is its own module in `src/client/Vfx/Effects/Ground/`, written from its own concept image (no shared recipe; `Ground/Fx.luau` is only a utility toolbox and `GroundMove.luau` only dispatches). Fusion E/R (Sword + element) are NOT done and still use the old generic path. Fire Q and the Q moves are unchanged.

| Move | Module | Notes |
| --- | --- | --- |
| Wind E | WindVortex | Concept is an inward-pulling Vortex; the server move is a forward push cone (Airfront). Spiral is drawn ahead of the caster across the cone length. Owner to confirm which is intended. |
| Wind R | WindCyclone | Dashed ring, three thick bands, rock chips. Bands look gappy in the first frame. |
| Earth E | EarthStoneField | Golden dashed ring, mixed-size stones rising with overshoot, ground cracks. |
| Earth R | EarthQuake | Foot ring, radiating cracks, three dashed shock rings, launched rocks. |
| Water E | WaterWhirlpool | Basin, bead-chain spiral arms, foam rim. |
| Water R | WaterTidalWave | Chevron strip telegraph, Wave mesh with foam scallops. Wave orientation not checked up close. |
| Fire E | FireFlameField | Double ring with flame ticks, bouncy blobs, pulse flashes. |
| Fire R | FireEruption | Double dashed rings, geyser with core and lobes, cloud ring, stones, stars. |
| Sword E | SwordRisingSlash | Concept is a parry; server move is a rising cone slash. Drawn as a rising crescent. |
| Sword R | SwordBladeStorm | Segmented ring, five chunky blades orbiting with trails. |
| Shadow E | ShadowSnare | Sigil, looping ribbon that coils. Reads as a bead cluster in the first frame. |
| Shadow R | ShadowNightfall | Concentric lavender disc, falling crescent, dome splash, puff ring. |

Animations: 12 new E/R casts in `blender/anims/build_q_casts.py` (own body language per move, long windups get a mid pose), release markers equal the server `Delay`. IDs in `PowerAnimations.luau` (V2 IDs in comments).

Seen in Studio (one frame each via server-fired packets): Earth R, Wind R, Fire R, Water R (wave at screen edge), Shadow R, Shadow E, Sword R, Water E. Not yet seen: Wind E, Earth E, Fire E, Sword E. Moving/airborne variants, two clients, real input for E/R and mobile are untested.
