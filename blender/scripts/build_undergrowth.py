"""Undergrowth mesh stage: three 60-triangle closed-solid templates.
Live Blender only; never opens files or touches existing tree/cliff geometry.
Run BE_UNDERGROWTH_MODE='build', then 'render', then compose_undergrowth.py.
"""
import bpy
import bmesh
import hashlib
import json
import math
from mathutils import Vector
from pathlib import Path

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater\blender')
TMP=ROOT/'.codex-tmp'/'undergrowth-review'
REVIEW=ROOT/'review'
FILE=ROOT/'BE_Nature_Undergrowth_mesh.blend'
SPECS={'BushA':(4,2,3),'BushB':(5,2.4,4),'FlowerClump':(2,1.2,2)}
COLORS={'BushA':['6FAE4A','4C8A3A'],'BushB':['6FAE4A','4C8A3A'],'FlowerClump':['4C8A3A','F2E7CC']}


def fingerprint(obj):
    data=(obj.type,[tuple(row) for row in obj.matrix_world])
    if obj.type=='MESH':
        data+=(tuple(tuple(v.co) for v in obj.data.vertices),
               tuple((tuple(p.vertices),p.material_index,p.use_smooth) for p in obj.data.polygons),
               tuple(m.name for m in obj.data.materials))
    return hashlib.sha256(repr(data).encode()).hexdigest()


def material(color):
    mat=bpy.data.materials.get('UNDER_'+color) or bpy.data.materials.new('UNDER_'+color)
    rgb=[int(color[i:i+2],16)/255 for i in (0,2,4)]
    rgba=tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb)+(1,)
    mat.diffuse_color=rgba;mat.use_nodes=True
    node=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=rgba;node.inputs['Roughness'].default_value=.85
    return mat


class Geometry:
    def __init__(self):self.verts=[];self.faces=[];self.mats=[]
    def add(self,verts,faces,mats):
        offset=len(self.verts);self.verts.extend(verts)
        self.faces.extend(tuple(offset+i for i in f) for f in faces);self.mats.extend(mats)
    def lobe(self,center,size,angle,seed):
        verts=[]
        for ring,(r,z) in enumerate([(.91,-.22),(.86,.24)]):
            for i in range(5):
                a=angle+i*math.tau/5+(math.pi/5 if ring else 0)
                irregular=1+.10*math.sin(i*2.3+seed)
                verts.append((center[0]+math.cos(a)*size[0]*.5*r*irregular,
                              center[1]+math.sin(a)*size[1]*.5*r*irregular,
                              center[2]+size[2]*(z+.04*math.sin(i*2+seed))))
        verts.extend([(center[0]-.08*size[0],center[1]+.08*size[1],center[2]-size[2]*.5),
                      (center[0]+.1*size[0],center[1]-.06*size[1],center[2]+size[2]*.5)])
        faces=[(i,(i+1)%5,(i+1)%5+5,i+5) for i in range(5)]
        faces += [(10,(i+1)%5,i) for i in range(5)]+[(11,i+5,(i+1)%5+5) for i in range(5)]
        self.add(verts,faces,[1 if i in (1,2) else 0 for i in range(5)]+[1]*5+[0]*5)
    def bloom(self,center,radius,tilt):
        # Five petal tips alternating with shallow valleys, closed by upper and
        # lower centers: twenty triangles, no alpha or single-sided cards.
        verts=[]
        for i in range(10):
            a=i*math.tau/10+.1
            r=radius if i%2==0 else radius*.53
            x=math.cos(a)*r;y=math.sin(a)*r
            verts.append((center[0]+x,center[1]+y,center[2]+x*tilt[0]+y*tilt[1]))
        verts += [(center[0],center[1],center[2]+.075),(center[0],center[1],center[2]-.065)]
        faces=[(10,i,(i+1)%10) for i in range(10)]+[(11,(i+1)%10,i) for i in range(10)]
        self.add(verts,faces,[1]*20)
    def stem(self,base,tip):
        verts=[(base[0]+math.cos(i*math.tau/3)*.065,base[1]+math.sin(i*math.tau/3)*.065,base[2]) for i in range(3)]
        verts.append(tip)
        self.add(verts,[(0,2,1),(0,1,3),(1,2,3),(2,0,3)],[0]*4)


def make(name,collection):
    geo=Geometry()
    if name=='BushA':
        for args in [((-.8,-.1,.72),(2.45,2.2,1.45),.1,.2),
                     ((.45,.35,1.0),(2.7,2.3,1.9),.8,1.3),
                     ((.9,-.6,.62),(2.2,1.9,1.2),-.2,2.4)]:geo.lobe(*args)
    elif name=='BushB':
        for args in [((-1.05,-.35,.87),(3.1,2.4,1.7),.4,.8),
                     ((.2,.6,1.1),(3.2,3.0,2.1),-.1,1.8),
                     ((1.3,-.45,.72),(2.7,2.4,1.4),.9,3.2)]:geo.lobe(*args)
    else:
        # Three broad leaf tips separated by shallow valleys; closed rosette.
        verts=[(math.cos(i*math.tau/6+.13)*(1 if i%2==0 else .4),
                math.sin(i*math.tau/6+.13)*(1 if i%2==0 else .4),
                .23 if i%2==0 else .16) for i in range(6)]
        verts.extend([(0,0,0),(-.05,.05,.42)])
        faces=[(6,(i+1)%6,i) for i in range(6)]+[(7,i,(i+1)%6) for i in range(6)]
        geo.add(verts,faces,[0]*12)
        geo.stem((-.33,-.18,.3),(-.38,-.22,.91))
        geo.stem((.31,.23,.3),(.35,.2,1.13))
        geo.bloom((-.38,-.22,.93),.39,(.05,-.22))
        geo.bloom((.35,.2,1.13),.43,(-.10,-.16))
    lo=[min(v[k] for v in geo.verts) for k in range(3)]
    hi=[max(v[k] for v in geo.verts) for k in range(3)]
    width,height,depth=SPECS[name]
    size=(width,depth,height)
    verts=[tuple((v[k]-(lo[k] if k==2 else (lo[k]+hi[k])/2))*size[k]/(hi[k]-lo[k]) for k in range(3)) for v in geo.verts]
    mesh=bpy.data.meshes.new('BE_Nature_'+name+'_Geometry');mesh.from_pydata(verts,[],geo.faces);mesh.update()
    for color in COLORS[name]:mesh.materials.append(material(color))
    for p,m in zip(mesh.polygons,geo.mats):p.material_index=m;p.use_smooth=False
    bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bmesh.ops.triangulate(bm,faces=bm.faces)
    bm.to_mesh(mesh);bm.free()
    obj=bpy.data.objects.new('BE_Nature_'+name,mesh);collection.objects.link(obj)
    obj['stage']='mesh; owner approval pending';obj['unit']='1 Blender unit = 1 Roblox stud'


def validate(protected):
    report={'stage':'mesh; owner approval pending','assets':[],
            'geometry_note':'Bushes contain three overlapping closed foliage solids; flower clump has one closed rosette, two closed stems and two closed cream blooms.',
            'review_only':'UNDER_REVIEW objects and yellow gauge excluded'}
    for name,size in SPECS.items():
        obj=bpy.data.objects['BE_Nature_'+name];mesh=obj.data;bm=bmesh.new();bm.from_mesh(mesh)
        lo=[min(v.co[k] for v in mesh.vertices) for k in range(3)];hi=[max(v.co[k] for v in mesh.vertices) for k in range(3)]
        dims=[round(hi[k]-lo[k],6) for k in (0,2,1)]
        item={'name':obj.name,'dimensions_W_H_D':dims,'target_W_H_D':list(size),'triangles':len(mesh.polygons),'budget':60,
              'bounds_min_xyz':lo,'bounds_max_xyz':hi,'location':list(obj.location),'rotation':list(obj.rotation_euler),'scale':list(obj.scale),
              'origin_at_base_center':abs(lo[2])<1e-6 and abs(hi[0]+lo[0])<1e-5 and abs(hi[1]+lo[1])<1e-5,
              'boundary_edges':sum(e.is_boundary for e in bm.edges),'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),
              'degenerate_faces':sum(f.calc_area()<1e-8 for f in bm.faces),'loose_vertices':sum(not v.link_edges for v in bm.verts),
              'inconsistent_winding_edges':sum(e.is_manifold and not e.is_contiguous for e in bm.edges),
              'flat_shaded':all(not p.use_smooth for p in mesh.polygons),'palette':['#'+c for c in COLORS[name]],
              'material_triangles':{c:sum(p.material_index==i for p in mesh.polygons) for i,c in enumerate(COLORS[name])},
              'textures':sum(n.type=='TEX_IMAGE' for m in mesh.materials for n in m.node_tree.nodes),
              'modifiers':len(obj.modifiers),'signed_volume':round(bm.calc_volume(signed=True),6)}
        item['pass']=(dims==list(size) and item['triangles']<=60 and item['origin_at_base_center'] and
                      all(item[k]==0 for k in ['boundary_edges','nonmanifold_edges','degenerate_faces','loose_vertices','inconsistent_winding_edges','textures','modifiers']) and
                      item['flat_shaded'] and item['signed_volume']>0 and tuple(obj.scale)==(1,1,1) and tuple(obj.rotation_euler)==(0,0,0))
        bm.free();report['assets'].append(item)
    report['preexisting_objects_unchanged']=all(name in bpy.data.objects and fingerprint(bpy.data.objects[name])==value for name,value in protected.items())
    report['pass']=all(a['pass'] for a in report['assets']) and report['preexisting_objects_unchanged']
    (REVIEW/'BE_Nature_Undergrowth_mesh.validation.json').write_text(json.dumps(report,indent=2))
    print('Undergrowth validation:',report['pass'],'|',', '.join(f"{a['name']} {a['triangles']}t" for a in report['assets']))
    assert report['pass'],'Undergrowth validation failed; progress saved'


def build():
    TMP.mkdir(parents=True,exist_ok=True);REVIEW.mkdir(parents=True,exist_ok=True)
    backup=TMP/'pre-undergrowth-backup.blend'
    if not backup.exists():bpy.ops.wm.save_as_mainfile(filepath=str(backup),copy=True)
    names=['BE_Nature_'+n for n in SPECS]
    protected={o.name:fingerprint(o) for o in bpy.data.objects if o.name not in names and not o.name.startswith('UNDER_REVIEW')}
    scene=bpy.data.scenes.get('BE_Nature_Undergrowth') or bpy.data.scenes.new('BE_Nature_Undergrowth')
    bpy.context.window.scene=scene
    for name in names:
        if name in bpy.data.objects:bpy.data.objects.remove(bpy.data.objects[name],do_unlink=True)
    collection=bpy.data.collections.get('BE_UNDERGROWTH_ASSETS') or bpy.data.collections.new('BE_UNDERGROWTH_ASSETS')
    if collection.name not in scene.collection.children:scene.collection.children.link(collection)
    for name in SPECS:make(name,collection)
    scene.unit_settings.scale_length=1
    bpy.ops.wm.save_as_mainfile(filepath=str(FILE));validate(protected)


def enum_set(owner,prop,value):
    assert value in [i.identifier for i in owner.bl_rna.properties[prop].enum_items],prop+' unsupported'
    setattr(owner,prop,value)


def review_scene(name):
    scene=bpy.data.scenes.get(name)
    if scene:
        for obj in list(scene.objects):bpy.data.objects.remove(obj,do_unlink=True)
    else:scene=bpy.data.scenes.new(name)
    bpy.context.window.scene=scene
    try:scene.render.engine='BLENDER_WORKBENCH'
    except TypeError as error:raise RuntimeError(str(error))
    sh=scene.display.shading;enum_set(sh,'light','STUDIO');enum_set(sh,'color_type','MATERIAL')
    sh.studio_light=next(x.name for x in bpy.context.preferences.studio_lights if x.name=='paint.sl')
    sh.show_shadows=False;sh.show_cavity=True;enum_set(sh,'cavity_type','WORLD')
    sh.curvature_ridge_factor=1.1;sh.curvature_valley_factor=.8
    scene.render.film_transparent=True
    enum_set(scene.render.image_settings,'file_format','PNG');enum_set(scene.render.image_settings,'color_mode','RGBA')
    return scene


def instance(scene,name,location):
    obj=bpy.data.objects.new('UNDER_REVIEW_'+name,bpy.data.objects['BE_Nature_'+name].data)
    scene.collection.objects.link(obj);obj.location=location;obj['review_only']=True


def marker(scene):
    verts=[];faces=[]
    for center,size in [((0,0,2.5),(.065,.065,5)),((0,0,.04),(.5,.14,.08)),((0,0,4.96),(.5,.14,.08))]:
        start=len(verts)
        for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]:
            verts.append(tuple(center[k]+(x,y,z)[k]*size[k]/2 for k in range(3)))
        faces.extend(tuple(start+i for i in f) for f in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)])
    mesh=bpy.data.meshes.new('UNDER_REVIEW_Gauge');mesh.from_pydata(verts,[],faces);mesh.update();mesh.materials.append(material('FFD43B'))
    obj=bpy.data.objects.new('UNDER_REVIEW_5STUD_GAUGE',mesh);scene.collection.objects.link(obj);obj.location=(8.3,0,0);obj['review_only']=True


def panel(scene,target,direction,scale,width,height,filename):
    data=bpy.data.cameras.new('UNDER_REVIEW_Camera');cam=bpy.data.objects.new('UNDER_REVIEW_Camera',data);scene.collection.objects.link(cam)
    enum_set(data,'type','ORTHO');data.ortho_scale=scale;data.clip_end=1000
    target=Vector(target);cam.location=target+Vector(direction).normalized()*100
    cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();scene.camera=cam
    scene.render.resolution_x=width;scene.render.resolution_y=height;scene.render.resolution_percentage=100
    scene.render.filepath=str(TMP/filename);bpy.ops.render.render(write_still=True)


def render():
    protected={o.name:fingerprint(o) for o in bpy.data.objects if not o.name.startswith('UNDER_REVIEW')}
    scene=review_scene('UNDER_REVIEW_Lineup')
    for name,x in zip(SPECS,[-6,0,5]):instance(scene,name,(x,0,0))
    marker(scene);panel(scene,(0,0,2),(0.08,-1,.55),21,1000,330,'lineup.png')
    scene=review_scene('UNDER_REVIEW_FlowerDetail');instance(scene,'FlowerClump',(0,0,0))
    panel(scene,(0,0,.5),(.3,-1,1.2),3.1,350,250,'flower.png')
    bpy.context.window.scene=bpy.data.scenes['UNDER_REVIEW_Lineup']
    bpy.ops.wm.save_as_mainfile(filepath=str(FILE));validate(protected)
    print('Undergrowth panels saved; mesh review only.')


if globals().get('BE_UNDERGROWTH_MODE','build')=='render':render()
else:build()
