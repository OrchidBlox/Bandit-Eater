# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Bandit Eater, a Roblox + Rojo game (Luau), created from the `template-game` starter template. It is not a finished game yet. See README.md for the full setup walkthrough.

## Commands

- Install toolchain (Rojo, pinned in `aftman.toml`): `aftman install`
- Install the Rojo Studio plugin: `rojo plugin install`
- Start the sync server (must stay running while editing so changes push into Studio): `rojo serve` (port 32222, set by `servePort` in `default.project.json`; connect the Studio Rojo plugin to 32222)
- Lint Luau (`selene.toml` sets `std = "roblox"`): `selene src`
- The template rename is already done (project name `Bandit-Eater`); `./scripts/rename-template.ps1` does not need to run again.

There is no build step or automated test suite. Verifying behavior means: run `rojo serve`, connect Roblox Studio to it via the Rojo plugin, press Play, and check the Output window.

## Architecture

`default.project.json` is the Rojo sync map and is the source of truth for how `src/` becomes the Roblox DataModel:

- `src/client` → `StarterPlayer.StarterPlayerScripts.Client`
- `src/server` → `ServerScriptService.Server`
- `src/shared` → `ReplicatedStorage.Shared`

Each maps to a child folder, not the service itself, so Rojo never removes things built in Studio (for example `ReplicatedStorage.Assets`). `init.server.luau` / `init.client.luau` become the `Server` / `Client` scripts; their subfolders become children.

- **Server:** `init.server.luau` requires each module in `Services/` in `SERVICE_ORDER`, calls every `Init()` (setup only, no calls into other services), then every `Start()` (connect events, begin work). One service per system.
- **Client:** `init.client.luau` starts each module in `Controllers/` in `CONTROLLER_ORDER`. Controllers display state and send requests only.
- **Remotes:** `src/shared/Remotes.luau` names every RemoteEvent and documents its payload. The server creates them; clients wait for them.
- **Saving:** there is no DataService yet on purpose. When a game needs saving, port the tested one from Grow & Battle (`src/server/Services/DataService.luau` in grow-a-seed-fighter: session locking, data repair, versioned migrations, save on leave and shutdown) in that game's first milestone, and playtest it there, rather than writing saving code from scratch.

Claude Code can inspect and interact with a running Roblox Studio session through the `Roblox_Studio` MCP server defined in `.mcp.json` (checked into the repo, so it works for any clone). This requires Roblox Studio to be open; on first load Claude Code will prompt to trust the project's `.mcp.json`. The `blender` MCP server in the same file lets Claude inspect Blender when it is open with the MCP addon connected.

## AI roles

Each AI answers a different question. The human owner makes every final decision.

| Who | Answers | Does |
| --- | --- | --- |
| **Owner (human)** | "Is this worth building?" | Creative direction, playtesting, feedback, approving systems, deciding what gets built next and when to release. |
| **ChatGPT (chat)** | "What should we build and why?" | Game design, mechanics, progression, balance tables, content names, player-experience questions, marketing ideas. Makes the **final design images** (creatures, pets, models, props and other game visuals) with image generation. Produces designs, not code. |
| **Codex (ChatGPT Codex CLI)** | "Build this spec." | Writes **big code changes** (new systems, multi-file milestones) from a spec Claude writes. Builds **3D models, rigs, and animations in Blender** through the Blender MCP. Never decides design or architecture. |
| **Claude (Claude Code)** | "How should we technically build it?" | Architecture and technical plans, concept artifacts (rough art plus a detailed brief), specs for Codex, **reviewing and fixing** Codex's work, **small code fixes directly** (a few lines up to a couple of files), debugging, Studio setup and testing through the Roblox Studio MCP, docs, and git. |
| **Studio AI** | "How can we quickly make this in Studio?" | Quick property edits and simple objects. Props are built by Codex in Blender, not generated in Studio. |
| **Google AI Pro** _(planned, not set up yet)_ | "How do we show the game off?" | **Veo** trailers and ad clips, **thumbnails and the game icon** for the Roblox game page, and possibly **image editing** (for example recolouring a finished design sheet while keeping its shape). Not for code, Blender or game design. |

### Claude and Codex split

- **Big code change** → Claude writes a spec → Codex implements → Claude reviews the diff, fixes problems, runs `rojo build`, and playtests through the Studio MCP.
- **Small fix** → Claude makes it directly. A spec and review round trip costs about as much as the fix.
- **Final design images come from ChatGPT (owner's rule, 2026-09-27).** ChatGPT makes the final concept images for creatures, pets, models, props and other visuals with its image generation. Claude's concept artifact is the brief: rough art plus a detailed description (rarity, build style, size, colours, standout features, effects) so GPT gets it right. The order can go either way: GPT makes the images first and Claude's artifact follows them, or Claude makes the artifact first and GPT turns it into the final images. Blender briefs and Codex model builds use GPT's final images as the reference; Claude's own artifact drawings are never the final art.
- **3D model or animation** → Claude writes a Blender brief → Codex builds it in Blender → Claude checks the report and exports → Claude uploads through Open Cloud, places the model, converts and uploads its animations, and wires them into code ([docs/asset-pipeline.md](docs/asset-pipeline.md)). A manual Import 3D by the owner is the fallback.
- **Map and scenery** → Claude writes a prop list and a Blender brief per prop set → Codex builds the props in Blender → Claude exports, uploads and places them with one script per area, following the `ai-map-building` skill ([docs/ai-map-building-workflow.md](docs/ai-map-building-workflow.md)). Ground, floors, island edges and bridges stay plain parts. Never move or delete the named anchors code depends on; the owner reviews each area.
- **Google AI Pro comes later (owner's plan, 2026-10-09).** It will be added for Veo video, thumbnails and the game icon, and possibly image editing, usually around the first-release marketing stage. Until the owner says it is set up, don't route work to it. When it is: test it on one job first (for example one design sheet made by Google AI and by Codex, compared for quality and cost) before it takes over any image work, then update this table.
- Pick the Codex model per run with `-m` (use the cheaper default unless the owner asks for a stronger one). How to run Codex: [docs/codex-workflow.md](docs/codex-workflow.md). To save Codex credits (owner's rules, 2026-09-28): runs go without the automatic approval reviewer (it bills the same credits and roughly doubled run costs), except `studio` runs that must use the Studio MCP; code runs check with `rojo build` and Claude does the Studio testing; each run does one job (one model, one milestone); Blender models are built in two stages, mesh then finish, with the owner approving the mesh unless they are away; checks use one composite image; Codex prints only summaries and failures; each model has its own short brief; every spec caps retries (stop after the same step fails twice and report); models that share a base file reuse the tested `blender/model_tools.py` helper instead of Codex re-writing the bake and export; and the first model of a batch is reviewed before the next is queued (owner's rules, 2026-10-10). Details in docs/codex-workflow.md and blender/README.md.

### Model escalation: Sonnet 5.5 by default, Opus 5.5 only when needed (owner's rule, 2026-10-10)

The owner starts every session and script on **Claude Sonnet 5.5** to keep costs down, and stays on it unless told to use Opus 5.5. Behave as if running on Sonnet 5.5, and escalate only when the criteria below are met.

**Sonnet handles by default:** Roblox scripting, Luau debugging, Blender modelling help, UI implementation, ModuleScript design, DataStore work, RemoteEvents and RemoteFunctions, asset pipeline guidance, code reviews under 1000 lines, feature implementation, documentation.

**Escalate to Opus only when:**
- reviewing more than 1000 lines of code
- designing entire game systems
- planning economies or progression systems
- architecture reviews
- debugging that has failed after 3 attempts
- complex performance investigations
- security reviews
- multi-system refactors
- large-scale technical decisions

**When escalation is needed, stop and write an Opus brief instead of continuing.** Do not keep solving after the brief; wait for the owner to decide whether to switch models (they switch with `/model`, an AI cannot switch its own model). Use this format:

```
===================================
OPUS RECOMMENDED
===================================

Reason:
[Why Opus is needed]

Project Context:
[Relevant project information]

Current Objective:
[What needs to be solved]

Relevant Files:
[List files involved]

Attempted Solutions:
1.
2.
3.

Constraints:
[List requirements]

Questions For Opus:
1.
2.
3.

Suggested Prompt:
[Single copy-paste prompt ready for Opus]

Expected Value:
High / Medium / Low
===================================
```

### Handoff process

Design and final design images (ChatGPT, with Claude's concept artifact before or after) → technical plan (Claude) → build (Codex or Claude) → review and test (Claude) → playtest (owner) → feedback (owner + ChatGPT) → repeat.

## Development phases

Track work as NOW / NEXT / FUTURE. Only NOW gets significant development time. Ideas go to NEXT or FUTURE unless the owner moves them. The master design describes the destination; the current phase decides what gets built.

- **NOW:** _(current phase and its checklist)_
- **NEXT:** _(what gets built if NOW succeeds)_
- **FUTURE:** _(ideas, not commitments)_

Before building anything, ask: Does it make the core loop more fun? Improve retention or clarity? Is it necessary right now? If not, wait.

Check off a task only after it is verified, and say when Studio testing is still pending.

## Project conventions

- **Server authority:** the server decides ownership, rewards, currency, and outcomes. The client only displays and requests; validate every remote.
- **Modular code:** one service or controller per system; no giant scripts. Only build the modules the current phase needs.
- **Assets:** code depends only on documented anchors (a named part or attribute), never on how a model looks, so swapping in custom assets never breaks gameplay. Track every asset in [docs/asset-checklist.md](docs/asset-checklist.md) and every animation ID in [docs/animations.md](docs/animations.md).
- **Workspace.StreamingEnabled:** if it is on, client code must look up map objects lazily.
- **Game design** lives in [docs/game-design.md](docs/game-design.md).
- **UI and icons come from BuiltByBit.** The owner buys game UI (windows, buttons, HUD icons) from [BuiltByBit's Roblox graphics and UI section](https://builtbybit.com/resources/roblox/graphics-ui/). **AI reminder:** whenever you design or build UI, icons, or other game visuals, remind the owner to use BuiltByBit UI and icons for most of the game's design, and ask whether they have already bought a pack to use before you make placeholders. All purchased GUI, UI and icon files live in the owner's **GuiPack** repo ([github.com/OrchidBlox/GuiPack](https://github.com/OrchidBlox/GuiPack), local clone `C:/Users/Kobe/GuiPack`): `packs/<pack-name>/` for each pack and `icons/` for single icons, with a table in its README giving each pack's source and licence. Pull UI and icons from there first, and only make placeholders when nothing there fits. Mock the screen up as an HTML artifact first so the owner can approve the look, then build it in Roblox with the purchased assets. Check each pack's licence allows use in a commercial Roblox game, and list every purchased asset in [docs/asset-checklist.md](docs/asset-checklist.md).
- **Figma UI route (optional, experimental).** When the owner wants an editable design file, build the UI in Figma through the Figma MCP, have the owner convert it with RoImport (JSON plus the image zip), then repair it in Studio. Follow the build rules and repair pass in [docs/figma-ui-workflow.md](docs/figma-ui-workflow.md): Fredoka One text, flattened icons, one fill per layer, and images uploaded from the zip through a localhost URL. Don't make it the default until the owner says it's proven, and record what you learn in that doc.
- **Default GUI style for simulator games: vibrant blocky (owner's choice, 2026-09-28; it replaced dark glass).** Unless the owner picks something else, design simulator GUIs in the bright, blocky Roblox look: windows with thick black outlines, a dark frame and a bright blue gradient header carrying a 3D icon; huge white titles with a heavy black text stroke, sitting **inside** the panel on their own row; a red square close button with an orange border; content cards on a light-grey Lego-stud texture, locked items as black silhouettes, and outlined labels. HUD buttons are square dark tiles holding a 3D icon and an outlined label; bottom-centre actions are a bare 3D icon with big outlined text; currency is big outlined coloured text with a "+" tile. In-world upgrade prompts are gold plates with a grey key tile ("E"), small detail text and big white outlined action text; unlock prompts are grey studded plates with white outlined text. No accent line along the top of windows and no instructional text chips. Build it from a purchased stud-style pack from BuiltByBit (measure it in Studio first); reference screenshots of the look are in grow-a-seed-fighter's `docs/reference/blocky-*.png`. The previous dark-glass style (the Essential UI Pack look) is no longer the default.
- **AI reminder: open the GUI reference in Studio before building UI (owner's rule).** Before Claude or Codex designs or builds any GUI, remind the owner to open the reference in Roblox Studio, meaning the purchased pack's `.rbxl` or `.rbxm` from GuiPack (File > Open) or the reference game. Then use the Roblox Studio MCP to screenshot its screens and read the exact properties off the real objects (colours, transparency, corner radius, fonts, text sizes, stroke thickness), and copy those numbers into the Theme. Reuse the pack's finished pieces directly where the licence allows. Never style from a verbal description alone: on Grow a Yokai Fighter that took three rounds of rework. When there is no pack to open, ask the owner for screenshots of the reference game and keep them in `docs/reference/` (one image per screen). Build against those images, and check the result at 1920x1080, 1366x768 and phone size.
- **Roblox UI gotchas.** Before calling UI work done, check it against the gotchas list in [docs/roblox-ui-gotchas.md](docs/roblox-ui-gotchas.md): gradients tint text, only one gradient per object, UIPadding moves children, the top-bar inset, text running under icons, and so on. Every Codex spec for UI links that list.
- **VFX style: chunky cartoon (owner's choice, 2026-10-24).** Every effect follows `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: round fat shapes, one candy colour per power (Wind, Earth, Water, Fire, Sword, Shadow, plus the yellow bandit), squash and stretch, white puffs and stars as dust. Do not ask the owner to pick a style again. The style is still a draft: `Vfx/Kit` and `Vfx/Cartoon.luau` are not built yet, so build them with the first effect (suggest the Fire M1 and the star spit) and get the owner's approval before rolling out. Effect rules that matter for this game: telegraphs, the bubble shield and star hitboxes must stay readable, and cosmetic skins never change hitbox, size, speed or damage. Use the `vfx-effect` skill for effects and `vfx-hero-spell` for big moves.
- **Animation style: snappy action (owner's choice, 2026-10-24).** Every animation follows `.claude/skills/animation/styles/snappy-action.md`: 3 to 5 extreme poses, fast in and slow out, a 2 to 3 frame hold on impact, hips and chest committing to every strike, strike frame named and synced to damage and VFX. Do not ask the owner to pick a style again. The style is still a draft: build the shared player set first (M1 combo, dash, bubble block, inhale, swallow, spit, swap) on one R15 rig, tune the first M1 in a playtest with the owner, then roll out to the power moves. Use the `animation` skill for briefs, tuning and review. Note: this repo has `scripts/export_animations.py` but not `export_r15_animations.py`; copy it from the template when the R15 player clips are exported.
- **Map style: low-poly nature (owner's choice, 2026-10-24; picked to match the grassland arena concept art).** Every area follows `.claude/skills/map-style/styles/low-poly-nature.md`: faceted flat-shaded rocks, cliffs and trees, a natural palette with muted greens, grey cliffs and dirt paths, and golden-hour lighting. The concept art also has textured grass and a cyan sci-fi gate as the one accent; keep both. Do not ask the owner to pick a map style again. The style is still a draft: build one area first and get the owner's approval before rolling out. Gameplay lanes, spawn plates and arena floor stay plain parts; chunky-cartoon VFX and bright yellow bandits must stay readable against the muted ground.
- **Git hygiene.** Commit only the files you changed: check `git status` first and add files by name, never `git add -A` in a repo with other uncommitted work (other sessions and the owner edit files too). Never push, force-push or rewrite history unless the owner asks.
