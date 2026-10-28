# Power Star loop and ability rollout — 2026-10-26

## Implemented

- Six server-owned Power Stars spawn at random clear arena positions, roam, bounce, reserve during inhale and respawn after capture. No pickup NPC attacks or rare/mystery bandit spawns. Fighter bots remain combatants.
- Swallow activates the new power, benches the former active power and discards the old bench. Swap exchanges slots. Per-power cooldown deadlines remain intact. Spit preserves the loadout.
- Shared swallow animation/VFX runs on the authoritative success event; standing and moving clips, torso emblem, puff/star accents, no shield or movement freeze.
- All 12 Q attacks are projectiles and inhaleable. The provisional frontal catch window is 0.35 seconds; the longer pickup inhale does not extend projectile protection. Dash cancels inhale; ordinary movement stays available.
- 36 distinct move definitions, timed server release/damage, interrupted-cast cancellation, wall collision and bounded client presentation. Shield/Block and Blade Guard are removed. Master Sword uses Crown Slash, Rising Cleave and Grand Cleave.
- 36 authored power clips and 36 moving variants uploaded and configured. Ten reusable choreography archetypes, with per-move timing/pose variations; these are not 36 entirely unrelated choreographies.
- 36 generated move-card icons uploaded and configured; twelve power emblems reused for loadout and swallow. Touch HUD has a responsive three-column layout.

## Checks performed

- Selene and Rojo build passed.
- Fresh Studio Play: six Power Stars spawned; a real inhale/swallow input test changed Fire active + Water bench to Water active + Fire bench. Swallow controller recorded one start/cleanup and no failed animation loads.
- Isolated Studio server regression (`scripts/test_power_moves.server.luau`): all 12 Qs captured without damage; expired catch window took damage; a wall 1.5 studs from the caster blocked a shot; cancelled delayed cast caused no damage. Fixtures removed afterward.
- All 36 effects exercised through windup/release/impact/cleanup: zero errors; peak 31 parts, below the 40-part project limit. Client controller caps concurrent effects at six and culls distant effects.
- All 72 V2 power animation tracks loaded at expected durations. Export validation checked exact Release markers, zero root translation and canonical rig integrity.
- Responsive layout math checked at 375x812 and 844x390. This is not a physical-device or gamepad acceptance test.

- Moving-Q regression passed: release sampled the caster after movement, rather than the cast-start position. Explicit Release packets align client flight with that origin.

## Still pending

- All ten approved/reused move templates are installed; final 36-effect test used zero mesh fallbacks. See power-mesh-installed.md.
- Full owner visual review, two-client replication/catch race test, real touch/gamepad interaction, extended soak and balance testing.
- Current sessions retain legacy rounds, scoring and rewards; the design's separate roundless session/economy migration was not included in this asset/gameplay loop change.

All temporary test scripts/fixtures are Play-only. No production data-store changes, commit or push performed.
