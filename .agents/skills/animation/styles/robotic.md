# Animation style: robotic (draft, not yet tested on a clip)

Stiff, precise, mechanical animation: hard stops, linear moves, segmented joints and no overshoot. Good for robots, constructs and sci-fi enemies. Not organic, not bouncy.

## Rules

1. **Linear movement.** Joints travel at constant speed between poses; no easing.
2. **Hard stops.** Motion ends abruptly with no overshoot or settle.
3. **One joint at a time.** Where possible, move one part, then the next, instead of everything together.
4. **Rigid torso.** The chest and hips rotate as blocks; the head turns in sharp steps.
5. **Precise angles.** Use clean angles (15, 30, 45, 90 degrees) for poses.
6. **Pauses between actions.** Short stops of 3 to 6 frames between sub-actions.
7. **Minimal secondary motion.** No lag, no bounce, no sway.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Charge | 6 to 10 | Parts move into position one by one |
| Action | 3 to 5 | Linear, fast movement |
| Stop | 4 to 6 | Hard stop in the final pose |
| Reset | 8 to 10 | Linear return, part by part |

## Pose rules

- Joints rotate in clean angles and along single axes where possible.
- Poses are symmetrical and blocky, with clear silhouettes.
- The head and arms lock into poses rather than drifting.

## Interpolation

Linear for all moves, constant for stops. Avoid ease and overshoot entirely; if the exporter adds easing, bake linear keys.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | Mostly still, with an occasional head turn or arm twitch, 90-frame loop |
| Run | A rigid 14-frame loop with piston-like legs and locked arms |
| Jump | Compress, launch at constant speed, rigid landing |
| M1 combo hit | Part-by-part raise, linear strike, hard stop, linear reset |
| Heavy or signature | Long charge with parts moving in sequence, a violent linear strike |
| Dash | Rigid lean, a constant-speed burst, a hard stop |
| Block | Parts snap into a locked guard |
| Cast or special | Arms raise to clean angles, then fire with a hard stop |
| Hit reaction | A sharp jolt and a stiff reset |

## Notes for Codex briefs

- Linear interpolation everywhere; no overshoot.
- Use clean angles and stop for 4 to 6 frames at the end of each action.
- Move one part at a time where it reads well.

## Never

Easing, overshoot, bounce, organic sway, secondary motion.

## Style checklist

- [ ] Linear speeds and hard stops
- [ ] No overshoot or bounce
- [ ] Clean angles and rigid torso
- [ ] Clear pauses between sub-actions
- [ ] Silhouette is blocky and readable

## Approval

Not tested yet. Make one attack clip, show the owner in game, then mark it proven.
