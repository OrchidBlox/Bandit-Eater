"""Preview-only revision on a separately appended canonical rig. No upload/export."""
from pathlib import Path
import math
import bpy
from mathutils import Vector, Matrix

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
base=ROOT/'blender/anims/build_hero_sprint_mrxeno.py'
ns={'__name__':'preview_helpers'}
exec(compile(base.read_text().split("if '--compose' in sys.argv:")[0],str(base),'exec'),ns)
ns.update(bpy=bpy,Vector=Vector,Matrix=Matrix,
          SCENE='BE_HeroSprint_MrXen0_V4',ACTION='BE_HeroSprintMrXen0_V4',
          FILE=ROOT/'blender/anims/BE_HeroSprint_MrXen0_V4.blend',
          TMP=ROOT/'blender/.codex-tmp/hero-sprint-mrxeno-v4')
ns['init']()
scene,rig,action=ns['scene'],ns['rig'],ns['action']
key=ns['key_control']
for curve in ns['curves'](action):
    for point in list(curve.keyframe_points):
        if point.co.x>=1:curve.keyframe_points.remove(point,fast=True)
# Explicit silhouette-first FK: contact, down, passing, extended flight.
# Negative thigh X is forward; positive knee X folds the lower leg backward.
legs=[(-64,18,40),(-28,26,2),(16,44,-30),(58,32,-56),
      (66,28,-53),(28,94,-60),(-45,72,-21),(-72,22,42)]
for frame in range(1,18):
    phase=(frame-1)%16
    scene.frame_set(frame)
    key('ROOT',loc=(0,0,0),frame=frame)
    key('TORSO',frame=frame)
    key('LowTorso',frame=frame)
    key('UpTorso',(-25,7*math.cos(phase*math.tau/16),0),frame=frame)
    key('HEAD',(14,-2*math.cos(phase*math.tau/16),0),frame=frame)
    for prop in ns['SWITCHES']:
        rig.pose.bones['PROPERTIES'][prop]=0
        rig.pose.bones['PROPERTIES'].keyframe_insert('["'+prop+'"]',frame=frame)
    for side,suffix,offset in [('Left','L',0),('Right','R',8)]:
        p=(phase+offset)%16
        i=p//2;t=(p%2)/2
        angles=[a*(1-t)+b*t for a,b in zip(legs[i],legs[(i+1)%8])]
        for name,angle in zip(['UpperLeg','LowerLeg','Foot'],angles):
            key('FK_'+name+'.'+suffix,(angle,0,0),frame=frame)
        key('FK_UpperArm.'+suffix,(8+60*math.cos(p*math.tau/16),0,-8 if side=='Left' else 8),frame=frame)
        key('FK_LowerArm.'+suffix,(-72-12*math.cos(p*math.tau/16),0,0),frame=frame)
        key('FK_Hand.'+suffix,frame=frame)
    ns['eval_rig']()
    bottom=min(v.z for side in ('LeftFoot','RightFoot') for v in ns['mesh_world'](side))
    # Keep contacts grounded and allow a small airborne extension between steps.
    lift={0:0,1:0,2:0,3:0,4:.04,5:.10,6:.14,7:.08}[phase%8]
    key('ROOT',loc=(0,0,-bottom+lift),frame=frame)
for curve in ns['curves'](action):
    for point in curve.keyframe_points:point.interpolation='LINEAR'
# Retiming is part of the saved Action: 24 frames per cycle, not just a slower GIF.
for curve in ns['curves'](action):
    for point in curve.keyframe_points:
        if point.co.x>=1: point.co.x=1+(point.co.x-1)*1.5
scene.frame_end=25
scene.frame_set(1)
ns['save']()
# Reuse renderer with the 24-frame range and a dedicated camera.
render_source=base.read_text().split('def render():',1)[1].split('def export():',1)[0]
render_source='def render():'+render_source.replace('range(1,17)','range(1,25)').replace('MRX_REVIEW_Camera','MRX_V4_Camera')
exec(compile(render_source,'v4_render','exec'),ns)
ns['render']()
print('V4 preview saved/rendered separately. No game asset changed.')
