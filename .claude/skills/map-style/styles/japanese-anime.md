# Map style: Japanese anime (draft, not yet tested on an area)

Torii gates, stone lanterns, wooden bridges, cherry blossoms and temple roofs under warm sunset or clear daylight. Serene, stylish and graphic, like an anime background painting. Not realistic and not blocky.

## Palette

| Use | Hex |
| --- | --- |
| Ground (packed earth) | `#CDB992` |
| Moss and grass | `#7FA865` |
| Vermilion (torii, rails) | `#D6392B` |
| Dark wood | `#4A3326` |
| Roof tile | `#3A4252` |
| Blossom pink | `#F8B8D0` |
| Stone | `#A8ADB5` |
| Sky (sunset) | `#FFC59A` |

One accent: vermilion. Blossom pink is a seasonal accent.

## Terrain and ground

Raked gravel and packed-earth courtyards, stone paths, moss patches; small ponds with stepping stones; stepped stone terraces; a wooden bridge over water; low hills in the distance.

## Materials

SmoothPlastic and Wood for structures; Slate for stone; Neon only for lantern glow. Keep surfaces clean with simple colour blocking.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Torii gate | 800 | Landmark, vermilion |
| Stone lantern | 400 | Repeat along paths |
| Temple building | 2500 | Layered curved roofs |
| Cherry blossom tree | 500 | Rounded pink canopy |
| Wooden bridge | 600 | Arched |
| Fence and rope barrier | 150 | Repeat with a script |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | ShadowMap |
| ClockTime | 17.5 (sunset) |
| Brightness | 2.5 |
| Ambient / OutdoorAmbient | `#C89A8A` / `#D8A890` |
| Atmosphere | Density 0.3, Haze 1.5, Color `#FFD8C0` |
| Sky | Warm gradient with soft clouds |
| Post effects | Bloom (0.5), SunRays (0.15), ColorCorrection Tint warm |

## Layout and readability

A central courtyard or bridge as the arena; torii gates and lanterns frame the edges and mark lanes; keep falling blossoms light so they never hide telegraphs.

## Scale and performance

Falling petals are particles, capped and distance-culled; reuse lantern and fence meshes; moderate triangle budgets.

## Notes for Codex prop briefs

- Clean stylised Japanese architecture, flat colours with simple shading, curved roof lines.
- Torii in vermilion with dark pillars; lanterns with a `_Glow` object.
- Origin at the base; modular fence and path pieces.

## Never

Realistic textures, cluttered detail, harsh midday light, particles that hide the fight.

## Style checklist

- [ ] Warm sunset palette with vermilion as the one accent
- [ ] Torii, lanterns and curved roofs read as Japanese
- [ ] Petals do not hide gameplay
- [ ] Clean surfaces and simple colour blocking
- [ ] Courtyard floor is clear and flat

## Approval

Not tested yet. Build one courtyard, show the owner, then mark it proven.
