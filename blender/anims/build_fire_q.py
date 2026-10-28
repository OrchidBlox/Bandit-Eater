"""Fire Q (Fireball) dedicated throw on the canonical MrXen0 rig.
Run: Blender -b --factory-startup --python this.py -- --render --export
Reuses the PowerMovesV2 helpers/exporter by exec'ing its source with a separate output name, so the V2 .blend,
rbxmx and validation report are untouched. Release marker stays at 0.18 s (frame 5.4); total length 0.68 s.
Poses: coiled weight-back anticipation, planted stride with a straight throwing arm, follow-through, recovery."""
from pathlib import Path
import sys
ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
V2 = ROOT / 'blender/anims/build_power_moves_v2.py'
source = V2.read_text().rsplit("\nif '--compose' in sys.argv:", 1)[0]
source = (source.replace("BE_PowerMovesV2.blend", "BE_FireQ.blend")
          .replace("power-moves-v2", "fire-q")
          .replace("BE_PowerMovesV2.validation.json", "BE_FireQ.validation.json")
          .replace("export/animations/BE_PowerMovesV2_", "export/animations/BE_FireQ_")
          .replace("BE_PowerMovesV2_{page+1}.png", "BE_FireQ_{page+1}.png"))

MINE = r'''
SELECTED = ['Fire_1']
ALLOW_REVISION = True

def fireq_poses():
    def r(p, n, v): p[n]['rot'] = [math.radians(x) for x in v]
    def base(lean, twist, hips=0):
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
    ready = legs(base(-6, 0), (-12, 22), (8, 18))
    # Anticipation: weight back on the rear leg, chest coiled away, throwing arm cocked behind the shoulder,
    # off hand pointing at the target for balance.
    wind = legs(base(16, -58), (-6, 30), (14, 40))
    r(wind, 'FK_UpperArm.R', (62, 0, 34)); r(wind, 'FK_LowerArm.R', (-105, 0, 0))
    wind = aim_arm(wind, 'L', (-.12, .9, .25))
    # Release: planted stride, hips and chest driven forward and open, throwing arm fully extended.
    release = legs(base(-30, 50), (-44, 58), (28, 30))
    release = aim_arm(release, 'R', (.02, 1, .16))
    release = aim_arm(release, 'L', (-.75, -.45, .35))
    # Hold two frames, then follow through: chest keeps rotating, arm flicks up and across.
    follow = legs(base(-38, 62), (-46, 58), (30, 32))
    follow = aim_arm(follow, 'R', (.28, .86, .42))
    follow = aim_arm(follow, 'L', (-.8, -.35, .3))
    d = MOVES['Fire_1']['delay'] * 30
    return {'Fire_1': [(0, ready), (2, wind), (d, release), (d + 2, release), (d + 5, follow), (d + 15, ready)]}

authored_poses = fireq_poses
import bpy
from mathutils import Matrix, Vector
setup()
author()
if '--render' in sys.argv: render()
if '--export' in sys.argv: export()
'''
exec(compile(source + MINE, str(V2), 'exec'), {'__name__': '__fireq__'})
