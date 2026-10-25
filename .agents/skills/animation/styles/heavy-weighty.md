# Animation style: heavy and weighty (draft, not yet tested on a clip)

Big, slow-building, powerful animation: every move has mass. A long windup, a hard slam on release, a big overshoot and a slow recover. Good for bruisers, bosses and giants. Not quick and twitchy.

## Rules

1. **Mass shows in the windup.** A long anticipation with the whole body loading (hips and chest coil, knees bend).
2. **One decisive strike.** The strike is still fast (3 to 4 frames) but follows a visibly slow build.
3. **Hard stop.** The limb stops abruptly on impact and the body sags into it; hold 4 to 6 frames.
4. **Big overshoot and settle.** The weight carries the body past the pose, then settles slowly over 8 to 12 frames.
5. **Ground reaction.** The planted foot drops and the hips dip on impact; the camera shake in game comes from this beat.
6. **Slow recoveries.** Characters take time to return to idle; combos have gaps.
7. **Fewer, bigger moves.** Better to have three heavy clips than many light ones.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Anticipation | 10 to 18 | Slow coil, weight loads onto the back leg |
| Strike | 3 to 4 | Fast release, whole body drives forward |
| Hold | 4 to 6 | Impact held, body sags into the hit |
| Overshoot and settle | 8 to 12 | Weight carries through, slow settle |
| Recovery | 14 to 20 | Slow return to idle |

## Pose rules

- Wide stance and low centre of gravity on the strike; knees bent.
- Limbs move as a chain: legs, then hips, then chest, then arms, with clear delay between each.
- Silhouette is large and blocky; arms stay away from the torso.

## Interpolation

Slow ease-in through the windup, linear or fast ease-in on the strike, constant hold, long ease-out on the settle. Keep roots moving through the hit so the body follows the weapon.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | Slow breathing loop of 90 to 120 frames, heavy shoulders, minimal sway |
| Run | 20-frame loop with a heavy lean, big foot plants, slight torso bob |
| Jump | Deep crouch (8 frames), slow launch, heavy landing with a long recovery |
| M1 combo hit | 24 to 32 frames per hit; alternate sides with a clear gap between hits |
| Heavy or signature | Overhead or two-handed slam with the longest windup, 6-frame hold, big settle |
| Dash | Lumbering charge with a forward-leaning shoulder, 12 frames |
| Block | Slow brace, hold with a firm stance, no tremble |
| Cast or special | Long gather with the whole body, huge release pose |
| Hit reaction | Small stagger, since heavy characters resist knockback |

## Notes for Codex briefs

- Windup at least 10 frames; strike no longer than 4 frames.
- Move the hips, knees and chest on every hit, not only the arms.
- Hold the impact 4 to 6 frames and settle for 8 to 12.
- Stepped blocking first, then smooth.

## Never

Short windups, light and bouncy settles, quick recoveries, arms-only motion.

## Style checklist

- [ ] The windup shows the weight loading
- [ ] Strike is fast but follows a visibly slow build
- [ ] Hard stop and long settle
- [ ] Hips, knees and chest move with the strike
- [ ] Recovery is slow and readable

## Approval

Not tested yet. Make one heavy hit, show the owner in game, then mark it proven.
