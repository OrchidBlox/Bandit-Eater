# BE_SwordRig_Sword - sword attached to the rig: grip, two-handed ready idle, M1 combo (4 clips)

Supersedes the first M1 pass (`BE_SwordM1_Sword`), which was authored without the sword in the scene and guessed the grip. Keep its files; do not delete them.

Approved references (owner approved 2026-10-28; match the pose and grip, ignore text and UI):
- Stance: `docs/reference/sword-concepts-v1-2026-10-28/sword-ready-stance.png` (top row: front, side, 3/4).
- Swings: `docs/reference/sword-concepts-v1-2026-10-28/sword-m1-combos.png`, row SWORD, HIT 1 to HIT 3. Swing identities are described in `blender/briefs/BE_SwordM1_Sword.md` (keep them).
- Style: snappy action (`.claude/skills/animation/styles/snappy-action.md`), plus the VFX and animation rules already in that brief.

## What the player must look like

The player holds the sword with a TWO-HANDED grasp in a forward, battle-ready stance: right hand on the grip nearest the guard, left hand on the lower grip near the pommel, both hands visibly gripping the handle in EVERY frame of every clip. The blade points forward and up (about 45 degrees) with the tip above head height, feet shoulder-width and staggered (right foot back), knees soft, torso turned about 30 degrees, weight over the front foot, elbows bent and tucked, head up. The sword is attached to the RIGHT hand; the left hand holds it by pose.

## Deliverables

1. **Rig with the sword attached.** Use the canonical MrXen0 R15 rig only (see `CLAUDE.md`: copy or append, never modify the source). Append the sword from `blender/BE_HeldSword.blend` (scene `HeldSword`, object `BE_HeldSword`; origin = grip centre, blade tip = Blender +Z, wide faces along Blender +-Y, width on X; 5.6 studs long, grip about 0.9 studs). Parent it to the RIGHT hand bone with one fixed offset for all clips.
2. **Choose the grip once, then freeze it.** Pick the sword's offset and rotation relative to the right hand so that in the ready pose the blade points forward-up as in the stance image and both hands sit on the grip (right hand near the guard end of the grip, left hand about 0.5 to 0.9 stud lower). Do not change it between clips. Export it as JSON `blender/review/BE_SwordRig_Sword_grip.json` with: `sword_in_right_hand_roblox` = the sword origin's CFrame relative to the RightHand part in ROBLOX axes (position xyz in studs and the 3x3 rotation matrix, row-major), using the mapping Roblox(x, y, z) = Blender(x, z, -y) and the rig's own hand part frame (the same frame the existing animation exporter writes for RightHand). Also record `left_hand_to_grip_distance`.
3. **Four clips**, all two-handed with the sword visible, on the canonical rig, 30 fps:
   - `Ready`: looping idle for sword holders, 48 frames, first pose = last pose. The stance above with a small weight shift and breathing; the blade stays quiet (small bob only). Idle priority, standing only (no moving variant).
   - `M1_1`, `M1_2`, `M1_3`: the three Sword swings from `BE_SwordM1_Sword.md`, now two-handed. Gameplay timing is UNCHANGED: 18, 18 and 20 frames, strike markers at frames 6, 6 and 7. Each clip starts from and ends in the Ready pose family so the combo chains and returns to Ready without a pop. The blade path must read as the swing in the combo sheet (hit 1 horizontal slash, hit 2 backhand return, hit 3 overhead chop into a lunge); the blade tip must lead the swing and never pass through the torso or head.
4. **Review sheet with the sword rendered.** ONE composite PNG `blender/review/BE_SwordRig_Sword_contact.png`: for Ready and for each M1 clip, render the key poses (pull-back, strike, hold, recovery) with the sword and both hands visible, side and three-quarter views. Check yourself, and fix before exporting: both hands on the grip in every pose, blade direction matches the intended swing, no limb or blade intersections, feet not sliding, extremes pushed 20 to 40 percent.

## Tooling

Use `blender/anims/build_q_casts.py` / `blender/anims/build_sword_m1_sword.py` as the pattern for the pose helpers (`pose`, `legs`, `aim_arm`, `base`), the render and the exporter, in a new script `blender/anims/build_sword_rig_sword.py` writing `blender/anims/BE_SwordRig_Sword.blend`. You must add the sword to the render scene and extend the render so it shows the sword. Run Blender headless with the Blender 5.2 exe. Export standing plus `Moving` upper-body variants for `M1_1..3` (legs and root muted, as before); `Ready` has no moving variant. Exports go to `blender/export/animations/BE_SwordRig_Sword_<clip>.rbxmx`, priority Action for the M1 clips and Idle for `Ready`, markers named `Strike`. Horizontal root travel zero.

## Transitions (animation skill)

Entry: from idle or locomotion into `M1_1`; the standing clip plays when still, the moving variant (upper body only) while running or airborne. `Ready` is the pose the M1 chain returns to and blends from and to idle; it is replaced by locomotion while running. Interrupts: dash, jump, hit reaction and a cast may cut in at any frame; first and last poses must not pop on a 0.06 s fade. Landing, jump and double jump are not authored here.

## Scope and limits

Do NOT edit src/, docs/, default.project.json, other briefs or scripts, or any Roblox/Studio files; do not use the Roblox_Studio MCP; do not upload. Write only the new script, `BE_SwordRig_Sword.blend`, blender/review/ and blender/export/animations/BE_SwordRig_Sword_*. If the same step fails twice, STOP and report the step, the error and what you tried; never rebuild from scratch. Print only summaries and failures.

Final report: clip names and lengths, strike markers, grip JSON path and values, the contact sheet path, export paths, validation result, and what to check by eye.
