"""Writes one M1 animation brief per sword into blender/briefs/ (BE_SwordM1_<Name>.md).
Run from the repo root: python scripts/make_sword_anim_briefs.py.
Designs: docs/reference/sword-concepts-v1-2026-10-28/sword-m1-combos.png (owner approved 2026-10-28)."""
from pathlib import Path

REF = 'docs/reference/sword-concepts-v1-2026-10-28/sword-m1-combos.png'

HITS = {
    'Sword': [
        ('Fast horizontal slash', 'Pull the blade back across the right hip with the chest coiled right; strike a flat right-to-left slash at shoulder height; arm fully extended and the blade continues its line; finish with the torso turned left.'),
        ('Backhand slash', 'From the finish of hit 1, sweep the blade back left-to-right with the back of the hand leading, hips snapping the other way; off hand swings back for balance.'),
        ('Overhead chop', 'Raise the blade high over the head with a deeper knee bend and arched back (bigger pull-back, not longer); chop down and forward into a deep lunge, blade pointing to the ground in front of the lead foot.'),
    ],
    'Wind': [
        ('Quick spinning slash', 'Lean away, then a fast 270 degree body spin with the blade trailing out level; hold the strike with the blade pointing forward at the end of the spin.'),
        ('Rising flick', 'Step in low, flick the blade from below the hip up and forward in a rising diagonal; weight on the front foot, chest tilting back at the end, off arm thrown wide.'),
        ('Whirl finish', 'Crouch, then a wide full spin with both arms out and the blade level; the spin continues past the strike by 30 degrees and settles. Big silhouette.'),
    ],
    'Earth': [
        ('Heavy two-hand chop', 'Both hands on the grip, raised behind the right shoulder with a deep stance; drive a diagonal downward chop with the whole torso and plant; heavy hold.'),
        ('Shoulder bash with the flat', 'Turn the left shoulder forward, blade held flat across the chest; drive forward in a short charge, shoulder and flat leading; stop hard on the strike.'),
        ('Ground slam', 'Lift the blade overhead with both hands, rise onto the toes, then slam it straight down into the ground in front of the feet with a deep crouch; long hold, small bounce-back.'),
    ],
    'Water': [
        ('Figure-eight slash', 'Flowing continuous slash: the blade traces a sideways figure-eight in front of the body, hips swaying with it; strike on the first crossing, light and fluid.'),
        ('Low-to-high scoop', 'Sweep the blade from low beside the knee up in a scooping arc to above the head, weight rolling from back foot to front foot; finish with the blade pointing up and forward.'),
        ('Arcing flourish', 'A wide arcing flourish with a pivot on the front foot: blade sweeps out in a big flat arc while the body turns 180 degrees; settle with a graceful pose.'),
    ],
    'Fire': [
        ('Stabbing lunge', 'Pull the blade back at the hip, then lunge forward in a deep stance with the arm fully extended in a straight thrust; the blade is the longest line in the silhouette.'),
        ('Fast double cut', 'Two quick diagonal cuts in one clip: first cut lands on the strike frame (down-right), second cut follows 3 frames later (down-left); arms snap, hips twist each time.'),
        ('Rising uppercut', 'Crouch with the blade low behind the hip, then explode upward in an uppercut that takes the blade overhead; body stretches, back foot lifts, arm fully extended up and forward.'),
    ],
    'Shadow': [
        ('Low cross slash', 'Crouch low with the blade pulled across the body; sweep a low cross slash from left to right near the ground with the torso twisting and leaning; sneaky and quick.'),
        ('Reverse-grip slash', 'Flip the blade into a reverse grip (blade running back along the forearm) and slash behind and across the body with a hip spin; off hand trailing.'),
        ('Fast spin slash', 'A quick tight spin with the blade low and out; small footwork, strike on the second half turn; end crouched with the blade extended.'),
    ],
    'Master': [
        ('Wide royal slash', 'Pull the blade across to the right hip, then a very wide, full-extension horizontal slash with a big step; chest open, head up, regal and large.'),
        ('Thrust with a star glint', 'Pull the blade back by the ribs, then a long straight thrust with a deep lunge and a hold; blade parallel to the ground and the arm locked straight.'),
        ('Overhead cleave', 'A big overhead cleave: arch back with the blade raised behind the head, then a decisive down-and-forward cleave into a deep lunge with a long hold and a small overshoot.'),
    ],
}

NAMES = {'Sword': 'Sword', 'Wind': 'Wind Sword', 'Earth': 'Earth Sword', 'Water': 'Water Sword',
         'Fire': 'Fire Sword', 'Shadow': 'Shadow Sword', 'Master': 'Master Sword'}
FRAMES = [18, 18, 20]
STRIKE = [6, 6, 7]


def main():
    out = Path('blender/briefs')
    for key, hits in HITS.items():
        lines = []
        for i, (title, text) in enumerate(hits, 1):
            extra = ' The second cut is a visual-only second strike at frame 9 (the gameplay strike stays at frame 6).' if key == 'Fire' and i == 2 else ''
            lines.append(f"{i}. **M1_{i}** - {title}. {FRAMES[i - 1]} frames, strike marker at frame {STRIKE[i - 1]}. {text}{extra}")
        body = f"""# BE_SwordM1_{key} - animation brief ({NAMES[key]} M1 combo, 3 clips)

Style: snappy action (`.claude/skills/animation/styles/snappy-action.md`): 3 to 5 extreme poses per clip, fast in and slow out, 2 to 3 frame hold on the strike, a 4 to 6 frame pull-back, hips then chest then shoulder then arm leading, push extremes 20 to 40 percent, a small overshoot and a clean return.
Approved design (owner approved 2026-10-28; match each swing's identity, ignore text and UI): `{REF}`, row "{NAMES[key].upper()}", columns HIT 1 to HIT 3.

## Clips (30 fps, one-handed unless stated)

{chr(10).join(lines)}

Gameplay timing is UNCHANGED: durations 18, 18 and 20 frames and strike frames 6, 6 and 7 (config `src/shared/Config/CombatActions.luau`). Do not lengthen any clip or move any strike frame; make the swings feel different through the pose and the path of the blade instead. Hits chain: each clip ends in a pose that leads into the next hit, and hit 3 recovers toward a ready stance.

## How the sword is held (so the poses read)

The sword is held in the RIGHT hand with the blade continuing the line of the forearm, pointing out of the fist the way the fingers point, grip centred in the palm. Aim the arm along the line you want the blade to travel; the blade is the arm line extended by about 4 studs. Keep the blade clear of the torso on the strike pose.

## Rig and tooling (follow exactly)

- Rig: the canonical MrXen0 R15 rig only. Do not replace, rescale or modify it. Source stays unchanged: `C:\\Users\\Kobe\\source\\repos\\R15 - Blener Model\\MrXen0_R15RIG_v1.2.blend`. If it is missing, stop and report the path.
- Copy `blender/anims/build_q_casts.py` to `blender/anims/build_sword_m1_{key.lower()}.py` and change only the clip list, the poses and the output names. It already runs the shared V2 helpers and exporter (`pose`, `legs`, `aim_arm`, `base`, render, export). In the copy: replace the output-name `.replace(...)` strings so the source is `blender/anims/BE_SwordM1_{key}.blend`, the validation is `blender/review/BE_SwordM1_{key}.validation.json` and the exports are `blender/export/animations/BE_SwordM1_{key}_<clip>.rbxmx`; set `SELECTED = ['M1_1', 'M1_2', 'M1_3']`; replace `qcast_poses` with the poses for these swings (keys at 0, a pull-back near frame 2, the strike frame, hold to strike+2, a follow-through, then the end pose). Before `setup()` and after the V2 source is exec'd, register each clip: `MOVES[name] = {{'power': '{key}', 'index': i, 'name': name, 'delay': strike_frame / 30}}`, `LENGTHS[name] = frames`, `MARKERS[name] = [(strike_frame, 'Strike', '')]`, `FRAMES[name] = sorted(set([float(f) for f in range(frames + 1)] + [float(frames), float(strike_frame)]))`. Clip names are exactly `M1_1`, `M1_2`, `M1_3`.
- Run headless: `"C:\\Program Files\\Blender Foundation\\Blender 5.2\\blender.exe" -b --factory-startup --python blender/anims/build_sword_m1_{key.lower()}.py -- --render` first and check ONE composite contact sheet (pull-back, strike, hold, recovery for each clip; side and three-quarter). Fix obvious problems (cramped arms, no extension, feet sliding, pose staying near neutral), then run with `-- --export`.
- Export gives the standing clip and a `...Moving` upper-body variant (legs and root muted) automatically; keep that.
- Priority Action, not looping, root horizontal travel zero. No sound, no VFX, no gameplay code.

## Transitions (animation skill, mandatory)

Entry: the clip starts from locomotion or idle; the standing variant plays when still, the moving variant (upper body only) plays while running or airborne. Recovery: hit 3 returns to a ready stance that blends to idle; hits 1 and 2 end in a lead-in pose for the next hit. Interrupts: dash, jump, hit reaction and a new power cast may cut in at any frame; the first and last pose must not pop on a 0.06 s fade. Landing, jump and double jump are not authored here: not applicable.

## Scope and limits

Do NOT edit src/, docs/, default.project.json, other briefs or any Roblox/Studio files, and do not use the Roblox_Studio MCP. Write only blender/anims/build_sword_m1_{key.lower()}.py, its .blend, blender/review/ and blender/export/animations/. If the same step fails twice, STOP and report the step, the error and what you tried; never rebuild from scratch. Print only summaries and failures.

Final report: clip names and lengths, strike markers, the review sheet path, export paths, validation result, and what to check by eye.
"""
        (out / f'BE_SwordM1_{key}.md').write_text(body, encoding='utf-8')
    print(len(HITS), 'animation briefs written')


if __name__ == '__main__':
    main()
