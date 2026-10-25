# Map style: low-poly nature (draft, not yet tested on an area)

Clean faceted forests, rocks, cliffs and water with flat shading and a harmonious natural palette. Calm and readable, like a stylised nature diorama. Not blocky simulator and not photoreal.

## Palette

| Use | Hex |
| --- | --- |
| Grass | `#6FAE4A` |
| Dark grass | `#4C8A3A` |
| Dirt path | `#B58A5A` |
| Rock | `#8A8F99` |
| Rock shade | `#5F6672` |
| Tree trunk | `#7A5236` |
| Autumn accent | `#E0883A` |
| Water | `#4FA3C7` |
| Sky and fog | `#CFE6F0` |

## Terrain and ground

Smooth terrain with gentle slopes, or faceted ground meshes; cliffs from big faceted rock meshes; water as a flat part or terrain water with a slightly lighter edge. Keep paths readable with lighter dirt.

## Materials

SmoothPlastic or Plastic for faceted props; Grass or Ground terrain materials at low contrast for terrain; no heavy textures.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Pine tree | 150 | Stacked cones |
| Round tree | 200 | Faceted blob canopy |
| Rock (3 sizes) | 80 to 250 | Faceted, two-tone |
| Bush, flowers | 60 | Instance heavily |
| Log, stump | 100 | |
| Cliff piece | 600 | Modular, tileable |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | ShadowMap |
| ClockTime | 16 to 17 (golden light) |
| Brightness | 2.5 |
| Ambient / OutdoorAmbient | `#7D8FA0` / `#A0B0C0` |
| Atmosphere | Density 0.3, Haze 1, Color `#D6E8F0` |
| Sky | Soft gradient sky, light clouds |
| Post effects | Bloom (0.3), ColorCorrection Contrast +0.05 |

## Layout and readability

Clearings carved out of forest; trees and rocks frame the play space and leave sight lines; clear trails; landmarks (a big rock or lone tree). Players in saturated clothes read well against muted greens.

## Scale and performance

Instance a few tree meshes thousands of times with random scale and rotation; use StreamingEnabled on large maps; keep canopy triangles low.

## Notes for Codex prop briefs

- Low-poly faceted shapes, flat shading, 2-tone colours (base plus shade), no textures.
- Build modular rocks and cliffs that tile; trees in three variants.
- Origin at the base; sizes in studs.

## Never

High-poly detail, noisy textures, bright neon colours, perfectly regular tree placement.

## Style checklist

- [ ] Faceted flat-shaded props with two tones
- [ ] Natural palette with one autumn accent at most
- [ ] Random scale and rotation on repeated props
- [ ] Clear trails and sight lines
- [ ] Meshes instanced, not unique

## Approval

Not tested yet. Build one clearing, show the owner, then mark it proven.
