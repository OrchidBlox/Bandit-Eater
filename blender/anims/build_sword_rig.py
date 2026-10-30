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
KEY = 'SwordFK' if '--fk' in sys.argv else 'SwordOHE' if '--onehand' in sys.argv and '--casts' in sys.argv else 'SwordOneHand' if '--onehand' in sys.argv else 'SwordCasts' if '--casts' in sys.argv else 'Sword'
source = V2.read_text().rsplit("\nif '--compose' in sys.argv:", 1)[0]
source = (source.replace("BE_PowerMovesV2.blend", f"BE_SwordRig_{KEY}.blend")
          .replace("power-moves-v2", f"sword-rig-{KEY.lower()}")
          .replace("BE_PowerMovesV2.validation.json", f"BE_SwordRig_{KEY}.validation.json")
          .replace("export/animations/BE_PowerMovesV2_", f"export/animations/BE_SwordRig_{KEY}_")
          .replace("assert max(s['mapping_error'] for s in stats)<.06,(name,'mapping')",
                   "print('MAP', name, [round(s['mapping_error'], 3) for s in stats]); assert max(s['mapping_error'] for s in stats)<.06,(name,'mapping')"))
source = source.replace("h['REVIEW_FRAMES']=[1,max(2,d-2),d+1,d+3,LENGTHS[name]+1]",
                        "h['REVIEW_FRAMES']=([float(f) for f in range(1,int(LENGTHS[name])+2)] if '--gif' in sys.argv else [1,max(2,d-2),d+1,d+3,LENGTHS[name]+1])")

MINE = r'''
import math
from mathutils import Matrix, Vector

CLIPS = {'Ready': (48, None), 'M1_1': (18, 6), 'M1_2': (18, 6), 'M1_3': (20, 7)}
CAST_POWERS = ['Sword', 'Sword_Wind', 'Sword_Earth', 'Sword_Water', 'Sword_Fire', 'Sword_Shadow', 'Sword_Sword']
CAST_R = {'Sword': 'spin', 'Sword_Wind': 'spin', 'Sword_Water': 'spin', 'Sword_Earth': 'cleave', 'Sword_Fire': 'cleave',
          'Sword_Sword': 'cleave', 'Sword_Shadow': 'eclipse'}
CAST_DELAY = {}
ONEHAND = '--onehand' in sys.argv or '--fk' in sys.argv
FKMODE = '--fk' in sys.argv
if '--casts' in sys.argv:
    CLIPS = {}
    for _power in CAST_POWERS:
        for _slot, _index in ((('E', 2),) if ONEHAND else (('Q', 1), ('E', 2), ('R', 3))):
            _delay = MOVES[_power + '_' + str(_index)]['delay']
            _name = 'Cast_' + _power + '_' + _slot
            CAST_DELAY[_name] = _delay * 30
            CLIPS[_name] = (round((_delay + 0.5) * 30), _delay * 30)
if ONEHAND and '--casts' not in sys.argv:
    CLIPS = {'Ready': (48, None), 'M1_1': (18, 6), 'M1_2': (18, 6), 'M1_3': (20, 7)}
if FKMODE and '--casts' not in sys.argv:
    CLIPS = {'M1_1': (18, 6)}
SELECTED = list(CLIPS)
for _name, (_frames, _strike) in CLIPS.items():
    MOVES[_name] = {'power': KEY, 'index': 0, 'name': _name, 'delay': (_strike or 0) / 30}
    LENGTHS[_name] = float(_frames)
    MARKERS[_name] = [(_strike, 'Release' if _name.startswith('Cast_') else 'Strike', '')] if _strike else []
    FRAMES[_name] = sorted(set([float(f) for f in range(_frames + 1)] + ([float(_strike)] if _strike else [])))

READY_BLADE = Vector((0.15, 0.71, 0.71)).normalized()
READY_FINGERS = Vector((0, 0.71, -0.71)).normalized()
SPACING, REACH = 0.78, 1.46

def P(lean=0, twist=5, head=-5, front=(-22, 30), back=(18, 28), wrist=(0.1, 1.2, 3.5), blade=(0.15, 0.71, 0.71), off=(0, 0, 0), free=(0, 0, -1.4), arms=None):
    return {'lean': lean, 'twist': twist, 'head': head, 'front': front, 'back': back, 'wrist': Vector(wrist), 'blade': Vector(blade).normalized(),
            'off': Vector(off), 'free': Vector(free), 'arms': arms}

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


CARRY = P(lean=-4, twist=-8, head=-4, front=(-14, 22), back=(10, 22), blade=(0.2, 0.55, 0.8), off=(0.25, 0.35, -1.05), free=(-0.15, 0.1, -1.4))
CARRY2 = P(lean=-6, twist=-10, head=-4, front=(-16, 25), back=(12, 24), blade=(0.2, 0.6, 0.78), off=(0.25, 0.4, -1.0), free=(-0.2, 0.15, -1.38))

def cast_keys(name, d):
    """Two-handed key poses for one cast: pull-back, release at d, hold, follow-through, back to Ready."""
    slot = name[-1]
    power = name[len('Cast_'):-2]
    if slot == 'Q':       # horizontal slash that launches the wave
        pull = P(lean=6, twist=-50, head=15, wrist=(0.9, 0.6, 3.4), blade=(1, -0.15, 0.25))
        rel = P(lean=-22, twist=25, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(-0.05, 1.65, 2.9), blade=(-0.45, 0.9, 0.0))
        fol = P(lean=-24, twist=35, head=-5, front=LUNGE_F, back=LUNGE_B, wrist=(-0.5, 1.5, 2.9), blade=(-0.65, 0.75, 0.0))
    elif slot == 'E' and ONEHAND:   # one-handed dash-slash: low draw back, forward thrust held through the dash, then a cross cut
        pull = P(lean=12, twist=-35, head=6, front=(-10, 30), back=(12, 38), blade=(0.2, -0.5, -0.3), off=(0.4, -0.9, -0.6), free=(0.1, 1.0, 0.3))
        lunge = P(lean=-34, twist=10, head=-12, front=(-55, 70), back=(42, 18), blade=(0, 1, 0.05), off=(0.1, 1.3, 0.1), free=(-1.0, -0.9, 0.3))
        cut = P(lean=-26, twist=-40, head=-8, front=(-48, 62), back=(36, 24), blade=(-0.9, 0.5, 0), off=(-0.7, 1.0, 0.2), free=(-1.1, -0.7, 0.2))
        return [(0, CARRY), (2, pull), (d, lunge), (d + 6, lunge), (d + 8, cut), (d + 11, cut), (d + 15, CARRY)]
    elif slot == 'E':     # dash-slash: crouch, then a low forward thrust lunge held through the dash, ending in a cross cut
        pull = P(lean=10, twist=-30, head=6, front=(-8, 28), back=(10, 36), wrist=(0.4, 0.7, 2.9), blade=(0.2, 0.4, -0.3))
        lunge = P(lean=-38, twist=8, head=-14, front=(-55, 70), back=(42, 18), wrist=(0.1, 1.95, 3.05), blade=(0, 1, 0.05))
        cut = P(lean=-28, twist=60, head=-10, front=(-48, 62), back=(36, 24), wrist=(-0.5, 1.6, 3.0), blade=(-0.9, 0.5, 0))
        return [(0, READY), (2, pull), (d, lunge), (d + 6, lunge), (d + 8, cut), (d + 11, cut), (d + 15, READY)]
    elif CAST_R[power] == 'spin':   # big wind-up and a wide sweeping spin
        pull = P(lean=6, twist=-70, head=15, wrist=(0.9, 0.5, 3.3), blade=(0.7, -0.5, 0.4))
        rel = P(lean=-20, twist=60, head=-12, front=LUNGE_F, back=LUNGE_B, wrist=(-0.3, 1.5, 2.95), blade=(-0.6, 0.8, 0.0))
        fol = P(lean=-22, twist=90, head=-15, front=LUNGE_F, back=LUNGE_B, wrist=(-0.6, 1.2, 3.0), blade=(-0.9, 0.35, 0.0))
    else:                 # cleave / eclipse: sword raised overhead, then driven down into a lunge
        high = 4.35 if CAST_R[power] == 'eclipse' else 4.2
        pull = P(lean=14, twist=0, head=10, front=(-10, 15), back=(10, 15), wrist=(0.05, 0.55, high), blade=(0, -0.45, 0.9))
        rel = P(lean=-16, twist=5, head=-5, front=(-45, 65), back=(30, 40), wrist=(0.05, 1.65, 2.85), blade=(0, 1, -0.3))
        fol = P(lean=-16, twist=5, head=-5, front=(-47, 68), back=(32, 42), wrist=(0.05, 1.55, 2.6), blade=(0, 0.9, -0.45))
    keys = [(0, READY), (2, pull)]
    if d > 8:
        keys.append((2 + (d - 2) * 0.6, pull))      # hold the wind-up so a long delay still reads as anticipation
    keys += [(d, rel), (d + 2, rel), (d + 5, fol), (d + 15, READY)]
    return keys

for _cast, _d in CAST_DELAY.items():
    KEYS[_cast] = cast_keys(_cast, _d)

# One-handed set (owner-approved concept docs/reference/sword-m1-onehand-concepts-v1-2026-10-29): `off` is the sword hand
# relative to the right shoulder, `free` the free left hand relative to the left shoulder (x right, y forward, z up).
LUNGE_ONE_F, LUNGE_ONE_B = (-48, 62), (34, 24)
if ONEHAND:
    KEYS['Ready'] = [(0, CARRY), (24, CARRY2), (48, CARRY)]
    # Hit 1: rising diagonal. Crouch with the sword trailing at the right hip, then a fast cut up across to the high left.
    KEYS['M1_1'] = [(0, CARRY),
        (3, P(lean=14, twist=-32, head=8, front=(-30, 48), back=(20, 40), blade=(0.3, -0.7, -0.65), off=(0.4, -0.9, -1.0), free=(0.1, 1.15, 0.3))),
        (6, P(lean=-18, twist=34, head=-6, front=LUNGE_ONE_F, back=LUNGE_ONE_B, blade=(-0.6, 0.5, 0.6), off=(-0.9, 0.9, 0.5), free=(-0.6, -0.9, 0.2))),
        (8, P(lean=-20, twist=40, head=-6, front=LUNGE_ONE_F, back=LUNGE_ONE_B, blade=(-0.4, 0.1, 0.9), off=(-1.0, 0.4, 1.1), free=(-1.1, -0.8, 0.3))),
        (11, P(lean=-18, twist=38, head=-6, front=LUNGE_ONE_F, back=LUNGE_ONE_B, blade=(-0.4, 0.1, 0.9), off=(-1.0, 0.4, 1.1), free=(-1.1, -0.8, 0.3))),
        (18, CARRY)]
    # Hit 2: wide backhand. Sword drawn across the chest to the left, then a flat sweep right with a half spin.
    KEYS['M1_2'] = [(0, CARRY),
        (3, P(lean=2, twist=48, head=-14, front=(-26, 40), back=(18, 34), blade=(-1, 0.2, 0.0), off=(-1.0, 0.5, 0.1), free=(0.2, 1.1, 0.3))),
        (5, P(lean=-8, twist=-10, head=-6, front=(-40, 56), back=(28, 28), blade=(0.2, 1, 0.0), off=(0.0, 1.3, 0.1), free=(-0.8, -0.6, 0.2))),
        (6, P(lean=-16, twist=-45, head=0, front=LUNGE_ONE_F, back=LUNGE_ONE_B, blade=(1, 0.3, 0.0), off=(1.2, 0.7, 0.1), free=(-1.3, -0.8, 0.1))),
        (8, P(lean=-16, twist=-50, head=0, front=LUNGE_ONE_F, back=LUNGE_ONE_B, blade=(1, -0.1, 0.0), off=(1.4, 0.1, 0.1), free=(-1.3, -0.9, 0.1))),
        (11, P(lean=-14, twist=-48, head=0, front=LUNGE_ONE_F, back=LUNGE_ONE_B, blade=(1, -0.1, 0.0), off=(1.4, 0.1, 0.1), free=(-1.3, -0.9, 0.1))),
        (18, CARRY)]
    # Hit 3: overhead crash. Hop back with the sword straight up, then a hard chop into a deep lunge.
    KEYS['M1_3'] = [(0, CARRY),
        (2, P(lean=6, twist=-2, head=4, front=(-14, 24), back=(10, 22), blade=(0.15, 0.2, 1), off=(0.35, 0.15, 0.55), free=(0.1, 0.9, 0.0))),
        (4, P(lean=12, twist=-6, head=10, front=(-6, 18), back=(8, 18), blade=(0, -0.25, 1), off=(0.2, -0.2, 1.4), free=(0.2, 1.2, 0.3))),
        (7, P(lean=-20, twist=6, head=-6, front=(-52, 68), back=(34, 28), blade=(0, 0.9, -0.45), off=(0.1, 1.1, -0.6), free=(-0.8, -1.1, 0.2))),
        (10, P(lean=-22, twist=8, head=-6, front=(-52, 68), back=(34, 28), blade=(0, 0.5, -0.85), off=(0.2, 0.9, -1.05), free=(-0.9, -1.1, 0.2))),
        (13, P(lean=-22, twist=8, head=-6, front=(-52, 68), back=(34, 28), blade=(0, 0.5, -0.85), off=(0.2, 0.9, -1.05), free=(-0.9, -1.1, 0.2))),
        (20, CARRY)]

# --- FK pilot (roblox-animation skill): sword Hit 1, rising diagonal. Intent: the sword is a one-hand carry, blade angled up and
# forward from a lowered hand; the swing crosses from low right behind the hip up across to high left, edge leading, and the
# whole torso carries it. FK convention measured on this rig family: X negative = forward, Z positive = to the character's
# right, child angles compound. Five poses: carry, anticipation, contact, follow-through, recovery.
def FKP(lean, twist, head, front, back, arms):
    return P(lean=lean, twist=twist, head=head, front=front, back=back, arms=arms)

FK_CARRY = dict(lean=-4, twist=-8, head=-4, front=(-14, 22), back=(10, 22),
                arms={'UpperArm.R': (-22, 0, 10), 'LowerArm.R': (-55, 0, 0), 'Hand.R': (-10, 0, 0),
                      'UpperArm.L': (-8, 0, -8), 'LowerArm.L': (-15, 0, 0)})
FK_ANTIC = dict(lean=12, twist=-38, head=10, front=(-30, 48), back=(20, 40),
                arms={'UpperArm.R': (30, 0, 28), 'LowerArm.R': (-18, 0, 0), 'Hand.R': (-15, 0, 0),
                      'UpperArm.L': (-58, 0, -12), 'LowerArm.L': (-20, 0, 0)})
FK_CONTACT = dict(lean=-20, twist=36, head=-8, front=(-50, 64), back=(36, 24),
                  arms={'UpperArm.R': (-118, 0, -32), 'LowerArm.R': (-22, 0, 0), 'Hand.R': (12, 0, 0),
                        'UpperArm.L': (22, 0, -62), 'LowerArm.L': (-12, 0, 0)})
FK_FOLLOW = dict(lean=-22, twist=44, head=-8, front=(-50, 64), back=(36, 24),
                 arms={'UpperArm.R': (-158, 0, -42), 'LowerArm.R': (-14, 0, 0), 'Hand.R': (20, 0, 0),
                       'UpperArm.L': (30, 0, -72), 'LowerArm.L': (-8, 0, 0)})
if FKMODE:
    CARRY_FK = FKP(**FK_CARRY)
    KEYS['M1_1'] = [(0, CARRY_FK),
                    (3, FKP(**FK_ANTIC), 'out'),
                    (6, FKP(**FK_CONTACT), 'in'),
                    (8, FKP(**FK_FOLLOW), 'out'),
                    (11, FKP(**FK_FOLLOW)),
                    (18, CARRY_FK, 'out')]

def blend_arms(a, b, t):
    if a is None or b is None:
        return b if a is None else a
    out = {}
    for k in set(a) | set(b):
        va, vb = a.get(k, (0, 0, 0)), b.get(k, (0, 0, 0))
        out[k] = tuple(x + (y - x) * t for x, y in zip(va, vb))
    return out

def blend(a, b, t):
    def lerp(x, y):
        return x + (y - x) * t
    pair = lambda k: (lerp(a[k][0], b[k][0]), lerp(a[k][1], b[k][1]))
    blade = a['blade'].lerp(b['blade'], t)
    if blade.length < 1e-4:
        blade = b['blade']
    return {'lean': lerp(a['lean'], b['lean']), 'twist': lerp(a['twist'], b['twist']), 'head': lerp(a['head'], b['head']),
            'front': pair('front'), 'back': pair('back'), 'wrist': a['wrist'].lerp(b['wrist'], t), 'blade': blade.normalized(),
            'off': a['off'].lerp(b['off'], t), 'free': a['free'].lerp(b['free'], t), 'arms': blend_arms(a['arms'], b['arms'], t)}

def pose_at(name, f):
    keys = KEYS[name]
    for k0, k1 in zip(keys, keys[1:]):
        (lo, a), (hi, b) = k0[:2], k1[:2]
        if lo <= f <= hi:
            t = (f - lo) / (hi - lo)
            ease = k1[2] if len(k1) > 2 else None   # the ease on a key describes how the pose ARRIVES at it
            if ease == 'in':
                t = t * t * t              # accelerate into the key (the strike)
            elif ease == 'out':
                t = 1 - (1 - t) ** 3       # decelerate into the key (settle)
            elif ease == 'linear':
                pass
            elif hi - lo > 3:
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
        if not ONEHAND and (wl - shoulder_l).length > REACH:
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
    GRIPL = empty('SwordGripL')
    if not ONEHAND:
        GRIPL.parent = TARGET
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
    props['ARM_IK_FK.R'] = 0.0 if FKMODE else 1.0; props['ARM_IK_FK.L'] = 0.0 if FKMODE else 1.0
    if FKMODE:
        for bone, ang in (p['arms'] or {}).items():
            rot('FK_' + bone, *ang)
    h['eval_rig']()
    bottom = min(v.z for n in ('LeftFoot', 'RightFoot') for v in h['mesh_world'](n))
    pb['ROOT'].location[2] -= bottom
    h['eval_rig']()
    if not FKMODE:
        shoulder_r = rig.matrix_world @ pb['RightUpperArm'].head
        shoulder_l = rig.matrix_world @ pb['LeftUpperArm'].head
        wrist = p['wrist'] + Vector((0, 0, -bottom))
        if ONEHAND:
            wrist = shoulder_r + p['off']
        asked = wrist.copy()
        wrist = solve_grip(wrist, p['blade'], shoulder_r, shoulder_l)
        if ONEHAND:
            free_pos = shoulder_l + p['free']
            if (free_pos - shoulder_l).length > REACH:
                free_pos = shoulder_l + p['free'].normalized() * REACH
            GRIPL.matrix_world = hand_frame(free_pos, p['free'].normalized())
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
                over = max(0.0, (w - shoulder_r).length - REACH)
                if not ONEHAND:
                    over += max(0.0, (w - blade * SPACING - shoulder_l).length - REACH)
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
if ('--grip' in sys.argv or '--export' in sys.argv) and '--casts' not in sys.argv: grip_report()
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
