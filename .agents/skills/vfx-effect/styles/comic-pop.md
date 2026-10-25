# Style: comic pop (draft, not yet tested on an effect)

Bold comic-book effects: thick black outlines, flat bright fills, halftone dots, speed lines and burst-shaped impact panels. Loud, graphic and funny. Not smooth or realistic, and not thin like anime-slick.

Helpers: `Vfx/Comic.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Use | Colour |
| --- | --- |
| Comic red | `#E8222B` |
| Comic yellow | `#FFD500` |
| Comic blue | `#1E63E8` |
| Comic cyan (secondary) | `#18C6E8` |
| Ink black | `#0A0A0A` |
| Paper white | `#FFFFFF` |

An effect uses two of the colours plus black outlines and white highlights. Yellow is the impact-burst colour.

## Rules

1. **Thick outlines on everything.** Heavy black outlines on every hero and support shape; fills are flat with at most one shading step.
2. **Hero, burst, dots.** One bold hero shape, one jagged starburst or shockwave layer, and halftone dots or small stars as the dust layer.
3. **Flat colour only** from the table: no gradients, no soft glow.
4. **Impact panels.** Every hit pops a jagged burst shape, optionally with a short word billboard, for 0.2 to 0.4 s.
5. **Materials:** SmoothPlastic with flat colour, Neon only for the burst's yellow; halftone through textures.
6. **Snappy and held:** a short windup, an instant release, a 0.1 s freeze on a heavy hit.
7. **Loud feedback:** screen shake in sharp jumps, a burst at the impact, speed lines along the motion.

## Assets this style needs

- `burst_jagged` (spiky starburst), `halftone_dots`, `speed_lines_card`, `star_hard`, `swoosh_arc`, and word billboards (`POW`, `BAM`, `ZAP`) drawn as flat textures with outlines.
- Optional mesh set from Codex: fat arrows, fists, stars and lightning bolts with thick flat faces; neutral white, outlined in code with Highlight or an inverted-hull shell.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.2 to 0.5 s | Hero shape squashes back, speed lines gather |
| Release | 0 to 0.05 s | Hero snaps forward, burst panel pops |
| Freeze | 0.1 s | Everything holds on heavy hits |
| Aftermath | about 1 s | Burst shrinks out, dots and stars scatter and vanish |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | An outlined flat shape with a swoosh arc trail and speed-line card behind it, a burst on impact |
| Ray or lance | A thick flat beam with a black outline, halftone fill stripes, a burst at the end |
| Ground area | A jagged burst laid flat on the floor, halftone ring on the rim, stars flying out |
| Strike from above | A big outlined fist or meteor dropping fast, a huge burst with a word billboard on landing |
| Charge or aura | A pulsing outlined halo, small hard stars orbiting |
| Hit feedback | A jagged yellow burst, optionally with a short word, plus a freeze on heavy hits |

## Helper API (proposed signatures)

```lua
Comic.outline(part, thickness)                  -- thick black outline (Highlight or inverted shell)
Comic.burst(parent, cframe, size, word)         -- jagged yellow burst with an optional word billboard
Comic.speedLines(parent, fromPos, toPos)        -- speed-line card along a path
Comic.dots(parent, cframe, count)               -- halftone dots and hard stars thrown outward
Comic.freeze(seconds)                           -- brief hitstop for heavy hits
```

## Hero spells in this style

Hero meshes are fat and simple (about 1000 triangles) with flat faces, neutral white with a thick black outline added in code. Creatures are exaggerated with big hands and simple faces; cast animations use extreme poses with a held smear frame on release.

## Never

Soft gradients, realistic smoke, thin outlines, desaturated colours.

## Style checklist

- [ ] Every shape has a thick black outline
- [ ] Flat primary fills; no gradients
- [ ] Impact makes a jagged burst
- [ ] Halftone or star dust layer
- [ ] Freeze on heavy hits, then clean-up

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
