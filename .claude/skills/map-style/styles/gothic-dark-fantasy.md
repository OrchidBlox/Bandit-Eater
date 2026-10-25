# Map style: gothic dark fantasy (draft, not yet tested on an area)

Ruined castles, graveyards, dead trees and fog under a low moon: weathered stone, iron and torchlight. Moody and ominous, readable through contrast between dark surroundings and small warm lights. Not bright or cute.

## Palette

| Use | Hex |
| --- | --- |
| Ground | `#2A2A30` |
| Stone | `#4A4D55` |
| Stone highlight | `#6A6E78` |
| Dead wood | `#3A2C24` |
| Iron | `#25272C` |
| Torch accent | `#FF9A3C` |
| Magic accent | `#7DF0A8` |
| Fog | `#1A1C24` |

## Terrain and ground

Cracked stone floors, mud and dead-grass terrain, uneven but with a flat, clear play space; broken walls and steps for height; shallow dark water or fog pools in low areas.

## Materials

Slate, Cobblestone, Concrete and Metal for stone and iron, matte only; WoodPlanks (dark) for wood; Neon only for torches, candles and magic accents. No shiny plastic.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Broken wall and arch | 600 | Modular pieces |
| Gravestone (3 variants) | 150 | |
| Dead tree | 400 | Twisted, sparse branches |
| Torch and brazier | 300 | The warm light source |
| Iron fence and gate | 300 | Repeat with a script |
| Statue or tower piece | 1500 | One-off landmark |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | ShadowMap or Future (if desktop-focused) |
| ClockTime | 0 to 2 (night) |
| Brightness | 0.5 |
| Ambient / OutdoorAmbient | `#202430` / `#2A3040` |
| Atmosphere | Density 0.45, Haze 2, Color `#1E2230` |
| Sky | Dark starry sky with a big pale moon |
| Post effects | Bloom (0.6) so torches glow, ColorCorrection Saturation -0.2 |

## Layout and readability

Dark surroundings with small pools of warm torchlight around the play space so players and enemies are lit; keep the arena floor lighter than the walls; use fog to hide the horizon but never the fight.

## Scale and performance

Limit point lights to a handful near play and reuse a torch prop; fog depth is cheap. Keep shadows on only for key lights on mobile.

## Notes for Codex prop briefs

- Weathered stone, broken edges, asymmetric silhouettes, 2-tone dark colours.
- Torch and candle pieces carry a `_Glow` object for the warm light.
- Modular walls and arches that snap together; origin at the base.

## Never

Bright cheerful colours, clean new surfaces, flat daylight, fog thick enough to hide gameplay.

## Style checklist

- [ ] Dark desaturated base with warm torchlight accents
- [ ] Play space is lit and readable
- [ ] Broken, weathered shapes, not clean ones
- [ ] Fog adds depth without hiding the fight
- [ ] Light count is within the mobile budget

## Approval

Not tested yet. Build one courtyard, show the owner, then mark it proven.
