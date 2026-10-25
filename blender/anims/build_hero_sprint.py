"""Hero Sprint R15 animation; isolated live-Blender scene, no file opening.
BE_SPRINT_MODE='block' creates stepped extremes and review panels.
BE_SPRINT_MODE='finish' bakes the smooth 16-frame loop, validates/exports and GIF panels.
System Python: python blender/anims/build_hero_sprint.py --compose [--gif]
"""
import json
import math
import hashlib
import sys
from pathlib import Path

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
FILE=ROOT/'blender/anims/BE_HeroSprint.blend'
REPORT=ROOT/'blender/review/BE_HeroSprint_Run.validation.json'
TMP=ROOT/'blender/.codex-tmp/hero-sprint'
RIG_NAME='BE_HeroSprint_R15'
SCENE_NAME='BE_HeroSprint'
POSE_FRAMES=[1,5,9,13]


def fingerprint(obj):
    value=(obj.type,[tuple(r) for r in obj.matrix_world])
    if obj.type=='MESH':value+=(tuple(tuple(v.co) for v in obj.data.vertices),tuple(tuple(p.vertices) for p in obj.data.polygons))
    return hashlib.sha256(repr(value).encode()).hexdigest()


def mapped(p):return Vector((-p[0],p[2],p[1]+rest['rootHeight']))
def rotation(x=0,y=0,z=0):return Euler(tuple(math.radians(v) for v in (x,y,z)),'XYZ').to_matrix()


def material(name,color):
    m=bpy.data.materials.get('BE_SPRINT_'+name) or bpy.data.materials.new('BE_SPRINT_'+name)
    rgb=[int(color[i:i+2],16)/255 for i in (0,2,4)]
    rgba=tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb)+(1,)
    m.diffuse_color=rgba;m.use_nodes=True
    node=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=rgba;node.inputs['Roughness'].default_value=.7
    return m


def box(name,center,size,mat,bone=None):
    verts=[(x*size[0]/2,y*size[1]/2,z*size[2]/2) for x,y,z in
           [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
    faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
    mesh=bpy.data.meshes.new('BE_SPRINT_'+name);mesh.from_pydata(verts,[],faces);mesh.update();mesh.materials.append(mat)
    obj=bpy.data.objects.new('BE_SPRINT_'+name,mesh);scene.collection.objects.link(obj);obj.location=center
    if bone:
        bpy.context.view_layer.update();world=obj.matrix_world.copy()
        obj.parent=rig;obj.parent_type='BONE';obj.parent_bone=bone
        bpy.context.view_layer.update();obj.matrix_world=world
    obj['review_proxy_only']=True
    return obj


def origin(name):
    bone=rig.data.bones[name];parent=rig.pose.bones[name].parent
    return parent.matrix @ parent.bone.matrix_local.inverted() @ bone.head_local if parent else bone.head_local.copy()


def set_world(name,rot,at=None):
    pb=rig.pose.bones[name];m=rot.to_4x4();m.translation=origin(name) if at is None else at
    pb.matrix=m
    if name!='LowerTorso':pb.location=(0,0,0)
    pb.scale=(1,1,1);bpy.context.view_layer.update()


def limb(a,b,c,target,pole):
    start=origin(a);l1=(heads[b]-heads[a]).length;l2=(heads[c]-heads[b]).length
    vector=Vector(target)-start;raw=vector.length
    distance=min(max(raw,abs(l1-l2)+.0001),l1+l2-.0001)
    if raw>l1+l2+.001:reach_errors.append((scene.frame_current,a,raw-(l1+l2)))
    d=vector.normalized();bend=Vector(pole)-start;bend=(bend-d*bend.dot(d)).normalized()
    along=(l1*l1-l2*l2+distance*distance)/(2*distance)
    middle=start+d*along+bend*math.sqrt(max(0,l1*l1-along*along))
    endpoint=start+d*distance
    for name,direction in [(a,middle-start),(b,endpoint-middle)]:
        restdir=rig.data.bones[name].tail_local-rig.data.bones[name].head_local
        set_world(name,restdir.rotation_difference(direction).to_matrix() @ R[name])


def hermite(keys,p):
    if p<=keys[0][0]:return keys[0][1]
    if p>=keys[-1][0]:return keys[-1][1]
    for (a,av,ad),(b,bv,bd) in zip(keys,keys[1:]):
        if a<=p<=b:
            t=(p-a)/(b-a);span=b-a
            return (2*t**3-3*t*t+1)*av+(t**3-2*t*t+t)*span*ad+(-2*t**3+3*t*t)*bv+(t**3-t*t)*span*bd


def foot_motion(p):
    y=-1.04+.52*p if p<=4 else hermite([(4,1.04,.52),(6,1.10,-.08),(8,.7,-.25),(10,.05,-.4),(12,-.65,-.3),(14,-.90,-.15),(16,-1.04,.52)],p)
    height=0 if p<=4 else hermite([(4,0,0),(6,.22,.17),(8,.67,.17),(10,.90,0),(12,.65,-.16),(14,.25,-.18),(16,0,0)],p)
    pitch=hermite([(0,0,0),(2,0,0),(4,12,7),(6,35,6),(8,45,0),(10,20,-12),(12,-10,-5),(14,-12,0),(16,0,0)],p)
    return y,height,pitch


def pose(frame):
    scene.frame_set(frame)
    for pb in rig.pose.bones:pb.matrix_basis.identity()
    phase=(frame-1)%16;cycle=phase%8
    bob=hermite([(0,-.37,-.04),(2,-.44,0),(4,-.33,.045),(6,-.28,0),(8,-.37,-.04)],cycle)
    hip=-4*math.cos(phase*math.tau/16);chest=6*math.cos(phase*math.tau/16)
    set_world('LowerTorso',rotation(x=5,z=hip) @ R['LowerTorso'],heads['LowerTorso']+Vector((0,0,bob)))
    set_world('UpperTorso',rotation(x=14,z=chest) @ R['UpperTorso'])
    set_world('Head',rotation(x=5,z=chest*.25) @ R['Head'])
    for side,p in [('Left',phase),('Right',(phase+8)%16)]:
        y,clearance,pitch=foot_motion(p)
        foot=side+'Foot';rot=rotation(x=pitch)
        info=rest['parts'][foot];center=mapped(info['center']);sx,sy,sz=info['size'][0],info['size'][2],info['size'][1]
        corners=[center+Vector((x*sx/2,yc*sy/2,z*sz/2))-heads[foot]
                 for x in (-1,1) for yc in (-1,1) for z in (-1,1)]
        ankle_z=clearance-min((rot @ v).z for v in corners)
        target=(heads[foot].x,y,ankle_z)
        limb(side+'UpperLeg',side+'LowerLeg',foot,target,(heads[foot].x,-3,1.2))
        set_world(foot,rot @ R[foot])
        shoulder=14+36*math.cos(p*math.tau/16)
        flex=90+8*math.cos(p*math.tau/16)
        set_world(side+'UpperArm',rotation(z=chest) @ rotation(x=shoulder) @ R[side+'UpperArm'])
        set_world(side+'LowerArm',rotation(z=chest) @ rotation(x=shoulder-flex) @ R[side+'LowerArm'])
        set_world(side+'Hand',rotation(z=chest) @ rotation(x=shoulder-flex) @ R[side+'Hand'])


def curves(action):
    for layer in action.layers:
        for strip in layer.strips:
            for bag in strip.channelbags:
                for curve in bag.fcurves:yield curve


def key_frames(frames,interpolation):
    prior={}
    for frame in frames:
        pose(frame)
        for pb in rig.pose.bones:
            q=pb.rotation_quaternion.copy()
            if pb.name in prior and prior[pb.name].dot(q)<0:q.negate();pb.rotation_quaternion=q
            prior[pb.name]=q.copy()
            pb.keyframe_insert('rotation_quaternion',frame=frame,group=pb.name)
            if pb.name=='LowerTorso':pb.keyframe_insert('location',frame=frame,group=pb.name)
    action=rig.animation_data.action
    assert len(action.slots)==1,'Unexpected action slots while building'
    rig.animation_data.action_slot=action.slots[0]
    for curve in curves(action):
        for point in curve.keyframe_points:point.interpolation=interpolation
    scene.frame_set(1)


def save_source():
    FILE.parent.mkdir(parents=True,exist_ok=True)
    bpy.data.libraries.write(str(FILE),{scene},fake_user=True,compress=True)


def setup():
    global scene,rig,heads,R
    TMP.mkdir(parents=True,exist_ok=True);REPORT.parent.mkdir(parents=True,exist_ok=True)
    assert SCENE_NAME not in bpy.data.scenes,'Existing HeroSprint scene: resume finish, do not rebuild'
    assert 'Run' not in bpy.data.actions,'Action Run exists; preserve it and inspect first'
    scene=bpy.data.scenes.new(SCENE_NAME);bpy.context.window.scene=scene
    scene.render.fps=30;scene.render.fps_base=1;scene.frame_start=1;scene.frame_end=17
    heads={name:mapped(v['pivot']) for name,v in rest['joints'].items()}
    arm=bpy.data.armatures.new(RIG_NAME);rig=bpy.data.objects.new(RIG_NAME,arm);scene.collection.objects.link(rig)
    bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
    nexts={'LowerTorso':'UpperTorso','UpperTorso':'Head'}
    for side in ('Left','Right'):
        for a,b in [('UpperArm','LowerArm'),('LowerArm','Hand'),('UpperLeg','LowerLeg'),('LowerLeg','Foot')]:nexts[side+a]=side+b
    for name in heads:
        bone=arm.edit_bones.new(name);bone.head=heads[name]
        bone.tail=heads[nexts[name]] if name in nexts else heads[name]+Vector((0,-.35,0) if 'Foot' in name else (0,0,.4) if name=='Head' else (0,0,-.3))
    for name,info in rest['joints'].items():
        if info['parent'] in arm.edit_bones:arm.edit_bones[name].parent=arm.edit_bones[info['parent']]
        arm.edit_bones[name].use_connect=False
    bpy.ops.object.mode_set(mode='OBJECT');rig.show_in_front=True
    R={name:arm.bones[name].matrix_local.to_3x3() for name in heads}
    for pb in rig.pose.bones:pb.rotation_mode='QUATERNION'
    blue=material('Blue','3488D9');yellow=material('Yellow','FFD55F');navy=material('Navy','26394F');white=material('White','F1F2ED')
    for name,info in rest['parts'].items():
        mat=white if 'Foot' in name else navy if 'Leg' in name else yellow if name=='Head' or 'Hand' in name or 'LowerArm' in name else blue
        box(name,mapped(info['center']),(info['size'][0],info['size'][2],info['size'][1]),mat,name)
    floor=box('Ground',(0,0,-.045),(14,14,.08),material('Ground','CCD3D6'))
    floor['review_proxy_only']=True
    rig.animation_data_create();action=bpy.data.actions.new('Run');action.use_fake_user=True;rig.animation_data.action=action
    for name,frame in [('Footstep_Left',1),('Footstep_Right',9)]:m=action.pose_markers.new(name);m.frame=frame
    key_frames([1,5,9,13,17],'CONSTANT')
    assert not reach_errors,'IK targets exceed leg reach: '+str(reach_errors)
    save_source();render_contact()
    print('Stepped HeroSprint extremes saved: 15 bones, frames 1/5/9/13; ready for pose review.')


def enum_set(owner,prop,value):
    assert value in [i.identifier for i in owner.bl_rna.properties[prop].enum_items],prop+' unsupported'
    setattr(owner,prop,value)


def camera(view,width=240,height=300):
    try:scene.render.engine='BLENDER_WORKBENCH'
    except TypeError as err:raise RuntimeError(str(err))
    sh=scene.display.shading;enum_set(sh,'light','STUDIO');enum_set(sh,'color_type','MATERIAL')
    sh.studio_light=next(x.name for x in bpy.context.preferences.studio_lights if x.name=='paint.sl')
    sh.show_shadows=True;sh.show_cavity=True;enum_set(sh,'cavity_type','WORLD')
    enum_set(sh,'background_type','WORLD');sh.background_color=(.055,.065,.08)
    scene.world=bpy.data.worlds.get('BE_SPRINT_World') or bpy.data.worlds.new('BE_SPRINT_World');scene.world.color=(.055,.065,.08)
    obj=bpy.data.objects.get('BE_SPRINT_Camera')
    if not obj:
        data=bpy.data.cameras.new('BE_SPRINT_Camera');obj=bpy.data.objects.new(data.name,data);scene.collection.objects.link(obj)
    enum_set(obj.data,'type','ORTHO');obj.data.ortho_scale=6.1 if view=='side' else 6.8
    target=Vector((0,-.20,2.25))
    obj.location=Vector((9,-.35,3.0) if view=='side' else (8,-12,6.0))
    obj.rotation_euler=(target-obj.location).to_track_quat('-Z','Y').to_euler();scene.camera=obj
    scene.render.resolution_x=width;scene.render.resolution_y=height;scene.render.resolution_percentage=100
    enum_set(scene.render.image_settings,'file_format','PNG');enum_set(scene.render.image_settings,'color_mode','RGBA')


def render_contact():
    for view in ('side','threequarter'):
        camera(view)
        for frame in POSE_FRAMES:
            scene.frame_set(frame);scene.render.filepath=str(TMP/f'{view}_{frame:02}.png');bpy.ops.render.render(write_still=True)
    scene.frame_set(1);save_source()


def xml_validate(path):
    import xml.etree.ElementTree as ET
    import numpy as np
    root=ET.parse(path).getroot();seq=root.find("Item[@class='KeyframeSequence']")
    props=seq.find('Properties')
    assert props.find("bool[@name='Loop']").text=='true','Loop flag missing'
    assert props.find("token[@name='Priority']").text=='1','Not Movement priority'
    frames=seq.findall("Item[@class='Keyframe']");values=[];markers=[];max_error=0
    expected=set(rest['joints'])|{'HumanoidRootPart'}
    for frame in frames:
        time=float(frame.find("Properties/float[@name='Time']").text)
        poses=frame.findall(".//Item[@class='Pose']")
        names={p.find("Properties/string[@name='Name']").text for p in poses}
        assert names==expected and len(poses)==16,'Exported hierarchy missing/duplicating pose'
        for pose_item in poses:
            n=pose_item.find("Properties/string[@name='Name']").text
            child_names={c.find("Properties/string[@name='Name']").text for c in pose_item.findall("Item[@class='Pose']")}
            assert child_names==set(exporter.TREE.get(n,[])),'Pose hierarchy differs: '+n
        frame_data={}
        for p in poses:
            name=p.find("Properties/string[@name='Name']").text;cf=p.find("Properties/CoordinateFrame[@name='CFrame']")
            numbers={child.tag:float(child.text) for child in cf};assert all(math.isfinite(v) for v in numbers.values())
            matrix=np.array([[numbers[f'R{i}{j}'] for j in range(3)] for i in range(3)])
            error=max(float(np.max(np.abs(matrix.T@matrix-np.eye(3)))),abs(float(np.linalg.det(matrix))-1));max_error=max(max_error,error)
            assert error<3e-5,'Non-orthonormal exported matrix'
            if name=='LowerTorso':assert abs(numbers['X'])<1e-6 and abs(numbers['Z'])<1e-6,'Root horizontal travel'
            frame_data[name]=numbers
        values.append(frame_data)
        for m in frame.findall("Item[@class='KeyframeMarker']"):
            markers.append({'time':time,'name':m.find("Properties/string[@name='Name']").text,'value':m.find("Properties/string[@name='Value']").text})
    duration=float(frames[-1].find("Properties/float[@name='Time']").text)
    assert abs(duration-16/30)<1e-8,'Duration differs'
    assert values[0]==values[-1],'Loop first/last matrices differ'
    assert len(markers)==2 and markers[0]=={'time':0.0,'name':'Footstep','value':'Left'} and markers[1]['name']=='Footstep' and markers[1]['value']=='Right' and abs(markers[1]['time']-8/30)<1e-8,'Footstep markers differ'
    return {'pass':True,'keyframes':len(frames),'duration_seconds':duration,'priority':'Movement','loop':True,
            'poses_per_keyframe':16,'bones':15,'first_last_equal':True,'maximum_orthonormal_error':max_error,'markers':markers}


def finish():
    global exporter
    import importlib.util
    spec=importlib.util.spec_from_file_location('be_r15_exporter',ROOT/'scripts/export_r15_animations.py');exporter=importlib.util.module_from_spec(spec)
    prior_bytecode=sys.dont_write_bytecode;sys.dont_write_bytecode=True
    try:spec.loader.exec_module(exporter)
    finally:sys.dont_write_bytecode=prior_bytecode
    key_frames(range(1,18),'LINEAR');save_source()
    assert not reach_errors,'IK targets exceed leg reach: '+str(reach_errors)
    exporter.check_rest(rig,rest)
    action=rig.animation_data.action;slot=exporter.select_action_slot(rig,action)
    metrics=[];bounces=[];max_contact_error=0
    for frame in range(1,18):
        scene.frame_set(frame);bpy.context.view_layer.update()
        bounces.append(rig.pose.bones['LowerTorso'].matrix.translation.z-heads['LowerTorso'].z)
        row={'frame':frame}
        for side in ('Left','Right'):
            foot=bpy.data.objects['BE_SPRINT_'+side+'Foot']
            bottom=min((foot.matrix_world @ v.co).z for v in foot.data.vertices)
            p=((frame-1)+(0 if side=='Left' else 8))%16
            desired=foot_motion(p)[1]
            row[side.lower()+'_foot_clearance']=round(bottom,5)
            row[side.lower()+'_ankle_y']=round(rig.pose.bones[side+'Foot'].head.y,5)
            max_contact_error=max(max_contact_error,abs(bottom-desired))
        metrics.append(row)
    assert max_contact_error<.025,'Foot contact/recovery does not match target: '+str(max_contact_error)
    assert .10<=max(bounces)-min(bounces)<=.18,'Hip bounce outside brief'
    assert metrics[0]['left_ankle_y']<metrics[0]['right_ankle_y'] and metrics[8]['right_ankle_y']<metrics[8]['left_ankle_y'],'Contact legs do not alternate'
    path=exporter.write_action(rig,'Run','BE_HeroSprint',1,slot)
    validation=xml_validate(path)
    validation.update({'rig':RIG_NAME,'action':'Run','fps':30,'frame_range':[1,17],
                       'slot':slot,'source_rest_sha256':hashlib.sha256((ROOT/'scripts/rigs/r15_rest.json').read_bytes()).hexdigest(),
                       'root_horizontal_travel':0,'hip_bounce_peak_to_peak':max(bounces)-min(bounces),
                       'hip_vertical_offset_range':[min(bounces),max(bounces)],
                       'torso_forward_lean_degrees':14,'support_travel_studs_per_four_frames':2.08,
                       'authored_support_speed_studs_per_second':15.6,'expected_support_speed_at_1_25_playback':19.5,
                       'max_foot_clearance_error':max_contact_error,'foot_samples':metrics,
                       'export':str(path),'source':str(FILE),'proxy_not_exported':True,
                       'preexisting_objects_unchanged':all(n in bpy.data.objects and fingerprint(bpy.data.objects[n])==v for n,v in protected.items()),
                       'validation_limit':'Blender poses and RBXMX structure verified. Actual Roblox playback and puff timing require Studio acceptance.'})
    assert validation['preexisting_objects_unchanged'],'A prior asset changed'
    REPORT.write_text(json.dumps(validation,indent=2))
    render_contact()
    for frame in range(1,17):
        camera('threequarter',480,520);scene.frame_set(frame)
        scene.render.filepath=str(TMP/f'motion_{frame:02}.png');bpy.ops.render.render(write_still=True)
    scene.frame_set(1);save_source()
    print('HeroSprint exported/validated: 16-frame loop, 15 bones + HRP, two Footstep markers; motion panels ready.')


def compose():
    from PIL import Image,ImageDraw,ImageFont
    canvas=Image.new('RGB',(960,770),'#1D242C');draw=ImageDraw.Draw(canvas)
    def font(n,bold=False):return ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if bold else 'segoeui.ttf'),n)
    draw.text((20,12),'BANDIT EATER  /  HERO SPRINT',font=font(24,True),fill='#DFE6EE')
    draw.text((20,47),'R15 PROXY • frames 1–17 / 30 fps • no root travel • alternating contacts',font=font(14),fill='#A9B7C5')
    for row,view in enumerate(('side','threequarter')):
        for col,frame in enumerate(POSE_FRAMES):
            im=Image.open(TMP/f'{view}_{frame:02}.png').convert('RGB');canvas.paste(im,(col*240,80+row*340))
            label={1:'F01  LEFT CONTACT',5:'F05  LEFT PUSH / RIGHT LIFT',9:'F09  RIGHT CONTACT',13:'F13  RIGHT PUSH / LEFT LIFT'}[frame]
            draw.text((col*240+10,383+row*340),label,font=font(12,True),fill='#DFE6EE')
    draw.text((20,752),'Proxy only • user-facing feel and footstep puffs still require Studio playback.',font=font(12),fill='#A9B7C5')
    canvas.save(ROOT/'blender/review/BE_HeroSprint_Run.png')
    if '--gif' in sys.argv:
        frames=[]
        for frame in range(1,17):
            im=Image.open(TMP/f'motion_{frame:02}.png').convert('RGB')
            d=ImageDraw.Draw(im);d.rectangle((0,0,480,32),fill='#1D242C');d.text((12,7),'HERO SPRINT  /  30 FPS',font=font(16,True),fill='#DFE6EE')
            frames.append(im)
        durations=[(round((i+1)*100/30)-round(i*100/30))*10 for i in range(16)]
        frames[0].save(ROOT/'blender/review/BE_HeroSprint_Run.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2)
    print('Saved HeroSprint contact sheet'+(' and motion GIF' if '--gif' in sys.argv else ''))


if '--compose' in sys.argv:compose()
else:
    import bpy
    from mathutils import Vector,Euler
    rest=json.loads((ROOT/'scripts/rigs/r15_rest.json').read_text())
    reach_errors=[]
    protected={o.name:fingerprint(o) for o in bpy.data.objects if not o.name.startswith('BE_SPRINT_') and o.name!=RIG_NAME}
    if globals().get('BE_SPRINT_MODE','block')=='block':setup()
    else:
        scene=bpy.data.scenes[SCENE_NAME];bpy.context.window.scene=scene;rig=bpy.data.objects[RIG_NAME]
        heads={name:mapped(v['pivot']) for name,v in rest['joints'].items()};R={name:rig.data.bones[name].matrix_local.to_3x3() for name in heads}
        finish()
