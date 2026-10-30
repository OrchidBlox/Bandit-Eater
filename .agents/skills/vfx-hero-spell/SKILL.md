---
name: vfx-hero-spell
description: Produce a cinematic hero spell or big visual move end to end - real 3D meshes from Codex in Blender, rigged creatures, a keyed cast animation, upload and Studio placement, server and client modules, and testing, in the game's chosen VFX style. Blender meshes from Codex are mandatory for every move. Use when a move should look like a key frame rather than a particle burst, needs a mesh, a creature, a dash or a chasing move, or when planning the asset queue for a batch of spells. For small particle-style effects use vfx-effect instead.
---

# VFX hero spell

The production line for any big visual move. Related skills: `vfx-effect` (styles, budgets, counting script), `codex-workflow` (running Codex), `asset-pipeline` (uploads, animation export). Look at how the game's existing spells are structured and copy the closest sibling; this skill describes the method, not any one spell.

## Hard rule: Blender meshes for every move (owner, 2026-10-30)

Blender meshes built by Codex are a **must** for moves, not an option. Every move's hero shapes (the flame tongue, the boulder, the blade, the creature, the wave) are modelled in Blender by Codex from the approved concept image, one model per run. Code builds only the support layers around them. Do not ship a move whose main shape is part-built, reused from another move without approval, or approximated with a texture or particle. If the Blender MCP or Codex is unavailable, report it and wait; do not substitute a code-only version.

## Who does what

| Role | Does |
| --- | --- |
| Owner | Picks the move, approves the concept, playtests, says what to tune |
| ChatGPT image generation | The final concept image of each move (and creature, armour, prop) |
| Claude | Concept artifact (rough art plus a detailed brief), Blender briefs, all code, player cast animations, upload, Studio placement, testing, docs, git |
| Codex (Blender MCP) | Meshes, rigs and creature animations, one job per set, from Claude's brief and the final image |

The owner approves each look before Codex spends credits on it. Claude's artifact drawings are never the final art.

## Steps

0. **Use the game's style, and ask if there isn't one.** Follow Step 0 of the `vfx-effect` skill: if `CLAUDE.md` has no `VFX style:` line, ask the owner (AskUserQuestion) before anything else and record the answer. Then read the style's file and copy its shape, colour, material and timing rules into every brief and the concept request so meshes, particles and timing all match.
1. **Pick the move and write the beats.** One sentence, then three beats: anticipation (the caster gathers), release (the shape that makes it unlike any other move), aftermath (what is left on the ground). Fix the gameplay numbers: cooldown, auto-attack pause, area, damage, how targets are picked.
2. **Concept artifact, then the final image.** Publish an animated HTML artifact when the move needs design review (a creature, a body that must bend, a path): live motion on the real path, anatomy, rig plan, numbers. Owner approves, then the final concept image is generated from the approved brief. Every later step is checked against it. Ask the owner for the stiff-or-flat verdict early; rebuilding a model after the code is written costs far more.
3. **Split the move into pieces and decide what is a mesh.**
   - Hero shapes are real meshes. Particles only add dust, sparks, embers, mist, spray and leaves around them.
   - Meshes are neutral white-grey with a separate `_Glow` object where something glows. The game recolours, scales, spins and makes things neon in code, so one mesh set serves many elements.
   - Creatures are rigged skinned meshes; static effects are plain meshes. Prefix every object with its set name so sets never clash in one Blender file.
   - One short brief per set (`blender/briefs/vfx/<Set>.md`: style, objects, sizes, origin, triangle budget) and one per creature (`blender/briefs/<Creature>.md`: model, rig bone names, animations with exact action names and durations). State which pieces the game moves from code.
4. **Codex builds meshes and creatures.** `bash scripts/codex-run.sh <spec.md> <model> <reasoning> blender` per job.
   - One job per set or creature. A run must never open or switch Blender files (it drops the MCP connection); specs tell Codex to create the working scene with `bpy.ops.scene.new(type='EMPTY')` (never `bpy.data.scenes.new`: it crashes Blender 5.2.2) and save the finished mesh with `bpy.data.libraries.write(path, {obj}, fake_user=True)` (the object only, never a scene; see the crash trap in docs/codex-workflow.md).
   - Queue jobs in a script that skips any job whose FBX exists, logs DONE, FAIL and STOP to a status file and stops cleanly on a usage limit (`scripts/run-spell-assets.sh`). Re-run to resume.
   - A failed job usually means leftovers in the live Blender file; delete them yourself and re-run.
   - Look at the check image before moving on. Reject flat or generic models and send a stronger brief (a smooth tube is not a 40-segment body).
5. **Upload and read the numbers.**
   1. `python scripts/upload_assets.py <Set> --json`. Creatures: copy `<Name>.fbx` to `<Name>_Base.fbx` first so the prefix matches.
   2. In the Studio Edit datamodel, `InsertService:LoadAsset(modelAssetId)` and print every MeshPart's name, `MeshId` and `Size`. Sizes come back x100; divide by 100.
   3. Register each piece in the game's spell mesh config (mesh id, colour, size, optional glow piece with its own mesh id, size and offset) and its mesh style (material, glow colour).
   4. Get each piece's box-centre offset from its origin with a headless Blender script (`bound_box` centre). Note it next to the mesh in the config and use it in the effect module.
6. **The axis rule.** Through the FBX importer: Roblox x = -Blender x, y = Blender z, z = Blender y. Characters face -Z, so a "left" piece in Blender can land on the character's right. Long shapes end up with their long axis on Roblox Y and their tip at +Y. To lay one along direction `d`: `CFrame.lookAt(origin, origin + d) * CFrame.Angles(-math.pi / 2, 0, 0)`, then `* CFrame.new(centre * scale)`.
7. **Rigged creatures.**
   1. Insert the uploaded model in Studio Edit. Rename the bone-holding `Part` to `<Name>_Rig` (animations match their top pose to this name) and set it as PrimaryPart. Store it under `ReplicatedStorage.Assets`. The place must be saved, and the folder copied into the real place before release.
   2. Dump the rig rest data (bone name, parent, WorldCFrame of every bone) into `scripts/rigs/roblox_rest.json` under the creature's key.
   3. `blender -b <file> --python scripts/export_animations.py -- --rig <Name>_Rig --model <Name> --actions ...`, then `upload_assets.py <Name> --include-animations`, and register the ids.
   4. Bones the code drives (a spine, a tail) export with `--passive '<regex>' --omit`. While any clip plays the Animator resets `Bone.Transform` of every bone to identity each frame, so code can't pose through `Transform`; write the pose into `Bone.CFrame` (the rest offset), which the Animator never touches. Always verify by reading bone world positions in Studio while a clip plays.
   5. Skinned glow meshes follow the bones on their own; never move them in code.
   6. Spawn creatures client-side with a shared kit: clone, anchor, destroy the extra Motor6Ds, parent the model into the workspace first and then load animation tracks (an Animator outside the world gives zero-length tracks), play clips by name, move with `PivotTo`.
   7. New animation assets can take a few minutes to play. Preload with `ContentProvider:PreloadAsync`.
   8. A body that bends like a snake: place every spine bone on the trail of the head (its past positions, bones at rest distance along the arc, turned along the trail). S-curves, dives and loops then come free from any head path.
8. **Player cast animations (R15).** Key them headless in Blender with a shared pose library (wrist targets with elbow poles, hip, chest and head angles, foot offsets, ease types), one script per wave. Write the strike frames in the script header; the spell syncs to them (the burst lands on the frame the palms thrust). Export with `scripts/export_r15_animations.py --actions ... --prefix <Wave>`, upload, register. Reuse an existing cast when a new pose adds nothing; give a hero move its own.
9. **Server and client modules.**
   - Server: `Cast(caster, target, stats, combat)` picks targets, works out hits, deals damage with `task.delay` at the moment each blow lands, and broadcasts only what the client needs (origin, direction, points, timings). Numbers live in the game's spell stats config, with cooldown, auto-attack pause and display name beside them.
   - Client: `Play(caster, data, look)` draws it. The module header records the art it follows, the timeline in seconds, the pieces and their offsets. Skip casters beyond the distance cutoff.
   - Shared helpers per family keep modules short. Copy a close sibling and change it.
   - Moves that chase: the server re-picks the biggest enemy group before every strike (predicting where they will be when the blow lands), works out where the creature must stand from its measured reach, and sends a phase update. The client keeps one state per caster.
   - Moves that carry the caster (dashes): body motion on the server (anchor the root, ForceField, always release on death, leave or finish).
   - Piercing projectiles work out who they hit when they leave (distance along the line over speed) instead of stepping every frame.
10. **Layers that make it look expensive.** Windup circle and hand charge, flash, impact marker, impact lines, two shock rings (one delayed), a ground decal (cracks, scorch, sigil), thrown rocks or shards, mist or dust, embers or sparks, a light, a camera shake sized to the move, and a sound. Adjust each to the style's rules (a chunky style swaps lines for puffs and stars; a dark style swaps flashes for smoke). Draw areas slimmer than they hurt. Creatures are solid and shaded with only eyes and edges glowing; all-neon bodies flatten every pose and semi-transparent glass makes parts vanish.
11. **Test in Studio.** There is no test suite. Restart Play (Studio only picks up code after a restart), set the equipped item from the Server datamodel, reset cooldown attributes, teleport near the dummies, press the key with `user_keyboard_input` on the Client, then count effect descendants by class (budget), check dummy health (damage landed), sample bone and part positions over time to measure reach, and screenshot with `screen_capture` using `camera_position` and `look_at_position`. Check the console for script errors. Tests run on the owner's live save: note it first and restore it, or tell the owner what changed.
12. **Review, docs, git.** `selene src`, a leak review (caster dies or leaves mid-cast, tweens, connections, anchored roots), part and emitter peaks, the style's checklist. Update the asset checklist, animation id list and spell table. Commit per wave; push only when the owner says.

## Lessons that cost the most time

- Cast the real spell with a key press as well as calling the module; a typo in a server module only shows when the real remote fires.
- Write measured reach into code and a comment (paw bones at the strike frame, jaw at the bite frame); never guess where a creature's blow lands.
- Check where a pose really puts the head. Turn or move the model so the head ends up where the effect should start.
- Mesh sets reuse. One neutral shard, bolt or rock set serves many moves; recolour and rescale in code.
