# PvP suitability audit - 2026-10-29

Static audit of `Shared.Config.PowerMoves`, `PilotCombat`, `CombatActions` and `PowerMoveService` (max health 100, walk speed 20, dash 20 studs / 3 s / 0.2 s i-frames, M1 6-6-9 every 0.4 s, inhale catch window 0.35 s frontal). No gameplay numbers were changed by this audit. Not play-tested with real opponents.

## What holds up

- **Telegraphs are escapable.** Every damaging Field/Area has a telegraph long enough to walk out of at 20 studs/s (Nightfall 1.0 s vs radius 10, Quake 0.8 s vs 14, Eruption 0.8 s vs 9). Server and client agree on the same release time.
- **Anti-chain stun is in.** Stun is capped at 0.6 s and followed by 1.5 s stun immunity, so no stun lock. Stun cancels the victim's cast and inhale.
- **Q shots are counterable.** All 12 Qs are catchable from the front, blocked by walls and cancelled when the caster is stunned.
- **Respawn safety:** 1 s invulnerability on spawn and halved damage during protection.

## Findings, fixed (visual honesty, no gameplay change)

1. **Cone moves drew a narrow lane but hit a 140 degree fan.** The server test is within range and `dot > 0.35` (about 69 degrees each side). Wind E (Airfront) and Sword E (Rising Slash) now telegraph radial lines across the real fan, and the gust fronts widen to the fan's chord.
2. **Telegraphs could be culled in a crowded FFA.** The client skipped any effect once 6 were active, hiding damage from the player it threatened. Effects within 70 studs may now exceed the cap (up to 12). Beyond 70 studs the cap is unchanged.

## Findings, need an owner decision (gameplay numbers; nothing changed)

1. **Cone width.** A 140 degree fan on a 7-stud Rising Slash or 14-stud Airfront is very forgiving to the attacker. Suggest tightening to `dot > 0.6` (about 53 degrees) so facing matters. One-line change in `PowerMoveService.hitArea`.
2. **Burst per kit.** One of each Q+E+R is 43-54 of 100 HP for base powers but 60-68 for Earth/Fire/Shadow/Master sword fusions, before M1 (about 17 dps). Fusions are meant to be stronger (they will cost more), but 68 plus an M1 chain is a KO in about 3 seconds. Suggest capping fusion burst near 60 or accepting it as the price of the fusion.
3. **Rock Shot (16) and Stone Edge (17)** have the highest Q damage per cooldown (7.3-7.7 dps vs 5.5 for Water/Shadow). Suggest 14 / 15 or a slower cooldown.
4. **Short telegraphs:** Whirlpool and Flame Field (0.3 s) are low damage and fine. Q windups are 0.18 s but the projectile travel time and catch window provide the counterplay; leave as is.
5. **Hit radius:** every Q uses a 2.5-stud radius (5 studs across) with ranges up to 60. Generous for a ranged hit; consider 2.0 for the fastest shots (Gale Edge 72 studs/s).
6. **Stun length:** Quake (0.45) and Shadow Snare (0.45) are the longest. Fine with the immunity window; keep an eye on them in playtests.

## To verify in a real playtest

Two or more real clients: fan and field telegraphs match what hits, the near-effects cap does not hurt frame rate, and Quake plus Eruption lift is readable. Sound is still skipped.

## Applied tuning (owner approved 2026-10-29)

- Cone moves now use `dot > 0.6` (about 53 degrees each side); Wind E and Sword E telegraphs follow the new fan.
- Rock Shot 16 -> 14, Stone Edge 17 -> 15.
- Fusion burst capped at 60: Mountain Splitter 32 -> 27, Eclipse Execution 31 -> 29, Crown Slash 16 -> 15, Rising Cleave 18 -> 17, Grand Cleave 34 -> 28. Burst is now Sword Earth 60, Sword Shadow 60, Master Sword 60 (Sword Fire was 60, Sword Wind 53, Sword Water 52).
- Q hit radius 2.5 -> 2.0 for shots at 60+ studs/s (Gust 65, Traveling Slash 60, Gale Edge 72, Foam Edge 60). Cooldowns, speeds, ranges and other damage are unchanged. Not play-tested.
