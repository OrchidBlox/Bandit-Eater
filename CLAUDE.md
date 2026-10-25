# CLAUDE.md

Guidance for Claude Code in this repository. Kept short on purpose: detail lives in docs and skills that load only when the work needs them.

## What this is

Bandit Eater, a Roblox + Rojo game (Luau), created from the `template-game` starter template. It is not a finished game yet. The V1 pilot spec is `docs/bandit-eater-design-doc (1).md`; build Part 1 only and ask before building anything from Part 2. See README.md for the full setup walkthrough.

## Commands

- Install toolchain (Rojo, pinned in `aftman.toml`): `aftman install`
- Install the Rojo Studio plugin: `rojo plugin install`
- Start the sync server (keep it running while editing): `rojo serve` (port 32222, set by `servePort` in `default.project.json`; connect the Studio Rojo plugin to 32222)
- Lint Luau (`selene.toml` sets `std = "roblox"`): `selene src`
- The template rename is already done (project name `Bandit-Eater`); `./scripts/rename-template.ps1` does not need to run again.

There is no build step or automated test suite. Verifying behavior means: run `rojo serve`, connect Roblox Studio via the Rojo plugin, press Play, and check Output. The `Roblox_Studio` and `blender` MCP servers in `.mcp.json` let Claude inspect and drive both apps when they are open.

## Architecture

`default.project.json` is the Rojo sync map: `src/client` -> `StarterPlayer.StarterPlayerScripts.Client`, `src/server` -> `ServerScriptService.Server`, `src/shared` -> `ReplicatedStorage.Shared`. Each maps to a child folder, so Rojo never removes things built in Studio (for example `ReplicatedStorage.Assets`).

- **Server:** `init.server.luau` requires each module in `Services/` in `SERVICE_ORDER`, calls every `Init()` (setup only), then every `Start()` (connect events, begin work). One service per system.
- **Client:** `init.client.luau` starts each module in `Controllers/` in `CONTROLLER_ORDER`. Controllers display state and send requests only.
- **Remotes:** `src/shared/Remotes.luau` names every RemoteEvent and documents its payload. The server creates them; clients wait for them.
- **Saving:** there is no DataService yet on purpose. When the game needs saving (V1 saves currency, cosmetics and stats), port the tested one from grow-a-seed-fighter (`src/server/Services/DataService.luau`: session locking, data repair, versioned migrations, save on leave and shutdown) and playtest it there.

## Who does what

The owner decides everything final. ChatGPT designs and makes the final concept images, Codex writes big code changes and builds Blender models and animations from Claude's specs, Claude plans, writes specs, reviews and fixes, makes small fixes directly and tests in Studio. Full table, the Claude and Codex split, credit-saving rules and handoffs: [docs/ai-roles.md](docs/ai-roles.md). Run Codex with the `codex-workflow` skill.

**Model:** work on Sonnet 5.5 by default. When a task meets the Opus criteria (more than 1000 lines of review, whole-system design, economy planning, architecture or security review, debugging that failed 3 times), stop and use the `opus-brief` skill; never keep solving.

## Skills (load when the job matches)

`codex-workflow` (Codex runs), `asset-pipeline` (Blender uploads and animation export), `ai-map-building` and `map-style` (maps), `vfx-effect` and `vfx-hero-spell` (effects and spells), `animation` (clips), `opus-brief` (escalation). Codex reads the same skills from `.agents/skills` (run `bash scripts/sync-skills.sh` after editing `.claude/skills`).

## Reading list by job

- **UI or icons:** read [docs/ui-guidelines.md](docs/ui-guidelines.md) first. Remind the owner to use BuiltByBit packs from the GuiPack repo and to open the reference in Studio before building; check the work against [docs/roblox-ui-gotchas.md](docs/roblox-ui-gotchas.md).
- **Assets and animations:** [docs/asset-checklist.md](docs/asset-checklist.md), [docs/animations.md](docs/animations.md), [docs/asset-pipeline.md](docs/asset-pipeline.md).
- **Game design:** `docs/bandit-eater-design-doc (1).md` (V1 pilot spec and long-term vision) and [docs/game-design.md](docs/game-design.md); playtest notes in [docs/pilot-playtest.md](docs/pilot-playtest.md).

## Development phases

Track work as NOW / NEXT / FUTURE. Only NOW gets significant development time; ideas go to NEXT or FUTURE unless the owner moves them. Before building anything ask: does it make the core loop more fun, improve retention or clarity, and is it necessary right now? If not, wait. Check off a task only after it is verified, and say when Studio testing is still pending.

- **NOW:** _(current phase and its checklist)_
- **NEXT:** _(what gets built if NOW succeeds)_
- **FUTURE:** _(ideas, not commitments)_

## Project conventions

- **Server authority:** the server decides ownership, rewards, currency, and outcomes. The client only displays and requests; validate every remote.
- **Modular code:** one service or controller per system; no giant scripts. Only build the modules the current phase needs.
- **Assets:** code depends only on documented anchors (a named part or attribute), never on how a model looks. Track every asset in docs/asset-checklist.md and every animation ID in docs/animations.md.
- **Workspace.StreamingEnabled:** if it is on, client code must look up map objects lazily.
- **Git hygiene.** Commit only the files you changed: check `git status` first and add files by name, never `git add -A` in a repo with other uncommitted work (other sessions and the owner edit files too). Never push, force-push or rewrite history unless the owner asks.

## Game choices (chosen by the owner; the AI asks with a recommendation before any new style decision)

- **VFX style: chunky cartoon (owner's choice, 2026-10-24).** Every effect follows `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: round fat shapes, one candy colour per power (Wind, Earth, Water, Fire, Sword, Shadow, plus the yellow bandit), squash and stretch, white puffs and stars as dust. Do not ask the owner to pick a style again. The style is still a draft: `Vfx/Kit` and `Vfx/Cartoon.luau` are not built yet, so build them with the first effect (suggest the Fire M1 and the star spit) and get the owner's approval before rolling out. Effect rules that matter for this game: telegraphs, the bubble shield and star hitboxes must stay readable, and cosmetic skins never change hitbox, size, speed or damage. Use the `vfx-effect` skill for effects and `vfx-hero-spell` for big moves.
- **Animation style: snappy action (owner's choice, 2026-10-24).** Every animation follows `.claude/skills/animation/styles/snappy-action.md`: 3 to 5 extreme poses, fast in and slow out, a 2 to 3 frame hold on impact, hips and chest committing to every strike, strike frame named and synced to damage and VFX. Do not ask the owner to pick a style again. The style is still a draft: build the shared player set first (M1 combo, dash, bubble block, inhale, swallow, spit, swap) on one R15 rig, tune the first M1 in a playtest with the owner, then roll out to the power moves. Use the `animation` skill for briefs, tuning and review. Note: this repo has `scripts/export_animations.py` but not `export_r15_animations.py`; copy it from the template when the R15 player clips are exported.
- **Map style: low-poly nature (owner's choice, 2026-10-24; picked to match the grassland arena concept art).** Every area follows `.claude/skills/map-style/styles/low-poly-nature.md`: faceted flat-shaded rocks, cliffs and trees, a natural palette with muted greens, grey cliffs and dirt paths, and golden-hour lighting. The concept art also has textured grass and a cyan sci-fi gate as the one accent; keep both. Do not ask the owner to pick a map style again. The style is still a draft: build one area first and get the owner's approval before rolling out. Gameplay lanes, spawn plates and arena floor stay plain parts; chunky-cartoon VFX and bright yellow bandits must stay readable against the muted ground.
