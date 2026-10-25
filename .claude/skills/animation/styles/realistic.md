# Animation style: realistic (draft, not yet tested on a clip)

Grounded, natural animation with believable weight shifts, subtle secondary motion and smooth easing, like motion capture. Quiet and convincing. Not exaggerated or stylised. It is the hardest style to make look good, because small errors read as wrong.

## Rules

1. **Reference first.** Work from real video or mocap-like reference; do not invent the motion.
2. **Weight and balance.** The centre of mass always sits over a support foot; show weight shifts before every action.
3. **Natural timing.** Real durations: a punch is about 8 to 12 frames, a step about 12 frames per foot plant.
4. **Subtle extremes.** Poses stay within natural ranges; push only 5 to 10%.
5. **Secondary motion.** Shoulders, head, hands and clothing follow with small delays and settle.
6. **Smooth curves.** Ease in and out everywhere; no snaps or holds apart from natural pauses.
7. **Feet are planted.** No foot sliding; plant and release on the right frames.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Preparation | 6 to 10 | Natural weight shift and wind-back |
| Action | 6 to 10 | Smooth acceleration through the move |
| Follow-through | 6 to 10 | Natural deceleration, body continues briefly |
| Recovery | 10 to 14 | Return to balanced stance |

## Pose rules

- Hips and chest rotate with the action; the head stays level to the target.
- Joint angles stay within real human limits (elbows and knees do not hyperextend).
- Hands and fingers relax into natural curls.

## Interpolation

Smooth bezier or spline curves with natural ease in and out; avoid constant holds. Add small noise or offsets on the head and shoulders to avoid a mechanical look.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | Slow breathing and subtle weight shifts, 120-frame loop |
| Run | 18 to 20-frame loop with a natural stride, arm swing and torso counter-rotation |
| Jump | Natural crouch, push-off, tucked legs, controlled landing absorbing weight |
| M1 combo hit | Realistic strike with hip drive and a natural follow-through |
| Heavy or signature | Full-body swing with a proper wind-up and weight shift |
| Dash | Quick sprint start with a forward lean and a controlled stop |
| Block | Raised guard with a slight crouch |
| Cast or special | Controlled gesture with weight shift and breath |
| Hit reaction | Natural recoil in the direction of the impact, then recover |

## Notes for Codex briefs

- Provide or request a reference clip for each move.
- Keep poses within natural limits and plant feet without sliding.
- Add secondary motion on the head, shoulders and hands.
- Use smooth curves with natural timing.

## Never

Exaggerated poses, stepped holds, foot sliding, mirrored symmetrical motion, stiff torsos.

## Style checklist

- [ ] Based on a reference clip
- [ ] Weight shifts before and after actions
- [ ] Feet plant without sliding
- [ ] Secondary motion on head, shoulders and hands
- [ ] Joint angles within natural limits

## Approval

Not tested yet. Make one attack and one run loop, show the owner in game, then mark it proven.
