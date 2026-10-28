"""Sword M1 combo; canonical rig, shared V2 helpers and exporter."""
from pathlib import Path
import sys
ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
V2 = ROOT / 'blender/anims/build_power_moves_v2.py'
source = V2.read_text().rsplit("\nif '--compose' in sys.argv:", 1)[0]
source = (source.replace("BE_PowerMovesV2.blend", "BE_SwordM1_Sword.blend")
          .replace("blender/.codex-tmp/power-moves-v2", "blender/review/sword-m1-sword")
          .replace("BE_PowerMovesV2.validation.json", "BE_SwordM1_Sword.validation.json")
          .replace("export/animations/BE_PowerMovesV2_", "export/animations/BE_SwordM1_Sword_")
          .replace("BE_PowerMovesV2_{page+1}.png", "BE_SwordM1_Sword_{page+1}.png"))


MINE = r'''
SELECTED = ['M1_1', 'M1_2', 'M1_3']
ALLOW_REVISION = True
for i, (name, frames, strike_frame) in enumerate([('M1_1',18,6),('M1_2',18,6),('M1_3',20,7)],1):
    MOVES[name] = {'power':'Sword','index':i,'name':name,'delay':strike_frame/30}
    LENGTHS[name] = frames
    MARKERS[name] = [(strike_frame,'Strike','')]
    FRAMES[name] = sorted(set([float(f) for f in range(frames+1)]+[float(frames),float(strike_frame)]))

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

    ready = arms(legs(base(-5, 0), (-12, 22), (8, 18)), (.35,.8,-.35), (-.6,.25,-.5))
    w1 = arms(legs(base(6,-48), (-12,26),(10,22)), (.8,-.5,-.28),(-.65,.5,.2))
    s1 = arms(legs(base(-12,46), (-22,32),(12,20)), (-.72,.7,.02),(-.7,-.45,.2))
    f1 = arms(legs(base(-14,58), (-24,34),(14,20)), (-.94,.3,.02),(-.6,-.5,.15))
    e1 = arms(legs(base(-8,40), (-18,28),(10,20)), (-.8,.5,.06),(-.6,-.35,.1))
    w2 = arms(legs(base(-5,55), (-18,28),(10,20)), (-.94,.3,.04),(-.65,.1,.15))
    s2 = arms(legs(base(-14,-46), (-24,34),(14,20)), (.85,.53,.02),(-.6,-.65,.2))
    f2 = arms(legs(base(-16,-58), (-26,36),(16,22)), (.98,.2,.03),(-.5,-.7,.15))
    e2 = arms(legs(base(2,-26), (-16,28),(10,24)), (.7,.05,.7),(-.65,-.25,.2))
    w3 = arms(legs(base(22,-12), (-14,40),(12,42)), (.18,-.25,1),(-.75,.35,.2))
    s3 = arms(legs(base(-32,14), (-48,60),(22,28)), (.05,.72,-.7),(-.8,-.5,.15))
    f3 = arms(legs(base(-36,18), (-50,62),(24,30)), (.02,.55,-.85),(-.75,-.55,.1))
    keys = {}
    for name, start, wind, strike, follow, end in [
        ('M1_1',ready,w1,s1,f1,e1),
        ('M1_2',e1,w2,s2,f2,e2),
        ('M1_3',e2,w3,s3,f3,ready)]:
        d = MOVES[name]['delay'] * 30
        keys[name] = [(0,start),(2,wind),(d-2,wind),(d,strike),(d+2,strike),(d+5,follow),(LENGTHS[name],end)]
    return keys

authored_poses = qcast_poses
import bpy
from mathutils import Matrix, Vector
setup()
author()
if '--render' in sys.argv: render()
if '--export' in sys.argv: export()
'''
exec(compile(source + MINE, str(V2), 'exec'), {'__name__': '__sword_m1__'})
