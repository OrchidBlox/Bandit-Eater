# Animation style: cartoony exaggerated (draft, not yet tested on a clip)

Bouncy, expressive animation with pushed poses: big anticipation dips, springy overshoot and elastic settles. Friendly, funny and full of personality. Not realistic, and not stiff. Roblox joints cannot squash or stretch, so the effect comes from extreme poses, offsets and timing.

## Rules

1. **Push every pose 40 to 60%** beyond natural: bigger leans, wider arms, deeper crouches.
2. **Anticipation dip.** Before any move the character dips or leans the opposite way, held 3 to 5 frames.
3. **Overshoot and bounce.** After the strike, limbs overshoot and bounce back 2 to 3 times with shrinking size (use elastic or bounce easing, or bake it into keys).
4. **Offset the root** (hips) up and down to fake squash and stretch: lower the hips on anticipation and landing, raise them on launch.
5. **Personality in the head and hands.** Tilt the head, spread the fingers, add small secondary motion.
6. **Quick but not sharp.** Moves are fast, then bouncy; nothing stops dead.
7. **Asymmetry.** Avoid mirrored poses; one arm leads, one trails.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Anticipation dip | 4 to 6 | Dip, lean back, arms pulled in |
| Strike | 3 to 4 | Fast stretch into the pose, hips up |
| Overshoot | 3 | Past the pose |
| Bounce settle | 8 to 12 | Two or three diminishing bounces |

## Pose rules

- Use the hips to fake squash: lowest on anticipation and landing, highest on launch.
- Spread limbs wide in the air, tuck them on the landing.
- Keep the face direction clear; the head leads every action by 1 frame.

## Interpolation

Ease-out into poses, elastic or bounce easing on the settles (or baked overshoot keys), fast ease-in on strikes. Check what easing the exporter writes before using elastic or bounce.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | Bouncy 60-frame loop with a head tilt and arm sway |
| Run | Springy 14-frame loop with bobbing hips and swinging arms |
| Jump | Deep dip, high stretch, hang in the air, squishy landing bounce |
| M1 combo hit | Dip, fast stretch swing, bouncy settle; alternate hands |
| Heavy or signature | Bigger dip, huge stretch, a long bounce settle |
| Dash | Lean back, zip forward with arms trailing, a skid and bounce stop |
| Block | A quick hunch with arms crossed and a bounce |
| Cast or special | Big gather, a theatrical flourish, a pose held with a wiggle |
| Hit reaction | A big cartoon recoil and bounce back |

## Notes for Codex briefs

- Push poses 40 to 60% beyond natural, and make poses asymmetric.
- Use hip offsets to fake squash and stretch.
- Add 2 to 3 diminishing bounces after strikes and landings.
- Keep a visible anticipation dip before every move.

## Never

Stiff or symmetrical poses, stopping dead, realistic restraint, scaling limbs (not supported).

## Style checklist

- [ ] Poses are clearly pushed past natural
- [ ] Anticipation dip before each move
- [ ] Overshoot and 2 to 3 bounces on settles
- [ ] Hips fake squash and stretch
- [ ] Asymmetric poses with personality

## Approval

Not tested yet. Make one attack and one jump, show the owner in game, then mark it proven.
