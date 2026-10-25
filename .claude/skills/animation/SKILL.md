---
name: animation
description: Plan, build, tune and review character animations (M1 combos, dash, block, idle, run, casts, creature clips) in a chosen animation style (snappy-action, heavy-weighty, fluid-martial-arts, stepped, cartoony-exaggerated, realistic, robotic, or a new one), asking the owner first if the game has no style yet. Use when writing a Blender animation brief for Codex, fixing animations that feel flat, floaty or stiff, syncing hits to strike frames, or exporting and registering animation IDs.
---

# Animation

Animations are built in Blender (Codex through the Blender MCP, or headless scripts), exported with `scripts/export_animations.py` or `scripts/export_r15_animations.py`, uploaded with `scripts/upload_assets.py` and registered in [docs/animations.md](../../../docs/animations.md). The upload and export mechanics are in the `asset-pipeline` skill; this skill is about how the animation should look and how to fix it when it doesn't.

## Step 0: the style is the owner's choice, ask first

Every animation in a game follows one style so the characters feel like they belong together. **The owner chooses, and you always bring a recommendation.**

1. Check `CLAUDE.md` for the line `Animation style:`. If one is recorded, use it and skip the rest of this step.
2. If none is recorded, stop and ask the owner before writing a brief or building any clip, with the AskUserQuestion tool. **Always suggest one:** first read the game design doc, genre, audience, platform (mobile or desktop), any concept art, and the styles already chosen for the other areas (VFX, animation, map). Put your recommended style first in the options, labelled "(Recommended)", with a one-line reason tied to this game and to how it pairs with the other chosen styles. The owner still decides; never record a style they did not pick. It takes at most four options, so offer the four that best fit the game and keep the rest reachable through "Other" or a second question. The owner can also describe a new style.
3. Record the answer in `CLAUDE.md` (`Animation style: <name>, chosen <date>`). From then on this step is skipped; ask again only if the owner wants to change the style or use a different one for one clip.
4. Read the chosen style's file before briefing or building.

| Style | File | Status |
| --- | --- | --- |
| Snappy action: few strong poses, fast in and slow out, held impact frames | [styles/snappy-action.md](styles/snappy-action.md) | Draft |
| Heavy and weighty: slow windup, hard slam, big overshoot | [styles/heavy-weighty.md](styles/heavy-weighty.md) | Draft |
| Fluid martial arts: continuous flow, overlapping action, handoffs | [styles/fluid-martial-arts.md](styles/fluid-martial-arts.md) | Draft |
| Stepped: held keys, no interpolation, stop-motion feel | [styles/stepped.md](styles/stepped.md) | Draft |
| Cartoony exaggerated: pushed poses, bouncy overshoot, elastic settles | [styles/cartoony-exaggerated.md](styles/cartoony-exaggerated.md) | Draft |
| Realistic: weight shifts, subtle secondary motion, smooth easing | [styles/realistic.md](styles/realistic.md) | Draft |
| Robotic: hard stops, linear moves, no overshoot | [styles/robotic.md](styles/robotic.md) | Draft |

| Style | Feel | Best for | Difficulty |
| --- | --- | --- | --- |
| Snappy action | Punchy, readable hits | PvP and combat games | Medium |
| Heavy and weighty | Big, powerful | Bruisers, bosses, giants | Medium |
| Fluid martial arts | Flowing combos | Fighters, ninjas | High |
| Stepped | Stylised, choppy on purpose | Stylised or comic games | Low |
| Cartoony exaggerated | Bouncy, expressive | Family and simulator games | Medium |
| Realistic | Grounded | Survival, shooters | High |
| Robotic | Stiff, precise | Robots, constructs | Low |

To add a style, copy [styles/_template.md](styles/_template.md), fill every section, add a row above, test it on one clip and get the owner's approval before rolling it out. Rules that hold for every style: one style per game, pose first and curves second, strike frames named and synced to gameplay, and the owner judges the feel in a playtest.

## Workflow

1. **Brief.** One short brief per clip set in `blender/briefs/` using the style's timing table: action name, frame count, loop or not, the **strike frame** (where damage lands), and which poses are the extremes. Reference video or a pose sketch from the owner beats words.
2. **Codex builds** in Blender (the `codex-workflow` skill), one clip set per run, on the shared rig. Stepped keys first (poses and timing only), smooth curves afterwards.
3. **Check.** Render a contact sheet of the extreme poses and look at it before export. Reject clips that stay close to the neutral stance.
4. **Export and upload** through the `asset-pipeline` skill, register IDs in docs/animations.md and the game config, with the strike frame time written next to the ID.
5. **Test in Studio at game speed** with the real cast or attack, not just the animation editor, and tune from what the owner feels.

## Movement transitions are part of animation delivery

Every character animation set must define how its clips enter, exit and get interrupted. A good isolated loop is not a finished movement system. Include applicable transitions in the brief and implementation; explicitly mark unsupported states as not applicable instead of silently omitting them.

- For locomotion, cover idle to walk/run, walk/run to idle, speed changes, takeoff, fall, landing to idle/run, and direction changes where supported. For actions, define entry from locomotion, recovery back to locomotion, and permitted interruptions.
- Preserve approved stride timing and silhouettes. Use tuned crossfades first; author dedicated start, stop, turn or landing clips only where blending cannot express the desired weight. Do not require extra full-body animations stacked together for smoothness.
- Tune start, stop, airborne and landing fades separately. Smooth animation playback speed when needed, without adding input delay or changing physical speed, jump behavior, hit timing or invulnerability unless gameplay changes are explicitly authorized.
- Assign priorities and joint coverage deliberately. Upper-body actions can layer over moving legs when allowed; a full-body action must not accidentally freeze locomotion. Do not let fades hide attack telegraphs or move damage windows.
- Keep footsteps and VFX tied to actual eligible contacts. Suppress step effects while idle or airborne, avoid duplicate markers during blends, and handle rapid starts/stops, jumps, landing, death, respawn and cleanup.
- Review transitions in a fresh Studio playtest at actual game speed: start, stop, reverse, jump while moving, land moving and stationary, then interrupt with relevant actions. Check feet, pose pops, unwanted sliding, stale tracks and duplicate effects. Record what was actually tested; a preview image or Blender loop alone does not verify transitions.

## Why animations come out flat, and the fix

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| No impact | Even spacing, no hold on the hit | Fast into the strike, hold 2 to 3 frames, slow out |
| Floaty | Smooth easing on every key, no weight shift | Stepped blocking first, move hips and chest, add a drop on landing |
| Stiff | Only arms move | Add hip, chest and head twist, and overlap (head and arms lag the body) |
| Weak windup | Anticipation too small | Push the pull-back pose further and give it 4 to 6 frames |
| Boring | Poses stay near neutral | Exaggerate extremes by 20 to 40% (R15 joints can only rotate, so pose is the only lever) |
| Looks late in game | Strike frame not synced | Align damage and VFX to the strike frame; shorten the windup, not the hit |
| Pops at loop point | First and last frames differ | Copy frame 1 to the end and check velocity matches |
| Feet slide | Root motion missing | Add root translation or lock the feet during planted frames |

## Roblox specifics

- R15 joints (Motor6D) are rotation and offset only: no squash or scale on limbs, so exaggeration comes from posing and timing.
- Clips are authored at 30 fps (see docs/animations.md) and Roblox interpolates on playback. Keep keyframes sparse and meaningful; a key every frame fights the interpolation.
- Check which easing styles the exporter writes before relying on them. If it only samples curves, bake the timing into the keys instead.
- Animation priority: Core < Idle < Movement < Action < Action2 < Action3 < Action4. Attacks use Action; looping idle and run use Idle and Movement. Mark loops in the clip and test the loop point.
- Sync gameplay to named strike frames (write the time in the brief and next to the ID in docs/animations.md; use keyframe markers if the exporter supports them).
- Publish every animation under the experience's owner, or it fails silently. New assets can take a few minutes to play, so preload with `ContentProvider:PreloadAsync`.
- Load tracks only after the model is parented to the workspace; an Animator outside the world gives zero-length tracks.

## Review checklist

- [ ] The clip follows the chosen style's timing and pose rules
- [ ] Extreme poses are clearly different from neutral
- [ ] Anticipation, strike and recovery are all readable
- [ ] Hips, chest and head move, not only the arms
- [ ] Strike frame is named, written in docs/animations.md and synced to damage and VFX
- [ ] Loops are seamless; non-loops return to idle cleanly
- [ ] Applicable movement/action transitions, interruptions and marker gating are implemented and tested at game speed
- [ ] Tested in game at real speed, from the owner's point of view and an opponent's
- [ ] Animation ID registered and published under the experience owner
