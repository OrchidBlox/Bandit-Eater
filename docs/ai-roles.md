# AI roles and handoffs

Moved out of CLAUDE.md so it is only read when the work needs it (who builds what, how Claude and Codex split work, handoffs).

Each AI answers a different question. The human owner makes every final decision.

| Who | Answers | Does |
| --- | --- | --- |
| **Owner (human)** | "Is this worth building?" | Creative direction, playtesting, feedback, approving systems, deciding what gets built next and when to release. |
| **ChatGPT (chat)** | "What should we build and why?" | Game design, mechanics, progression, balance tables, content names, player-experience questions, marketing ideas. Makes the **final design images** (creatures, pets, models, props and other game visuals) with image generation. Produces designs, not code. |
| **Codex (ChatGPT Codex CLI)** | "Build this spec." | Writes **big code changes** (new systems, multi-file milestones) from a spec Claude writes. Builds **3D models, rigs, and animations in Blender** through the Blender MCP. Never decides design or architecture. |
| **Claude (Claude Code)** | "How should we technically build it?" | Architecture and technical plans, concept artifacts (rough art plus a detailed brief), specs for Codex, **reviewing and fixing** Codex's work, **small code fixes directly** (a few lines up to a couple of files), debugging, Studio setup and testing through the Roblox Studio MCP, docs, and git. |
| **Studio AI** | "How can we quickly make this in Studio?" | Quick property edits and simple objects. Props are built by Codex in Blender, not generated in Studio. |
| **Google AI Pro** _(planned, not set up yet)_ | "How do we show the game off?" | **Veo** trailers and ad clips, **thumbnails and the game icon** for the Roblox game page, and possibly **image editing** (for example recolouring a finished design sheet while keeping its shape). Not for code, Blender or game design. |

## Claude and Codex split

- **Big code change** → Claude writes a spec → Codex implements → Claude reviews the diff, fixes problems, runs `rojo build`, and playtests through the Studio MCP.
- **Small fix** → Claude makes it directly. A spec and review round trip costs about as much as the fix.
- **Final design images come from ChatGPT (owner's rule, 2026-09-27).** ChatGPT makes the final concept images for creatures, pets, models, props and other visuals with its image generation. Claude's concept artifact is the brief: rough art plus a detailed description (rarity, build style, size, colours, standout features, effects) so GPT gets it right. The order can go either way: GPT makes the images first and Claude's artifact follows them, or Claude makes the artifact first and GPT turns it into the final images. Blender briefs and Codex model builds use GPT's final images as the reference; Claude's own artifact drawings are never the final art.
- **3D model or animation** → Claude writes a Blender brief → Codex builds it in Blender → Claude checks the report and exports → Claude uploads through Open Cloud, places the model, converts and uploads its animations, and wires them into code ([docs/asset-pipeline.md](asset-pipeline.md)). A manual Import 3D by the owner is the fallback.
- **Map and scenery** → Claude writes a prop list and a Blender brief per prop set → Codex builds the props in Blender → Claude exports, uploads and places them with one script per area, following the `ai-map-building` skill ([docs/ai-map-building-workflow.md](ai-map-building-workflow.md)). Ground, floors, island edges and bridges stay plain parts. Never move or delete the named anchors code depends on; the owner reviews each area.
- **Google AI Pro comes later (owner's plan, 2026-10-09).** It will be added for Veo video, thumbnails and the game icon, and possibly image editing, usually around the first-release marketing stage. Until the owner says it is set up, don't route work to it. When it is: test it on one job first (for example one design sheet made by Google AI and by Codex, compared for quality and cost) before it takes over any image work, then update this table.
- Pick the Codex model per run with `-m` (use the cheaper default unless the owner asks for a stronger one). How to run Codex: [docs/codex-workflow.md](codex-workflow.md). To save Codex credits (owner's rules, 2026-09-28): runs go without the automatic approval reviewer (it bills the same credits and roughly doubled run costs), except `studio` runs that must use the Studio MCP; code runs check with `rojo build` and Claude does the Studio testing; each run does one job (one model, one milestone); Blender models are built in two stages, mesh then finish, with the owner approving the mesh unless they are away; checks use one composite image; Codex prints only summaries and failures; each model has its own short brief; every spec caps retries (stop after the same step fails twice and report); models that share a base file reuse the tested `blender/model_tools.py` helper instead of Codex re-writing the bake and export; and the first model of a batch is reviewed before the next is queued (owner's rules, 2026-10-10). Details in docs/codex-workflow.md and blender/README.md.

## Handoff process

Design and final design images (ChatGPT, with Claude's concept artifact before or after) → technical plan (Claude) → build (Codex or Claude) → review and test (Claude) → playtest (owner) → feedback (owner + ChatGPT) → repeat.
