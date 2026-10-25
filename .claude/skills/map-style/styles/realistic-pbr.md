# Map style: realistic PBR (draft, not yet tested on an area)

Grounded, detailed environments with physically based materials, natural lighting and believable scale: weathered surfaces, real foliage, soft shadows. Immersive and film-like. Not stylised, and it is the most expensive style to build and run.

## Palette (natural, desaturated)

| Use | Hex |
| --- | --- |
| Soil | `#5A4A3A` |
| Grass | `#4F6B3A` |
| Concrete | `#8C8C88` |
| Wood | `#6A4A32` |
| Rust | `#8A4A2A` |
| Sky and fog | `#B8C8D8` |

Colour comes from material textures; palette values guide the average tint only.

## Terrain and ground

Smooth terrain with real material blends (Grass, Mud, Rock, Sand); detailed ground meshes and decals for cracks and stains; believable slopes; water with Terrain water settings.

## Materials

PBR SurfaceAppearance with ColorMap, NormalMap, RoughnessMap and MetalnessMap on key meshes; use built-in Roblox materials with MaterialVariants for the rest. Avoid Neon except for light sources.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Hero building | 8000 | PBR textures |
| Modular wall and floor | 1500 | Tileable |
| Tree | 3000 | Billboard LODs far away |
| Rock | 1500 | |
| Debris and clutter | 200 to 800 | Instanced |
| Vehicle | 6000 | |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | Future (ShadowMap fallback) |
| ClockTime | 15 |
| Brightness | 3 |
| Ambient / OutdoorAmbient | `#707A88` / `#8896A8` |
| Atmosphere | Density 0.3, Haze 1, Color `#C8D4E0` |
| Sky | Realistic daytime sky with soft clouds |
| Post effects | Bloom (0.3), DepthOfField (subtle), ColorCorrection Contrast +0.05, SunRays (0.1) |

## Layout and readability

Realistic spaces still need clear lanes: use light, props and colour contrast to guide players; keep sight lines honest; cover looks physical (cars, walls, crates).

## Scale and performance

Heavy: StreamingEnabled is required for large maps; budgets of about 1.5 million visible triangles; use RenderFidelity and LOD meshes, and limit SurfaceAppearance texture sizes (1024 for most, 2048 for hero props). Expect to cut features for mobile.

## Notes for Codex prop briefs

- Realistic proportions, bevelled edges, UV unwrapped for PBR; triangle budgets above; export normal, roughness and metalness maps.
- Modular pieces with consistent texel density; origin at the base.
- Provide LODs for props over 2000 triangles.

## Never

Flat cartoon colours, oversized props, uniform clean surfaces, unbounded texture sizes.

## Style checklist

- [ ] PBR textures on the main surfaces
- [ ] Natural, desaturated palette and soft lighting
- [ ] Wear and clutter without hiding lanes
- [ ] Triangle and texture budgets respected
- [ ] Streaming and LODs set up

## Approval

Not tested yet. Build one small area, check performance on a phone, show the owner, then mark it proven.
