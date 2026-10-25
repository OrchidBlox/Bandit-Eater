# Animation style: snappy action (draft, not yet tested on a clip)

Punchy, readable combat animation: a few strong extreme poses, fast movement into the strike, a held frame on impact and a slower recovery. Every hit reads clearly at a glance and feels crisp in PvP. Not floaty or smooth-everywhere, and not slow and heavy.

## Rules

1. **Pose first.** Build the clip from 3 to 5 extreme poses (pull-back, strike, follow-through, recover); everything else is in-betweens.
2. **Fast in, slow out.** The strike covers its distance in 2 to 3 frames; the recovery takes 3 to 4 times as long.
3. **Hold the hit.** Keep the strike pose for 2 to 3 frames (matching the game's hitstop) so the impact lands.
4. **Real anticipation.** A visible pull-back of 4 to 6 frames before every attack; the bigger the move, the bigger the pull-back, not a longer one.
5. **Whole-body commit.** Hips, chest and head rotate into the strike; the leading foot plants on the strike frame.
6. **Push extremes 20 to 40%** beyond a natural pose. R15 joints only rotate, so pose is the lever.
7. **Overshoot, then settle.** The limb passes the target by a few degrees and settles in 2 to 3 frames.
8. **Short total length.** A basic attack is 14 to 20 frames; players should be able to chain at once.
9. **Clean returns.** Every move ends in a pose that blends into idle or the next combo step without a pop.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Anticipation | 4 to 6 | Pull back, weight shifts away from the target |
| Strike | 2 to 3 | Fast travel into the extreme strike pose, hips and chest lead |
| Hold | 2 to 3 | Strike pose held, tiny shake optional |
| Overshoot | 2 | Limb passes the pose slightly |
| Recovery | 8 to 10 | Ease back toward the next pose or idle |

Heavy or signature moves keep the same shape with a longer anticipation (8 to 12 frames) and a bigger hold (4 to 5), never a slower strike.

## Pose rules

- Lead the strike with the hips, then chest, then shoulder, then arm; each part arrives 1 frame after the one before it.
- On the strike frame the weight is over the front foot and the back heel lifts.
- Keep the silhouette clear: the striking arm or weapon should not overlap the torso on the strike pose.

## Interpolation

- Block everything stepped first and judge poses and timing before smoothing.
- Anticipation: ease-out into the pull-back. Strike: linear or fast ease-in, nothing slow. Hold: constant. Recovery: ease-out.
- If the exporter samples curves, bake the fast-in, slow-out shape into the keyframes instead of relying on easing styles.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | Loop of 60 to 90 frames: slight weight shift and breathing, shoulders loose; never fully still |
| Run | 16-frame loop with a pronounced forward lean, arms pumping, torso counter-rotating |
| Jump | Crouch anticipation (4 frames), fast launch, stretched airborne pose, quick landing squash pose |
| M1 combo hit | 14 to 20 frames per step; alternate sides, each step ends in a pose that leads into the next |
| Heavy or signature | Big pull-back, one decisive strike, long hold, bigger overshoot |
| Dash | 8 to 10 frames: lean into the direction, one fast burst, slide-out recovery |
| Block | 4-frame snap into a guard pose, hold with a small tremble, 4-frame release |
| Cast or special | Gather pose (hands pulled in), thrust or raise on the strike frame, held pose while the effect plays |
| Hit reaction | 2-frame snap away from the hit direction, 6-frame recovery |
| Inhale (hold) | Lean back, arms wide, loop of 20 frames with a gentle pull |
| Swallow | Head tilt back and a gulp pose, 8 frames |
| Spit | Quick wind-up and thrust forward, hold 2 frames on release |

## Notes for Codex briefs

- Block stepped first with 3 to 5 extreme poses per clip, then add in-betweens, then smooth.
- Write the strike frame number in the brief and in the action name or a marker (`Strike` at frame N).
- Push extremes 20 to 40% beyond natural; use hips, chest and head, not only arms.
- Hold the strike pose for 2 to 3 frames; recovery at least 3 times the length of the strike.
- Check with a contact sheet of the extreme poses before export.

## Never

Even spacing between keys, smooth easing on the strike, anticipation under 3 frames, moving only the arms, clips with no hold on impact.

## Style checklist

- [ ] 3 to 5 clear extreme poses, different from neutral
- [ ] Strike covers its distance in 2 to 3 frames
- [ ] Strike pose is held 2 to 3 frames
- [ ] Anticipation 4 to 6 frames (more only on heavy moves)
- [ ] Hips, chest and head commit to the strike
- [ ] Recovery is at least 3 times the strike length
- [ ] Strike frame named and synced to damage and VFX

## Approval

Not tested yet. Make one M1 clip, show the owner in game, then mark it proven.
