"""Three authored low-poly oak templates; mesh stage only, no file opening.
Run in live Blender with BE_TREE_MODE='build' then 'render'.
Each whole tree is 194 triangles: flared trunk, three branches, six crown lobes.
Only TREE-owned objects are replaced on repeat; prior assets stay untouched.
"""
import bpy
import bmesh
import hashlib
import json
import math
from pathlib import Path
from mathutils import Vector

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater\blender')
TMP=ROOT/'.codex-tmp'/'trees-review'
REVIEW=ROOT/'review'
FILE=ROOT/'BE_Nature_Trees_mesh.blend'
PREFIX='BE_Nature_Tree'
SPECS={'RoundA':(22,27,20),'RoundB':(20,25,18),'RoundC':(24,29,22)}
COLORS=['6FAE4A','4C8A3A','7A5236','62412C']


def fingerprint(obj):
    data=(obj.type,[tuple(row) for row in obj.matrix_world])
    if obj.type=='MESH':
        data+=(tuple(tuple(v.co) for v in obj.data.vertices),
               tuple((tuple(p.vertices),p.material_index,p.use_smooth) for p in obj.data.polygons),
               tuple(m.name for m in obj.data.materials))
    return hashlib.sha256(repr(data).encode()).hexdigest()


def material(color):
    name='TREE_'+color
    mat=bpy.data.materials.get(name) or bpy.data.materials.new(name)
    rgb=[int(color[i:i+2],16)/255 for i in (0,2,4)]
    rgba=tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb)+(1,)
    mat.diffuse_color=rgba;mat.use_nodes=True
    node=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=rgba
    node.inputs['Roughness'].default_value=.85
    return mat


class Geometry:
    def __init__(self):self.verts=[];self.faces=[];self.mats=[]
    def add(self,verts,faces,mats):
        start=len(self.verts)
        self.verts.extend(verts)
        self.faces.extend(tuple(start+i for i in f) for f in faces)
        self.mats.extend(mats)

    def trunk(self,rings,angle=.22):
        verts=[];faces=[];mats=[]
        for center,r in rings:
            for i in range(5):
                a=angle+i*math.tau/5
                verts.append((center[0]+r*math.cos(a),center[1]+r*math.sin(a),center[2]))
        for k in range(len(rings)-1):
            for i in range(5):
                faces.append((k*5+i,k*5+(i+1)%5,(k+1)*5+(i+1)%5,(k+1)*5+i))
                mats.append(3 if i==1 else 2)
        faces.extend([tuple(reversed(range(5))),tuple((len(rings)-1)*5+i for i in range(5))]);mats.extend([3,2])
        self.add(verts,faces,mats)

    def branch(self,start,end,r1,r2,angle=.1):
        # Five-sided taper, rooted inside the main trunk, terminating inside leaves.
        axis=(Vector(end)-Vector(start)).normalized()
        helper=Vector((0,0,1)) if abs(axis.z)<.95 else Vector((0,1,0))
        u=axis.cross(helper).normalized();v=axis.cross(u).normalized()
        verts=[]
        for center,radius in [(Vector(start),r1),(Vector(end),r2)]:
            for i in range(5):
                a=angle+i*math.tau/5
                verts.append(tuple(center+(u*math.cos(a)+v*math.sin(a))*radius))
        faces=[(i,(i+1)%5,(i+1)%5+5,i+5) for i in range(5)]
        faces += [tuple(reversed(range(5))),tuple(range(5,10))]
        self.add(verts,faces,[3 if i==1 else 2 for i in range(5)]+[3,2])

    def crown(self,center,size,angle,seed):
        # Twelve authored vertices / twenty triangles. Overlapping angular lobes
        # create one connected-looking crown, rather than a ball on a stick.
        verts=[]
        profiles=[(.91,-.22),(.86,.24)]
        for ring,(radius,z) in enumerate(profiles):
            for i in range(5):
                a=angle+i*math.tau/5+(math.pi/5 if ring else 0)
                irregular=1+.10*math.sin(i*2.3+seed)
                verts.append((center[0]+math.cos(a)*size[0]*.5*radius*irregular,
                              center[1]+math.sin(a)*size[1]*.5*radius*irregular,
                              center[2]+size[2]*(z+.055*math.sin(i*2+seed))))
        verts.extend([(center[0]-.1*size[0],center[1]+.08*size[1],center[2]-size[2]*.5),
                      (center[0]+.12*size[0],center[1]-.06*size[1],center[2]+size[2]*.5)])
        faces=[(i,(i+1)%5,(i+1)%5+5,i+5) for i in range(5)]
        faces += [(10,(i+1)%5,i) for i in range(5)]
        faces += [(11,i+5,(i+1)%5+5) for i in range(5)]
        self.add(verts,faces,[1 if i in (1,2) else 0 for i in range(5)]+[1]*5+[0]*5)


def build_tree(variant,collection):
    geo=Geometry()
    if variant=='RoundA':
        rings=[((0,0,0),2.0),((.3,.1,6),1.25),((-.4,.3,12),.85)]
        branches=[((0,0,8),(-6,-.2,17),1.0,.48),((-.2,.2,10),(6,.4,18),.9,.42),((-.3,.3,11),(-.2,4.5,22),.8,.35)]
        lobes=[((-5,-.6,18),(12,12,8.5),.2),((5,-.1,18.5),(12,12,9),-.2),
               ((0,4,20.8),(13,12,9),.6),((-.7,-4,19.6),(11,11,9),.1),
               ((-4.1,1.3,23),(11,11,8),.7),((4.2,2.4,22.2),(11,11,8),-.4)]
    elif variant=='RoundB':
        rings=[((0,0,0),1.9),((1.4,.2,6),1.2),((2.7,.2,11),.8)]
        branches=[((1,.1,7.5),(-5,-.1,15),1.0,.45),((2,.2,9),(7,.6,19),1,.42),((2.5,.2,10),(1.2,4,20),.7,.32)]
        lobes=[((-5,-.3,16),(11,11,8),.2),((4.5,.2,19.5),(11,12,9),-.4),
               ((1,4.1,18.7),(11,10,8),.8),((-.5,-3.6,18),(12,11,9),.4),
               ((4.3,1.6,22.0),(10,10,7),.9),((-4.1,1.8,19.3),(9,10,7),-.2)]
    else:
        rings=[((0,0,0),2.05),((-.5,.2,7),1.25),((-1.5,.5,13),.8)]
        branches=[((-.6,.2,9),(-6,-.5,18.5),1,.45),((-1.2,.4,11),(6,1,20.5),1,.4),((-1.4,.5,12),(-3,4,24),.8,.32)]
        lobes=[((-5,-.3,19),(12,12,9),.2),((5.2,.7,20.3),(13,12,9),-.2),
               ((-.4,4.2,23),(13,13,10),.6),((-.3,-4,20.3),(13,11,10),.3),
               ((-4,1.8,25),(11,10,9),-.5),((3.6,2.5,24),(12,12,9),.8)]
    geo.trunk(rings)
    for params in branches:geo.branch(*params)
    for i,(center,size,angle) in enumerate(lobes):geo.crown(center,size,angle,i*.73)
    # Normalize each side about the trunk base, preserving its centered origin.
    width,height,depth=SPECS[variant]
    extremes=[(min(v[k] for v in geo.verts),max(v[k] for v in geo.verts)) for k in range(3)]
    verts=[]
    for v in geo.verts:
        x=v[0]*(width/2)/(extremes[0][1] if v[0]>=0 else -extremes[0][0])
        y=v[1]*(depth/2)/(extremes[1][1] if v[1]>=0 else -extremes[1][0])
        verts.append((x,y,v[2]*height/extremes[2][1]))
    name=PREFIX+variant
    mesh=bpy.data.meshes.new(name+'_Geometry');mesh.from_pydata(verts,[],geo.faces);mesh.update()
    for color in COLORS:mesh.materials.append(material(color))
    for p,i in zip(mesh.polygons,geo.mats):p.material_index=i;p.use_smooth=False
    bm=bmesh.new();bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm,faces=bm.faces)
    bmesh.ops.triangulate(bm,faces=bm.faces)
    bm.to_mesh(mesh);bm.free()
    obj=bpy.data.objects.new(name,mesh);collection.objects.link(obj)
    obj['stage']='mesh; awaiting owner approval'
    obj['structure']='6 overlapping closed crown lobes, 3 closed branch forks, 1 flared trunk'
    obj['unit']='1 Blender unit = 1 Roblox stud'
    return obj


def validate(protected=None):
    report={'stage':'mesh, owner approval pending','palette':['#'+c for c in COLORS],
            'geometry_note':'Each tree is one mesh with ten closed overlapping solids. Crown lobes overlap intentionally; branch caps remain enclosed.',
            'review_only':'TREE_REVIEW objects and 5-stud yellow gauge excluded','assets':[]}
    for name,size in SPECS.items():
        obj=bpy.data.objects[PREFIX+name];mesh=obj.data
        bm=bmesh.new();bm.from_mesh(mesh)
        lo=[min(v.co[k] for v in mesh.vertices) for k in range(3)]
        hi=[max(v.co[k] for v in mesh.vertices) for k in range(3)]
        dims=[round(hi[k]-lo[k],6) for k in (0,2,1)]
        item={'name':obj.name,'dimensions_W_H_D':dims,'target_W_H_D':list(size),
              'triangles':len(mesh.polygons),'budget':200,'bounds_min_xyz':lo,'bounds_max_xyz':hi,
              'location':list(obj.location),'rotation':list(obj.rotation_euler),'scale':list(obj.scale),
              'origin_at_base_center':abs(lo[2])<1e-6 and abs(hi[0]+lo[0])<1e-5 and abs(hi[1]+lo[1])<1e-5,
              'boundary_edges':sum(e.is_boundary for e in bm.edges),'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),
              'degenerate_faces':sum(f.calc_area()<1e-8 for f in bm.faces),'loose_vertices':sum(not v.link_edges for v in bm.verts),
              'inconsistent_winding_edges':sum(e.is_manifold and not e.is_contiguous for e in bm.edges),
              'flat_shaded':all(not p.use_smooth for p in mesh.polygons),
              'material_triangles':{COLORS[i]:sum(p.material_index==i for p in mesh.polygons) for i in range(4)},
              'textures':sum(n.type=='TEX_IMAGE' for m in mesh.materials for n in m.node_tree.nodes),
              'modifiers':len(obj.modifiers),'signed_volume':round(bm.calc_volume(signed=True),5)}
        item['pass']=(dims==list(size) and item['triangles']<=200 and item['origin_at_base_center'] and
                      all(item[k]==0 for k in ['boundary_edges','nonmanifold_edges','degenerate_faces','loose_vertices','inconsistent_winding_edges','textures','modifiers']) and
                      item['flat_shaded'] and item['signed_volume']>0 and tuple(obj.scale)==(1,1,1) and tuple(obj.rotation_euler)==(0,0,0))
        bm.free();report['assets'].append(item)
    if protected:
        report['preexisting_objects_unchanged']=all(name in bpy.data.objects and fingerprint(bpy.data.objects[name])==value for name,value in protected.items())
    report['pass']=all(x['pass'] for x in report['assets']) and report.get('preexisting_objects_unchanged',True)
    (REVIEW/'BE_Nature_Trees_mesh.validation.json').write_text(json.dumps(report,indent=2))
    print('Tree validation:',report['pass'],'|',', '.join(f"{x['name']} {x['triangles']}t" for x in report['assets']))
    assert report['pass'],'Tree validation failed; progress retained'


def build():
    TMP.mkdir(parents=True,exist_ok=True);REVIEW.mkdir(parents=True,exist_ok=True)
    backup=TMP/'pre-trees-backup.blend'
    if not backup.exists():bpy.ops.wm.save_as_mainfile(filepath=str(backup),copy=True)
    protected={o.name:fingerprint(o) for o in bpy.data.objects if not o.name.startswith(PREFIX) and not o.name.startswith('TREE_REVIEW')}
    scene=bpy.data.scenes.get('BE_Nature_Trees') or bpy.data.scenes.new('BE_Nature_Trees')
    bpy.context.window.scene=scene
    for obj in list(bpy.data.objects):
        if obj.name.startswith(PREFIX):bpy.data.objects.remove(obj,do_unlink=True)
    collection=bpy.data.collections.get('BE_TREE_ASSETS') or bpy.data.collections.new('BE_TREE_ASSETS')
    if collection.name not in scene.collection.children:scene.collection.children.link(collection)
    for name in SPECS:build_tree(name,collection)
    scene.unit_settings.scale_length=1
    bpy.ops.wm.save_as_mainfile(filepath=str(FILE))
    validate(protected)


def enum_set(owner,prop,value):
    assert value in [i.identifier for i in owner.bl_rna.properties[prop].enum_items],prop+' unsupported'
    setattr(owner,prop,value)


def review_scene(name,turn=0):
    scene=bpy.data.scenes.get(name)
    if scene:
        for obj in list(scene.objects):bpy.data.objects.remove(obj,do_unlink=True)
    else:scene=bpy.data.scenes.new(name)
    bpy.context.window.scene=scene
    try:scene.render.engine='BLENDER_WORKBENCH'
    except TypeError as error:raise RuntimeError(str(error))
    sh=scene.display.shading
    enum_set(sh,'light','STUDIO');enum_set(sh,'color_type','MATERIAL')
    sh.studio_light=next(x.name for x in bpy.context.preferences.studio_lights if x.name=='paint.sl')
    sh.show_shadows=False;sh.show_cavity=True;enum_set(sh,'cavity_type','WORLD')
    sh.curvature_ridge_factor=1.1;sh.curvature_valley_factor=.8
    scene.render.film_transparent=True
    enum_set(scene.render.image_settings,'file_format','PNG');enum_set(scene.render.image_settings,'color_mode','RGBA')
    for name,x in zip(SPECS,[-30,0,30]):
        source=bpy.data.objects[PREFIX+name]
        obj=bpy.data.objects.new('TREE_REVIEW_'+name,source.data);scene.collection.objects.link(obj)
        obj.location=(x,0,0);obj.rotation_euler.z=turn;obj['review_only']=True
    # Simple yellow gauge is exactly 5 studs tall and excluded from asset checks.
    mesh=bpy.data.meshes.new('TREE_REVIEW_Gauge')
    verts=[];faces=[]
    for center,size in [((0,0,2.5),(.4,.4,5)),((0,0,.12),(2,.6,.24)),((0,0,4.88),(2,.6,.24))]:
        start=len(verts)
        for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]:
            verts.append(tuple(center[k]+(x,y,z)[k]*size[k]/2 for k in range(3)))
        faces.extend(tuple(start+i for i in f) for f in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)])
    mesh.from_pydata(verts,[],faces);mesh.update();mesh.materials.append(material('FFD43B'))
    obj=bpy.data.objects.new('TREE_REVIEW_5STUD_GAUGE',mesh);scene.collection.objects.link(obj);obj.location=(-15,-3,0);obj['review_only']=True
    return scene


def render_panel(scene,width,height,filename):
    data=bpy.data.cameras.new('TREE_REVIEW_Camera');cam=bpy.data.objects.new('TREE_REVIEW_Camera',data)
    scene.collection.objects.link(cam);enum_set(data,'type','ORTHO');data.ortho_scale=91;data.clip_end=1000
    target=Vector((0,0,13.5));cam.location=target+Vector((.06,-1,.23)).normalized()*200
    cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();scene.camera=cam
    scene.render.resolution_x=width;scene.render.resolution_y=height;scene.render.resolution_percentage=100
    scene.render.filepath=str(TMP/filename);bpy.ops.render.render(write_still=True)


def render():
    protected={o.name:fingerprint(o) for o in bpy.data.objects if not o.name.startswith('TREE_REVIEW')}
    render_panel(review_scene('TREE_REVIEW_Front'),1000,420,'front.png')
    render_panel(review_scene('TREE_REVIEW_Side',math.radians(80)),530,230,'side.png')
    bpy.context.window.scene=bpy.data.scenes['TREE_REVIEW_Front']
    bpy.ops.wm.save_as_mainfile(filepath=str(FILE))
    validate(protected)
    print('Tree review panels saved. No export/rig/placement.')


if globals().get('BE_TREE_MODE','build')=='render':render()
else:build()
