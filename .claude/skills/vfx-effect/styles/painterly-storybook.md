# Style: painterly storybook (draft, not yet tested on an effect)

Soft, hand-painted effects that feel like an illustrated fairy tale: gentle gradients, brush-stroke textures, drifting petals, wisps and dust motes, warm light. Magical and calm rather than punchy. Not hard-edged like anime-slick and not gritty like dark fantasy.

Helpers: `Vfx/Painterly.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Mood | Light | Mid | Deep | Highlight |
| --- | --- | --- | --- | --- |
| Meadow | `#CFE8A9` | `#8FBF7A` | `#4F8A5B` | `#FFF3D1` |
| Dusk | `#F4C6A5` | `#D98C8C` | `#7C5C8A` | `#FFF3D1` |
| Tide | `#BFE3E8` | `#7FB5CF` | `#456E9B` | `#FFF3D1` |
| Ember | `#F7D199` | `#E8955A` | `#A8503C` | `#FFF3D1` |

Three hues at most per effect, always with the warm cream highlight. Muted and slightly chalky.

## Rules

1. **Soft edges, flowing shapes.** Curves, ribbons and swirls; shapes feather out at the borders.
2. **Hero, ribbon, motes.** One flowing hero shape, one or two ribbon or glow layers, and drifting petals, leaves, light motes or dust.
3. **Warm, harmonious palette** from the table; never neon-harsh.
4. **Materials:** ParticleEmitters with painterly textures over solid parts; Neon only as a faint glow beneath soft textures. No outlines; edges come from value contrast.
5. **Gentle timing:** a slow swell, a soft bloom on release instead of a snap, a long drifting aftermath.
6. **Subtle feedback:** a warm light pulse and a ring of petals or motes, a very small camera sway, no hitstop.

## Assets this style needs

- `brush_stroke_a`, `brush_stroke_b` (wide tapered strokes), `watercolour_bloom` (soft blotch with a darker rim), `petal`, `leaf`, `mote_soft`, `wisp` (thin curved smoke), `paper_grain` (optional overlay for ground decals).
- Optional mesh set from Codex: soft ribbon curves and simple leaf or petal clusters; low poly, neutral cream, recoloured in code.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.5 to 1.2 s | Motes drift toward the caster, ribbons swell |
| Release | 0.1 to 0.3 s | Soft bloom expands, petals scatter |
| Hold | 0.3 s | Hero shape glows warmly |
| Aftermath | 2 to 4 s | Petals and motes drift upward and fade |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | A glowing wisp head with two trailing brush-stroke ribbons, petals shed behind |
| Ray or lance | A broad soft ribbon that widens then narrows, motes along the edges, a bloom at the end |
| Ground area | A watercolour bloom decal that spreads, petals rising from its rim |
| Strike from above | A falling streak of soft light, a bloom and petal ring on landing |
| Charge or aura | A slow orbiting ribbon around the caster, rising motes |
| Hit feedback | A small bloom and a ring of petals at the point of impact |

## Helper API (proposed signatures)

```lua
Painterly.ribbon(parent, fromCf, toCf, width, look)   -- tapered brush-stroke ribbon; returns the part
Painterly.bloom(parent, cframe, radius, look)         -- watercolour decal that spreads and fades
Painterly.petals(parent, cframe, count, look)         -- drifting petals or leaves with sway
Painterly.motes(parent, cframe, count, look)          -- slow rising light motes
Painterly.glow(parent, cframe, size, look)            -- faint soft glow beneath the hero
```

## Hero spells in this style

Hero meshes are soft and curved (about 1500 triangles), cream or pale grey with a separate `_Glow`; use them as bases for ribbons and leaf clusters. Creatures are gentle and rounded with soft shading; cast animations are flowing with a slow open-palm release.

## Never

Hard outlines, needle-thin streaks, black smoke, harsh flashes, neon colours.

## Style checklist

- [ ] Every shape has soft or feathered edges
- [ ] Three related hues at most, muted, with a warm highlight
- [ ] Release blooms rather than snaps; aftermath drifts
- [ ] Dust layer is petals, motes or wisps
- [ ] No outlines, hard streaks or harsh flashes

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
