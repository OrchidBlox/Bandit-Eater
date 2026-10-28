"""Dedicated Q casts for Wind, Earth, Water, Sword and Shadow on the canonical MrXen0 rig.
Run: Blender -b --factory-startup --python this.py -- --render --export
Same approach as build_fire_q.py (exec of the PowerMovesV2 helpers/exporter, separate BE_QCasts outputs).
Every clip keeps Release at 0.18 s (frame 5.4) and length 0.68 s; only the motion differs:
Wind two-hand shove, Earth overhead heave, Water scoop-and-push, Sword diagonal slash, Shadow backhand flick."""
from pathlib import Path
import sys
ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
V2 = ROOT / 'blender/anims/build_power_moves_v2.py'
source = V2.read_text().rsplit("\nif '--compose' in sys.argv:", 1)[0]
source = (source.replace("BE_PowerMovesV2.blend", "BE_QCasts.blend")
          .replace("power-moves-v2", "q-casts")
          .replace("BE_PowerMovesV2.validation.json", "BE_QCasts.validation.json")
          .replace("export/animations/BE_PowerMovesV2_", "export/animations/BE_QCasts_")
          .replace("BE_PowerMovesV2_{page+1}.png", "BE_QCasts_{page+1}.png"))

MINE = r'''
SELECTED = ['Wind_1', 'Earth_1', 'Water_1', 'Sword_1', 'Shadow_1', 'Sword_Wind_1', 'Sword_Earth_1', 'Sword_Water_1', 'Sword_Fire_1', 'Sword_Shadow_1', 'Sword_Sword_1',
            'Wind_2', 'Wind_3', 'Earth_2', 'Earth_3', 'Water_2', 'Water_3', 'Fire_2', 'Fire_3', 'Sword_2', 'Sword_3', 'Shadow_2', 'Shadow_3']
ALLOW_REVISION = True

def qcast_poses():
    def r(p, n, v): p[n]['rot'] = [math.radians(x) for x in v]
    def base(lean, twist):
        p = pose(lean, (0, 0, 0), (8, -70), twist)
        r(p, 'LowTorso', (0, -twist * .25, 0))
        return p
    def legs(p, front, back, side_front='L'):
        side_back = 'R' if side_front == 'L' else 'L'
        for side, (u, l) in ((side_front, front), (side_back, back)):
            r(p, 'FK_UpperLeg.' + side, (u, 0, 0))
            r(p, 'FK_LowerLeg.' + side, (l, 0, 0))
            r(p, 'FK_Foot.' + side, (-(u + l), 0, 0))
        return p
    def arms(p, right=None, left=None):
        if right: p = aim_arm(p, 'R', right)
        if left: p = aim_arm(p, 'L', left)
        return p
    ready = legs(base(-6, 0), (-12, 22), (8, 18))
    d = MOVES['Wind_1']['delay'] * 30
    out = {}

    # Wind: gather both hands low and back, then a wide two-handed shove with a hop-light narrow stance.
    wind = arms(legs(base(8, -20), (-4, 26), (10, 30)), (.55, -.6, -.45), (-.55, -.6, -.45))
    rel = arms(legs(base(-26, 12), (-34, 48), (20, 26)), (.18, 1, .12), (-.18, 1, .12))
    fol = arms(legs(base(-32, 14), (-36, 50), (22, 28)), (.5, .9, .35), (-.5, .9, .35))
    out['Wind_1'] = (wind, rel, fol)

    # Earth: both arms hoisted overhead with the chest arched back, then a heavy deep-knee heave forward-down.
    wind = arms(legs(base(26, -10), (-6, 36), (12, 40)), (.1, -.25, 1), (-.1, -.25, 1))
    rel = arms(legs(base(-48, 8), (-56, 74), (26, 34)), (.1, .85, -.4), (-.1, .85, -.4))
    fol = arms(legs(base(-54, 10), (-58, 76), (28, 36)), (.2, .5, -.8), (-.2, .5, -.8))
    out['Earth_1'] = (wind, rel, fol)

    # Water: low scoop with the throwing hand sweeping up and out, light flowing stance, off hand balancing wide.
    wind = arms(legs(base(6, -44), (-8, 30), (12, 34)), (.35, -.5, -.85), (-.8, .2, .25))
    rel = arms(legs(base(-24, 34), (-38, 54), (22, 28)), (.1, .92, .42), (-.85, -.3, .3))
    fol = arms(legs(base(-28, 42), (-40, 56), (24, 30)), (.2, .6, .78), (-.9, -.2, .3))
    out['Water_1'] = (wind, rel, fol)

    # Sword: blade arm raised high behind the head, then a diagonal downward-forward slash that finishes low across.
    wind = arms(legs(base(14, -52), (-6, 32), (14, 40)), (.18, -.45, .88), (-.7, .5, .2))
    rel = arms(legs(base(-34, 54), (-46, 60), (28, 30)), (-.45, .86, -.25), (-.75, -.5, .3))
    fol = arms(legs(base(-40, 66), (-48, 62), (30, 32)), (-.75, .35, -.55), (-.8, -.4, .3))
    out['Sword_1'] = (wind, rel, fol)

    # Shadow: arm drawn across the chest, then a sweeping backhand flick outward with a quick spin of the chest.
    wind = arms(legs(base(4, 48), (-6, 28), (12, 32)), (-.95, .25, .22), (.6, .5, .1))
    rel = arms(legs(base(-22, -46), (-36, 52), (22, 26)), (.95, .55, .1), (-.5, -.45, .4))
    fol = arms(legs(base(-26, -58), (-38, 54), (24, 28)), (1, .15, .2), (-.5, -.4, .4))
    out['Shadow_1'] = (wind, rel, fol)

    # Sword fusions: all sword casts, each with its own swing path.
    # Wind: coil right, then a flat horizontal sweep across the body.
    wind = arms(legs(base(8, -60), (-6, 30), (12, 34)), (.95, -.3, .1), (-.6, .4, .2))
    rel = arms(legs(base(-20, 55), (-38, 52), (22, 28)), (-.7, .7, .05), (-.8, -.3, .3))
    fol = arms(legs(base(-24, 70), (-40, 54), (24, 30)), (-.95, .2, .1), (-.8, -.3, .3))
    out['Sword_Wind_1'] = (wind, rel, fol)
    # Earth: heavy overhead chop with a deep stance.
    wind = arms(legs(base(24, -12), (-6, 36), (12, 40)), (.1, -.3, .95), (-.1, -.3, .9))
    rel = arms(legs(base(-46, 10), (-54, 72), (26, 34)), (.05, .8, -.55), (-.05, .8, -.5))
    fol = arms(legs(base(-52, 12), (-58, 76), (28, 36)), (.05, .4, -.9), (-.05, .4, -.85))
    out['Sword_Earth_1'] = (wind, rel, fol)
    # Water: low flowing arc sweeping upward.
    wind = arms(legs(base(6, -40), (-8, 30), (12, 34)), (.4, -.5, -.75), (-.8, .2, .25))
    rel = arms(legs(base(-24, 38), (-38, 54), (22, 28)), (.1, .8, .6), (-.85, -.3, .3))
    fol = arms(legs(base(-28, 46), (-40, 56), (24, 30)), (-.2, .4, .9), (-.9, -.2, .3))
    out['Sword_Water_1'] = (wind, rel, fol)
    # Fire: pulled-back thrust into a deep lunge, flicking upward.
    wind = arms(legs(base(12, -30), (-6, 30), (14, 40)), (.3, -.8, -.1), (-.7, .4, .2))
    rel = arms(legs(base(-34, 30), (-52, 66), (26, 30)), (.05, 1, .2), (-.8, -.4, .3))
    fol = arms(legs(base(-38, 36), (-54, 68), (28, 32)), (.1, .8, .5), (-.8, -.4, .3))
    out['Sword_Fire_1'] = (wind, rel, fol)
    # Shadow: reverse sweep from low behind up across the body.
    wind = arms(legs(base(8, 50), (-6, 28), (12, 32)), (.8, -.5, -.4), (.6, .5, .1))
    rel = arms(legs(base(-22, -44), (-36, 52), (22, 26)), (-.8, .5, .55), (.6, -.3, .3))
    fol = arms(legs(base(-26, -58), (-38, 54), (24, 28)), (-.9, .1, .5), (.6, -.3, .3))
    out['Sword_Shadow_1'] = (wind, rel, fol)
    # Master Sword: both hands overhead, then a big two-handed diagonal chop.
    wind = arms(legs(base(22, -20), (-6, 34), (12, 38)), (.1, -.3, .95), (-.1, -.3, .95))
    rel = arms(legs(base(-44, 20), (-50, 68), (26, 32)), (-.3, .8, -.5), (-.5, .8, -.4))
    fol = arms(legs(base(-50, 26), (-54, 72), (28, 34)), (-.4, .5, -.8), (-.6, .5, -.7))
    out['Sword_Sword_1'] = (wind, rel, fol)


    # ---- E and R casts: each has its own body language ----
    # Wind E Vortex: low sweeping scoop with both hands circling inward, hip swivel.
    wind = arms(legs(base(10, -34), (-6, 30), (12, 34)), (.7, -.3, -.35), (-.7, -.3, -.35))
    rel = arms(legs(base(-22, 28), (-36, 52), (22, 28)), (.5, .7, -.45), (-.5, .7, -.45))
    fol = arms(legs(base(-26, 40), (-38, 54), (24, 30)), (.2, .5, -.8), (-.2, .5, -.8))
    out['Wind_2'] = (wind, rel, fol)
    # Wind R Cyclone: arms sweep out and up in a big circle, then both thrust skyward, rising onto the toes.
    wind = arms(legs(base(14, -10), (-6, 30), (10, 34)), (.95, -.1, -.2), (-.95, -.1, -.2))
    mid = arms(legs(base(4, 10), (-4, 20), (6, 22)), (.8, .1, .6), (-.8, .1, .6))
    rel = arms(legs(base(8, 0), (-2, 10), (2, 12)), (.12, .2, 1), (-.12, .2, 1))
    fol = arms(legs(base(6, 0), (-2, 10), (2, 12)), (.5, .3, .85), (-.5, .3, .85))
    out['Wind_3'] = (wind, rel, fol, mid)
    # Earth E Stone Field: arms pulled up like lifting, then both palms pressed down at the ground, knees bent.
    wind = arms(legs(base(12, 0), (-6, 30), (10, 34)), (.5, .2, .8), (-.5, .2, .8))
    rel = arms(legs(base(-34, 0), (-48, 66), (22, 30)), (.4, .8, -.6), (-.4, .8, -.6))
    fol = arms(legs(base(-38, 0), (-50, 68), (24, 32)), (.5, .6, -.75), (-.5, .6, -.75))
    out['Earth_2'] = (wind, rel, fol)
    # Earth R Quake: one foot raised high, fists up, then a thunderous stomp into a deep crouch with arms driven down.
    wind = legs(arms(base(24, 0), (.3, -.2, .95), (-.3, -.2, .95)), (-70, 90), (6, 14))
    mid = legs(arms(base(30, 0), (.25, -.2, 1), (-.25, -.2, 1)), (-82, 100), (6, 14))
    rel = arms(legs(base(-52, 0), (-62, 80), (-8, 82)), (.5, .5, -.85), (-.5, .5, -.85))
    fol = arms(legs(base(-56, 0), (-64, 82), (-10, 84)), (.7, .3, -.7), (-.7, .3, -.7))
    out['Earth_3'] = (wind, rel, fol, mid)
    # Water E Whirlpool: arms trace a flowing circle out to the side and down, light stance, a graceful pivot.
    wind = arms(legs(base(6, -50), (-8, 30), (12, 34)), (.9, .1, .35), (-.9, .1, .35))
    rel = arms(legs(base(-18, 36), (-34, 48), (20, 26)), (.6, .6, -.5), (-.6, .6, -.5))
    fol = arms(legs(base(-22, 52), (-36, 50), (22, 28)), (.3, .7, -.6), (-.3, .7, -.6))
    out['Water_2'] = (wind, rel, fol)
    # Water R Tidal Wave: crouch gathering both hands low behind, then rise and heave both arms forward like pushing a wave.
    wind = arms(legs(base(18, 0), (-6, 38), (12, 42)), (.4, -.8, -.45), (-.4, -.8, -.45))
    mid = arms(legs(base(22, 0), (-8, 44), (14, 48)), (.45, -.85, -.35), (-.45, -.85, -.35))
    rel = arms(legs(base(-36, 0), (-48, 62), (22, 30)), (.25, 1, .15), (-.25, 1, .15))
    fol = arms(legs(base(-42, 0), (-52, 66), (24, 32)), (.5, .9, .4), (-.5, .9, .4))
    out['Water_3'] = (wind, rel, fol, mid)
    # Fire E Flame Field: hands pulled to the chest like cupping a spark, then both arms flung down and out in a burst.
    wind = arms(legs(base(8, 0), (-6, 30), (12, 34)), (.25, .5, .05), (-.25, .5, .05))
    rel = arms(legs(base(-26, 0), (-40, 56), (22, 28)), (.9, .5, -.35), (-.9, .5, -.35))
    fol = arms(legs(base(-30, 0), (-42, 58), (24, 30)), (1, .1, -.4), (-1, .1, -.4))
    out['Fire_2'] = (wind, rel, fol)
    # Fire R Eruption: crouch with fists low, rise slowly gathering, then punch both fists straight up and arch back.
    wind = arms(legs(base(26, 0), (-6, 48), (12, 52)), (.3, .2, -.8), (-.3, .2, -.8))
    mid = arms(legs(base(18, 0), (-6, 40), (12, 44)), (.4, .1, -.4), (-.4, .1, -.4))
    rel = arms(legs(base(14, 0), (-2, 14), (4, 18)), (.15, .1, 1), (-.15, .1, 1))
    fol = arms(legs(base(18, 0), (-2, 14), (4, 18)), (.5, -.1, .9), (-.5, -.1, .9))
    out['Fire_3'] = (wind, rel, fol, mid)
    # Sword E Rising Slash: low draw to the hip then a fast upward diagonal cut finishing overhead.
    wind = arms(legs(base(-14, -40), (-6, 30), (14, 38)), (.6, -.3, -.6), (-.6, .3, .1))
    rel = arms(legs(base(8, 44), (-40, 54), (24, 28)), (-.15, .7, .75), (.6, -.4, .2))
    fol = arms(legs(base(14, 56), (-42, 56), (26, 30)), (-.4, .1, 1), (.7, -.4, .2))
    out['Sword_2'] = (wind, rel, fol)
    # Sword R Blade Storm: blade raised high, then a full spin with arms wide on the way around.
    wind = arms(legs(base(6, -40), (-6, 30), (12, 34)), (.1, -.2, 1), (-.7, .2, .3))
    mid = arms(legs(base(6, -80), (-4, 26), (10, 30)), (.5, -.6, .55), (-.9, .1, .3))
    rel = arms(legs(base(-14, 70), (-34, 48), (20, 26)), (.95, .45, .1), (-.95, .45, .1))
    fol = arms(legs(base(-16, 100), (-34, 48), (20, 26)), (.9, .2, .2), (-.9, .2, .2))
    out['Sword_3'] = (wind, rel, fol, mid)
    # Shadow E Snare: arm sweeps across and flicks out like casting a ribbon at the ground, off hand trailing.
    wind = arms(legs(base(8, 50), (-6, 28), (12, 32)), (-.9, .3, .1), (.5, .5, .1))
    rel = arms(legs(base(-26, -40), (-38, 54), (22, 26)), (.5, .8, -.5), (-.4, -.4, .35))
    fol = arms(legs(base(-30, -52), (-40, 56), (24, 28)), (.7, .5, -.7), (-.4, -.4, .35))
    out['Shadow_2'] = (wind, rel, fol)
    # Shadow R Nightfall: both arms raised overhead slowly, fingers spread, then yanked down hard in a crouch.
    wind = arms(legs(base(12, 0), (-6, 30), (10, 34)), (.5, -.1, .85), (-.5, -.1, .85))
    mid = arms(legs(base(22, 0), (-6, 30), (10, 34)), (.25, -.3, 1), (-.25, -.3, 1))
    rel = arms(legs(base(-48, 0), (-56, 76), (22, 34)), (.4, .6, -.85), (-.4, .6, -.85))
    fol = arms(legs(base(-52, 0), (-58, 78), (24, 36)), (.6, .4, -.8), (-.6, .4, -.8))
    out['Shadow_3'] = (wind, rel, fol, mid)

    keys = {}
    for n, poses in out.items():
        w, rl, f = poses[:3]
        mid = poses[3] if len(poses) > 3 else None
        dd = MOVES[n]['delay'] * 30
        seq = [(0, ready), (2, w)]
        if mid is not None and dd > 8:
            seq.append((2 + (dd - 2) * .62, mid))
        seq += [(dd, rl), (dd + 2, rl), (dd + 5, f), (dd + 15, ready)]
        keys[n] = seq
    return keys

authored_poses = qcast_poses
import bpy
from mathutils import Matrix, Vector
setup()
author()
if '--render' in sys.argv: render()
if '--export' in sys.argv: export()
'''
exec(compile(source + MINE, str(V2), 'exec'), {'__name__': '__qcasts__'})
