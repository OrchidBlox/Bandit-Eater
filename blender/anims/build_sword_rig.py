"""Two-handed sword clips on the canonical MrXen0 rig, authored WITH the sword in the scene.
Run: Blender -b --factory-startup --python this.py -- --render [--export]

How the grip works (owner-approved stance, docs/reference/sword-concepts-v1-2026-10-28/sword-ready-stance.png):
- The sword (blender/BE_HeldSword.blend) rides the RightHand deform bone with one fixed grip: tip along the hand's -Z
  (out of the front of the fist), blade width along the fingers (+Y), grip centre 0.45 below the wrist.
- Both arms run in IK. The right IK target (TargetR) carries the wrist position and the blade direction; the left IK
  target is TargetR shifted 0.8 down the handle, so both hands are on the grip in every frame by construction.
- A reach fit keeps both wrists within the short R15 arm reach (shoulder to wrist about 1.49 studs).
- Body (torso, head, legs) uses the V2 FK helpers; feet are grounded every sampled frame.
Exports go through the validated V2 exporter (evaluated deform bones), so IK is baked into the clips.
GRIP_ROBLOX below is the sword's CFrame relative to the Roblox RightHand part; the game welds the sword with it."""
from pathlib import Path
import sys
ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
V2 = ROOT / 'blender/anims/build_power_moves_v2.py'
KEY = 'Sword'
source = V2.read_text().rsplit("\nif '--compose' in sys.argv:", 1)[0]
source = (source.replace("BE_PowerMovesV2.blend", f"BE_SwordRig_{KEY}.blend")
          .replace("power-moves-v2", f"sword-rig-{KEY.lower()}")
          .replace("BE_PowerMovesV2.validation.json", f"BE_SwordRig_{KEY}.validation.json")
          .replace("export/animations/BE_PowerMovesV2_", f"export/animations/BE_SwordRig_{KEY}_"))

MINE = r'''
import math
from mathutils import Matrix, Vector

CLIPS = {'Ready': (48, None), 'M1_1': (18, 6), 'M1_2': (18, 6), 'M1_3': (20, 7)}
SELECTED = list(CLIPS)
for _name, (_frames, _strike) in CLIPS.items():
    MOVES[_name] = {'power': KEY, 'index': 0, 'name': _name, 'delay': (_strike or 0) / 30}
    LENGTHS[_name] = float(_frames)
    MARKERS[_name] = [(_strike, 'Strike', '')] if _strike else []
    FRAMES[_name] = sorted(set([float(f) for f in range(_frames + 1)] + ([float(_strike)] if _strike else [])))

READY_BLADE = Vector((0.15, 0.71, 0.71)).normalized()
READY_FINGERS = Vector((0, 0.71, -0.71)).normalized()
SPACING, REACH = 0.78, 1.46

def P(lean=0, twist=5, head=-5, front=(-22, 30), back=(18, 28), wrist=(0.1, 1.2, 3.5), blade=(0.15, 0.71, 0.71)):
    return {'lean': lean, 'twist': twist, 'head': head, 'front': front, 'back': back, 'wrist': Vector(wrist), 'blade': Vector(blade).normalized()}

READY = P()
BREATH = P(lean=-2, front=(-24, 33), back=(19, 31), wrist=(0.1, 1.18, 3.44), blade=(0.15, 0.74, 0.66))
LUNGE_F, LUNGE_B = (-38, 50), (26, 32)
KEYS = {
    'Ready': [(0, READY), (24, BREATH), (48, READY)],
    # Hit 1: fast horizontal slash, right to left.
    'M1_1': [(0, READY),
             (3, P(lean=6, twist=-50, head=15, wrist=(0.9, 0.6, 3.4), blade=(1, -0.15, 0.25))),
             (6, P(lean=-22, twist=25, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(-0.05, 1.65, 2.9), blade=(-0.45, 0.9, 0.0))),
             (8, P(lean=-22, twist=25, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(-0.05, 1.65, 2.9), blade=(-0.45, 0.9, 0.0))),
             (11, P(lean=-24, twist=35, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(-0.5, 1.5, 2.9), blade=(-0.65, 0.75, 0.0))),
             (18, READY)],
    # Hit 2: backhand return, left to right.
    'M1_2': [(0, READY),
             (3, P(lean=0, twist=35, head=-12, wrist=(-0.45, 1.0, 3.35), blade=(-1, 0.1, 0.25))),
             (6, P(lean=-22, twist=-25, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(0.3, 1.6, 2.85), blade=(0.45, 0.9, -0.05))),
             (8, P(lean=-22, twist=-25, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(0.3, 1.6, 2.85), blade=(0.45, 0.9, -0.05))),
             (11, P(lean=-24, twist=-35, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(0.75, 1.4, 2.85), blade=(0.65, 0.75, -0.05))),
             (18, READY)],
    # Hit 3: overhead chop into a deep lunge (bigger pull-back, same speed).
    'M1_3': [(0, READY),
             (4, P(lean=10, twist=-10, head=8, front=(-10, 15), back=(10, 15), wrist=(0.35, 0.85, 4.05), blade=(0.1, -0.4, 0.9))),
             (7, P(lean=-16, twist=5, head=-5, front=(-45, 65), back=(30, 40), wrist=(0.05, 1.65, 2.85), blade=(0, 1, -0.3))),
             (10, P(lean=-16, twist=5, head=-5, front=(-45, 65), back=(30, 40), wrist=(0.05, 1.65, 2.85), blade=(0, 1, -0.3))),
             (13, P(lean=-16, twist=5, head=-5, front=(-47, 68), back=(32, 42), wrist=(0.05, 1.55, 2.6), blade=(0, 0.9, -0.45))),
             (20, READY)],
}

def blend(a, b, t):
    def lerp(x, y):
        return x + (y - x) * t
    pair = lambda k: (lerp(a[k][0], b[k][0]), lerp(a[k][1], b[k][1]))
    blade = a['blade'].lerp(b['blade'], t)
    if blade.length < 1e-4:
        blade = b['blade']
    return {'lean': lerp(a['lean'], b['lean']), 'twist': lerp(a['twist'], b['twist']), 'head': lerp(a['head'], b['head']),
            'front': pair('front'), 'back': pair('back'), 'wrist': a['wrist'].lerp(b['wrist'], t), 'blade': blade.normalized()}

def pose_at(name, f):
    keys = KEYS[name]
    for (lo, a), (hi, b) in zip(keys, keys[1:]):
        if lo <= f <= hi:
            t = (f - lo) / (hi - lo)
            # Fast attack segments stay linear; longer recoveries ease out (snappy action).
            if hi - lo > 3:
                t = t * t * (3 - 2 * t)
            return blend(a, b, t)
    return keys[-1][1]

def hand_frame(pos, blade):
    q = READY_BLADE.rotation_difference(blade)
    fingers = (q @ READY_FINGERS).normalized()
    fingers = (fingers - blade * fingers.dot(blade)).normalized()
    x = fingers.cross(-blade).normalized()
    m = Matrix((x, fingers, -blade)).transposed().to_4x4()
    m.translation = pos
    return m

def fit(wrist, blade, shoulder_r, shoulder_l):
    w = wrist.copy()
    for _ in range(12):
        if (w - shoulder_r).length > REACH:
            w = shoulder_r + (w - shoulder_r).normalized() * REACH
        wl = w - blade * SPACING
        if (wl - shoulder_l).length > REACH:
            w += (shoulder_l + (wl - shoulder_l).normalized() * REACH) - wl
    return w

def build_sword():
    global SWORD, TARGET, GRIPL
    with bpy.data.libraries.load(str(ROOT / 'blender/BE_HeldSword.blend'), link=False) as (src, dst):
        dst.objects = [n for n in src.objects if n.startswith('BE_HeldSword')]
    SWORD = dst.objects[0]
    scene.collection.objects.link(SWORD)
    def empty(n):
        e = bpy.data.objects.new(n, None)
        scene.collection.objects.link(e)
        return e
    grip_r = empty('SwordGripR')
    c = grip_r.constraints.new('COPY_TRANSFORMS'); c.target = rig; c.subtarget = 'RightHand'
    SWORD.parent = grip_r
    SWORD.matrix_parent_inverse = Matrix.Identity(4)
    SWORD.matrix_basis = Matrix.Translation((0, 0.45, 0)) @ Matrix(((0, 1, 0), (1, 0, 0), (0, 0, -1))).to_4x4()
    TARGET = empty('SwordTargetR')
    GRIPL = empty('SwordGripL'); GRIPL.parent = TARGET
    GRIPL.matrix_parent_inverse = Matrix.Identity(4); GRIPL.matrix_basis = Matrix.Translation((0, 0, SPACING))
    for bone, target in (('IK_Hand.R', TARGET), ('IK_Hand.L', GRIPL)):
        k = rig.pose.bones[bone].constraints.new('COPY_TRANSFORMS'); k.name = 'SwordGrip'; k.target = target

def apply_pose(name, value):
    p = pose_at(name, value)
    pb = rig.pose.bones
    def rot(n, x=0, y=0, z=0):
        b = pb[n]; b.rotation_mode = 'XYZ'; b.rotation_euler = (math.radians(x), math.radians(y), math.radians(z))
    for n in CONTROLS:
        pb[n].rotation_mode = 'XYZ'; pb[n].rotation_euler = rest[n]['rot']; pb[n].location = rest[n]['loc']
    rot('UpTorso', p['lean'], p['twist'], 0); rot('LowTorso', 0, -p['twist'] * 0.25, 0); rot('HEAD', -p['lean'] * 0.4, p['head'], 0)
    for side, (u, l) in (('L', p['front']), ('R', p['back'])):
        rot('FK_UpperLeg.' + side, u); rot('FK_LowerLeg.' + side, l); rot('FK_Foot.' + side, -(u + l))
    props = pb['PROPERTIES']
    for prop in h['SWITCHES']:
        props[prop] = 0
    props['ARM_IK_FK.R'] = 1.0; props['ARM_IK_FK.L'] = 1.0
    h['eval_rig']()
    bottom = min(v.z for n in ('LeftFoot', 'RightFoot') for v in h['mesh_world'](n))
    pb['ROOT'].location[2] -= bottom
    h['eval_rig']()
    shoulder_r = rig.matrix_world @ pb['RightUpperArm'].head
    shoulder_l = rig.matrix_world @ pb['LeftUpperArm'].head
    wrist = p['wrist'] + Vector((0, 0, -bottom))
    asked = wrist.copy()
    wrist = solve_grip(wrist, p['blade'], shoulder_r, shoulder_l)
    DEBUG.append((CURRENT[0], round(value, 1), round((wrist - asked).length, 2), round(grip_penetration(wrist, p['blade'], body_boxes()), 2)))
    TARGET.matrix_world = hand_frame(wrist, p['blade'])
    h['eval_rig']()

CLEAR_PARTS = ('UpperTorso', 'LowerTorso', 'Head', 'LeftUpperLeg', 'RightUpperLeg')
GRIP_OFFSET = 0.45  # the handle axis sits this far from the wrist joint, along the fingers (see build_sword)

def body_boxes():
    boxes = []
    for part in CLEAR_PARTS:
        obj = h['mesh_objects'][part]
        lo = Vector([min(c[i] for c in obj.bound_box) for i in range(3)])
        hi = Vector([max(c[i] for c in obj.bound_box) for i in range(3)])
        boxes.append((obj.matrix_world.inverted(), lo, hi))
    return boxes

def sword_points(wrist, blade):
    # Handle axis from pommel to guard top, plus the guard's two tips (the guard runs along the fingers).
    fingers = hand_frame(wrist, blade).col[1].xyz
    axis = wrist + fingers * GRIP_OFFSET
    points = [axis + blade * t for t in (-1.3, -0.9, -0.5, -0.1, 0.3, 0.7, 0.97)]
    guard = axis + blade * 0.68
    points += [guard + fingers * 0.9, guard - fingers * 0.9]
    return points

def grip_penetration(wrist, blade, boxes, margin=0.1):
    total = 0.0
    for point in sword_points(wrist, blade):
        for inv, lo, hi in boxes:
            l = inv @ point
            depth = min(min(l[i] - (lo[i] - margin), (hi[i] + margin) - l[i]) for i in range(3))
            if depth > 0:
                total += depth
    return total

def solve_grip(wrist, blade, shoulder_r, shoulder_l):
    # Search near the authored wrist for a grip both arms can reach that keeps the sword out of the body.
    boxes = body_boxes()
    best, best_score = None, None
    steps = [-0.75, -0.6, -0.45, -0.3, -0.15, 0.0, 0.15, 0.3, 0.45, 0.6, 0.75]
    for dx in steps:
        for dy in steps:
            for dz in steps:
                w = wrist + Vector((dx, dy, dz))
                over = max(0.0, (w - shoulder_r).length - REACH) + max(0.0, (w - blade * SPACING - shoulder_l).length - REACH)
                score = over * 20 + grip_penetration(w, blade, boxes) * 8 + (dx * dx + dy * dy + dz * dz)
                if best_score is None or score < best_score:
                    best, best_score = w, score
    return fit(best, blade, shoulder_r, shoulder_l)

def frame(value):
    scene.frame_set(int(value), subframe=value - int(value))
    name = CURRENT[0]
    apply_pose(name, value - 1)

CURRENT = ['Ready']
DEBUG = []
_select = select
def select(name):
    CURRENT[0] = name
    _select(name)

def author():
    for name in SELECTED:
        a = bpy.data.actions.get('BE_PowerMovesV2_' + name) or rest_action.copy()
        a.name = 'BE_PowerMovesV2_' + name; a.use_fake_user = True
        for fc in h['curves'](a):
            for index in range(len(fc.keyframe_points) - 1, -1, -1):
                fc.keyframe_points.remove(fc.keyframe_points[index], fast=True)
        for marker in list(a.pose_markers):
            a.pose_markers.remove(marker)
        for markerframe, marker, v in MARKERS[name]:
            m = a.pose_markers.new(marker + '_' + v); m.frame = round(markerframe + 1)
    print('Clips', SELECTED)

def grip_report():
    # Sword CFrame relative to the Roblox RightHand part: measured at rest, where the part is axis-aligned.
    pb = rig.pose.bones
    for n in CONTROLS:
        pb[n].rotation_mode = 'XYZ'; pb[n].rotation_euler = rest[n]['rot']; pb[n].location = rest[n]['loc']
    for prop in h['SWITCHES']:
        pb['PROPERTIES'][prop] = 0
    pb['PROPERTIES']['ARM_IK_FK.R'] = 0.0; pb['PROPERTIES']['ARM_IK_FK.L'] = 0.0
    h['eval_rig']()
    verts = h['mesh_world']('RightHand')
    center = sum(verts, Vector()) / len(verts)
    world = SWORD.matrix_world
    P_ = Matrix(((1, 0, 0), (0, 0, 1), (0, -1, 0)))
    rot = world.to_3x3().normalized()
    cols = [P_ @ rot.col[0], P_ @ rot.col[2], -(P_ @ rot.col[1])]  # Roblox sword X = width, Y = tip, Z = thin
    pos = P_ @ (world.translation - center)
    grip = {'position': [round(v, 4) for v in pos], 'right': [round(v, 4) for v in cols[0]],
            'up': [round(v, 4) for v in cols[1]], 'back': [round(v, 4) for v in cols[2]]}
    (REVIEW / f'BE_SwordRig_{KEY}_grip.json').write_text(json.dumps({'sword_in_right_hand_roblox': grip, 'spacing': SPACING}, indent=2))
    print('GRIP', grip)


def clip_report():
    # Deepest point of the sword inside a body part (studs), per clip and per sword section.
    body = ['Head', 'UpperTorso', 'LowerTorso', 'LeftUpperLeg', 'RightUpperLeg']
    verts = [v.co.copy() for v in SWORD.data.vertices]
    for name in SELECTED:
        select(name)
        worst = {'blade': (0, None, None), 'guard': (0, None, None), 'handle': (0, None, None)}
        for f in range(int(LENGTHS[name]) + 1):
            frame(f + 1)
            for part in body:
                obj = h['mesh_objects'][part]
                inv = obj.matrix_world.inverted()
                lo = Vector([min(c[i] for c in obj.bound_box) for i in range(3)])
                hi = Vector([max(c[i] for c in obj.bound_box) for i in range(3)])
                for v in verts:
                    l = inv @ (SWORD.matrix_world @ v)
                    depth = min(min(l[i] - lo[i], hi[i] - l[i]) for i in range(3))
                    if depth > 0:
                        key = 'blade' if v.z > 0.97 else 'guard' if v.z > 0.4 else 'handle'
                        if depth > worst[key][0]:
                            worst[key] = (round(depth, 2), f, part + f' z={round(v.z, 2)}')
        print(f'CLIP {name}: ' + ', '.join(f'{k} {d} in {p} @f{fr}' for k, (d, fr, p) in worst.items() if d > 0) or 'clear')

import bpy
from mathutils import Matrix, Vector
setup()
build_sword()
author()
if '--grip' in sys.argv or '--export' in sys.argv: grip_report()
if '--clip' in sys.argv:
    clip_report()
    for row in DEBUG:
        if row[3] > 0.05 and float(row[1]).is_integer():
            print('LEFT', row)
if '--render' in sys.argv:
    # The base renderer hides every mesh that is not a rig body part; show the sword in the review too.
    h['mesh_objects']['HeldSword'] = SWORD
    render()
    del h['mesh_objects']['HeldSword']
if '--export' in sys.argv: export()
'''
exec(compile(source + MINE, str(V2), 'exec'), {'__name__': '__swordrig__', 'KEY': KEY})
