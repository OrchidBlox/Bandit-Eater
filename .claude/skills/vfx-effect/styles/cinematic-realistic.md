# Style: cinematic realistic (draft, not yet tested on an effect)

Grounded, film-like effects: believable fire, smoke, sparks, dust and light with real physics and restrained colour. Serious and weighty. Not stylised outlines, not cartoon shapes.

Helpers: `Vfx/Cinema.luau` (to build) on top of `Vfx/Kit`.

## Palettes (natural, never tinted rainbow)

| Element | Core | Body | Smoke or residue |
| --- | --- | --- | --- |
| Fire | `#FFF2C2` | `#FF8A1F` to `#C93A0F` | `#2A2522` |
| Electricity | `#FFFFFF` | `#9FD0FF` | `#3A3F4A` |
| Explosion | `#FFE9A8` | `#FF6A1A` | `#4A423B` |
| Magic energy | `#FFFFFF` | one saturated hue, kept physical | `#2E2E36` |
| Dust and debris | `#CBB89A` | `#8C7A63` | `#5A4E40` |

Colour comes from temperature: white-yellow cores, orange bodies, grey-brown smoke that darkens as it ages.

## Rules

1. **Physical, not symbolic.** Fire rises, smoke drifts and expands, sparks fall with gravity, debris bounces.
2. **Hero, volume, detail.** One main body, one or two layers of volume (smoke, dust, steam), and fine sparks, embers and grit.
3. **Natural colour** from the table; no rainbow, no flat fills.
4. **Materials:** ParticleEmitters with soft textures and additive or alpha blends, a real point light with flicker, little Neon. Meshes only for solid debris.
5. **Realistic timing:** a short buildup, a violent release that decays on a curve, and a long aftermath as smoke thins.
6. **Physical feedback:** strong camera shake with fast decay, a decaying light flash (never above the brightness rule), debris, a dust shelf and ground scorch.
7. **Spend the particle budget on the hero** and keep every other layer cheap.

## Assets this style needs

- `smoke_soft_a`, `smoke_soft_b`, `fire_flipbook` (4x4 sheet), `spark_streak`, `debris_chunk`, `dust_puff`, `scorch_decal`, `crater_decal`, `heat_haze` (optional distortion plane).
- Optional mesh set from Codex: rock chunks, splintered wood, metal shards in several sizes; realistic grey, tinted in code.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |
| Buildup | 0.3 to 0.8 s | Light flickers up, dust lifts, ground trembles |
| Release | 0 to 0.15 s | Fire and sparks burst, light flash decays on a curve |
| Hold | 0.3 to 0.6 s | Fire body burns, smoke starts rising |
| Aftermath | 3 to 6 s | Smoke thins and drifts, embers fall, scorch fades |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | A flickering fire or energy core, a heat trail with smoke, sparks falling behind, a fireball and debris on impact |
| Ray or lance | A bright beam with a hot core, sparks flying off the path, smoke at the origin, scorch line on the ground |
| Ground area | A shockwave ring that kicks up a dust shelf, cracks and debris, rolling smoke |
| Strike from above | A falling fire or energy streak, an impact fireball, debris, a mushrooming smoke column, a crater decal |
| Charge or aura | Heat shimmer and rising embers around the caster, a flickering light that builds |
| Hit feedback | A spark shower and a short dust puff at the point of impact, small camera shake |

## Helper API (proposed signatures)

```lua
Cinema.fire(parent, cframe, size, duration)        -- flipbook fire body with a flickering light
Cinema.smoke(parent, cframe, size, duration)       -- expanding smoke that darkens and thins
Cinema.sparks(parent, cframe, count, speed)        -- gravity sparks with streak textures
Cinema.debris(parent, cframe, count, meshes)       -- thrown chunks that bounce and fade
Cinema.shock(parent, cframe, radius)               -- shockwave ring with a dust shelf
Cinema.scorch(parent, cframe, radius, fade)        -- scorch or crater decal
```

## Hero spells in this style

Hero shapes are mostly particles and light; add meshes only for debris, rock and metal (about 500 triangles each). Creatures use realistic proportions with detailed textures and subtle glow; cast animations are weighted and grounded, with believable anticipation.

## Never

Outlines, flat cartoon fills, speed lines, symbolic shapes, brightness above the budget rule.

## Style checklist

- [ ] Fire, smoke and sparks obey gravity and drift
- [ ] Natural colours with a bright core
- [ ] Ground reacts (scorch, dust, debris)
- [ ] Light flash decays and stays under the brightness rule
- [ ] Smoke thins out and leftover is 0

## Approval

Not tested yet. Make one effect, show the owner, then mark it proven.
