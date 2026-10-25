# Style: ink wash (draft, not yet tested on an effect)

Black ink brush strokes on a pale world: bold sweeping strokes, splatter, bleeding edges, one red or gold seal-colour accent. Calm, deadly and graphic, like sumi-e painting or a samurai film. Not colourful and not glowing.

Helpers: `Vfx/Ink.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Use | Colour |
| --- | --- |
| Ink black | `#0D0D10` |
| Ink grey (wash) | `#5A5A63` |
| Pale wash | `#C9C6BD` |
| Paper | `#F1EDE2` |
| Seal red (accent) | `#C8281E` |
| Seal gold (accent) | `#D9A441` |

One accent per game, used for the core and the impact seal only. Everything else is ink black, grey and pale wash.

## Rules

1. **Strokes, not shapes.** A few confident brush strokes with tapered ends and rough, bleeding edges; leave empty space.
2. **Hero, splatter, drips.** One sweeping stroke shape, one or two wash or ring layers, and ink flecks and drips as the dust layer.
3. **Near-monochrome** with the single accent. Effects may lighten the surroundings slightly.
4. **Materials:** matte, SmoothPlastic and flat textured decals; Neon only for the accent. Prefer decals and textured ribbons to solid parts.
5. **Deliberate timing:** a still windup, a single fast stroke on release, ink bleeds and fades.
6. **Graphic feedback:** a stamped seal or splatter at the impact, a tiny camera nudge, a brief hold on the killing blow.

## Assets this style needs

- `brush_stroke_long`, `brush_stroke_short`, `ink_splatter_a`, `ink_splatter_b`, `ink_drip`, `wash_circle` (enso-like ring with a gap), `seal_stamp` (square seal mark), `paper_grain`.
- Optional mesh set from Codex: flat curved ribbon strips with tapered ends, thin blade shapes; neutral black, tinted in code.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.4 to 1.0 s | A faint wash circle draws in, everything goes still |
| Release | 0 to 0.12 s | One stroke sweeps through the path in a single fast pass |
| Hold | 0.2 s | The stroke stays at full ink, splatter lands |
| Aftermath | 1 to 3 s | Ink bleeds outward at the edges and fades to pale grey |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | A tapered brush stroke head with a long thin tail, flecks shed behind, a seal stamp on impact |
| Ray or lance | One long stroke drawn across the path in 0.12 s, splatter at the far end |
| Ground area | A wash circle that expands with a ragged edge, splatter rising from the rim |
| Strike from above | A single vertical stroke slamming down, a splatter star on landing, a seal stamp |
| Charge or aura | A slowly drawn enso circle around the caster, a few drips falling |
| Hit feedback | A small splatter and a seal stamp at the point of impact |

## Helper API (proposed signatures)

```lua
Ink.stroke(parent, fromPos, toPos, width, duration)   -- tapered brush stroke drawn along the path
Ink.splatter(parent, cframe, radius, count)           -- ink splatter decals that dry and fade
Ink.wash(parent, cframe, radius, duration)            -- wash ring that expands with a ragged edge
Ink.seal(parent, cframe, size, accent)                -- accent seal stamp that fades
Ink.drips(parent, cframe, count)                      -- ink drips falling from a point
```

## Hero spells in this style

Hero meshes are flat strokes and blades (about 600 triangles), neutral black, with the accent as a thin `_Glow` core. Creatures are drawn as calligraphic silhouettes with very few colours; cast animations are still, then a single decisive sweep.

## Never

Glow gradients, rainbow colours, smoke puffs, more than one accent colour.

## Style checklist

- [ ] Hero reads as a few tapered brush strokes
- [ ] Palette is black and grey plus one accent
- [ ] Splatter or seal at the impact
- [ ] Plenty of empty space; nothing busy
- [ ] Ink fades out and everything is cleaned up

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
