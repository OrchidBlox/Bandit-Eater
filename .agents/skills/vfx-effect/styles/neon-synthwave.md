# Style: neon synthwave (draft, not yet tested on an effect)

Glowing grid-and-laser effects for a sci-fi or cyber world: hard neon lines, scanlines, holograms and glitches against dark backgrounds, magenta and cyan. Technological and cool rather than magical or organic. Not warm or soft, and not anime outlines.

Helpers: `Vfx/Neon.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Pair | Hue A | Hue B | Core |
| --- | --- | --- | --- |
| Classic | `#00F0FF` | `#FF2BD6` | `#FFFFFF` |
| Sunset | `#FF7A18` | `#FF2BD6` | `#FFF4D6` |
| Matrix | `#00FF9C` | `#0A4F3A` | `#E6FFF3` |
| Alarm | `#FF2B4B` | `#FFB000` | `#FFFFFF` |

Use one pair per effect plus a white-hot core, on dark. The surround is dark navy `#07061A`; effects may dim the area slightly.

## Rules

1. **Straight lines and geometry.** Beams, grids, hexagons, rings and wireframes; curves are perfect circles or arcs.
2. **Hero, lines, bits.** One bold glowing hero, one or two layers of grid lines, rings or scanlines, and small data bits as the dust layer.
3. **Two neon hues from the table plus a white-hot core**, on a dark surround.
4. **Materials:** Neon everywhere, a little Glass for holograms, thin parts for lines. Bloom comes from a faint wider, more transparent copy of each line, never from a screen flash.
5. **Glitch accents:** a quick two-frame offset or colour split on release and on hit, never longer than 0.15 s.
6. **Crisp timing:** lines draw in, instant release, lines fade from the ends inward.
7. **Electric feedback:** a ring and grid ripple on the floor, a short camera jolt, a low synth pulse sound.

## Assets this style needs

- `grid_tile` (square grid, grey on black to alpha), `scanline` (horizontal lines), `hex_cell`, `ring_thin`, `data_bit` (small square or glyph), `glow_line` (soft wide line for bloom).
- Optional mesh set from Codex: hexagonal prisms, wireframe polyhedra, thin ring and arc meshes; neutral white, recoloured in code.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.3 to 0.8 s | Lines draw in around the caster, a grid fades in on the floor |
| Release | 0 to 0.05 s | Beam fires, glitch offset for two frames |
| Hold | 0.15 s | Everything at full brightness |
| Aftermath | 0.5 to 2 s | Lines fade from the ends inward, grid ripples out and fades |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | A glowing diamond or short beam with a long thin line trail, data bits shed behind |
| Ray or lance | A thin white core beam in a wider coloured sleeve, scanline texture scrolling along it |
| Ground area | A grid that spreads across the floor, hex cells flashing on the rim, a ring ripple |
| Strike from above | A vertical beam with a ring stack descending, a grid ripple and glitch flash on landing |
| Charge or aura | Concentric thin rings rotating around the caster, a small hologram glyph overhead |
| Hit feedback | A hex ring and a glitch offset at the impact, data bits flying out |

## Helper API (proposed signatures)

```lua
Neon.line(parent, fromPos, toPos, width, palette)     -- neon line with a wide faint bloom copy
Neon.grid(parent, cframe, size, palette, duration)    -- floor grid that fades in and ripples
Neon.ring(parent, cframe, radius, palette)            -- thin neon ring that expands and fades
Neon.glitch(parts, duration)                          -- two-frame offset and colour split, then restores
Neon.bits(parent, cframe, count, palette)             -- small data bits thrown outward
```

## Hero spells in this style

Hero meshes are clean geometry (about 800 triangles), neutral white so code can tint them, with the glow carried by Neon material. Creatures are robotic or holographic with segmented bodies and light strips; cast animations are precise and mechanical with hard stops.

## Never

Organic textures, warm earthy colours, smoke, fullscreen flashes, soft painterly edges.

## Style checklist

- [ ] Shapes are lines, grids and perfect geometry
- [ ] Two neon hues plus a white-hot core on a dark surround
- [ ] Glow comes from layered wide copies, not a screen flash
- [ ] Glitch accents last 0.15 s or less
- [ ] Lines fade out and everything is cleaned up

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
