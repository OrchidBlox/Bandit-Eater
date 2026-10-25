# Style: dark fantasy (draft, not yet tested on an effect)

Heavy, weighty effects in a dim, desaturated world with a few hot accents: smoke, embers, cracked ground, slow menace. Power reads through mass and aftermath rather than speed lines. Not bright candy colours and not anime outlines.

Helpers: `Vfx/Dark.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Mood | Base | Mid | Hot accent |
| --- | --- | --- | --- |
| Hellfire | `#1B1416` | `#4A2A24` | `#FF5A1F` |
| Necrotic | `#101612` | `#2E4A3A` | `#8CFF5A` |
| Blood | `#170C0F` | `#4A1620` | `#D6192E` |
| Frost | `#0F141A` | `#33475C` | `#9AD7FF` |
| Void | `#0B0A12` | `#2A2540` | `#B06BFF` |

Smoke is always a neutral grey-brown, never tinted by the accent. The accent appears only in the core, embers and one point light.

## Rules

1. **Mass first.** The hero is large, jagged and slow to arrive; the ground and air react (cracks, scorch, dust shelf, falling debris).
2. **Hero, smoke, embers.** One heavy shape, one or two layers of smoke or fog, and embers, ash or sparks as the dust layer.
3. **Desaturated base, one hot accent** used for the core, a few sparks and one light.
4. **Materials:** matte, Metal and SmoothPlastic for bodies; Neon only for the small hot core and embers. Soft smoke textures, not hard-edged shapes.
5. **Dark world, small light.** Effects may darken surroundings (a brightness dip is allowed) and carry a small coloured point light; no large bright flashes.
6. **Long, ominous windup** and a slow aftermath as smoke thins.
7. **Heavy feedback:** strong camera shake, a brief hitstop on big hits, a low thud sound.

## Assets this style needs

- `smoke_soft` (large soft puff), `smoke_wisp` (thin trailing), `ember` (small hard dot), `crack_ground` (decal), `scorch_ring` (decal), `ash_flake`.
- Optional mesh set from Codex: jagged spikes, broken-stone shards, bone-like claws; neutral dark grey, tinted in code.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.6 to 1.5 s | Light dims, smoke gathers toward the caster, ground rumbles |
| Release | 0 to 0.1 s | Heavy shape slams in, hitstop 0.06 s on big hits |
| Hold | 0.2 to 0.4 s | Core burns hot, embers pour |
| Aftermath | 2 to 4 s | Smoke thins, embers fall, cracks and scorch stay then fade |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | Dark mass with a hot core, a thick smoke trail, embers shed behind, scorch mark on impact |
| Ray or lance | Dark beam with a narrow hot core, smoke along the path, heat shimmer, crack decal at the end |
| Ground area | Cracks spread outward from the caster, smoke rises from them, one slow shockwave |
| Strike from above | A falling dark shape with a hot trail, crater decal, dust shelf, debris, long smoke column |
| Charge or aura | Smoke pulled toward the caster, a dim hot core, a low pulse light |
| Hit feedback | Ember burst and dark puff at the impact, short hitstop on heavy hits |

## Helper API (proposed signatures)

```lua
Dark.smoke(parent, cframe, size, duration)     -- soft grey-brown smoke column that thins out
Dark.embers(parent, cframe, count, accent)     -- falling hot embers with gravity
Dark.cracks(parent, cframe, radius)            -- ground crack decal that grows outward
Dark.scorch(parent, cframe, radius, fade)      -- scorch decal that fades
Dark.dim(amount, time)                         -- brief ambient darkening, restores itself
Dark.core(parent, cframe, size, accent)        -- small neon core with a point light
```

## Hero spells in this style

Hero meshes are jagged and asymmetric (about 2500 triangles), neutral dark grey with a small `_Glow` core. Creatures are gaunt and heavy with solid shading and glowing eyes only; cast animations are slow with a hard slam on release.

## Never

Bright candy colours, cartoon outlines, thin speed streaks, large bright flashes, smoke tinted rainbow colours.

## Style checklist

- [ ] Palette is desaturated with one hot accent
- [ ] Ground and air react (cracks, scorch, smoke)
- [ ] Hero is heavy; the windup is readable and ominous
- [ ] Smoke and embers are cleaned up when the effect ends
- [ ] No large bright flashes

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
