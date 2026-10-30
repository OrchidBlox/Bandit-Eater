# Resume after a PC reset (written 2026-10-30)

Everything that does not need Blender was finished and committed first. This note lists what is left and how to restart it. Nothing here depends on the old machine's state except the Studio place (see Setup).

## Setup on the fresh machine

1. Install the toolchain: `aftman install` (Rojo, Selene), Roblox Studio and the Rojo plugin, Python 3 with `Pillow`, ffmpeg, Blender 5.2 (`C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`), the Codex CLI (the ChatGPT VS Code extension provides `codex.exe`), and the Roblox Studio MCP and Blender MCP (`.mcp.json`; install the Blender add-on with `uvx mcp-for-blender install-addon`, enable it, then Start MCP Server).
2. Put the Open Cloud key in `.env` (`ROBLOX_API_KEY`, creator id; never commit it).
3. The canonical rig is in the repo: `blender/rigs/MrXen0_R15RIG_v1.2.blend` (also in template-game).
4. Studio place: the new effect meshes and swords live in `ReplicatedStorage.Assets` in the place, not in the repo. If the place file is lost, reinstall them from the uploaded asset ids in `scripts/asset_ids.json` (PowerMoves meshes: finish with `python scripts/finish_fx_batch.py FxName`, which prints ids; install by loading each asset in Studio, cloning its MeshPart, Size and PivotOffset divided by 100, TextureID empty, Anchored, no collision).
5. `rojo serve` (port 34873), connect the Studio plugin, press Play to test. Studio-only test hook: set the player attribute `DevPower` (for example `Fire`) on the server to put a power in hand.

## Pending Blender work

- **Codex meshes still to build** (briefs in `blender/briefs/BE_Fx*.md`, queue `.codex-tmp/run_all_meshes.sh`, skips finished ones): FxTidalCrest, FxFloatBlade, FxSkywheelDisc, FxSnareTendrils, FxDarkCrescent, FxCrownStar, FxSplitterRidge, FxEclipseDisc, FxGoldWave. Run with the Blender MCP connected; then `python scripts/finish_fx_batch.py <names>` and install in Studio.
- **Animations, redo with the roblox-animation method** (FK, five poses, per-segment easing, GIF approved by the owner): pilot is sword Hit 1 (`python blender/anims/build_sword_rig.py -- --fk --gif --render`, GIF at `blender/review/SwordFK_M1_1.gif`). Next: Hits 2 and 3, the carry/Ready, the seven sword E lunges, then the Q/R casts and the base power casts. Proposed skill improvements are being tried in template-game `experiments/roblox-animation-lab/` (Blender 5 compatible `calibrate_rig.py` works; `anim_render.py` needs the EEVEE engine fix applied there and a re-test).
- **Fire**: `FlameTongue` mesh failed twice in Codex (not needed now).

## Pending game work (no Blender needed)

- Moves not yet rebuilt in the anime-slick style: Sword dashes (E) and Blade Storm, Shadow moves 2 and 3, fusion finishers, Water move 3. Older effects play until each mesh is installed.
- Real playtests: fights with several moves at once, phone-size readability and part counts, two clients.
- Sound is skipped on purpose.
- Save the Studio place after installing meshes.
