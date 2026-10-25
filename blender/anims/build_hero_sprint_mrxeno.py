"""HeroSprint authored on the ORIGINAL appended MrXen0 rig, never a proxy.
Live Blender modes: author (default), render, export. System Python: --compose.
Rest Action is preserved. Controls are FK; output samples evaluated deform matrices.
Canonical source is only read. Saves an isolated scene via libraries.write.
"""
from pathlib import Path
import hashlib
import json
import math
import sys

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
SOURCE=Path(r'C:\Users\Kobe\source\repos\R15 - Blener Model\MrXen0_R15RIG_v1.2.blend')
SCENE='BE_HeroSprint_MrXen0'
ACTION='BE_HeroSprintMrXen0_Run'
FILE=ROOT/'blender/anims/BE_HeroSprint_MrXen0.blend'
TMP=ROOT/'blender/.codex-tmp/hero-sprint-mrxeno'
REPORT=ROOT/'blender/review/BE_HeroSprint_MrXen0.validation.json'
EXPORT=ROOT/'blender/export/animations/BE_HeroSprintMrXen0_Run.rbxmx'
CHAIN={'LowerTorso':'HumanoidRootPart','UpperTorso':'LowerTorso','Head':'UpperTorso',
       'LeftUpperArm':'UpperTorso','LeftLowerArm':'LeftUpperArm','LeftHand':'LeftLowerArm',
       'RightUpperArm':'UpperTorso','RightLowerArm':'RightUpperArm','RightHand':'RightLowerArm',
       'LeftUpperLeg':'LowerTorso','LeftLowerLeg':'LeftUpperLeg','LeftFoot':'LeftLowerLeg',
       'RightUpperLeg':'LowerTorso','RightLowerLeg':'RightUpperLeg','RightFoot':'RightLowerLeg'}
SWITCHES=['ARM_IK_FK.L','ARM_IK_FK.R','LEG_IK_FK.L','LEG_IK_FK.R']


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def curves(action):
    for layer in action.layers:
        for strip in layer.strips:
            for bag in strip.channelbags:
                yield from bag.fcurves


def key_control(name,rot=(0,0,0),loc=None,frame=1):
    pb=rig.pose.bones[name];pb.rotation_mode='XYZ'
    pb.rotation_euler=tuple(math.radians(v) for v in rot)
    pb.keyframe_insert('rotation_euler',frame=frame,group=name)
    if loc is not None:
        pb.location=loc;pb.keyframe_insert('location',frame=frame,group=name)


def eval_rig():
    rig.update_tag();bpy.context.view_layer.update()
    return rig.evaluated_get(bpy.context.evaluated_depsgraph_get())


def matrices():
    evaluated=eval_rig()
    return {n:rig.matrix_world @ evaluated.pose.bones[n].matrix for n in ['HumanoidRootPart']+list(CHAIN)}


def mesh_world(name):
    obj=mesh_objects[name];evaluated=obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    return [evaluated.matrix_world @ v.co for v in evaluated.data.vertices]


def init():
    global scene,rig,action,baseline,mesh_objects,rest_game
    TMP.mkdir(parents=True,exist_ok=True);REPORT.parent.mkdir(parents=True,exist_ok=True)
    scene=bpy.data.scenes.get(SCENE)
    if not scene:
        scene=bpy.data.scenes.new(SCENE);scene['canonical_sha256']=sha(SOURCE)
        scene['previous_scene']=bpy.context.scene.name
        with bpy.data.libraries.load(str(SOURCE),link=False) as (src,dst):dst.collections=['R15_v1.2_MrXen0']
        scene.collection.children.link(dst.collections[0])
        scene['rig_name']=next(o.name for o in scene.objects if o.type=='ARMATURE')
    assert sha(SOURCE)==scene['canonical_sha256'],'Canonical rig changed'
    bpy.context.window.scene=scene;rig=bpy.data.objects[scene['rig_name']]
    mesh_objects={n:next(o for o in scene.objects if o.type=='MESH' and o.parent==rig and o.parent_bone==n) for n in CHAIN}
    if rig.animation_data.action.name!=ACTION:
        rest_action=rig.animation_data.action;scene['rest_action']=rest_action.name
        action=rest_action.copy();action.name=ACTION;rig.animation_data.action=action
    else:action=rig.animation_data.action
    assert len(action.slots)==1,'Explicit slot selection needed'
    rig.animation_data.action_slot=action.slots[0]
    scene.render.fps=30;scene.render.fps_base=1;scene.frame_start=1;scene.frame_end=17
    props=rig.pose.bones['PROPERTIES']
    for k in SWITCHES:props[k]=0;props.keyframe_insert(data_path='["'+k+'"]',frame=0)
    scene.frame_set(0);eval_rig()
    if 'fk_rest_matrices' not in scene:
        baseline=matrices();scene['fk_rest_matrices']=json.dumps({n:[list(r) for r in m] for n,m in baseline.items()})
        scene['fk_rest_mesh_corners']=json.dumps({n:[list(v) for v in mesh_world(n)] for n in ('LeftFoot','RightFoot')})
        scene['canonical_mesh_fingerprints']=json.dumps({n:hashlib.sha256(repr([tuple(v.co) for v in o.data.vertices]).encode()).hexdigest() for n,o in mesh_objects.items()})
    baseline={n:Matrix(m) for n,m in json.loads(scene['fk_rest_matrices']).items()}
    rest_game=json.loads((ROOT/'scripts/rigs/r15_rest.json').read_text())


def hermite(keys,p):
    if p<=keys[0][0]:return keys[0][1]
    if p>=keys[-1][0]:return keys[-1][1]
    for (a,av,ad),(b,bv,bd) in zip(keys,keys[1:]):
        if a<=p<=b:
            t=(p-a)/(b-a);span=b-a
            return (2*t**3-3*t*t+1)*av+(t**3-2*t*t+t)*span*ad+(-2*t**3+3*t*t)*bv+(t**3-t*t)*span*bd


def foot_path(p):
    # +Y forward on this canonical rig. Four-frame support, then short flight.
    y=1.04-.52*p if p<=4 else hermite([(4,-1.04,-.52),(6,-1.10,.08),(8,-.65,.28),(10,.10,.45),(12,.85,.20),(14,1.03,-.02),(16,1.04,-.52)],p)
    lift=0 if p<=4 else hermite([(4,0,0),(6,.33,.21),(8,.82,.15),(10,1.08,0),(12,.91,-.14),(14,.37,-.24),(16,0,0)],p)
    pitch=hermite([(0,0,0),(2,0,0),(4,-16,-8),(6,-38,-5),(8,-35,5),(10,-2,14),(12,12,0),(14,6,-4),(16,0,0)],p)
    return y,lift,pitch


def analytic_leg(side,p,bob):
    """Author explicit FK angles for a planar stride; no Blender IK constraints."""
    hip=baseline[side+'UpperLeg'].translation;knee=baseline[side+'LowerLeg'].translation;ankle=baseline[side+'Foot'].translation
    l1=(knee-hip).length;l2=(ankle-knee).length
    y,lift,pitch=foot_path(p)
    foot_vertices=[Vector(v) for v in json.loads(scene['fk_rest_mesh_corners'])[side+'Foot']]
    foot_rot=Matrix.Rotation(math.radians(pitch),3,'X')
    desired_ankle_z=lift-min((foot_rot @ (v-ankle)).z for v in foot_vertices)
    dy=y-hip.y;down=hip.z+bob-desired_ankle_z;distance=math.hypot(dy,down)
    assert abs(l1-l2)<distance<l1+l2, f'{side} phase {p}: stride exceeds rigid leg reach {distance:.4f}'
    alpha=math.atan2(dy,down)+math.acos((l1*l1+distance*distance-l2*l2)/(2*l1*distance))
    knee_y=l1*math.sin(alpha);knee_down=l1*math.cos(alpha)
    beta=math.atan2(dy-knee_y,down-knee_down)
    alpha0=math.atan2((knee-hip).y,-(knee-hip).z);beta0=math.atan2((ankle-knee).y,-(ankle-knee).z)
    upper=-math.degrees(alpha-alpha0)
    lower=-math.degrees((beta-alpha)-(beta0-alpha0))
    foot=-upper-lower-pitch
    return upper,lower,foot


def author():
    # Keep frame0 rest keys; replace only this action's authored frames.
    for fcurve in curves(action):
        for point in list(fcurve.keyframe_points):
            if point.co.x>=1:fcurve.keyframe_points.remove(point,fast=True)
    for marker in list(action.pose_markers):action.pose_markers.remove(marker)
    for name,frame in [('Footstep_Left',1),('Footstep_Right',9)]:marker=action.pose_markers.new(name);marker.frame=frame
    for frame in range(1,18):
        phase=(frame-1)%16;cycle=phase%8
        bob=hermite([(0,-.40,-.045),(2,-.47,0),(4,-.36,.04),(6,-.30,0),(8,-.40,-.045)],cycle)
        scene.frame_set(frame)
        key_control('ROOT',(0,0,0),(0,0,bob),frame)
        key_control('TORSO',(0,0,0),frame=frame)
        key_control('LowTorso',(0,0,0),frame=frame)
        key_control('UpTorso',(-24,5*math.cos(phase*math.tau/16),0),frame=frame)
        key_control('HEAD',(8,-2*math.cos(phase*math.tau/16),0),frame=frame)
        props=rig.pose.bones['PROPERTIES']
        for k in SWITCHES:props[k]=0;props.keyframe_insert(data_path='["'+k+'"]',frame=frame)
        for side,suffix,p in [('Left','L',phase),('Right','R',(phase+8)%16)]:
            upper,lower,foot=analytic_leg(side,p,bob)
            for name,angle in [('UpperLeg',upper),('LowerLeg',lower),('Foot',foot)]:key_control('FK_'+name+'.'+suffix,(angle,0,0),frame=frame)
            # Opposite arm pump, relaxed outward shoulder stance. Elbows remain bent.
            arm=20+42*math.cos(p*math.tau/16)
            elbow=-88-8*math.cos(p*math.tau/16)
            key_control('FK_UpperArm.'+suffix,(arm,0,-5 if side=='Left' else 5),frame=frame)
            key_control('FK_LowerArm.'+suffix,(elbow,0,0),frame=frame)
            key_control('FK_Hand.'+suffix,(0,0,0),frame=frame)
    for curve in curves(action):
        for point in curve.keyframe_points:point.interpolation='LINEAR'
    scene.frame_set(1);eval_rig();save()
    print('Authored canonical MrXen0 FK Run: 16-frame stride, 24-degree chest lean; preserved rest action.')


def save():
    assert sha(SOURCE)==scene['canonical_sha256'],'Canonical source file changed'
    FILE.parent.mkdir(parents=True,exist_ok=True)
    bpy.data.libraries.write(str(FILE),{scene},fake_user=True,compress=True)


def render():
    # Actual appended meshes rendered with a single neutral material for readable joints.
    for o in scene.objects:
        if o.type=='MESH' and o not in mesh_objects.values():o.hide_render=True
    try:scene.render.engine='BLENDER_WORKBENCH'
    except TypeError as e:raise RuntimeError(str(e))
    sh=scene.display.shading;sh.light='STUDIO';sh.color_type='SINGLE';sh.single_color=(.57,.62,.68)
    sh.studio_light=next(x.name for x in bpy.context.preferences.studio_lights if x.name=='paint.sl')
    sh.show_shadows=False;sh.show_cavity=True;sh.cavity_type='WORLD';scene.render.film_transparent=True
    scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
    points=[]
    for frame in range(1,17):
        scene.frame_set(frame);eval_rig()
        for name in mesh_objects:points.extend(mesh_world(name))
    lo=Vector(tuple(min(v[i] for v in points) for i in range(3)));hi=Vector(tuple(max(v[i] for v in points) for i in range(3)))
    center=(lo+hi)/2
    cam=bpy.data.objects.get('MRX_REVIEW_Camera')
    if not cam:
        data=bpy.data.cameras.new('MRX_REVIEW_Camera');cam=bpy.data.objects.new(data.name,data);scene.collection.objects.link(cam)
    cam.data.type='ORTHO';cam.data.clip_end=1000;scene.camera=cam
    scene.render.resolution_x=400;scene.render.resolution_y=430;scene.render.resolution_percentage=100
    for view,direction in [('side',Vector((-1,.03,.08))),('tq',Vector((-7,11,4)))]:
        cam.location=center+direction.normalized()*20;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler()
        inv=cam.rotation_euler.to_matrix().transposed()
        projected=[inv @ (v-center) for v in points]
        spanx=max(v.x for v in projected)-min(v.x for v in projected);spany=max(v.y for v in projected)-min(v.y for v in projected)
        cam.data.ortho_scale=max(spany,spanx*430/400)*1.16
        for frame in range(1,17):
            scene.frame_set(frame);scene.render.filepath=str(TMP/f'{view}_{frame:02}.png');bpy.ops.render.render(write_still=True)
    scene.frame_set(1);save();print('Rendered actual canonical mesh: side and three-quarter, all16 frames.')


def export():
    # Export derived from evaluated deform bones, independent of the FK author data.
    import xml.etree.ElementTree as ET
    P=Matrix(((1,0,0),(0,0,1),(0,-1,0)))
    source_root=baseline['HumanoidRootPart'].translation
    baseline_rot={n:m.to_3x3().normalized() for n,m in baseline.items()}
    samples=[];geometry_stats=[];mapping_position_error=0.;mapping_rotation_error=0.;joint_integrity_error=0.
    original_lengths={n:(baseline[n].translation-baseline[p].translation).length for n,p in CHAIN.items() if n!='LowerTorso'}
    for frame in range(1,18):
        scene.frame_set(frame);current=matrices()
        world={n:P @ (m.to_3x3().normalized() @ baseline_rot[n].inverted()) @ P.transposed() for n,m in current.items()}
        poses={};reconstructed={'HumanoidRootPart':Matrix.Identity(3)};positions={}
        # Scene ROOT moves all the bones including HRP. Roblox HRP is physics-owned,
        # so transfer the whole evaluated body displacement onto LowerTorso.
        root_translation=P @ (current['LowerTorso'].translation-baseline['LowerTorso'].translation)
        for n,parent in CHAIN.items():
            rot=world[parent].transposed() @ world[n]
            if n=='LowerTorso':rot=world[n]
            poses[n]=(rot,root_translation if n=='LowerTorso' else Vector((0,0,0)))
            reconstructed[n]=reconstructed[parent] @ rot
            mapping_rotation_error=max(mapping_rotation_error,max(abs(reconstructed[n][i][j]-world[n][i][j]) for i in range(3) for j in range(3)))
            info=rest_game['joints'][n];pivot=Vector(info['pivot'])
            if n=='LowerTorso':positions[n]=pivot+root_translation
            else:positions[n]=positions[parent]+reconstructed[parent] @ (pivot-Vector(rest_game['joints'][parent]['pivot']))
            expected=P @ (current[n].translation-source_root)
            mapping_position_error=max(mapping_position_error,(positions[n]-expected).length)
            if n in original_lengths:
                joint_integrity_error=max(joint_integrity_error,abs((current[n].translation-current[parent].translation).length-original_lengths[n]))
        feet={}
        for side in ('Left','Right'):
            name=side+'Foot';actual=min(v.z for v in mesh_world(name));info=rest_game['parts'][name]
            c=Vector(info['center']);pivot=Vector(rest_game['joints'][name]['pivot']);sz=info['size']
            corners=[c+Vector((a*sz[0]/2,b*sz[1]/2,d*sz[2]/2)) for a in (-1,1) for b in (-1,1) for d in (-1,1)]
            game_min=min((positions[name]+reconstructed[name]@(v-pivot)).y+rest_game['rootHeight'] for v in corners)
            feet[side]={'Blender_bottom':round(actual,6),'Roblox_predicted_bottom':round(game_min,6),'ankle_forward':round(current[name].translation.y,6)}
        samples.append(poses);geometry_stats.append({'frame':frame,'feet':feet,'root_vertical':root_translation.y})
    assert mapping_rotation_error<1e-5,'Evaluated rotation reconstruction differs'
    assert joint_integrity_error<.015,'Rig joint separation changed'
    assert mapping_position_error<.06,'R15 rest attachment mapping differs'
    loop_error=max(abs(samples[0][n][0][i][j]-samples[-1][n][0][i][j]) for n in CHAIN for i in range(3) for j in range(3))
    loop_error=max(loop_error,max((samples[0][n][1]-samples[-1][n][1]).length for n in CHAIN))
    assert loop_error<1e-6,'Run loop mismatch'
    for frame,side in [(1,'Left'),(9,'Right')]:
        assert abs(geometry_stats[frame-1]['feet'][side]['Blender_bottom'])<.035,'Blender contact not grounded'
        assert abs(geometry_stats[frame-1]['feet'][side]['Roblox_predicted_bottom'])<.055,'Retargeted contact not grounded'
    sequence=ET.Element('roblox',version='4');seq=ET.SubElement(sequence,'Item',{'class':'KeyframeSequence'});props=ET.SubElement(seq,'Properties')
    ET.SubElement(props,'string',name='Name').text='Run';ET.SubElement(props,'bool',name='Loop').text='true';ET.SubElement(props,'token',name='Priority').text='1'
    def pose_xml(parent,name,rot,loc):
        item=ET.SubElement(parent,'Item',{'class':'Pose'});properties=ET.SubElement(item,'Properties')
        ET.SubElement(properties,'string',name='Name').text=name
        cf=ET.SubElement(properties,'CoordinateFrame',name='CFrame')
        for tag,value in zip(('X','Y','Z'),loc):ET.SubElement(cf,tag).text=f'{value:.9f}'
        for i in range(3):
            for j in range(3):ET.SubElement(cf,f'R{i}{j}').text=f'{rot[i][j]:.9f}'
        for tag,name_,value in [('token','EasingDirection','0'),('token','EasingStyle','0'),('float','Weight','1')]:ET.SubElement(properties,tag,name=name_).text=value
        return item
    for index,poses in enumerate(samples):
        frame=ET.SubElement(seq,'Item',{'class':'Keyframe'});properties=ET.SubElement(frame,'Properties')
        ET.SubElement(properties,'string',name='Name').text='Keyframe';ET.SubElement(properties,'float',name='Time').text=f'{index/30:.9f}'
        if index in (0,8):
            marker=ET.SubElement(frame,'Item',{'class':'KeyframeMarker'});mp=ET.SubElement(marker,'Properties')
            ET.SubElement(mp,'string',name='Name').text='Footstep';ET.SubElement(mp,'string',name='Value').text='Left' if index==0 else 'Right'
        nodes={'HumanoidRootPart':pose_xml(frame,'HumanoidRootPart',Matrix.Identity(3),Vector((0,0,0)))}
        for n,parent in CHAIN.items():nodes[n]=pose_xml(nodes[parent],n,*poses[n])
    EXPORT.parent.mkdir(parents=True,exist_ok=True);ET.indent(sequence);ET.ElementTree(sequence).write(EXPORT,encoding='utf-8',xml_declaration=True)
    parsed=ET.parse(EXPORT).getroot();keys=parsed.findall('.//Item[@class="Keyframe"]');markers=parsed.findall('.//Item[@class="KeyframeMarker"]')
    assert len(keys)==17 and len(markers)==2 and all(len(k.findall('.//Item[@class="Pose"]'))==16 for k in keys)
    max_ortho=0.
    for cf in parsed.findall('.//CoordinateFrame'):
        vals={e.tag:float(e.text) for e in cf};assert all(math.isfinite(v) for v in vals.values())
        rot=Matrix(tuple(tuple(vals[f'R{i}{j}'] for j in range(3)) for i in range(3)));orth=rot.transposed()@rot
        max_ortho=max(max_ortho,max(abs(orth[i][j]-int(i==j)) for i in range(3) for j in range(3)))
    assert max_ortho<1e-5
    report={'pass':True,'canonical_source':str(SOURCE),'source_sha256':sha(SOURCE),'source_unchanged':sha(SOURCE)==scene['canonical_sha256'],
            'rig':rig.name,'action':ACTION,'source_rest_action_preserved':scene['rest_action'],
            'authored_using':'FK controls on original rig; FK switch properties keyed0',
            'export_method':'Evaluated deform world rotation deltas relative to captured FK rest; derive parent-relative rotations; ROOT motion transferred to LowerTorso',
            'axis_map':'Blender(x,y,z) -> Roblox(x,z,-y), measured from canonical rig',
            'scale':1,'rest_HRP_height_Blender':3,'actual_game_rootHeight':rest_game['rootHeight'],
            'duration':16/30,'frames':[1,17],'fps':30,'priority':'Movement','loop':True,
            'markers':[{'name':'Footstep','value':'Left','time':0},{'name':'Footstep','value':'Right','time':8/30}],
            'evaluated_rotation_reconstruction_max_error':mapping_rotation_error,'game_rest_FK_max_pivot_difference':mapping_position_error,
            'rig_joint_length_max_error':joint_integrity_error,'loop_max_error':loop_error,'export_orthonormal_error':max_ortho,
            'feet':geometry_stats,'export':str(EXPORT),'export_sha256':sha(EXPORT),
            'canonical_meshes_unchanged':all(hashlib.sha256(repr([tuple(v.co) for v in mesh_objects[n].data.vertices]).encode()).hexdigest()==v for n,v in json.loads(scene['canonical_mesh_fingerprints']).items()),
            'visual_status':'Actual canonical rig renders generated; contact sheet and decoded GIF review required before handoff.',
            'runtime_limit':'Actual Studio playback, avatar floor clearance and marker puff placement require game acceptance.'}
    assert report['source_unchanged'] and report['canonical_meshes_unchanged']
    REPORT.write_text(json.dumps(report,indent=2));scene.frame_set(1);save()
    print('Export validated: evaluated canonical deform matrices, 17 keys, two markers, original source/meshes unchanged.')


def compose():
    from PIL import Image,ImageDraw,ImageFont
    font=lambda n,b=False:ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if b else 'segoeui.ttf'),n)
    bg='#202832';combined=[]
    for frame in range(1,17):
        im=Image.new('RGB',(800,474),bg);d=ImageDraw.Draw(im)
        d.text((15,10),'HERO SPRINT / ORIGINAL MRXEN0 R15 RIG',font=font(20,True),fill='#EEF2F5')
        for view,x in [('side',0),('tq',400)]:
            part=Image.open(TMP/f'{view}_{frame:02}.png').convert('RGBA');im.paste(part,(x,44),part)
        combined.append(im)
    times=[(round((i+1)*100/30)-round(i*100/30))*10 for i in range(16)]
    gif=ROOT/'blender/review/BE_HeroSprint_MrXen0.gif'
    combined[0].save(gif,save_all=True,append_images=combined[1:],duration=times,loop=0,disposal=2)
    # Build review from DECODED GIF frames, not original render panels.
    decoded=Image.open(gif);sheet=Image.new('RGB',(1000,940),bg);d=ImageDraw.Draw(sheet)
    d.text((18,12),'HERO SPRINT / CANONICAL RIG / DECODED GIF CHECK',font=font(22,True),fill='#EEF2F5')
    for i,frame in enumerate([0,4,8,12]):
        decoded.seek(frame);tile=decoded.convert('RGB').resize((500,296),Image.Resampling.LANCZOS);sheet.paste(tile,((i%2)*500,50+(i//2)*326))
        d.text(((i%2)*500+15,348+(i//2)*326),f'FRAME {frame+1:02} / '+('LEFT CONTACT' if frame==0 else 'RIGHT CONTACT' if frame==8 else 'PUSH + RECOVERY'),font=font(14,True),fill='#EEF2F5')
    ref=Image.open(ROOT/'docs/reference/run-options-v1/01-hero-sprint.png').convert('RGB');ref.thumbnail((385,245),Image.Resampling.LANCZOS);sheet.paste(ref,(15,690))
    d.text((420,710),'REFERENCE CHECK',font=font(20,True),fill='#EEF2F5')
    for y,line in [(750,'24-degree forward chest lean'),(782,'Bent elbow pump / long alternating stride'),(814,'Ground contacts at frames 1 and 9'),(846,'Actual supplied mesh, bone names and controls'),(890,'Game playback and footstep puffs verified separately.')]:d.text((420,y),line,font=font(15),fill='#BAC8D5')
    sheet.save(ROOT/'blender/review/BE_HeroSprint_MrXen0.png')
    print('Saved GIF and decoded-frame reference comparison; inspect before handoff.')


if '--compose' in sys.argv:compose()
else:
    import bpy
    from mathutils import Vector,Matrix
    init()
    mode=globals().get('MRX_MODE','author')
    if mode=='author':author()
    elif mode=='render':render()
    elif mode=='export':export()
