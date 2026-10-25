# Map style: voxel retro (draft, not yet tested on an area)

Everything built from cubes on a grid with flat colours, like a sandbox or 8-bit world: blocky terrain, cube trees, pixel-style props. Nostalgic and very cheap. Not smooth, and not detailed.

## Palette (limited, flat)

| Use | Hex |
| --- | --- |
| Grass top | `#6BBF4A` |
| Dirt | `#8A5A36` |
| Stone | `#8E9298` |
| Sand | `#E6D08A` |
| Water | `#3F7FD6` |
| Wood | `#9A6A3A` |
| Leaves | `#3F8F3A` |
| Accent (ore, flowers) | `#FFD400` |
| Sky | `#8FC8FF` |

Use 8 to 12 colours total across the whole map.

## Terrain and ground

A cube grid (for example 4-stud cubes): flat top layer, dirt sides, stepped hills one cube at a time, water as flat blue cubes, caves and tunnels by removing cubes. Use a script to generate terrain from a heightmap, then merge or mesh the output for performance.

## Materials

SmoothPlastic for all cubes, flat colours, no textures; Neon only for torches and ore.

## Props

| Prop | Triangle budget | Notes |
| --- | ---: | --- |
| Cube tree | 24 to 100 | Trunk plus leaf cubes |
| Flower, grass tuft | 12 to 24 | Single cross or cube |
| Rock | 50 | Stacked cubes |
| House | 200 | Cube walls, simple roof |
| Torch, chest, sign | 50 | |

## Lighting and atmosphere

| Setting | Value |
| --- | --- |
| Lighting.Technology | Compatibility or ShadowMap |
| ClockTime | 14 |
| Brightness | 2.5 |
| Ambient / OutdoorAmbient | `#A0B0C0` / `#B8C8D8` |
| Atmosphere | Density 0.15, Haze 0 |
| Sky | Simple blue sky, square clouds |
| Post effects | None, or very light Bloom |

## Layout and readability

Clear tiers of height; cube steps mark lanes; keep a flat play area; use colour contrast between ground and objects; keep tunnels wide enough for the player.

## Scale and performance

Merge adjacent cubes (greedy meshing or unions) rather than placing thousands of parts; cap part count; chunk the world and stream chunks.

## Notes for Codex prop briefs

- Voxel-style props made of cubes on a fixed grid, flat colours, no textures; 12 colours maximum from the palette.
- Origin at the bottom centre; sizes in whole cubes.

## Never

Smooth shapes, gradients, textures, thousands of unmerged parts, tiny cubes on a different grid.

## Style checklist

- [ ] All shapes sit on one cube grid
- [ ] Flat colours from a 12-colour palette
- [ ] Cubes merged for performance
- [ ] Height tiers and a flat play area
- [ ] No smooth shapes or textures

## Approval

Not tested yet. Build one area, show the owner, then mark it proven.
