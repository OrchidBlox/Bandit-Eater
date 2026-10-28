# SyphoDev skills integration

Restored from https://github.com/SyphoDev-yt/roblox-ai-skills at commit
`f12e129166f85cd28e9a505f855c24326a033a2f` on 2026-10-28.
Source credit: [SyphoDev YouTube](https://www.youtube.com/@SyphoDev).
License: [upstream license](third-party/syphodev-skills-LICENSE.txt).

## Retained supplements

- **roblox-animation:** pose-spec tools, rig calibration, contact sheets, GIFs and troubleshooting. Start with the existing `animation` skill for style and transitions; use `asset-pipeline` for exports/uploads.
- **roblox-vfx:** owned-pack harvesting, recipe search and audition tooling. Start with `vfx-effect` or `vfx-hero-spell` for design and integration. No effects are bundled.
- **roblox-sfx:** sound search, Studio playback verification and sound-bank tooling. Listen to candidates before accepting them.

These three complete tool folders are mirrored from .claude/skills to
.agents/skills. They supplement the established workflow rather than replace it.
No runtime game files or existing project skills were changed by this cleanup.

## Removed duplicate workflows

- `roblox-3d-model`: existing Blender modeling and asset-pipeline workflow already owns production and uploads; optional alternate AI mesh-generation routes are not needed here.
- `roblox-texture-gen`: existing image generation, Studio texture tools and uploads already cover this.
- `roblox-skills-setup`: machine setup is already established. Retained tools can use their LOCAL.template.md if an individual path is missing.
- The four imported `roblox-asset-*` agents: existing `codex-workflow` already defines delegation, scope and review. No second agent system is needed.

Upstream license/attribution and the retained scripts/references are preserved.
Removed folders can be restored from the pinned upstream revision if specifically needed.

## Project overrides

- Preserve the existing architecture and asset pipeline. Do not scaffold Knit or
  replace working systems as a side effect of using an imported workflow.
- Follow the project's chosen visual style and approved concepts. Review actual
  gameplay at normal camera distance; loading and numeric checks are not visual
  approval. Polish one representative animation + VFX move and get owner approval
  before rolling out. Listen to sounds instead of only checking that they load.
- Use `C:/Users/Kobe/source/repos/R15 - Blener Model/MrXen0_R15RIG_v1.2.blend`
  for R15. Preserve hierarchy, rest pose and controls; work in a project copy or
  new scene. Never substitute the rig silently or overwrite live unsaved work.
- Animation briefs include entry, anticipation, release, follow-through, recovery
  and exit transitions. Verify idle/run/jump/landing and interruption blends as
  applicable, track priorities/weights, and moving/airborne variants. Movement
  transitions are part of animation quality. Do not stack tracks blindly.
- Preserve approved gameplay timing, damage, hitboxes, cooldowns and responsiveness
  unless a change is explicitly authorized. Generic fallback rules cannot approve
  a different silhouette or visual style.
- Use existing tools and documented credential interfaces. LOCAL.md is machine-local;
  never put API keys in it. New dependencies are not required merely because an
  upstream example mentions them.
- Preserve unrelated uncommitted work, stage explicit files only, and do not push
  without a request.

## Maintenance

Edit .claude/skills first, then mirror only changed folders to .agents/skills.
Keep these local integration notices during upstream updates. Existing animation,
VFX and asset-pipeline skills remain complementary project-specific guides.
