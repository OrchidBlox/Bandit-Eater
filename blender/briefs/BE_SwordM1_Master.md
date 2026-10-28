# BE_SwordM1_Master - animation brief (Master Sword M1 combo, 3 clips)

Style: snappy action (`.claude/skills/animation/styles/snappy-action.md`): 3 to 5 extreme poses per clip, fast in and slow out, 2 to 3 frame hold on the strike, a 4 to 6 frame pull-back, hips then chest then shoulder then arm leading, push extremes 20 to 40 percent, a small overshoot and a clean return.
Approved design (owner approved 2026-10-28; match each swing's identity, ignore text and UI): `docs/reference/sword-concepts-v1-2026-10-28/sword-m1-combos.png`, row "MASTER SWORD", columns HIT 1 to HIT 3.

## Clips (30 fps, one-handed unless stated)

1. **M1_1** - Wide royal slash. 18 frames, strike marker at frame 6. Pull the blade across to the right hip, then a very wide, full-extension horizontal slash with a big step; chest open, head up, regal and large.
2. **M1_2** - Thrust with a star glint. 18 frames, strike marker at frame 6. Pull the blade back by the ribs, then a long straight thrust with a deep lunge and a hold; blade parallel to the ground and the arm locked straight.
3. **M1_3** - Overhead cleave. 20 frames, strike marker at frame 7. A big overhead cleave: arch back with the blade raised behind the head, then a decisive down-and-forward cleave into a deep lunge with a long hold and a small overshoot.

Gameplay timing is UNCHANGED: durations 18, 18 and 20 frames and strike frames 6, 6 and 7 (config `src/shared/Config/CombatActions.luau`). Do not lengthen any clip or move any strike frame; make the swings feel different through the pose and the path of the blade instead. Hits chain: each clip ends in a pose that leads into the next hit, and hit 3 recovers toward a ready stance.

## How the sword is held (so the poses read)

The sword is held in the RIGHT hand with the blade continuing the line of the forearm, pointing out of the fist the way the fingers point, grip centred in the palm. Aim the arm along the line you want the blade to travel; the blade is the arm line extended by about 4 studs. Keep the blade clear of the torso on the strike pose.

## Rig and tooling (follow exactly)

- Rig: the canonical MrXen0 R15 rig only. Do not replace, rescale or modify it. Source stays unchanged: `C:\Users\Kobe\source\repos\R15 - Blener Model\MrXen0_R15RIG_v1.2.blend`. If it is missing, stop and report the path.
- Copy `blender/anims/build_q_casts.py` to `blender/anims/build_sword_m1_master.py` and change only the clip list, the poses and the output names. It already runs the shared V2 helpers and exporter (`pose`, `legs`, `aim_arm`, `base`, render, export). In the copy: replace the output-name `.replace(...)` strings so the source is `blender/anims/BE_SwordM1_Master.blend`, the validation is `blender/review/BE_SwordM1_Master.validation.json` and the exports are `blender/export/animations/BE_SwordM1_Master_<clip>.rbxmx`; set `SELECTED = ['M1_1', 'M1_2', 'M1_3']`; replace `qcast_poses` with the poses for these swings (keys at 0, a pull-back near frame 2, the strike frame, hold to strike+2, a follow-through, then the end pose). Before `setup()` and after the V2 source is exec'd, register each clip: `MOVES[name] = {'power': 'Master', 'index': i, 'name': name, 'delay': strike_frame / 30}`, `LENGTHS[name] = frames`, `MARKERS[name] = [(strike_frame, 'Strike', '')]`, `FRAMES[name] = sorted(set([float(f) for f in range(frames + 1)] + [float(frames), float(strike_frame)]))`. Clip names are exactly `M1_1`, `M1_2`, `M1_3`.
- Run headless: `"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" -b --factory-startup --python blender/anims/build_sword_m1_master.py -- --render` first and check ONE composite contact sheet (pull-back, strike, hold, recovery for each clip; side and three-quarter). Fix obvious problems (cramped arms, no extension, feet sliding, pose staying near neutral), then run with `-- --export`.
- Export gives the standing clip and a `...Moving` upper-body variant (legs and root muted) automatically; keep that.
- Priority Action, not looping, root horizontal travel zero. No sound, no VFX, no gameplay code.

## Transitions (animation skill, mandatory)

Entry: the clip starts from locomotion or idle; the standing variant plays when still, the moving variant (upper body only) plays while running or airborne. Recovery: hit 3 returns to a ready stance that blends to idle; hits 1 and 2 end in a lead-in pose for the next hit. Interrupts: dash, jump, hit reaction and a new power cast may cut in at any frame; the first and last pose must not pop on a 0.06 s fade. Landing, jump and double jump are not authored here: not applicable.

## Scope and limits

Do NOT edit src/, docs/, default.project.json, other briefs or any Roblox/Studio files, and do not use the Roblox_Studio MCP. Write only blender/anims/build_sword_m1_master.py, its .blend, blender/review/ and blender/export/animations/. If the same step fails twice, STOP and report the step, the error and what you tried; never rebuild from scratch. Print only summaries and failures.

Final report: clip names and lengths, strike markers, the review sheet path, export paths, validation result, and what to check by eye.
