# Map style: neon cyberpunk (draft, not yet tested on an area)

A night city of dark towers, glowing signs, wet streets and neon trim: magenta and cyan light on near-black surfaces, holograms and steam. Loud, futuristic and moody. Not daylight and not natural.

## Palette

| Use | Hex |
| --- | --- |
| Asphalt | `#14141C` |
| Building | `#1E2030` |
| Metal | `#3A3F52` |
| Neon cyan | `#00F0FF` |
| Neon magenta | `#FF2BD6` |
| Warning orange | `#FF8A1F` |
| Sky and fog | `#0A0820` |

Two neon hues per area plus one warning accent.

## Terrain and ground

Flat asphalt plazas and rooftops (parts); glossy wet-road look; stairs, ramps and catwalks for height; low fog pooling at street level; a dark river or canal with reflections if needed.

## Materials

SmoothPlastic and Metal with low Roughness-style looks (use Reflectance 0.1 to 0.3 on wet ground); Glass for windows and holograms; Neon for trim, signs and lights.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Tower segment | 800 | Modular, with window strips |
| Neon sign (billboard) | 200 | Texture or neon parts |
| Street light | 300 | `_Glow` pole top |
| Vent and pipe cluster | 400 | |
| Vehicle (parked) | 1500 | Static decoration |
| Holographic sign | 200 | Glass plus neon |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | ShadowMap (Future on desktop-only) |
| ClockTime | 0 |
| Brightness | 0.3 |
| Ambient / OutdoorAmbient | `#1A1840` / `#241E50` |
| Atmosphere | Density 0.35, Haze 1.5, Color `#2A1E50` |
| Sky | Dark city sky, optional neon glow at the horizon |
| Post effects | Bloom (0.8, wide), ColorCorrection Contrast +0.1, Saturation +0.1 |

## Layout and readability

A plaza or rooftop arena with neon edges marking the boundary; tall towers frame the sky; neon colour coding for lanes or teams; keep emissive signs out of the sight lines that matter.

## Scale and performance

Neon parts are cheap; point lights are not, so use few real lights and fake glow with Neon parts and Bloom. Avoid many reflective parts on mobile.

## Notes for Codex prop briefs

- Dark sci-fi geometry with clean panel lines; windows and trim in separate `_Glow` objects.
- Modular tower and walkway pieces; origin at the base.
- Keep colours neutral dark; neon colour is applied in code.

## Never

Daylight, natural textures, warm earthy palettes, dozens of real point lights.

## Style checklist

- [ ] Near-black surfaces with two neon hues
- [ ] Glow is Neon plus Bloom, not many point lights
- [ ] Play space is lit by the neon, not lost in the dark
- [ ] Fog adds depth at street level
- [ ] Mobile light and reflection budget respected

## Approval

Not tested yet. Build one plaza, show the owner, then mark it proven.
