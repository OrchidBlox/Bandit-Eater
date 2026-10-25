"""Approved inhale concept: one smooth crescent, mesh stage only.
Live Blender: BE_INHALE_MODE='build' (default), then 'render'.
After owner mesh approval: BE_INHALE_MODE='finish' exports the untouched mesh.
System Python with Pillow: python blender/scripts/build_inhale.py --compose
No opening Blender files, rig, texture, or gameplay changes.
"""
from pathlib import Path
import hashlib
import json
import math
import sys

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater\blender')
TMP=ROOT/'.codex-tmp'/'inhale'
REVIEW=ROOT/'review'
FILE=ROOT/'BE_Inhale_mesh.blend'
NAME='BE_Inhale_Crescent_Body'
SEGMENTS=40
SIDES=12
ARC_DEGREES=290


def fingerprint(obj):
    data=(obj.type,[tuple(row) for row in obj.matrix_world])
    if obj.type=='MESH':
        data+=(tuple(tuple(v.co) for v in obj.data.vertices),
               tuple((tuple(p.vertices),p.material_index,p.use_smooth) for p in obj.data.polygons),
               tuple(m.name for m in obj.data.materials))
    return hashlib.sha256(repr(data).encode()).hexdigest()


def protect():
    return {o.name:fingerprint(o) for o in bpy.data.objects
            if o.name!=NAME and not o.name.startswith('INHALE_REVIEW_')}


def geometry():
    verts=[];faces=[]
    start=math.radians((360-ARC_DEGREES)/2)
    arc=math.radians(ARC_DEGREES)
    major=1.57
    def section(theta,radial,depth,offset=0):
        radial_axis=Vector((math.cos(theta),0,math.sin(theta)))
        tangent=Vector((-math.sin(theta),0,math.cos(theta)))
        center=radial_axis*major+tangent*offset
        ids=[]
        for j in range(SIDES):
            phi=j*math.tau/SIDES
            v=center+radial_axis*(radial*math.cos(phi))+Vector((0,depth*math.sin(phi),0))
            ids.append(len(verts));verts.append(tuple(v))
        return ids
    rings=[]
    for i in range(SEGMENTS+1):
        t=i/SEGMENTS
        fullness=math.sin(math.pi*t)
        rings.append(section(start+arc*t,.18+.25*fullness**.8,.18+.08*fullness**.6))
    def bridge(a,b):
        for j in range(SIDES):faces.append((a[j],a[(j+1)%SIDES],b[(j+1)%SIDES],b[j]))
    for a,b in zip(rings,rings[1:]):bridge(a,b)
    # Ellipsoidal hemispheres give genuinely rounded tips instead of pinched cones.
    for theta,ring,sign in [(start,rings[0],-1),(start+arc,rings[-1],1)]:
        previous=ring
        for latitude in (math.pi/6,math.pi/3):
            current=section(theta,.18*math.cos(latitude),.18*math.cos(latitude),sign*.18*math.sin(latitude))
            bridge(previous,current);previous=current
        center=Vector((math.cos(theta),0,math.sin(theta)))*major
        tangent=Vector((-math.sin(theta),0,math.cos(theta)))
        pole=len(verts);verts.append(tuple(center+tangent*(sign*.18)))
        for j in range(SIDES):faces.append((previous[j],previous[(j+1)%SIDES],pole))
    # Ring-center stays at (0,0,0); no recentering to the asymmetric open-arc box.
    raw_min=[min(v[k] for v in verts) for k in range(3)]
    raw_max=[max(v[k] for v in verts) for k in range(3)]
    factors=(4/(raw_max[0]-raw_min[0]),1,4/(raw_max[2]-raw_min[2]))
    return [tuple(v[k]*factors[k] for k in range(3)) for v in verts],faces


def validate(protected):
    obj=bpy.data.objects[NAME];mesh=obj.data;bm=bmesh.new();bm.from_mesh(mesh)
    lo=[min(v.co[k] for v in mesh.vertices) for k in range(3)]
    hi=[max(v.co[k] for v in mesh.vertices) for k in range(3)]
    bounds=[round(hi[k]-lo[k],6) for k in (0,2,1)]
    data={'stage':'mesh; owner approval pending','object':NAME,'triangles':len(mesh.polygons),
          'triangle_budget':1200,'vertices':len(mesh.vertices),'dimensions_W_H_D':bounds,
          'bounds_min_xyz':lo,'bounds_max_xyz':hi,
          'origin':'ring center (0,0,0), intentional VFX exception to ground/base pivots',
          'plane':'Blender XZ, depth Y; intended Roblox XY, depth Z after import',
          'opening':'right (+X)','centerline_arc_degrees':ARC_DEGREES,
          'caps':'rounded ellipsoidal hemispheres; radial body tapers to 0.18-stud cap radii before dimension normalization',
          'location':list(obj.location),'rotation':list(obj.rotation_euler),'scale':list(obj.scale),
          'smooth_shaded':all(p.use_smooth for p in mesh.polygons),
          'boundary_edges':sum(e.is_boundary for e in bm.edges),'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),
          'loose_vertices':sum(not v.link_edges for v in bm.verts),'degenerate_faces':sum(f.calc_area()<1e-8 for f in bm.faces),
          'inconsistent_winding_edges':sum(e.is_manifold and not e.is_contiguous for e in bm.edges),
          'signed_volume':round(bm.calc_volume(signed=True),6),
          'materials':[m.name for m in mesh.materials],'textures':sum(n.type=='TEX_IMAGE' for m in mesh.materials for n in m.node_tree.nodes),
          'modifiers':len(obj.modifiers),'rig':False,'animation':False,
          'preexisting_objects_unchanged':all(n in bpy.data.objects and fingerprint(bpy.data.objects[n])==v for n,v in protected.items()),
          'validation_limit':'Static mesh and review images only. Export, Roblox axes and effect animation not yet validated.'}
    bm.free()
    data['pass']=(data['triangles']<=1200 and bounds==[4,4,.52] and data['smooth_shaded'] and
                  all(data[k]==0 for k in ['boundary_edges','nonmanifold_edges','loose_vertices','degenerate_faces','inconsistent_winding_edges','textures','modifiers']) and
                  data['signed_volume']>0 and len(mesh.materials)==1 and tuple(obj.location)==(0,0,0) and
                  tuple(obj.rotation_euler)==(0,0,0) and tuple(obj.scale)==(1,1,1) and data['preexisting_objects_unchanged'])
    (REVIEW/'BE_Inhale_mesh.validation.json').write_text(json.dumps(data,indent=2))
    print('Inhale validation:',data['pass'],'|',data['triangles'],'tris | bounds',bounds)
    assert data['pass'],'Inhale validation failed; progress saved'


def build():
    TMP.mkdir(parents=True,exist_ok=True);REVIEW.mkdir(parents=True,exist_ok=True)
    backup=TMP/'pre-inhale-backup.blend'
    if not backup.exists():bpy.ops.wm.save_as_mainfile(filepath=str(backup),copy=True)
    protected=protect()
    scene=bpy.data.scenes.get('BE_Inhale_Mesh') or bpy.data.scenes.new('BE_Inhale_Mesh')
    bpy.context.window.scene=scene
    if NAME in bpy.data.objects:bpy.data.objects.remove(bpy.data.objects[NAME],do_unlink=True)
    coll=bpy.data.collections.get('BE_INHALE_ASSET') or bpy.data.collections.new('BE_INHALE_ASSET')
    if coll.name not in scene.collection.children:scene.collection.children.link(coll)
    verts,faces=geometry()
    mesh=bpy.data.meshes.new(NAME+'_Geometry');mesh.from_pydata(verts,[],faces);mesh.update()
    mat=bpy.data.materials.get('BE_Inhale_White') or bpy.data.materials.new('BE_Inhale_White')
    mat.diffuse_color=(1,1,1,1);mat.use_nodes=True
    shader=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    shader.inputs['Base Color'].default_value=(1,1,1,1);shader.inputs['Roughness'].default_value=.45
    mesh.materials.append(mat)
    bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bmesh.ops.triangulate(bm,faces=bm.faces)
    bm.to_mesh(mesh);bm.free()
    for polygon in mesh.polygons:polygon.use_smooth=True
    obj=bpy.data.objects.new(NAME,mesh);coll.objects.link(obj)
    obj['stage']='mesh; awaiting owner approval';obj['pivot']='ring center';obj['recolor']='neutral white; Wind palette applied in game later'
    scene.unit_settings.scale_length=1
    bpy.ops.wm.save_as_mainfile(filepath=str(FILE));validate(protected)


def enum_set(owner,prop,value):
    assert value in [i.identifier for i in owner.bl_rna.properties[prop].enum_items],prop+' unsupported'
    setattr(owner,prop,value)


def render_view(name,direction,width,height,scale):
    scene=bpy.data.scenes.get('INHALE_REVIEW_'+name)
    if scene:
        for obj in list(scene.objects):bpy.data.objects.remove(obj,do_unlink=True)
    else:scene=bpy.data.scenes.new('INHALE_REVIEW_'+name)
    bpy.context.window.scene=scene
    try:scene.render.engine='BLENDER_WORKBENCH'
    except TypeError as error:raise RuntimeError(str(error))
    sh=scene.display.shading;enum_set(sh,'light','STUDIO');enum_set(sh,'color_type','MATERIAL')
    sh.studio_light=next(x.name for x in bpy.context.preferences.studio_lights if x.name=='paint.sl')
    sh.show_shadows=False;sh.show_cavity=False
    scene.render.film_transparent=True
    enum_set(scene.render.image_settings,'file_format','PNG');enum_set(scene.render.image_settings,'color_mode','RGBA')
    obj=bpy.data.objects.new('INHALE_REVIEW_Body_'+name,bpy.data.objects[NAME].data);scene.collection.objects.link(obj);obj['review_only']=True
    data=bpy.data.cameras.new('INHALE_REVIEW_Camera_'+name);cam=bpy.data.objects.new(data.name,data);scene.collection.objects.link(cam)
    enum_set(data,'type','ORTHO');data.ortho_scale=scale;data.clip_end=1000
    cam.location=Vector(direction).normalized()*20
    cam.rotation_euler=(-cam.location).to_track_quat('-Z','Y').to_euler();scene.camera=cam
    scene.render.resolution_x=width;scene.render.resolution_y=height;scene.render.resolution_percentage=100
    scene.render.filepath=str(TMP/(name+'.png'));bpy.ops.render.render(write_still=True)


def render():
    protected=protect()
    render_view('Front',(0,-1,0),330,340,5)
    render_view('Side',(1,0,0),200,340,5)
    render_view('Perspective',(4,-7,3),330,340,5)
    bpy.context.window.scene=bpy.data.scenes['INHALE_REVIEW_Front']
    bpy.ops.wm.save_as_mainfile(filepath=str(FILE));validate(protected)
    print('Inhale review panels saved; compose next. No export.')


def compose():
    from PIL import Image,ImageDraw,ImageFont
    canvas=Image.new('RGB',(900,790),'#1D242C');draw=ImageDraw.Draw(canvas)
    def font(n,bold=False):return ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if bold else 'segoeui.ttf'),n)
    def text(x,y,s,n=14,color='#DFE6EE',bold=False):draw.text((x,y),s,font=font(n,bold),fill=color)
    def paste(path,xy,size=None):
        im=Image.open(path).convert('RGBA')
        if size:
            im.thumbnail(size,Image.Resampling.LANCZOS)
            xy=(xy[0]+(size[0]-im.width)//2,xy[1]+(size[1]-im.height)//2)
        canvas.paste(im,xy,im)
    text(20,12,'BANDIT EATER  /  INHALE CRESCENT',24,bold=True)
    text(20,47,'MESH REVIEW  •  smooth neutral-white body / rounded tips / open right',14,'#A9B7C5')
    paste(TMP/'Front.png',(0,76));paste(TMP/'Side.png',(350,76));paste(TMP/'Perspective.png',(570,76))
    text(125,402,'FRONT',15,bold=True);text(430,402,'SIDE',15,bold=True);text(675,402,'PERSPECTIVE',15,bold=True)
    draw.line((20,436,880,436),fill='#3F4C58')
    text(20,456,'ONE REUSABLE MESH',17,bold=True)
    text(20,493,'4 × 4 × 0.52 studs',17)
    text(20,522,'1,080 triangles / 1,200 budget',14,'#A9B7C5')
    text(20,553,'290° arc with soft rounded caps',14,'#A9B7C5')
    text(20,584,'Ring-center pivot at (0, 0, 0)',14,'#A9B7C5')
    text(20,615,'Blender XZ plane • depth along Y',14,'#A9B7C5')
    text(20,661,'Neutral white for game recoloring.',13,'#A9B7C5')
    text(20,687,'Static mesh only; no rig or animation.',13,'#A9B7C5')
    text(20,752,'Appearance awaits owner approval.',13,'#A9B7C5')
    text(360,451,'APPROVED CONCEPT',15,bold=True)
    paste(ROOT.parent/'docs/reference/inhale-vfx-v1.png',(360,481),(520,299))
    canvas.save(REVIEW/'BE_Inhale_mesh.png');print('Saved composite:',REVIEW/'BE_Inhale_mesh.png')


def finish():
    """Approved static export using model_tools, retaining the VFX center pivot."""
    import contextlib
    import importlib.util
    import io
    spec=importlib.util.spec_from_file_location('inhale_export_checks',ROOT/'scripts/export_cliffs_rocks.py')
    checks=importlib.util.module_from_spec(spec)
    old_bytecode=sys.dont_write_bytecode;sys.dont_write_bytecode=True
    try:spec.loader.exec_module(checks)
    finally:sys.dont_write_bytecode=old_bytecode
    protected=protect();source=bpy.data.objects[NAME]
    source_before=fingerprint(source);source_sha=checks.sha(FILE)
    output=ROOT/'export/BE_Inhale_Crescent.fbx'
    finish_file=ROOT/'BE_Inhale.blend'
    report_file=REVIEW/'BE_Inhale_export.validation.json'
    output.parent.mkdir(parents=True,exist_ok=True)
    report={'stage':'approved mesh finish/export','source_blend':str(FILE),
            'source_sha256':source_sha,'finish_blend':str(finish_file),'export':str(output),
            'object':NAME,'pivot':'ring center at (0,0,0), not bounding-box center',
            'axis_forward':'-Y','axis_up':'Z','apply_scale_options':'FBX_SCALE_ALL',
            'apply_unit_scale':True,'unit':'1 Blender unit = 1 Roblox stud',
            'Blender_plane':'XZ; depth Y','intended_Roblox_plane':'XY; depth Z; verify Studio import orientation',
            'rig':False,'animation':False,'textures':0,'triangle_tolerance_studs':1e-5}
    bpy.context.window.scene=bpy.data.scenes['BE_Inhale_Mesh']
    qa=None
    try:
        assert len(source.data.polygons)==1080 and len(source.data.materials)==1,'Approved mesh signature differs'
        assert checks.bounds([source])['W_H_D']==[4,4,.52],'Approved mesh bounds differ'
        assert tuple(source.location)==(0,0,0) and tuple(source.scale)==(1,1,1),'Source pivot/scale differs'
        helper=checks.mt.Model('BE_Inhale_Crescent',parts=['Body'],rig=None,actions=(),
                               root=str(TMP/'finish'),base_file=str(FILE))
        with contextlib.redirect_stdout(io.StringIO()):
            helper.snapshot_base();helper.validate_export()
        (Path(helper.out)/'BE_Inhale_Crescent_Base.fbx').replace(output)
        qa=bpy.data.scenes.new('INHALE_REVIEW_FBX_CHECK');bpy.context.window.scene=qa
        qa.unit_settings.scale_length=1
        with contextlib.redirect_stdout(io.StringIO()):bpy.ops.import_scene.fbx(filepath=str(output),use_anim=False)
        imported=[o for o in qa.objects if o.type=='MESH']
        assert len(imported)==1,'FBX must contain exactly one mesh'
        result=imported[0]
        report['triangles']=len(source.data.polygons)
        report['bounds']=checks.bounds([source])
        report['roundtrip_bounds']=checks.bounds(imported)
        report['roundtrip_triangles']=sum(len(p.vertices)-2 for p in result.data.polygons)
        report['triangle_positions_match']=checks.triangles_match(checks.raw_triangles(imported),checks.raw_triangles([source]))
        report['center_pivot_preserved']=result.location.length<1e-5
        report['material_count']=len(result.data.materials)
        report['neutral_white']=all(max(abs(c-1) for c in next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED').inputs['Base Color'].default_value)<1e-5 for m in result.data.materials)
        report['textures']=sum(n.type=='TEX_IMAGE' for m in result.data.materials for n in m.node_tree.nodes)
        # Compare smooth per-corner normals, not flat polygon normals. The FBX
        # importer preserves these as custom normals, with minor packing error.
        original_coords=[source.matrix_world @ v.co for v in source.data.vertices]
        original_normals={loop.vertex_index:source.data.corner_normals[loop.index].vector.copy() for loop in source.data.loops}
        normal_matrix=result.matrix_world.to_3x3().inverted().transposed()
        vertex_mapping={v.index:min(range(len(original_coords)),key=lambda i:(result.matrix_world @ v.co-original_coords[i]).length_squared) for v in result.data.vertices}
        dots=[(normal_matrix @ result.data.corner_normals[loop.index].vector).normalized().dot(original_normals[vertex_mapping[loop.vertex_index]]) for loop in result.data.loops]
        report['smooth_normals_min_dot']=round(min(dots),8)
        report['smooth_normals_preserved']=min(dots)>.9998
        report['source_mesh_unchanged']=fingerprint(source)==source_before
        report['source_blend_unchanged']=checks.sha(FILE)==source_sha
        report['preexisting_objects_unchanged']=all(n in bpy.data.objects and fingerprint(bpy.data.objects[n])==v for n,v in protected.items())
        report['export_sha256']=checks.sha(output)
        report['pass']=(report['triangle_positions_match'] and report['center_pivot_preserved'] and
                        report['roundtrip_triangles']==1080 and report['material_count']==1 and
                        report['neutral_white'] and report['textures']==0 and report['smooth_normals_preserved'] and
                        report['source_mesh_unchanged'] and report['source_blend_unchanged'] and report['preexisting_objects_unchanged'])
        assert report['pass'],'Inhale export validation failed; see report'
        print('Inhale FBX OK: 1 mesh / 1080 tris / 4 x 4 x 0.52 studs / center pivot / smooth normals preserved')
    except Exception as error:
        report['pass']=False;report['error']=str(error)
        raise
    finally:
        if qa:
            for obj in list(qa.objects):bpy.data.objects.remove(obj,do_unlink=True)
            bpy.context.window.scene=bpy.data.scenes['BE_Inhale_Mesh'];bpy.data.scenes.remove(qa)
        report_file.write_text(json.dumps(report,indent=2))
        bpy.ops.wm.save_as_mainfile(filepath=str(finish_file))


if '--compose' in sys.argv:
    compose()
else:
    import bpy
    import bmesh
    from mathutils import Vector
    mode=globals().get('BE_INHALE_MODE','build')
    if mode=='render':render()
    elif mode=='finish':finish()
    else:build()
