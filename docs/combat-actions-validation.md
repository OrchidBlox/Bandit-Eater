# Dash and M1 integration — 2026-10-25

The owner rejected the first M1 pass as too tight and the first dash as stiff and too short. V2 corrects the striking shoulder direction, uses actual evaluated arm extension, holds punches for three frames, and gives dash a longer asymmetric pose sequence and recovery.

## Gameplay and presentation

- M1 damage stays 6 / 6 / 9. Server strike times are 6/30, 6/30 and 7/30 seconds, with line-of-sight checks. Client animation markers cannot request damage.
- Standing M1 uses full-body clips; moving/airborne M1 uses upper-body variants so locomotion can continue underneath.
- Dash now travels 20 studs (previously 12), easing from a fast launch into braking. Total clip 15/30 seconds; burst 2/30, brake 11/30. Cooldown remains 3 seconds; invulnerability remains 0.2 seconds.
- Server collision sweeps stop dash at walls; cancellation restores rotation and automatic network ownership. Death, stun and character replacement cancel action state.
- White swing/dash puffs reuse the existing texture. Yellow stars appear only on confirmed damage. Effects are bounded and cleaned up.

## Checks

- Selene: zero errors/warnings; Rojo build passed. Selene used its cached Roblox API library.
- First-pass server timing checks: no early damage; damage 6/6/9; spam rejected; combo reset; cancellation/stun prevented pending hits; dash cooldown rejected repeats.
- First-pass actual mouse/keyboard session loaded all seven action tracks without failed loads or marker fallbacks; moving variants activated. Controller teardown returned connections/tracks/characters/effect parts to zero.
- V2 movement check: actual player actor traveled exactly 20 studs in an open temporary test area. Settled-player wall check detected the test wall and stopped at 5.49 studs; action cleared. Open-area cleanup restored AutoRotate.
- A first wall fixture ran before the relocated avatar settled and did not provide reliable collision evidence; the settled-player check above supersedes it. Earlier synthetic actor fixtures lacked fields expected by the HUD; those fixture errors did not recur in fresh actual-input testing.

## Remaining acceptance

Fresh V2 actual mouse/keyboard playback loaded all seven new IDs with expected lengths, zero failed loads and zero fallback markers. Moving variants activated during running. A forced Humanoid death respawned at health 100 with one character/seven tracks cached, without duplicate character state. Effects returned to zero between actions. Studio Play was stopped afterward, removing temporary validation scripts and test geometry.

Owner visual review remains pending. Phone/gamepad, two-client replication and broad avatar proportions are not yet validated. Studio screenshot capture returned blank images, so it is not evidence of visual acceptance. No public place publish or Git push performed.
