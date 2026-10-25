# Style: retro pixel (draft, not yet tested on an effect)

Chunky voxel and 8-bit effects: square particles, stepped animation, limited palettes, big blocky bursts. Reads as a classic arcade or sandbox game. Not smooth or soft; everything is deliberately low resolution.

Helpers: `Vfx/Pixel.luau` (to build) on top of `Vfx/Kit`.

## Palettes (four to six flat colours each, no gradients)

| Element | Dark | Base | Light | Highlight | Accent |
| --- | --- | --- | --- | --- | --- |
| Fire | `#7A1F1F` | `#D8421F` | `#FF8A1F` | `#FFE36B` | `#FFFFFF` |
| Ice | `#1E3A6B` | `#3F7FD6` | `#8FD0FF` | `#E6F7FF` | `#FFFFFF` |
| Poison | `#1F4A2A` | `#3FA64B` | `#9BE36B` | `#E4FFB0` | `#B14BFF` |
| Lightning | `#3A3A8A` | `#FFD400` | `#FFF27A` | `#FFFFFF` | `#4BC8FF` |
| Shadow | `#16102A` | `#4B2D8A` | `#8A5BFF` | `#D8C2FF` | `#FF4B7A` |

Colour changes happen in steps from highlight down to dark as an effect ages.

## Rules

1. **Everything is a square.** Cube parts and square-pixel textures only; no spheres or smooth rings. Round shapes are built from cubes on a grid.
2. **Hero, burst, pixels.** One big blocky hero shape, one or two burst or ring layers made of cubes, and single-pixel sparks as the dust layer.
3. **Limited palette from the table**, flat, with colour changes in steps and no transparency fades (cubes shrink or vanish instead).
4. **Stepped motion.** Animate at 4 to 8 visible steps per second with Linear or stepped easing; scale and rotate in 45 or 90 degree jumps.
5. **Materials:** SmoothPlastic or Neon cubes; glow is a brighter colour step, not a blur.
6. **Arcade timing:** instant release, short aftermath where pixels fall and vanish one by one.
7. **Blocky feedback:** screen shake in whole-pixel jumps, a short hitstop on big hits, a cube burst at the impact.

## Assets this style needs

- `pixel_square` (solid white square for particles), optional `pixel_grid_overlay` (decal), 8-bit style sound set.
- No meshes needed: cubes come from parts. Optional Codex mesh set: voxel-style swords, skulls, arrows, hearts (neutral white, recoloured in code).

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.2 to 0.6 s | A pixel ring builds cube by cube, colour steps up |
| Release | 0 s | Burst of cubes in a 3D grid pattern |
| Hold | 0.1 s | Hero stays at full size, hitstop on big hits |
| Aftermath | 0.5 to 1.5 s | Cubes fall and vanish one by one, colour steps down |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | A 3x3 cube block with stepped colour, a trail of single cubes that vanish in order |
| Ray or lance | A line of cubes drawn in over 0.15 s, flicking between two colour steps |
| Ground area | A square or diamond ring of cubes that expands in steps, cubes hop on the rim |
| Strike from above | A tall column of cubes snapping down, a flat cube ring on landing, falling cube debris |
| Charge or aura | Cubes orbiting on a fixed square path, colour stepping up |
| Hit feedback | An 8-cube cross burst at the impact |

## Helper API (proposed signatures)

```lua
Pixel.cube(parent, cframe, size, color)            -- one flat cube part; returns the part
Pixel.block(parent, cframe, cells, color)          -- grid of cubes forming a shape
Pixel.burst(parent, cframe, count, palette)        -- cubes thrown on a grid pattern, falling and vanishing
Pixel.ring(parent, cframe, radius, palette)        -- square ring that expands in steps
Pixel.step(part, colors, interval)                 -- steps a part through palette colours
```

Cap total cubes at the shared part budget (40); use ParticleEmitters with `pixel_square` for the rest.

## Hero spells in this style

Hero shapes are voxel sculptures built from cubes or a Codex voxel mesh set (about 1000 triangles), flat colours with no textures. Creatures are blocky with step-animated poses (few keyframes, no easing); cast animations use hard snap poses.

## Never

Smooth gradients, soft glows, thin streaks, motion blur, spheres.

## Style checklist

- [ ] Only cubes and square particles; no smooth shapes
- [ ] Four to six flat colours, no gradients
- [ ] Motion is stepped, not eased smoothly
- [ ] Aftermath pixels fall and vanish; everything is cleaned up
- [ ] Reads as chunky at phone size

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
