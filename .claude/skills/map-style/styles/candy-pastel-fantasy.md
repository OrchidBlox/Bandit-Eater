# Map style: candy pastel fantasy (draft, not yet tested on an area)

Soft rounded shapes, pastel meadows and cute props under a bright, sunny sky: cloud-puff trees, mushroom houses, candy details, floating islands. Friendly and playful, in the spirit of a Kirby-style game. Not gritty and not sharp.

## Palette

| Use | Hex |
| --- | --- |
| Meadow | `#A8E6A1` |
| Meadow accent | `#8ED68C` |
| Path | `#FFE6B8` |
| Rock and cliff | `#D8C8F0` |
| Pink accent | `#FF9EC4` |
| Sky blue | `#9ADCFF` |
| Sun yellow | `#FFE77A` |
| Water | `#7FD8FF` |

Cliffs are lilac or cream, never grey.

## Terrain and ground

Smooth rolling hills (smooth terrain or rounded meshes) in pastel greens; soft edges with rounded lips on platforms; floating islands with rounded undersides; shallow bright water. Keep the arena floor flat and calm.

## Materials

SmoothPlastic with pastel colours; a little Neon for glowing crystals, flowers and stars. Avoid rough or realistic materials.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Cloud-puff tree | 400 | Rounded canopy blobs, curved trunk |
| Mushroom house | 600 | Big cap, round door |
| Flowers and grass tufts | 100 | Instance heavily |
| Rounded rocks | 250 | Soft, lilac-tinted |
| Candy decorations (lollipops, swirls) | 300 | Accent, used sparingly |
| Floating island piece | 800 | Rounded underside |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | ShadowMap |
| ClockTime | 13 |
| Brightness | 3 |
| Ambient / OutdoorAmbient | `#B8B0E0` / `#C8C0F0` |
| Atmosphere | Density 0.25, Haze 0.5, Color `#F0E4FF` |
| Sky | Bright blue with big puffy clouds |
| Post effects | Bloom (0.5, soft), ColorCorrection Saturation +0.2, light SunRays |

## Layout and readability

An open circular arena with soft ramps and a few rounded cover pieces; pastel background props, with fighters and pickups in stronger saturated colours so they never blend into the ground.

## Scale and performance

Under 20k parts; round shapes cost triangles, so keep props to the budgets above and reuse meshes. Mobile friendly.

## Notes for Codex prop briefs

- Soft, rounded, chunky pastel shapes; flat colours with a white highlight; 400 to 800 triangles.
- Neutral base with a `_Glow` piece for crystals and flowers.
- No sharp points or dark colours; origin at the bottom centre.

## Never

Sharp spikes, dark or grey palettes, harsh fog, realistic textures.

## Style checklist

- [ ] Rounded shapes and soft edges throughout
- [ ] Pastel palette with one accent
- [ ] Gameplay objects are more saturated than the background
- [ ] Bright sunny lighting with soft atmosphere
- [ ] Flat, calm arena floor

## Approval

Not tested yet. Build one area, show the owner, then mark it proven.
