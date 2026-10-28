"""Headless canonical MrXen0 power casts. Run Blender -b --factory-startup --python this.py -- --export; then system Python this.py --compose. Source and live Blender remain unchanged."""
from pathlib import Path
import json, math, hashlib, sys
ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
FILE=ROOT/'blender/anims/BE_PowerMovesV2.blend'
TMP=ROOT/'blender/.codex-tmp/power-moves-v2'
REVIEW=ROOT/'blender/review'
BASE=ROOT/'blender/anims/build_hero_sprint_mrxeno.py'
V5=ROOT/'blender/anims/BE_HeroSprint_MrXen0_V5.blend'
import re
MOVE_SOURCE=ROOT/'src/shared/Config/PowerMoves.luau'
MOVES={}
power=None;index=0
for line in MOVE_SOURCE.read_text().splitlines():
    match=re.match(r'\s*(\w+) = \{',line)
    if match:power=match[1];index=0
    match=re.match(r'\s*(shot|move)\("([^"]+)"(.*)',line)
    if match:
        index+=1
        delay=.18 if match[1]=='shot' else float(match[3].split(',')[6].strip())
        MOVES[power+'_'+str(index)]={'power':power,'index':index,'name':match[2],'delay':delay}
assert len(MOVES)==36,len(MOVES)
LENGTHS={n:round((m['delay']+.5)*30,6) for n,m in MOVES.items()}
MARKERS={n:[(m['delay']*30,'Release','')] for n,m in MOVES.items()}
FRAMES={n:sorted(set([float(i) for i in range(int(c)+1)]+[c,round(MOVES[n]['delay']*30,6)])) for n,c in LENGTHS.items()}
SELECTED=['Wind_1','Earth_3','Water_3','Sword_1','Sword_Sword_3','Shadow_2'] if '--preview' in sys.argv else list(LENGTHS)
CONTROLS=['ROOT','TORSO','LowTorso','UpTorso','HEAD']+['FK_'+part+'.'+side for side in ('L','R') for part in ('UpperArm','LowerArm','Hand','UpperLeg','LowerLeg','Foot')]

def setup():
    global h,scene,rig,rest,run,rest_action
    h={'__name__':'transition_helpers'}
    exec(compile(BASE.read_text().split("if '--compose' in sys.argv:")[0],str(BASE),'exec'),h)
    h.update(bpy=bpy,Vector=Vector,Matrix=Matrix,SCENE='BE_PowerMovesV2',ACTION='BE_PowerMovesV2_Rest',FILE=FILE,TMP=TMP)
    existing=bpy.data.scenes.get('BE_PowerMovesV2')
    if existing:
        r=bpy.data.objects[existing['rig_name']];a=bpy.data.actions['BE_PowerMovesV2_Rest']
        r.animation_data.action=a;r.animation_data.action_slot=a.slots[0]
    h['init']();scene=h['scene'];rig=h['rig'];rest_action=h['action']
    scene.frame_set(0);h['eval_rig']()
    if 'neutral_controls' not in scene:scene['neutral_controls']=json.dumps(capture(rig))
    rest=json.loads(scene['neutral_controls']);run=rest
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
    a=bpy.data.actions['BE_PowerMovesV2_'+name]
    rig.animation_data.action=a;rig.animation_data.action_slot=a.slots[0];h['action']=a
    scene.frame_start=1;scene.frame_end=math.ceil(LENGTHS[name])+1

def save():
    assert h['sha'](h['SOURCE'])==scene['canonical_sha256']
    # Include all three actions explicitly; only one is active at a time.
    data={scene}|{bpy.data.actions['BE_PowerMovesV2_'+n] for n in LENGTHS if bpy.data.actions.get('BE_PowerMovesV2_'+n)}|{rest_action}
    bpy.data.libraries.write(str(FILE),data,fake_user=True,compress=True)

def set_pose(p):
    for n,v in p.items():
        pb=rig.pose.bones[n];pb.rotation_mode='XYZ';pb.rotation_euler=v['rot'];pb.location=v['loc']
    h['eval_rig']()

def aim_arm(p,side,direction):
    # Aim the evaluated joint segments, not guessed local Euler axes. No scaling.
    set_pose(p);direction=Vector(direction).normalized()
    for control,a,b in [('FK_UpperArm.'+side,('Left' if side=='L' else 'Right')+'UpperArm',('Left' if side=='L' else 'Right')+'LowerArm'),('FK_LowerArm.'+side,('Left' if side=='L' else 'Right')+'LowerArm',('Left' if side=='L' else 'Right')+'Hand')]:
        e=h['eval_rig']();v=e.pose.bones[b].matrix.translation-e.pose.bones[a].matrix.translation
        delta=v.normalized().rotation_difference(direction).to_matrix()
        pb=rig.pose.bones[control];mat=pb.matrix.copy();loc=mat.translation.copy()
        mat=(delta@mat.to_3x3()).to_4x4();mat.translation=loc;pb.matrix=mat
        h['eval_rig']()
        p[control]['rot']=list(pb.rotation_euler)
        p[control]['loc']=[0,0,0]
    set_pose(p)
    return p

def authored_poses():
    def r(p,n,v):p[n]['rot']=[math.radians(x) for x in v]
    def stance(lean=0,twist=0,knee=30):
        p=pose(lean,(-knee/2,knee,-knee/2),(8,-70),twist)
        r(p,'LowTorso',(0,-twist*.25,0))
        for side in ('L','R'):
            r(p,'FK_UpperLeg.'+side,(-knee/2,twist*.25,0))
        return p
    ready=stance(-10,0,20)
    profiles={}
    # Aim actual shoulder/elbow segments for strong visible extension.
    wind=stance(14,-40,40);release=aim_arm(stance(-38,40,42),'R',(0,1,.08))
    profiles['push']=(wind,release)
    wind=stance(10,-48,44);r(wind,'FK_UpperArm.R',(30,0,25));r(wind,'FK_LowerArm.R',(-100,0,0))
    release=aim_arm(stance(-42,44,48),'R',(0,1,.14));profiles['throw']=(wind,release)
    wind=stance(12,-18,50);release=stance(-42,18,48)
    for side in ('L','R'):release=aim_arm(release,side,(0,1,.1))
    profiles['wave']=(wind,release)
    wind=stance(-35,-12,58);release=stance(14,12,18)
    release=aim_arm(release,'L',(-.6,.4,.7));release=aim_arm(release,'R',(.6,.4,.7))
    r(release,'FK_LowerArm.L',(-20,0,0));r(release,'FK_LowerArm.R',(-20,0,0))
    profiles['raise']=(wind,release)
    wind=stance(8,-52,40);r(wind,'FK_UpperArm.R',(-100,0,35));r(wind,'FK_LowerArm.R',(-55,0,0))
    release=aim_arm(stance(-35,52,46),'R',(-.45,.86,-.25));profiles['slash']=(wind,release)
    wind=stance(-42,-42,60);r(wind,'FK_UpperArm.R',(25,0,25));r(wind,'FK_LowerArm.R',(-20,0,0))
    release=aim_arm(stance(18,42,20),'R',(0,.55,.84));profiles['rising']=(wind,release)
    wind=stance(22,-18,30)
    for side in ('L','R'):wind=aim_arm(wind,side,(0,.3,.95))
    release=stance(-52,22,64)
    for side in ('L','R'):release=aim_arm(release,side,(0,.8,-.6))
    profiles['slam']=(wind,release)
    wind=stance(18,-28,24);r(wind,'FK_UpperLeg.R',(-38,0,0));r(wind,'FK_LowerLeg.R',(70,0,0));r(wind,'FK_Foot.R',(-32,0,0))
    release=stance(-42,22,70);r(release,'FK_UpperArm.L',(25,0,-35));r(release,'FK_UpperArm.R',(25,0,35))
    profiles['stomp']=(wind,release)
    wind=stance(-32,-34,55);release=aim_arm(stance(16,36,18),'R',(0,.35,.94));profiles['ritual']=(wind,release)
    wind=stance(12,-65,42);r(wind,'FK_UpperArm.R',(-110,0,20))
    release=aim_arm(stance(-30,65,40),'R',(-.9,.4,.15));profiles['spin']=(wind,release)
    assignment={'Wind':['push','wave','raise'],'Earth':['throw','raise','stomp'],
        'Water':['push','raise','wave'],'Fire':['throw','raise','raise'],'Sword':['slash','rising','spin'],
        'Shadow':['push','ritual','slam'],'Sword_Wind':['slash','slash','spin'],
        'Sword_Earth':['slash','slam','slam'],'Sword_Water':['slash','slash','spin'],
        'Sword_Fire':['slash','slash','wave'],'Sword_Shadow':['slash','slash','ritual'],
        'Sword_Sword':['slash','rising','slam']}
    keys={}
    for n,m in MOVES.items():
        profile=assignment[m['power']][m['index']-1];m['profile']=profile
        wind,release=[json.loads(json.dumps(p)) for p in profiles[profile]]
        # Small kit-specific variation; broad silhouette remains intentionally shared.
        tilt=(list(assignment).index(m['power'])%3-1)*4
        r(wind,'HEAD',(4,tilt,0));r(release,'HEAD',(-4,-tilt,0))
        d=m['delay']*30
        overshoot=json.loads(json.dumps(release))
        overshoot['UpTorso']['rot'][0]+=math.radians(-7 if profile not in ('rising','raise','ritual') else 5)
        overshoot['UpTorso']['rot'][1]+=math.radians(8)
        keys[n]=[(0,ready),(max(1,d-3),wind),(d,release),(d+2,release),(d+5,overshoot),(d+15,ready)]
    return keys

def frame(value):
    scene.frame_set(int(value),subframe=value-int(value))

def author():
    keys=authored_poses()
    for name in SELECTED:
        count=LENGTHS[name]
        existing=bpy.data.actions.get('BE_PowerMovesV2_'+name)
        assert existing is None or globals().get('ALLOW_REVISION',False),'Already authored; resume explicitly'
        a=existing or rest_action.copy();a.name='BE_PowerMovesV2_'+name;a.use_fake_user=True
        select(name)
        for marker in list(a.pose_markers):a.pose_markers.remove(marker)
        for fc in h['curves'](a):
            for index in range(len(fc.keyframe_points)-1,-1,-1):
                if fc.keyframe_points[index].co.x>=1:fc.keyframe_points.remove(fc.keyframe_points[index],fast=True)
        for i in FRAMES[name]:
            frame(i+1)
            for (lo,p0),(hi,p1) in zip(keys[name],keys[name][1:]):
                if lo<=i<=hi:
                    t=(i-lo)/(hi-lo)
                    # Fast attack segment, held strike, eased recovery.
                    if hi-lo>2:t=t*t*(3-2*t)
                    p=interpolate(p0,p1,t);break
            apply(p,i+1)
            bottom=min(v.z for n in ('LeftFoot','RightFoot') for v in h['mesh_world'](n))
            p['ROOT']['loc'][2]-=bottom
            apply(p,i+1)
        for fc in h['curves'](a):
            for pt in fc.keyframe_points:pt.interpolation='LINEAR'
        for markerframe,marker,value in MARKERS[name]:
            m=a.pose_markers.new(marker+'_'+value);m.frame=round(markerframe+1)
    select(SELECTED[0]);scene.frame_set(1);save()
    print('Authored',SELECTED)

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
    for name in SELECTED:
        count=LENGTHS[name]
        select(name);samples=[];stats=[]
        for i in FRAMES[name]:
            frame(i+1);p,s=sample();samples.append(p);stats.append(s)
        endpoint=run if name in ('Start','LandRun') else rest if name in ('Stop','LandIdle') else None
        endpoint_error=0
        if endpoint:
            now=capture(rig)
            endpoint_error=max(abs(x-y) for n in CONTROLS for k in ('rot','loc') for x,y in zip(now[n][k],endpoint[n][k]))
            assert endpoint_error<1e-6,(name,'endpoint differs',endpoint_error)
        assert max(s['mapping_error'] for s in stats)<.06,(name,'mapping')
        assert max(s['joint_length_error'] for s in stats)<.015,(name,'joint length')
        # Staggered/rotated feet may overlap in X projection without intersecting in 3D.
        assert min(s['feet'][side]['Blender'] for s in stats for side in ('Left','Right'))>-.002,(name,'source floor penetration')
        assert min(s['feet'][side]['Roblox'] for s in stats for side in ('Left','Right'))>-.055,(name,'game floor penetration')
        markers=[{'name':m,'value':v,'time':f/30} for f,m,v in MARKERS[name]]
        tree=ET.Element('roblox',version='4');seq=ET.SubElement(tree,'Item',{'class':'KeyframeSequence'});prop=ET.SubElement(seq,'Properties')
        for typ,n,val in [('string','Name',name),('bool','Loop','false'),('token','Priority','2')]:ET.SubElement(prop,typ,name=n).text=val
        def write_pose(parent,n,rot,loc):
            item=ET.SubElement(parent,'Item',{'class':'Pose'});pr=ET.SubElement(item,'Properties');ET.SubElement(pr,'string',name='Name').text=n
            cf=ET.SubElement(pr,'CoordinateFrame',name='CFrame')
            for tag,v in zip(('X','Y','Z'),loc):ET.SubElement(cf,tag).text=f'{v:.9f}'
            for i in range(3):
                for j in range(3):ET.SubElement(cf,f'R{i}{j}').text=f'{rot[i][j]:.9f}'
            for typ,n,v in [('token','EasingStyle','0'),('token','EasingDirection','0'),('float','Weight','1')]:ET.SubElement(pr,typ,name=n).text=v
            return item
        for sampleindex,poses in enumerate(samples):
            i=FRAMES[name][sampleindex]
            k=ET.SubElement(seq,'Item',{'class':'Keyframe'});pr=ET.SubElement(k,'Properties')
            ET.SubElement(pr,'string',name='Name').text='Keyframe';ET.SubElement(pr,'float',name='Time').text=f'{i/30:.9f}'
            for m in markers:
                if abs(m['time']-i/30)<1e-6:
                    mi=ET.SubElement(k,'Item',{'class':'KeyframeMarker'});mp=ET.SubElement(mi,'Properties')
                    ET.SubElement(mp,'string',name='Name').text=m['name'];ET.SubElement(mp,'string',name='Value').text=m['value']
            nodes={'HumanoidRootPart':write_pose(k,'HumanoidRootPart',Matrix.Identity(3),Vector((0,0,0)))}
            for n,parent in h['CHAIN'].items():nodes[n]=write_pose(nodes[parent],n,*poses[n])
        path=ROOT/f'blender/export/animations/BE_PowerMovesV2_{name}.rbxmx'
        ET.indent(tree);ET.ElementTree(tree).write(path,encoding='utf-8',xml_declaration=True)
        parsed=ET.parse(path);keys=parsed.findall('.//Item[@class="Keyframe"]');orth=0
        assert len(keys)==len(FRAMES[name]) and all(len(k.findall('.//Item[@class="Pose"]'))==16 for k in keys)
        for cf in parsed.findall('.//CoordinateFrame'):
            vals={e.tag:float(e.text) for e in cf};assert all(math.isfinite(v) for v in vals.values())
            rot=Matrix([[vals[f'R{i}{j}'] for j in range(3)] for i in range(3)]);o=rot.transposed()@rot
            orth=max(orth,max(abs(o[i][j]-int(i==j)) for i in range(3) for j in range(3)))
        assert orth<1e-5
        reports[name]={'duration':count/30,'loop':False,'priority':'Action','keys':len(FRAMES[name]),'markers':markers,'endpoint_control_error':endpoint_error,'export_orthonormal_error':orth,'samples':stats,'export':str(path),'sha256':h['sha'](path)}
        if True:
            import copy
            moving=copy.deepcopy(tree)
            moving.find('.//Item[@class="KeyframeSequence"]/Properties/string[@name="Name"]').text=name+'Moving'
            muted=[]
            for node in moving.findall('.//Item[@class="Pose"]'):
                part=node.find('Properties/string[@name="Name"]').text
                if part in ('HumanoidRootPart','LowerTorso') or 'Leg' in part or 'Foot' in part:
                    node.find('Properties/float[@name="Weight"]').text='0';muted.append(part)
            assert len(muted)==8*len(FRAMES[name])
            mp=ROOT/f'blender/export/animations/BE_PowerMovesV2_{name}Moving.rbxmx'
            ET.indent(moving);ET.ElementTree(moving).write(mp,encoding='utf-8',xml_declaration=True)
            reports[name]['moving_export']={'path':str(mp),'sha256':h['sha'](mp),'muted_per_frame':8,'kept':'UpperTorso, Head and both full arm chains; all other weights0'}

    report={'pass':True,'source_sha256':h['sha'](h['SOURCE']),'source_unchanged':h['sha'](h['SOURCE'])==scene['canonical_sha256'],'axis_map':'Blender(x,y,z) -> Roblox(x,z,-y)','scale':1,'clips':reports,'marker_policy':'Release equals PowerMoves.Delay, duration Delay+.5; horizontal root translation zero; vertical grounding only.','visual_status':'Pending actual render inspection','runtime_status':'Parent integrates and validates live game.'}
    (REVIEW/'BE_PowerMovesV2.validation.json').write_text(json.dumps(report,indent=2));select(SELECTED[0]);scene.frame_set(1);save()
    print('Exported all36 power clips and36 moving variants; canonical unchanged.')

def render():
    source=BASE.read_text().split('def render():',1)[1].split('def export():',1)[0]
    source='def render():'+source.replace('range(1,17)','REVIEW_FRAMES').replace('MRX_REVIEW_Camera','POWER_REVIEW_Camera').replace('400','320').replace('430','360').replace('scene.frame_set(frame)','set_frame(frame)')
    h['save']=lambda:None;h['set_frame']=frame
    for name in SELECTED:
        select(name);folder=TMP/name;folder.mkdir(parents=True,exist_ok=True);h['TMP']=folder
        d=MOVES[name]['delay']*30
        h['REVIEW_FRAMES']=[1,max(2,d-2),d+1,d+3,LENGTHS[name]+1]
        # filenames use float frame values; replace integer formatting with rounded stage IDs.
        text=source.replace('{frame:02}',"{int(round(frame*100)):04}")
        exec(compile(text,'power_render','exec'),h);h['render']()
    save()

def compose():
    from PIL import Image,ImageDraw,ImageFont
    font=ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf',17)
    for page in range(math.ceil(len(SELECTED)/12)):
        sheet=Image.new('RGB',(1280,min(12,len(SELECTED)-page*12)*240),'#202832');d=ImageDraw.Draw(sheet)
        for row,name in enumerate(SELECTED[page*12:(page+1)*12]):
            m=MOVES[name];release=m['delay']*30
            stages=[max(2,release-2),release+1,release+3,LENGTHS[name]+1]
            d.text((8,row*240),f"{name} {m['name']} | Release {m['delay']}s",font=font,fill='white')
            for col,f in enumerate(stages):
                p=Image.open(TMP/name/f'tq_{int(round(f*100)):04}.png').convert('RGBA').resize((192,216))
                q=Image.open(TMP/name/f'side_{int(round(f*100)):04}.png').convert('RGBA').resize((128,144))
                sheet.paste(p,(col*320,row*240+24),p);sheet.paste(q,(col*320+192,row*240+65),q)
        sheet.save(REVIEW/f'BE_PowerMovesV2_{page+1}.png')

if '--compose' in sys.argv:compose()
else:
    import bpy
    from mathutils import Matrix,Vector
    setup()
    author()
    if '--render' in sys.argv:render()
    if '--export' in sys.argv:export()
