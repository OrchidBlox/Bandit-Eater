# Style: crystal ethereal (draft, not yet tested on an effect)

Holy and arcane effects made of faceted crystal, glass and light: prisms, floating shards, halos, rays and shimmering particles in cool whites, golds and pale blues. Pure, elegant and radiant. Not smoky, not gritty.

Helpers: `Vfx/Crystal.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Mood | Core | Body | Edge | Highlight |
| --- | --- | --- | --- | --- |
| Holy | `#FFFFFF` | `#FFF1B8` | `#FFD36B` | `#FFFFFF` |
| Frost | `#FFFFFF` | `#BFE8FF` | `#6FB8FF` | `#E6F7FF` |
| Arcane | `#FFFFFF` | `#D9C2FF` | `#9A6BFF` | `#FFF1B8` |
| Verdant | `#FFFFFF` | `#CFFFE0` | `#5FD69A` | `#FFF1B8` |

White-gold cores with pale bodies; keep a rare warm gold highlight in every palette.

## Rules

1. **Facets and rays.** The hero is faceted shards, spires or a bright geometric sigil; light fans out as thin straight rays.
2. **Hero, halo, shimmer.** One crystalline hero, one halo or ring layer, and floating shimmer and light motes as the dust layer.
3. **Cool and bright** from the table; light surroundings are fine, avoid dark smoke.
4. **Materials:** Glass pieces with a faint Neon inner glow, plus Neon rays. Keep glass opaque enough that parts never vanish.
5. **Graceful timing:** a rising windup as shards gather, a bright chime-like release, shards float up and dissolve.
6. **Radiant feedback:** a halo ring and ray burst at the impact, a gentle camera lift, a soft chime.

## Assets this style needs

- `ray_fan` (thin radiating lines), `halo_ring`, `sparkle_four` (four-point glint), `mote_soft`, `prism_flare`.
- Mesh set from Codex: shards in three sizes, a long spire, a faceted gem, a hexagonal crystal column; neutral white, split into body and `_Glow`, recoloured in code (about 400 to 800 triangles each).

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.5 to 1.2 s | Shards rise and orbit inward, motes gather, a halo draws in |
| Release | 0 to 0.1 s | Shards snap into place, ray fan and halo flare |
| Hold | 0.3 s | Crystal glows at full, rays shimmer |
| Aftermath | 2 to 3 s | Shards float up and dissolve into motes |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | A spinning faceted gem with a small ray fan and a trail of glints, shatters into shards on impact |
| Ray or lance | A long crystal spear with a bright sleeve, glints along the path, a halo at the tip |
| Ground area | A sigil of crystal spires erupting from the floor, a halo ring, rising motes |
| Strike from above | A falling spire of light with a ray fan, a crystal burst and halo ring on landing |
| Charge or aura | Shards orbiting the caster, a faint halo behind the back, rising motes |
| Hit feedback | A four-point glint and a small shard burst at the impact |

## Helper API (proposed signatures)

```lua
Crystal.shard(parent, cframe, size, palette)         -- faceted shard from the shard mesh set; returns the part
Crystal.rays(parent, cframe, length, count, palette) -- thin ray fan that shimmers and fades
Crystal.halo(parent, cframe, radius, palette)        -- expanding halo ring
Crystal.motes(parent, cframe, count, palette)        -- rising shimmer motes
Crystal.shatter(shard, count)                        -- breaks a shard into small shards that dissolve
```

## Hero spells in this style

Hero shapes come from the Codex shard mesh set, assembled in code into spires, sigils and bursts. Creatures are elegant with faceted armour or crystal growths and glowing cores; cast animations are slow and graceful with an open release.

## Never

Smoke, soot, hard black outlines, heavy dark colours, glass pieces so transparent they vanish.

## Style checklist

- [ ] Hero is faceted shards or a geometric sigil
- [ ] Cool whites and blues with a gold highlight
- [ ] Halo plus ray burst at the impact
- [ ] Shimmer motes as the dust layer
- [ ] Shards dissolve and everything is cleaned up

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
