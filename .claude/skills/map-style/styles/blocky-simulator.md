# Map style: blocky simulator (draft, not yet tested on an area)

The classic bright Roblox look: chunky flat-coloured shapes, studs or smooth plastic, big readable landmarks and saturated simple colours. Fast to build, runs everywhere and reads instantly. Not detailed or moody.

## Palette

| Use | Hex |
| --- | --- |
| Grass | `#5BC236` |
| Grass accent (stripes) | `#4AA82C` |
| Path | `#E6C98E` |
| Stone | `#9AA3AD` |
| Wood | `#A66A3A` |
| Water | `#3FA9F5` |
| Accent (signs, gates) | `#FFCB3D` |
| Sky and fog | `#BDE6FF` |

## Terrain and ground

Flat plates and wide platforms (parts, not smooth terrain); alternate two close greens in stripes or checker for scale. Paths are lighter flat strips. Water is a flat transparent blue part. Edges are clean block steps, never noisy.

## Materials

SmoothPlastic and Plastic for almost everything; Grass material only on big flat ground if you want a subtle texture; Wood for fences and bridges. Avoid realistic materials and detailed textures.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Tree (cube canopy) | 200 | Trunk plus 1 to 3 cube blobs |
| Fence section | 100 | Repeat with a script |
| Rock cluster | 150 | 3 chunky rocks |
| Sign, gate, lantern | 150 to 400 | Landmarks; bright accent colour |
| Building | 400 to 800 | Box with a coloured roof and door |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | ShadowMap (Compatibility if mobile-heavy) |
| ClockTime | 14 |
| Brightness | 2.5 |
| Ambient / OutdoorAmbient | `#8FA0B8` / `#A8B8CC` |
| Atmosphere | Density 0.2, Haze 0, Color `#C8E4FF` |
| Sky | Clear blue sky with a few clouds |
| Post effects | Light Bloom (0.3), ColorCorrection Saturation +0.15 |

## Layout and readability

Large open spaces with clear landmarks; one obvious central feature; fences and cliffs define lanes. Gameplay objects use the brightest colours; background props stay mid-tone.

## Scale and performance

Under 15k parts is easy; use unions sparingly. Instance the same meshes. No streaming needed for small maps.

## Notes for Codex prop briefs

- Blocky low-poly, chunky Roblox simulator shapes, flat colours, 2 to 3 colours per prop.
- No texture detail; colours from the palette; neutral base with `_Glow` pieces only where lit.
- Size in studs in the brief; origin at the bottom centre.

## Never

Realistic textures, noisy terrain, dark fog, tiny detail, more than three colours per prop.

## Style checklist

- [ ] Flat colours from the palette
- [ ] Big readable landmarks
- [ ] Clean block edges, no noisy terrain
- [ ] Gameplay objects pop against the ground
- [ ] Runs well at phone size

## Approval

Not tested yet. Build one area, show the owner, then mark it proven.
