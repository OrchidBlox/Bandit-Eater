---
name: vfx-effect
description: Build or polish a small visual effect (projectile, ray, ground area, strike from above, aura, hit feedback) in a chosen VFX style (anime-slick, chunky-cartoon, dark-fantasy, painterly-storybook, retro-pixel, neon-synthwave, ink-wash, comic-pop, cinematic-realistic, crystal-ethereal, or a new one), asking the owner first if the game has no style yet. Use when adding or restyling an effect module, picking or adding a VFX style, reviewing an effect against a style's rules, breaking a reference clip into layers, or measuring an effect's part and emitter budget. For hero spells with real meshes, rigs or chasing moves use vfx-hero-spell instead. Moves always need Codex Blender meshes for their hero shapes.
---

# VFX effect

Effects are built from the game's `Vfx/Kit` (small constructors), one module per effect in `Vfx/Effects/`, played by name through the VFX controller. Palettes, texture ids and budgets live in `Config/Vfx.luau`. Style-specific helpers sit beside the Kit (the anime-slick ones are `Vfx/Anime`). A worked example of taking a clip apart: [reference-breakdown.md](reference-breakdown.md).

## Hard rule: a move's hero shapes come from Codex in Blender (owner, 2026-10-30)

For any move (a Q, E or R, a spell, a dash, a finisher) the **hero shapes must be real meshes that Codex builds in Blender** from the owner-approved concept image, following `vfx-hero-spell` (brief, one model per run, finish, upload, install). Building a move only from parts, particles, billboards or a reused mesh is **not allowed**; code is for the support layers (ground telegraphs, speed bars, rings, runes, outlines, particles, timing and hit logic). A mesh made for another move is reused only if the owner approved it for this one. If a move has no approved concept image and Codex meshes yet, stop and get them first instead of faking the shape in code. Small hit feedback (a spark, a ring on a hit) can stay particle-only.

## Step 0: the style is the owner's choice, ask first

Every effect in a game follows one style, so the game never reads as a pile of separately made effects. **The owner chooses, and you always bring a recommendation.**

1. Check `CLAUDE.md` for the line `VFX style:` and for an existing `Vfx` helper module. If a style is recorded, use it and skip the rest of this step.
2. If none is recorded, stop and ask the owner before building any effect, with the AskUserQuestion tool. **Always suggest one:** first read the game design doc, genre, audience, platform (mobile or desktop), any concept art, and the styles already chosen for the other areas (VFX, animation, map). Put your recommended style first in the options, labelled "(Recommended)", with a one-line reason tied to this game and to how it pairs with the other chosen styles. The owner still decides; never record a style they did not pick. It takes at most four options, so offer the four that best fit the game (the other styles stay reachable through "Other" or a second question), and say that the owner can also describe a new style.
3. Record the answer in `CLAUDE.md` (`VFX style: <name>, chosen <date>`) and in `Vfx.Style` in `Config/Vfx.luau` if the game has one. From then on this step is skipped; ask again only if the owner wants to change the style or use a different one for one effect.
4. Read the chosen style's file before building, and copy its helpers or build the module it names.

| Style | File | Status |
| --- | --- | --- |
| Anime-slick: sharp silhouettes, speed streaks, outlines, snappy timing | [styles/anime-slick.md](styles/anime-slick.md) | Proven |
| Chunky cartoon: rounded, bright, bouncy, simulator-friendly | [styles/chunky-cartoon.md](styles/chunky-cartoon.md) | Draft |
| Dark fantasy: heavy, desaturated, smoky, low light with hot accents | [styles/dark-fantasy.md](styles/dark-fantasy.md) | Draft |
| Painterly storybook: soft, hand-painted, drifting petals and wisps | [styles/painterly-storybook.md](styles/painterly-storybook.md) | Draft |
| Retro pixel: cubes, flat palettes, stepped 8-bit motion | [styles/retro-pixel.md](styles/retro-pixel.md) | Draft |
| Neon synthwave: glowing lines, grids, holograms, glitch accents | [styles/neon-synthwave.md](styles/neon-synthwave.md) | Draft |
| Ink wash: black brush strokes, splatter, one seal-colour accent | [styles/ink-wash.md](styles/ink-wash.md) | Draft |
| Comic pop: thick outlines, flat primaries, halftone, burst panels | [styles/comic-pop.md](styles/comic-pop.md) | Draft |
| Cinematic realistic: physical fire, smoke, sparks and debris | [styles/cinematic-realistic.md](styles/cinematic-realistic.md) | Draft |
| Crystal ethereal: faceted shards, halos, rays, shimmer | [styles/crystal-ethereal.md](styles/crystal-ethereal.md) | Draft |

Quick comparison, for explaining the options when you ask:

| Style | Shapes | Colour | Mood | Cost | Needs |
| --- | --- | --- | --- | --- | --- |
| Anime-slick | Sharp, tapered, outlined | Saturated plus hot core | Stylish, fast | Medium | Helpers exist |
| Chunky cartoon | Round, fat, bouncy | Candy colours | Friendly | Low | Puff and star textures |
| Dark fantasy | Jagged, heavy | Desaturated plus one accent | Ominous | Medium | Smoke and decal textures |
| Painterly storybook | Soft, flowing | Muted warm hues | Calm, magical | Medium | Brush and petal textures |
| Retro pixel | Cubes only | Flat 4 to 6 colours | Arcade | Low | Almost nothing |
| Neon synthwave | Lines, grids, rings | Two neon hues on dark | Cool, techy | Low | Grid and line textures |
| Ink wash | Brush strokes | Black and grey plus one accent | Calm, deadly | Low | Stroke and splatter textures |
| Comic pop | Outlined, flat, bursts | Primaries | Loud, funny | Low | Halftone and burst textures |
| Cinematic realistic | Physical fire, smoke | Natural | Serious | High | Many particle textures |
| Crystal ethereal | Faceted, rays | Cool whites and gold | Pure, radiant | Medium | Codex shard meshes |

Each style file holds its palettes (hex), assets, timing table, recipes per move type, proposed helper signatures and notes for hero spells.

To add a style, copy [styles/_template.md](styles/_template.md), fill every section, add a row above, and build or reuse the helper module it names. Test it on one effect and get the owner's approval before rolling it out; mark it Proven afterwards. A style file is the rulebook for reviews and for briefing Codex.

Rules that hold for every style: one style per game, one idea per move, keep the move's original motion, stay in budget, and let the owner judge the look.

## The loop for one effect

1. Name the one idea in a sentence and say what the move already does. Polish keeps that motion.
2. Optional reference: pull frames with `ffmpeg -i clip.mp4 -vf "fps=2,scale=480:-1,tile=4x4" sheet_%d.png`, look at them, and write the layers using the table in reference-breakdown.md. Take the treatment (colours, layers, timing), not the motion.
3. Build `Vfx/Effects/<Name>.luau` exposing `Play(data, look)`. Validate `data` (types and ranges) and return early when `look.distanceFactor == 0`. Copy a close sibling effect and apply the chosen style's helpers.
4. `selene src` and `rojo build`.
5. Measure in a playtest with the counting script below, calling the module directly with a fake payload.
6. The owner looks in play and says what to tune. Tune numbers; don't redesign.
7. Roll out to the next effects in batches of a few, reviewing each batch.

## Budgets (one effect playing at once, all styles)

14 emitters, 700 particles, 3 lights, 12 beams, 40 parts, 6 outlines (see `Vfx.Budget`). No fullscreen additive overlay and no brightness pulse above 0.08 for 0.2 s (darkening effects may go down). Everything created is destroyed. Multi-hit effects give the full treatment to one hero hit and a cheap version to the rest. Polish must not grow an already-heavy effect by more than about 20%. A style file may tighten these, never loosen them.

## Server-driven effects

The server decides damage, targets and timing, then fires a RemoteEvent with a small payload (positions, delays, radius). Register the remote in `src/shared/Remotes.luau`, play it with `VfxController.Play(name, payload, isOwn)`, validate every field on the client before drawing, and never let the client decide an outcome.

## Counting script (playtest, Client datamodel)

```lua
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local root = lp.Character:WaitForChild("HumanoidRootPart")
local Kit = require(lp.PlayerScripts.Client.Vfx.Kit)
local folder = workspace:FindFirstChild("VfxTest") or Instance.new("Folder")
folder.Name = "VfxTest"
folder.Parent = workspace
Kit.setFolder(folder)
local effect = require(lp.PlayerScripts.Client.Vfx.Effects.PillarStrike) -- swap in the effect under test
effect.Play({ position = root.Position + root.CFrame.LookVector * 30 }, Kit.look(nil, 1, true))
local peakParts, peakEmitters, started = 0, 0, os.clock()
while os.clock() - started < 8 do
	local parts, emitters = 0, 0
	for _, d in folder:GetDescendants() do
		if d:IsA("BasePart") then parts += 1 end
		if d:IsA("ParticleEmitter") then emitters += 1 end
	end
	peakParts, peakEmitters = math.max(peakParts, parts), math.max(peakEmitters, emitters)
	task.wait(0.03)
end
return `peak parts {peakParts}, emitters {peakEmitters}, leftover {#folder:GetDescendants()}`
```

Leftover must be 0, and peaks under `Vfx.Budget`.

## Review checklist (add the style's own checklist)

- [ ] One sentence says what it does, and the main shape shows that
- [ ] It still moves the way the original move moved
- [ ] Readable in one glance at phone size
- [ ] Matches the chosen style's rules and palette
- [ ] Readable windup, clean aftermath, nothing left behind
- [ ] Peak parts and emitters measured, effects folder empty afterward

## Lessons

- Play-mode screenshots from the Studio MCP may show only the UI. Measure with scripts and ask the owner to look; try `screen_capture` with `camera_position` and `look_at_position` first, which has shown the 3D world.
- `require` from the Studio MCP can create a second module copy, so call `Kit.setFolder` yourself in test scripts.
- Highlight outlines are pooled (max 6). `Destroying` doesn't fire for a destroyed ancestor, so prune dead outlines on each call.
- Studio only picks up code changes after the playtest restarts. Stop play, check the module's `Source` in the Edit datamodel, then start again.
- A multi-hit effect blows the part budget fast; one hero hit gets the full treatment.
- A UnionOperation ignores its part colour unless `UsePartColor` is true.
- `Vfx.Textures` ids belong to the game that uploaded them. For a new game regenerate them (grey on black, converted to alpha), upload and replace the ids.
