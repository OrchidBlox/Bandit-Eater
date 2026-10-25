"""Original MrXen0 FK movement transitions. Live modes: author/render/export.
System Python --compose assembles actual rendered frames. No source file opened.
V5 phase zero is read from its saved action; its file and live rig stay unchanged.
"""
from pathlib import Path
import json, math, hashlib, sys
ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
FILE=ROOT/'blender/anims/BE_MovementTransitions.blend'
TMP=ROOT/'blender/.codex-tmp/movement-transitions'
REVIEW=ROOT/'blender/review'
BASE=ROOT/'blender/anims/build_hero_sprint_mrxeno.py'
V5=ROOT/'blender/anims/BE_HeroSprint_MrXen0_V5.blend'
LENGTHS={'Start':8,'Stop':8,'Takeoff':6,'LandRun':6,'LandIdle':8}
CONTROLS=['ROOT','TORSO','LowTorso','UpTorso','HEAD']+['FK_'+part+'.'+side for side in ('L','R') for part in ('UpperArm','LowerArm','Hand','UpperLeg','LowerLeg','Foot')]

def setup():
    global h,scene,rig,rest,run,rest_action
    h={'__name__':'transition_helpers'}
    exec(compile(BASE.read_text().split("if '--compose' in sys.argv:")[0],str(BASE),'exec'),h)
    h.update(bpy=bpy,Vector=Vector,Matrix=Matrix,SCENE='BE_MovementTransitions',ACTION='BE_MovementTransitions_Rest',FILE=FILE,TMP=TMP)
    existing=bpy.data.scenes.get('BE_MovementTransitions')
    if existing:
        r=bpy.data.objects[existing['rig_name']];a=bpy.data.actions['BE_MovementTransitions_Rest']
        r.animation_data.action=a;r.animation_data.action_slot=a.slots[0]
    h['init']();scene=h['scene'];rig=h['rig'];rest_action=h['action']
    # Read the actual approved action, never re-author its pose from a description.
    if 'v5_endpoint' not in scene:
        other=bpy.data.scenes.get('BE_HeroSprint_MrXen0_V5')
        if other is None:
            with bpy.data.libraries.load(str(V5),link=False) as (src,dst):dst.scenes=['BE_HeroSprint_MrXen0_V5']
            other=dst.scenes[0]
        old_frame=other.frame_current;other_rig=bpy.data.objects[other['rig_name']]
        bpy.context.window.scene=other;other.frame_set(1);bpy.context.view_layer.update()
        scene['v5_endpoint']=json.dumps(capture(other_rig))
        other.frame_set(old_frame);bpy.context.window.scene=scene
        scene['v5_file_sha256']=h['sha'](V5)
    scene.frame_set(0);h['eval_rig']()
    if 'neutral_controls' not in scene:scene['neutral_controls']=json.dumps(capture(rig))
    rest=json.loads(scene['neutral_controls']);run=json.loads(scene['v5_endpoint'])
    scene.render.fps=30

def capture(r):
    return {n:{'rot':list(r.pose.bones[n].rotation_euler),'loc':list(r.pose.bones[n].location)} for n in CONTROLS}

def pose(lean=0,legs=(0,0,0),arms=(-5,-8),twist=0):
    p=json.loads(json.dumps(rest))
    def rot(n,v):p[n]['rot']=[math.radians(x) for x in v]
    rot('UpTorso',(lean,twist,0));rot('HEAD',(-lean*.4,0,0))
    for s in ('L','R'):
        for n,a in zip(('UpperLeg','LowerLeg','Foot'),legs):rot('FK_'+n+'.'+s,(a,0,0))
        rot('FK_UpperArm.'+s,(arms[0],0,-8 if s=='L' else 8))
        rot('FK_LowerArm.'+s,(arms[1],0,0))
    return p

def apply(p,frame):
    for n,v in p.items():
        pb=rig.pose.bones[n];pb.rotation_mode='XYZ';pb.rotation_euler=v['rot'];pb.location=v['loc']
        pb.keyframe_insert('rotation_euler',frame=frame,group=n);pb.keyframe_insert('location',frame=frame,group=n)
    for prop in h['SWITCHES']:
        rig.pose.bones['PROPERTIES'][prop]=0
        rig.pose.bones['PROPERTIES'].keyframe_insert('["'+prop+'"]',frame=frame)
    h['eval_rig']()

def interpolate(a,b,t):
    return {n:{k:[x+(y-x)*t for x,y in zip(a[n][k],b[n][k])] for k in ('rot','loc')} for n in CONTROLS}

def select(name):
    a=bpy.data.actions['BE_MovementTransitions_'+name]
    rig.animation_data.action=a;rig.animation_data.action_slot=a.slots[0];h['action']=a
    scene.frame_start=1;scene.frame_end=LENGTHS[name]+1

def save():
    assert h['sha'](V5)==scene['v5_file_sha256']
    assert h['sha'](h['SOURCE'])==scene['canonical_sha256']
    # Include all five actions explicitly; only one is active at a time.
    data={scene}|{bpy.data.actions['BE_MovementTransitions_'+n] for n in LENGTHS}|{rest_action}
    bpy.data.libraries.write(str(FILE),data,fake_user=True,compress=True)

def author():
    compression=pose(-32,(-38,76,-38),(20,-75))
    impact=pose(-17,(-22,44,-22),(12,-60))
    brake=pose(8,(-30,60,-30),(-28,-45))
    push=pose(-36,(-21,42,-21),(22,-70),-6)
    extend=pose(-12,(-4,8,-4),(-65,-55))
    airborne=pose(-12,(-45,65,-12),(-85,-55))
    airborne['FK_UpperLeg.R']['rot'][0]=math.radians(24)
    airborne['FK_LowerLeg.R']['rot'][0]=math.radians(65)
    airborne['FK_Foot.R']['rot'][0]=math.radians(-65)
    keys={'Start':[(0,rest),(2,push),(4,push),(8,run)],
          'Stop':[(0,run),(2,brake),(3,brake),(8,rest)],
          'Takeoff':[(0,impact),(2,extend),(6,airborne)],
          'LandRun':[(0,impact),(1,compression),(2,compression),(6,run)],
          'LandIdle':[(0,impact),(1,compression),(3,compression),(8,rest)]}
    for name,count in LENGTHS.items():
        assert not bpy.data.actions.get('BE_MovementTransitions_'+name),'Action already exists; use explicit resume, not destructive rebuild'
        a=rest_action.copy();a.name='BE_MovementTransitions_'+name;a.use_fake_user=True
        select(name)
        for fc in h['curves'](a):
            for pt in list(fc.keyframe_points):
                if pt.co.x>=1:fc.keyframe_points.remove(pt,fast=True)
        for i in range(count+1):
            scene.frame_set(i+1)
            for (lo,p0),(hi,p1) in zip(keys[name],keys[name][1:]):
                if lo<=i<=hi:
                    t=(i-lo)/(hi-lo);t=t*t*(3-2*t)
                    p=interpolate(p0,p1,t);break
            exact=(name in ('Start','LandRun') and i==count) or (name=='Stop' and i==0) or (name in ('Stop','LandIdle') and i==count) or (name=='Start' and i==0)
            apply(p,i+1)
            if not exact:
                bottom=min(v.z for n in ('LeftFoot','RightFoot') for v in h['mesh_world'](n))
                # Takeoff never delays physics: this is only a rising silhouette.
                lift=.12*(i/count) if name=='Takeoff' else 0
                p['ROOT']['loc'][2]+=-bottom+lift
                apply(p,i+1)
        for fc in h['curves'](a):
            for pt in fc.keyframe_points:pt.interpolation='LINEAR'
        if name.startswith('Land'):
            m=a.pose_markers.new('Landing_Both');m.frame=1
    select('Start');scene.frame_set(1);save()
    print('Authored 5 nonloop FK transitions on separate canonical rig; V5 unchanged.')

def sample():
    P=Matrix(((1,0,0),(0,0,1),(0,-1,0)));base=h['baseline'];cur=h['matrices']();game=h['rest_game']
    world={n:P@(m.to_3x3().normalized()@base[n].to_3x3().normalized().inverted())@P.transposed() for n,m in cur.items()}
    root=P@(cur['LowerTorso'].translation-base['LowerTorso'].translation)
    poses={};rots={'HumanoidRootPart':Matrix.Identity(3)};pos={};error=0.;joint=0.
    for n,parent in h['CHAIN'].items():
        rot=world[n] if n=='LowerTorso' else world[parent].transposed()@world[n]
        poses[n]=(rot,root if n=='LowerTorso' else Vector((0,0,0)));rots[n]=rots[parent]@rot
        pivot=Vector(game['joints'][n]['pivot'])
        pos[n]=pivot+root if n=='LowerTorso' else pos[parent]+rots[parent]@(pivot-Vector(game['joints'][parent]['pivot']))
        error=max(error,(pos[n]-P@(cur[n].translation-base['HumanoidRootPart'].translation)).length)
        if n!='LowerTorso':joint=max(joint,abs((cur[n].translation-cur[parent].translation).length-(base[n].translation-base[parent].translation).length))
    feet={}
    for side in ('Left','Right'):
        n=side+'Foot';info=game['parts'][n];c=Vector(info['center']);pivot=Vector(game['joints'][n]['pivot']);sz=info['size']
        verts=[c+Vector((x*sz[0]/2,y*sz[1]/2,z*sz[2]/2)) for x in (-1,1) for y in (-1,1) for z in (-1,1)]
        feet[side]={'Blender':min(v.z for v in h['mesh_world'](n)), 'Roblox':min((pos[n]+rots[n]@(v-pivot)).y+game['rootHeight'] for v in verts)}
    # Rig's actual feet have one stud width; keep their separated X extents.
    l=h['mesh_world']('LeftFoot');r=h['mesh_world']('RightFoot')
    gap=min(v.x for v in r)-max(v.x for v in l)
    return poses,{'feet':feet,'mapping_error':error,'joint_length_error':joint,'foot_lateral_gap':gap}

def export():
    import xml.etree.ElementTree as ET
    reports={}
    for name,count in LENGTHS.items():
        select(name);samples=[];stats=[]
        for i in range(count+1):
            scene.frame_set(i+1);p,s=sample();samples.append(p);stats.append(s)
        endpoint=run if name in ('Start','LandRun') else rest if name in ('Stop','LandIdle') else None
        endpoint_error=0
        if endpoint:
            now=capture(rig)
            endpoint_error=max(abs(x-y) for n in CONTROLS for k in ('rot','loc') for x,y in zip(now[n][k],endpoint[n][k]))
            assert endpoint_error<1e-6,(name,'endpoint differs',endpoint_error)
        assert max(s['mapping_error'] for s in stats)<.06,(name,'mapping')
        assert max(s['joint_length_error'] for s in stats)<.015,(name,'joint length')
        assert min(s['foot_lateral_gap'] for s in stats)>-.001,(name,'feet intersect laterally')
        assert min(s['feet'][side]['Blender'] for s in stats for side in ('Left','Right'))>-.002,(name,'source floor penetration')
        assert min(s['feet'][side]['Roblox'] for s in stats for side in ('Left','Right'))>-.055,(name,'game floor penetration')
        markers=[{'name':'Landing','value':'Both','time':0}] if name.startswith('Land') else []
        if markers:
            assert max(abs(stats[0]['feet'][side]['Blender']) for side in ('Left','Right'))<.002
        tree=ET.Element('roblox',version='4');seq=ET.SubElement(tree,'Item',{'class':'KeyframeSequence'});prop=ET.SubElement(seq,'Properties')
        for typ,n,val in [('string','Name',name),('bool','Loop','false'),('token','Priority','1')]:ET.SubElement(prop,typ,name=n).text=val
        def write_pose(parent,n,rot,loc):
            item=ET.SubElement(parent,'Item',{'class':'Pose'});pr=ET.SubElement(item,'Properties');ET.SubElement(pr,'string',name='Name').text=n
            cf=ET.SubElement(pr,'CoordinateFrame',name='CFrame')
            for tag,v in zip(('X','Y','Z'),loc):ET.SubElement(cf,tag).text=f'{v:.9f}'
            for i in range(3):
                for j in range(3):ET.SubElement(cf,f'R{i}{j}').text=f'{rot[i][j]:.9f}'
            for typ,n,v in [('token','EasingStyle','0'),('token','EasingDirection','0'),('float','Weight','1')]:ET.SubElement(pr,typ,name=n).text=v
            return item
        for i,poses in enumerate(samples):
            k=ET.SubElement(seq,'Item',{'class':'Keyframe'});pr=ET.SubElement(k,'Properties')
            ET.SubElement(pr,'string',name='Name').text='Keyframe';ET.SubElement(pr,'float',name='Time').text=f'{i/30:.9f}'
            if i==0:
                for m in markers:
                    mi=ET.SubElement(k,'Item',{'class':'KeyframeMarker'});mp=ET.SubElement(mi,'Properties')
                    ET.SubElement(mp,'string',name='Name').text=m['name'];ET.SubElement(mp,'string',name='Value').text=m['value']
            nodes={'HumanoidRootPart':write_pose(k,'HumanoidRootPart',Matrix.Identity(3),Vector((0,0,0)))}
            for n,parent in h['CHAIN'].items():nodes[n]=write_pose(nodes[parent],n,*poses[n])
        path=ROOT/f'blender/export/animations/BE_MovementTransitions_{name}.rbxmx'
        ET.indent(tree);ET.ElementTree(tree).write(path,encoding='utf-8',xml_declaration=True)
        parsed=ET.parse(path);keys=parsed.findall('.//Item[@class="Keyframe"]');orth=0
        assert len(keys)==count+1 and all(len(k.findall('.//Item[@class="Pose"]'))==16 for k in keys)
        for cf in parsed.findall('.//CoordinateFrame'):
            vals={e.tag:float(e.text) for e in cf};assert all(math.isfinite(v) for v in vals.values())
            rot=Matrix([[vals[f'R{i}{j}'] for j in range(3)] for i in range(3)]);o=rot.transposed()@rot
            orth=max(orth,max(abs(o[i][j]-int(i==j)) for i in range(3) for j in range(3)))
        assert orth<1e-5
        reports[name]={'duration':count/30,'loop':False,'priority':'Movement','keys':count+1,'markers':markers,'endpoint_control_error':endpoint_error,'export_orthonormal_error':orth,'samples':stats,'export':str(path),'sha256':h['sha'](path)}
    report={'pass':True,'source_sha256':h['sha'](h['SOURCE']),'V5_sha256':h['sha'](V5),'source_unchanged':h['sha'](h['SOURCE'])==scene['canonical_sha256'],'V5_unchanged':h['sha'](V5)==scene['v5_file_sha256'],'axis_map':'Blender(x,y,z) -> Roblox(x,z,-y)','scale':1,'clips':reports,'marker_policy':'Only LandRun/LandIdle Landing Both at time0. No duplicated footstep at V5 handoff; gameplay gates grounded eligibility. Takeoff has no anticipation delay or marker.','visual_status':'Pending actual render inspection','runtime_status':'Parent integrates and validates live game.'}
    (REVIEW/'BE_MovementTransitions.validation.json').write_text(json.dumps(report,indent=2));select('Start');scene.frame_set(1);save()
    print('Exported/validated all five Movement nonloops; original rig and V5 unchanged.')

def render():
    # Reuse the proven actual-mesh renderer with only clip length/output/camera changed.
    text=BASE.read_text().split('def render():',1)[1].split('def export():',1)[0]
    text='def render():'+text.replace('range(1,17)','range(1,scene.frame_end+1)').replace('MRX_REVIEW_Camera','TRANSITION_REVIEW_Camera').replace('400','320').replace('430','360')
    exec(compile(text,'transition_render','exec'),h)
    h['save']=lambda:None
    for name in LENGTHS:
        select(name);folder=TMP/name;folder.mkdir(parents=True,exist_ok=True);h['TMP']=folder
        h['render']()
    select('Start');scene.frame_set(1);save();print('Actual canonical rig rendered for all five clips.')

def compose():
    from PIL import Image,ImageDraw,ImageFont
    font=lambda n:ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf',n)
    sheets=[];all_frames=[];durations=[]
    for name,count in LENGTHS.items():
        frames=[]
        for i in range(count+1):
            im=Image.new('RGB',(640,405),'#202832');d=ImageDraw.Draw(im);d.text((15,10),f'{name}  |  {count/30:.3f}s  |  original MrXen0 rig',font=font(18),fill='white')
            for x,v in [(0,'side'),(320,'tq')]:
                p=Image.open(TMP/name/f'{v}_{i+1:02}.png').convert('RGBA');im.paste(p,(x,45),p)
            frames.append(im)
        gif=REVIEW/f'BE_MovementTransitions_{name}.gif'
        ds=[30 if i%3 else 40 for i in range(len(frames))];ds[-1]=500
        frames[0].save(gif,save_all=True,append_images=frames[1:],duration=ds,loop=0,disposal=2)
        decoded=Image.open(gif);row=Image.new('RGB',(1280,235),'#202832');draw=ImageDraw.Draw(row);draw.text((15,5),name,font=font(18),fill='white')
        # GIF merges identical held poses; select by playback time, not frame index.
        decoded_frames=[];elapsed=0
        for gi in range(decoded.n_frames):
            decoded.seek(gi);elapsed+=decoded.info.get('duration',30)
            decoded_frames.append((elapsed,decoded.convert('RGB').copy()))
        for col,i in enumerate([0,round(count/3),round(count*2/3),count]):
            timestamp=sum(ds[:i])
            p=next(im for end,im in decoded_frames if end>timestamp).resize((320,203));row.paste(p,(320*col,30))
        sheets.append(row);all_frames.extend(frames);durations.extend(ds)
    contact=Image.new('RGB',(1280,1535),'#202832')
    for i,row in enumerate(sheets):contact.paste(row,(0,i*235))
    ref=Image.open(ROOT/'docs/reference/movement-transitions-v1.png');ref.thumbnail((620,345));contact.paste(ref,(12,1185))
    d=ImageDraw.Draw(contact);d.text((660,1230),'Approved concept / actual rig motion',font=font(23),fill='white');d.text((660,1280),'Start + LandRun -> exact V5 phase0',font=font(21),fill='white');d.text((660,1320),'Stop + LandIdle -> neutral',font=font(21),fill='white');d.text((660,1360),'Landing contact -> held compression -> recovery',font=font(18),fill='white')
    contact.save(REVIEW/'BE_MovementTransitions.png')
    all_frames[0].save(REVIEW/'BE_MovementTransitions.gif',save_all=True,append_images=all_frames[1:],duration=durations,loop=0,disposal=2)
    print('Composite and five decoded GIF reviews saved.')

if '--compose' in sys.argv:compose()
else:
    import bpy
    from mathutils import Matrix,Vector
    setup()
    {'author':author,'render':render,'export':export}[globals().get('TRANSITION_MODE','author')]()
