# Animation style: stepped (draft, not yet tested on a clip)

Held keys with no interpolation: the character snaps from pose to pose like stop-motion or a comic panel sequence. Stylised, punchy and cheap to make, and every pose has to be good. Not smooth. Make it deliberately, with clean holds.

## Rules

1. **Every key is a finished pose.** No in-betweens: each pose must read on its own.
2. **Constant interpolation** on every key (hold, then snap).
3. **Uneven holds.** Hold spacing carries the rhythm: short holds for fast actions (2 frames), longer on impacts (4 to 6).
4. **Smear and impact poses.** Use one stretched or blurred-feeling pose on the fastest frame, then the extreme pose.
5. **Few keys.** A basic attack is 4 to 6 keys; a loop is 4 to 8.
6. **Consistent step rate.** Pick a step cadence (for example one key every 3 or 4 frames at 30 fps) and keep it across the whole game, except for deliberate holds.
7. **Clean silhouettes.** With no motion between poses, the silhouette of each pose does all the work.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Anticipation | 2 keys, 6 to 8 frames | Pull-back pose, then deeper pull-back |
| Strike | 1 key, 2 to 3 frames | Smear pose snaps in |
| Impact hold | 1 key, 4 to 6 frames | Extreme strike pose held |
| Recovery | 2 keys, 6 to 8 frames | Step back toward idle |

## Pose rules

- Poses are extreme and graphic; push them 30 to 50% beyond natural.
- Change the whole silhouette between keys, not small amounts.
- Keep the head and torso consistent between keys so the character does not jitter.

## Interpolation

Constant (stepped) for every key. Check the exporter writes constant easing; if it does not, add duplicate keys one frame before each next pose so the hold is baked in.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | 4 to 6 key loop, a subtle weight shift every 12 frames |
| Run | 6-key loop: contact, down, pass, up for each side, held 3 frames each |
| Jump | Crouch, launch smear, peak pose, fall pose, landing pose |
| M1 combo hit | 4 to 6 keys with an impact hold |
| Heavy or signature | Larger holds and a bigger smear |
| Dash | Lean pose, smear pose, slide-out pose |
| Block | Snap into the guard pose, hold, snap out |
| Cast or special | Gather pose, thrust pose, held effect pose |
| Hit reaction | One snapped pose away from the hit, held 4 frames |

## Notes for Codex briefs

- Use constant interpolation for every key and name each key's pose.
- Hold impacts 4 to 6 frames; hold fast actions 2 frames.
- Keep silhouettes clear; push poses 30 to 50% beyond natural.
- Keep the same step rate across all clips for the game.

## Never

Smooth interpolation, tiny pose changes, mixing step rates between clips, jittery head or torso.

## Style checklist

- [ ] Every key is a readable pose
- [ ] All interpolation is constant
- [ ] Holds are uneven, with long impact holds
- [ ] Step rate matches the rest of the game
- [ ] Silhouettes are clean

## Approval

Not tested yet. Make one attack clip, show the owner in game, then mark it proven.
