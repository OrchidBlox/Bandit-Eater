# Animation style: fluid martial arts (draft, not yet tested on a clip)

Flowing combos where each move hands its momentum to the next: continuous motion, overlapping action, circular arcs and smooth weight transfers, like a martial arts film. Beautiful in chains. Not stop-and-go, and not stiff. The hardest style to get right.

## Rules

1. **Momentum is passed on.** The end pose of a hit is the start of the next; avoid returning to neutral between hits.
2. **Arcs, not lines.** Hands, feet and weapons travel on curved paths; the body rotates around a spine axis.
3. **Overlapping action.** The torso leads, the arms follow a few frames later, the head and loose parts lag and settle after.
4. **Weight transfer.** The weight visibly moves from foot to foot; hips lead every strike.
5. **Smooth curves, sharp accents.** Smooth easing between poses, with one crisp accent frame (2-frame hold or snap) on each strike.
6. **Rhythm.** Combos have a beat: uneven spacing (quick-quick-slow) rather than even steps.
7. **Cancel windows.** The last third of each move is loose enough to blend into the next one.

## Timing guide (30 fps, starting values)

| Beat | Frames | What happens |
| --- | ---: | --- |
| Gather | 3 to 5 | Coil on the arc already in motion from the previous move |
| Strike | 3 to 4 | Arc whips through the target; accent hold of 1 to 2 frames |
| Flow-through | 6 to 8 | Momentum carries the body into the next stance |
| Recovery (final hit only) | 10 to 12 | Settle into a ready stance |

## Pose rules

- Each hit ends in an open stance that already points toward the next strike.
- Spine twists across the chest and hips with a 1-frame offset.
- Feet slide or pivot on the toes rather than stepping flat.

## Interpolation

Smooth (bezier or spline) curves with ease in and out, plus a 1 to 2 frame constant hold on the strike accent. Use the follow-through (overlap) offsets rather than uniform timing, and check the clip as a chain, not only alone.

## Move recipes

| Move | Build it like this |
| --- | --- |
| Idle | A relaxed ready stance with weight shifts between feet, 90 frames |
| Run | Smooth 18-frame loop with a long stride and a spiral torso twist |
| Jump | Springy crouch, spinning launch, landing that rolls into the next stance |
| M1 combo hit | 3 to 5 chained hits (14 to 18 frames each) that alternate hands and feet along arcs |
| Heavy or signature | A spinning or sweeping finisher that ends in a held pose |
| Dash | A gliding slide with the trailing leg dragging, 10 frames |
| Block | A flowing guard that starts from the current stance rather than snapping |
| Cast or special | Circular hand arcs that gather, then a sweeping release |
| Hit reaction | A roll with the hit then recover into stance |

## Notes for Codex briefs

- Animate combos as a chain so end poses match start poses.
- Add overlap offsets on the arms, head and any loose parts (1 to 3 frames of lag).
- Use arcs for every extremity path; check them with motion trails.
- Keep a crisp accent frame on each strike.

## Never

Returning to neutral between hits, straight-line limb paths, uniform timing, stiff torsos.

## Style checklist

- [ ] End pose of each move flows into the next
- [ ] Extremities move on arcs
- [ ] Torso leads and limbs overlap
- [ ] Weight transfers between feet
- [ ] Each strike has a crisp accent

## Approval

Not tested yet. Make a three-hit chain, show the owner in game, then mark it proven.
