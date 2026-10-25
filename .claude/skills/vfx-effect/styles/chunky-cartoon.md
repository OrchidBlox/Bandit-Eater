# Style: chunky cartoon (draft, not yet tested on an effect)

Bright, rounded, bouncy effects that match the blocky simulator look of the game's UI: fat shapes, soft edges, saturated candy colours, squash and stretch. Friendly rather than fierce. Not sharp and streaky like anime-slick, and not gritty.

Helpers: `Vfx/Cartoon.luau` (to build) on top of `Vfx/Kit`.

## Palettes

| Element | Body | Highlight | Shade |
| --- | --- | --- | --- |
| Fire | `#FF8A1F` | `#FFD34D` | `#E0481B` |
| Water | `#3FB6FF` | `#BDEBFF` | `#1E6FE0` |
| Nature | `#5BD65B` | `#C9F7A0` | `#2E9B3E` |
| Lightning | `#FFE23D` | `#FFFBD0` | `#F2A900` |
| Shadow | `#9B5CFF` | `#D9C2FF` | `#5A2DB5` |
| Light | `#FFF1A8` | `#FFFFFF` | `#FFCF5C` |
| Wind | `#7FE8CF` | `#E8FFF8` | `#2FAE93` |
| Earth | `#B98443` | `#EBC48C` | `#6B4423` |
| Sword | `#C9D3DE` | `#FFFFFF` | `#6E7F94` |
| Bandit (base model) | `#FFD93D` | `#FFF3A0` | `#E0A800` |

Every effect uses one element's body plus its highlight and shade, plus white puffs. The shade is the outline colour.

## Rules

1. **Round and fat.** Spheres, blobs, thick rings and stars with rounded points. Nothing needle-thin.
2. **Hero, support, confetti.** One big bouncy shape, one or two supporting puffs or rings, and small stars, hearts or sparkles as the dust layer.
3. **Candy colour.** Bright saturated body, white highlight, one darker shade. No dark smoke; white cloud puffs are the dust.
4. **Squash and stretch.** Shapes overshoot their size by 15 to 25% and settle back (Back or Elastic easing). Pops, not snaps.
5. **Soft glow, thick shade outline.** Outlines are a darker shade of the fill, never black linework.
6. **Slightly slower than anime-slick**, with a bounce on release.
7. **Friendly feedback:** stars pop at the impact, a small camera bump, no hitstop.

## Assets this style needs

- `soft_puff` (round cloud puff, grey on black to alpha), `star_round` (five-point star with rounded tips), `heart`, `sparkle_cross`, `ring_thick` (fat ring).
- Optional mesh set from Codex: rounded hero blobs, thick rings, a fat arrow, chunky shards; neutral white, recoloured in code.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Windup | 0.4 to 1.0 s | Hero swells with a wobble, puffs gather |
| Release | 0 to 0.1 s | Pop to 120% size, ring and stars burst |
| Settle | 0.2 s | Back to 100% with an elastic bounce |
| Aftermath | 1 to 2 s | Puffs drift and shrink, stars twinkle out |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | Fat glowing ball with a shade-colour outline, a trail of shrinking puffs, a star pop on impact |
| Ray or lance | Thick tube with round caps, wobbling width, ring pops at both ends |
| Ground area | Fat ring that bounces outward, puffs along the rim, stars on the ground |
| Strike from above | A big round meteor or fist that squashes on landing, shock ring, puff ring |
| Charge or aura | Pulsing rounded halo, orbiting small stars, slow squash on the caster's chest |
| Hit feedback | Round star pop sized to the damage, tiny camera bump |

## Helper API (proposed signatures)

```lua
Cartoon.blob(parent, cframe, size, look)        -- round hero shape with outline; returns the part
Cartoon.pop(part, scale, time)                  -- squash-and-stretch overshoot tween
Cartoon.puffs(parent, cframe, count, look)      -- white cloud puffs that drift and shrink
Cartoon.stars(parent, cframe, count, look)      -- round star and heart burst
Cartoon.ring(parent, cframe, radius, look)      -- fat ring that bounces outward
```

All helpers parent into the effect folder and destroy themselves; none outlive the effect.

## Hero spells in this style

Hero meshes are rounded and chunky (triangle budget about 1500 each), neutral white, split into body and `_Glow`. Creatures are plump with big simple eyes; cast animations use big anticipation poses and a bouncy release.

## Never

Thin streaks, heavy black outlines, gritty textures, dark smoke, hitstop.

## Style checklist

- [ ] Every shape is rounded; nothing needle-thin
- [ ] One element body, highlight and shade plus white; no dark smoke
- [ ] Squash and stretch on the hero shape
- [ ] Dust layer is stars, puffs or sparkles
- [ ] Reads as friendly at phone size

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
