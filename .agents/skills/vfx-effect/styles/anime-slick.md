# Style: anime-slick (proven)

Clean, chunky, readable stylised shapes plus anime snap: sharp tapered silhouettes, speed streaks, hard-edged two-tone shading, thin dark outlines on hero shapes, and punchy timing (instant hit, short hold, fast settle). Saturated element colours, a bright glowing core on anything magic, dark or desaturated mass on anything physical. Think a stylish action anime, not photoreal and not rounded cartoon.

Helpers: `Vfx/Anime`.

## Rules

1. **Hero, support, dust.** Three layers of weight only: one big solid shape, one or two mid layers (ring, trail, glow), tiny sparks and motes.
2. **Glow = magic, matte = matter.** Energy pieces are Neon with a small bright core. Rock, steel and bark are SmoothPlastic or Metal and get drama from dust, cracks and smoke, never glow.
3. **Two colours plus a hot core** from `Vfx.Palettes`. No third accent, no rainbow gradients.
4. **Bright needs dark behind it** (smoke, scorch, dark flecks).
5. **Bold shape, sharp detail.** Thin linework (runes, streaks, outlines) lives at the edges; the main shape stays big and simple.
6. **Timing:** windup 0.3 to 1.0 s, sharp release, aftermath settling in 1 to 3 s. Fast in, tiny overshoot, 0.045 s hold on a heavy hit.
7. **Never a full-screen flash.** Impact frames are shapes, not screen brightness.
8. **Rarity changes size and richness, never style.**

## Helpers

| Rule | Helper |
| --- | --- |
| Hero shapes get a thin dark outline | `Anime.outline` |
| Projectiles are sharp arrow shapes with 2 to 4 thin hard streaks | `Anime.arrow`, `Anime.streaks`, `Anime.halo` |
| Straight shots get speed lines along their path | `Anime.travelStreaks` |
| Every impact: a hard four-point star and a radial burst of thin lines | `Anime.hit`, `impactStar`, `impactLines` |
| Every special opens with a magic circle on the ground | `Anime.windupCircle` |
| Big strikes from above: white core, coloured body, streak sheets, one glass ring | `Anime.pillar` |
| The ground answers with a pale mist ring | `Anime.mist` |

| The move is | Use |
| --- | --- |
| Auto attack or projectile | `arrow`, `streaks`, `outline(holder)`, `hit`, plus the element's own wrap as emitters |
| Straight ray or lance | `travelStreaks(from, to, ...)`, `impactStar` at both ends, `hit` |
| Ground area | `windupCircle`, then `impactLines(..., flat = true)` and `mist` on release |
| Strike from above | `pillar` (hero hit full, the rest `{ streaks = 0, body = false }`), `hit`, `mist` |
| Charge or aura | `windupCircle` and `outline` on the glowing orb |

## Style checklist

- [ ] Hero, support, dust: no more than three layers of weight
- [ ] Only the element's two colours and a hot core
- [ ] Something dark behind every bright effect
- [ ] Hero shapes outlined, impacts have a star and lines
- [ ] No full-screen flash
