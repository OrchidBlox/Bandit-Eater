---
name: map-style
description: Choose and apply a visual style for a Roblox map (blocky-simulator, candy-pastel-fantasy, low-poly-nature, gothic-dark-fantasy, japanese-anime, neon-cyberpunk, realistic-pbr, voxel-retro, or a new one), asking the owner first if the game has no map style yet. Use when starting a new map or area, briefing Codex for map props, setting up Lighting and Atmosphere, planning terrain and layout, or reviewing a map against its style.
---

# Map style

A map style fixes the shape language, palette, materials, props, lighting and layout rules for every area in a game, so the lobby, arena and later zones feel like one world. The build process itself (Codex props, upload, placement scripts, safety rules) is the `ai-map-building` skill; this skill decides what the map should look like.

## Step 0: the style is the owner's choice, ask first

**Never pick a map style for a game on your own.**

1. Check `CLAUDE.md` for the line `Map style:`. If one is recorded, use it and skip the rest of this step.
2. If none is recorded, stop and ask the owner before listing props or writing any brief, with the AskUserQuestion tool. It takes at most four options, so offer the four that best fit the game, keep the rest reachable through "Other" or a second question, and say that the owner can describe a new style or send reference images.
3. Record the answer in `CLAUDE.md` (`Map style: <name>, chosen <date>`). Ask again only if the owner wants to change it or use another style for one area (a lobby can differ from an arena if the owner says so).
4. Read the chosen style's file before planning.

| Style | File | Status |
| --- | --- | --- |
| Blocky simulator: bright studs, chunky flat colours, classic Roblox | [styles/blocky-simulator.md](styles/blocky-simulator.md) | Draft |
| Candy pastel fantasy: soft rounded shapes, pastel meadows, cute props | [styles/candy-pastel-fantasy.md](styles/candy-pastel-fantasy.md) | Draft |
| Low-poly nature: clean faceted forests, rocks and water, flat shading | [styles/low-poly-nature.md](styles/low-poly-nature.md) | Draft |
| Gothic dark fantasy: ruins, fog, stone and iron, low light | [styles/gothic-dark-fantasy.md](styles/gothic-dark-fantasy.md) | Draft |
| Japanese anime: torii, lanterns, blossoms, soft sunset light | [styles/japanese-anime.md](styles/japanese-anime.md) | Draft |
| Neon cyberpunk: night city, glowing signs, wet streets | [styles/neon-cyberpunk.md](styles/neon-cyberpunk.md) | Draft |
| Realistic PBR: detailed materials, natural lighting, grounded | [styles/realistic-pbr.md](styles/realistic-pbr.md) | Draft |
| Voxel retro: cubes only, flat colours, sandbox look | [styles/voxel-retro.md](styles/voxel-retro.md) | Draft |

| Style | Feel | Best for | Cost (parts, triangles) | Mobile |
| --- | --- | --- | --- | --- |
| Blocky simulator | Bright, familiar | Simulators, tycoons, obbies | Low | Excellent |
| Candy pastel fantasy | Cute, friendly | Kirby-like brawlers, family games | Low to medium | Excellent |
| Low-poly nature | Clean, calm | Adventure, survival-lite | Medium | Good |
| Gothic dark fantasy | Moody, ominous | RPG, horror-lite, bosses | Medium | Good |
| Japanese anime | Serene, stylish | Fighters, anime games | Medium | Good |
| Neon cyberpunk | Loud, futuristic | Shooters, racers, hubs | Medium to high | Fair (watch lights) |
| Realistic PBR | Grounded, detailed | Shooters, survival | High | Hard |
| Voxel retro | Sandbox, nostalgic | Survival, mini-games | Low | Excellent |

To add a style, copy [styles/_template.md](styles/_template.md), fill every section, add a row above, test it on one area and get the owner's approval before rolling it out. Rules that hold for every style: gameplay readability beats decoration, one style per game, anchors and gameplay surfaces never change, and the owner reviews each area.

## What every style file defines

Palette (hex), terrain and ground, materials, the prop list with triangle budgets, lighting and atmosphere values, layout and readability rules, scale and performance limits, notes for Codex prop briefs, and a checklist. Apply them in this order: layout and ground first, then lighting, then props, then polish.

## Universal rules

1. **Gameplay lanes stay clear.** Floors, paths and spawn areas are plain parts or terrain with exact collision; decoration never sits on them.
2. **Silhouette and contrast.** Players, enemies and pickups must stand out from the background: keep the ground and background calmer and less saturated than the gameplay objects.
3. **Anchors never move.** Named parts and attributes code depends on are listed in docs/asset-checklist.md.
4. **Budget for the weakest device.** Aim for roughly 20 to 30k visible parts and under about 1.5 million visible triangles on mobile; use `Workspace.StreamingEnabled` for big maps and `RenderFidelity` Automatic or Performance on detailed meshes.
5. **Reuse meshes.** A small set of props placed many times beats many unique props: instance the same MeshId with different scale and rotation.
6. **Set the mood with Lighting first.** `Lighting` and `Atmosphere` do half the style for free. Record the values used in the style's notes so every area matches.
7. **Colour discipline.** Stay inside the palette; one accent colour per area.
8. **Test at phone size** and at night or the darkest lighting the game uses.
