# Reference breakdown: the pillar strike

From the owner's reference reel (a cyan pillar strike, 2026-10-16). This is the worked example of taking a clip apart so its treatment can be reused. Take the layers, colours and timing; keep each move's own motion.

## Layers

| Layer | What you see | How it is built in Roblox | Helper |
| --- | --- | --- | --- |
| Core | A pure white column, narrow, brighter than everything else | Neon cylinder, white, snaps from thin to wide in 0.06 s | `pillar` |
| Body | A wider coloured column around the core, see-through | Neon cylinder in the element colour, about 55% transparent | `pillar` |
| Streak sheets | Many thin vertical lines that lean outward at the base | Thin neon blocks tilted 3 to 8 degrees, alternating white and colour | `pillar` |
| Glass ring | A pale see-through ring that drifts up the beam and fades | Flat cylinder, white, 60% transparent, tweened up and out | `pillar` |
| Ground ring | A thin bright circle on the floor before the strike | Ground decal of a rune ring that grows and spins | `windupCircle` |
| Impact star | A hard white starburst at the base for a few frames | Billboard glint texture that pops in 0.14 s | `impactStar` |
| Spike lines | Long thin lines shooting sideways from the impact | One particle emitter of streaks stretched along velocity | `impactLines` |
| Mist halo | Pale dust rolling out along the ground | Ground decal of a dust ring, grows and fades in 0.55 s | `mist` |
| Dark flecks | Small dark and white debris through the light | A few small chunk parts; dark against bright makes the light read | (per game) |
| Outline | A hard edge on orbs and rings | Highlight with no fill and a dark outline | `outline` |

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.3 to 0.8 s | Ground ring grows and spins, the air darkens slightly |
| Release | 0 to 0.06 s | Everything appears at once: pillar snaps wide, ring flares, star pops |
| Hold | 0.14 s | The pillar stays full width; this is where the hit lands |
| Thin away | 0.24 s | Core narrows to nothing, streaks fade, the glass ring keeps rising |
| Aftermath | 0.5 to 1.5 s | Mist spreads, flecks fall, the ground ring fades |

## Rules to reuse

1. Thin to thick to thin: pop wide in under 0.1 s, hold a beat, thin away. Never fade softly from full width.
2. White core, coloured body: the brightest part is always white; the element colour lives around it.
3. Many thin lines beat one fat shape.
4. The ground reacts: a ring before, a flare and mist after.
5. Dark against bright: a few dark flecks and a dark floor make light look brighter than turning it up.
6. One floating ring is the cheapest way to add scale.
7. Frame it low: a short low camera push-in on heavy specials carries half the power (not built yet).
8. Hero only: multi-hit effects give the full treatment to one hit and a plain core to the rest.

## One recipe, every element

Same skeleton every time (windup ring, pop-in, white core, coloured body, thin streaks, one floating ring, star, mist, flecks). Only colours, streak shapes and leftovers change per element: lightning has forked streaks, ice's ring becomes shards, shadow has a dark body that pulls inward with no white core, fire leaves embers and smoke instead of mist, earth has no glow (slabs, dust, cracks).
