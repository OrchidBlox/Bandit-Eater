"""BE Nature mesh-stage source. Execute in live Blender through MCP.

1 unit = 1 stud; native assets at base-center origin. No export/rig/texture stage.
Run with BE_MODE='build' (default), then BE_MODE='render' for review panels.
Compose panels using compose_cliffs_rocks.py in system Python (Pillow).
"""
import bpy
import bmesh
import json
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
OUT = ROOT / 'blender'
REVIEW = OUT / 'review'
PANELS = OUT / '.codex-tmp' / 'cliffs-rocks-review'
PREFIX = 'BE_Nature_'
NAMES = ['CliffStraightA', 'CliffStraightB', 'CliffCorner', 'CliffEnd',
         'RockSmall', 'RockMedium', 'RockLarge']
BUDGETS = [600, 600, 600, 600, 80, 160, 250]
SIZES = [(48,28,12),(48,24,12),(26,30,26),(12,24,12),
         (12,3,8),(16,3.3,11),(20,3.6,13)]


def linear(c):
    return c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4


def material(name, color):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    rgba = tuple(linear(int(color[i:i+2],16)/255) for i in (0,2,4)) + (1,)
    mat.diffuse_color = rgba
    mat.use_nodes = True
    shader = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    shader.inputs['Base Color'].default_value = rgba
    shader.inputs['Roughness'].default_value = .86
    return mat


def enum_set(owner, prop, desired):
    valid = [x.identifier for x in owner.bl_rna.properties[prop].enum_items]
    if desired not in valid:
        raise RuntimeError(f'{prop}: {desired} unavailable; found {valid}')
    setattr(owner, prop, desired)


def make_mesh(name, vertices, faces, dark_faces=()):
    mesh = bpy.data.meshes.new(PREFIX + name + '_Geometry')
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(PREFIX + name, mesh)
    bpy.data.collections['BE_ASSETS'].objects.link(obj)
    for mat in (bpy.data.materials['BE_Rock_8A8F99'], bpy.data.materials['BE_Shadow_5F6672']):
        mesh.materials.append(mat)
    for i, poly in enumerate(mesh.polygons):
        poly.material_index = int(i in dark_faces)
        poly.use_smooth = False
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    # Explicit triangles make the measured runtime silhouette reproducible.
    bmesh.ops.triangulate(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    obj['stage'] = 'mesh / awaiting owner visual approval'
    obj['unit'] = '1 Blender unit = 1 Roblox stud'
    obj['origin_contract'] = 'base center; local Z minimum 0'
    return obj


def straight(name, variant):
    # Six-point section: broad front lower/upper plates, chamfer, top, closed back.
    # Identical X-plane terminals permit exact A/B joins; interior tops vary.
    if variant == 'A':
        xs = [-24,-18,-9,-8,-7,2,9,10,11,19,24]
        heights = [22,26,28,26,26,25,27,25,26,24,22]
        front = [-4.8,-5.8,-6,-4.3,-5.7,-5.1,-5.8,-4.0,-5.9,-5.3,-4.8]
        shift = [0,-.9,1,.4,-.3,-1.7,.7,.4,.1,-1,0]
        folds = {2,7}
    else:
        xs = [-24,-17,-11,-10,-9,0,8,9,10,17,24]
        heights = [22,23,24,22,23,21.7,22.7,21,22,24,22]
        front = [-4.8,-6,-5.7,-4.2,-5.8,-5.9,-5.8,-4.4,-5.7,-5.2,-4.8]
        shift = [0,1.3,-.8,-.2,.2,1.6,-.6,-.3,.2,1,0]
        folds = {2,7}
    verts=[]
    for i,(x,h,y,s) in enumerate(zip(xs,heights,front,shift)):
        terminal = i in (0,len(xs)-1)
        mid = 10 if terminal else h * (.43 + .05*math.sin(i*1.9))
        verts.extend([(x,y,0), (x+s,y+.45,mid),
                      (x+s*.25,y+1.0,h-2), (x,y+1.7,h),
                      (x,6,h), (x,6,0)])
    faces=[]
    dark=[]
    for i in range(len(xs)-1):
        for j in range(6):
            faces.append((i*6+j,(i+1)*6+j,(i+1)*6+(j+1)%6,i*6+(j+1)%6))
            if i in folds and j < 3:
                dark.append(len(faces)-1)
    faces += [tuple(reversed(range(6))),tuple((len(xs)-1)*6+j for j in range(6))]
    return make_mesh(name,verts,faces,dark)


def ring_solid(name, outline, heights, max_height, top_scale=.88, shoulder=.85, dark=()):
    # Deliberately authored polygon perimeter, with low broad planes.
    n=len(outline)
    verts=[]
    for ring in range(3):
        for i,(x,y) in enumerate(outline):
            if ring==0:
                verts.append((x,y,0))
            elif ring==1:
                verts.append((x*.96,y*.96,heights[i]*shoulder))
            else:
                verts.append((x*top_scale,y*top_scale,heights[i]))
    faces=[]
    ds=[]
    for r in range(2):
        for i in range(n):
            faces.append((r*n+i,r*n+(i+1)%n,(r+1)*n+(i+1)%n,(r+1)*n+i))
            if i in dark:
                ds.append(len(faces)-1)
    faces.append(tuple(reversed(range(n))))
    # Upper surface split into large, readable planes around an offset broad crown.
    cx=sum(x for x,y in outline)/n*.18
    cy=sum(y for x,y in outline)/n*.18
    verts.append((cx,cy,max_height))
    for i in range(n):
        faces.append((2*n+i,2*n+(i+1)%n,3*n))
    return make_mesh(name,verts,faces,ds)


def validate():
    report={'stage':'mesh; visual approval pending', 'units':'studs; Blender Z-up, faces -Y',
            'palette':['#8A8F99','#5F6672'], 'assets':[],
            'review_only':'REVIEW_* objects, including yellow 5-stud marker, excluded',
            'validation_limits':'Static mesh validation only. No Roblox import, placement, or gameplay test.'}
    for name,budget,size in zip(NAMES,BUDGETS,SIZES):
        obj=bpy.data.objects[PREFIX+name]
        mesh=obj.data
        bm=bmesh.new(); bm.from_mesh(mesh)
        coords=[v.co for v in mesh.vertices]
        lo=[min(v[k] for v in coords) for k in range(3)]
        hi=[max(v[k] for v in coords) for k in range(3)]
        bounds=[round(hi[k]-lo[k],6) for k in range(3)]
        tris=sum(len(p.vertices)-2 for p in mesh.polygons)
        item={'name':obj.name,'triangles':tris,'triangle_budget':budget,
              'dimensions_W_H_D':[bounds[0],bounds[2],bounds[1]],
              'bounds_min_xyz':lo,'bounds_max_xyz':hi,
              'location':list(obj.location),'rotation':list(obj.rotation_euler),'scale':list(obj.scale),
              'base_origin':abs(lo[2])<1e-5 and abs(hi[0]+lo[0])<1e-5 and abs(hi[1]+lo[1])<1e-5,
              'boundary_edges':sum(e.is_boundary for e in bm.edges),
              'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),
              'loose_vertices':sum(not v.link_edges for v in bm.verts),
              'degenerate_faces':sum(f.calc_area()<1e-8 for f in bm.faces),
              'inconsistent_winding_edges':sum(e.is_manifold and not e.is_contiguous for e in bm.edges),
              'signed_volume':round(bm.calc_volume(signed=True),5),
              'flat_shaded':all(not p.use_smooth for p in mesh.polygons),
              'material_count':len(mesh.materials),'modifiers':len(obj.modifiers)}
        item['pass'] = (tris<=budget and item['base_origin'] and
                       all(abs(a-b)<1e-4 for a,b in zip(item['dimensions_W_H_D'],size)) and
                       all(item[k]==0 for k in ['boundary_edges','nonmanifold_edges','loose_vertices',
                                                   'degenerate_faces','inconsistent_winding_edges','modifiers']) and
                       item['signed_volume']>0 and item['flat_shaded'] and item['material_count']==2 and
                       tuple(obj.scale)==(1,1,1) and tuple(obj.rotation_euler)==(0,0,0) and tuple(obj.location)==(0,0,0))
        report['assets'].append(item); bm.free()
    a=bpy.data.objects[PREFIX+'CliffStraightA']; b=bpy.data.objects[PREFIX+'CliffStraightB']
    sections=[]
    for obj,side in [(a,-24),(a,24),(b,-24),(b,24)]:
        sections.append(sorted((round(v.co.y,5),round(v.co.z,5)) for v in obj.data.vertices if abs(v.co.x-side)<1e-6))
    report['tile_interfaces']={'all_four_end_sections_identical':all(s==sections[0] for s in sections),
                               'join_plane_x':[-24,24], 'section_yz':sections[0],
                               'ABA_centers_x':[-48,0,48],'gap_studs':0}
    report['pass']=all(a['pass'] for a in report['assets']) and report['tile_interfaces']['all_four_end_sections_identical']
    (REVIEW/'BE_Nature_CliffsRocks_mesh.validation.json').write_text(json.dumps(report,indent=2))
    print('Validation:',report['pass'],'|',', '.join(f"{a['name'].replace(PREFIX,'')} {a['triangles']}t" for a in report['assets']))
    if not report['pass']:
        print('FAILURES:', [a['name'] for a in report['assets'] if not a['pass']])
    return report


def build():
    REVIEW.mkdir(parents=True,exist_ok=True)
    backup=OUT/'.codex-tmp'/'prebuild-backup.blend'
    backup.parent.mkdir(parents=True,exist_ok=True)
    if not backup.exists():
        bpy.ops.wm.save_as_mainfile(filepath=str(backup),copy=True)
    # The original scene remains intact, in addition to the separate backup.
    scene=bpy.data.scenes.get('BE_Nature_CliffsRocks')
    if not scene:
        scene=bpy.data.scenes.new('BE_Nature_CliffsRocks')
    bpy.context.window.scene=scene
    for obj in list(bpy.data.objects):
        if obj.name.startswith(PREFIX) or obj.name.startswith('REVIEW_'):
            bpy.data.objects.remove(obj,do_unlink=True)
    coll=bpy.data.collections.get('BE_ASSETS') or bpy.data.collections.new('BE_ASSETS')
    if coll.name not in scene.collection.children:
        scene.collection.children.link(coll)
    material('BE_Rock_8A8F99','8A8F99'); material('BE_Shadow_5F6672','5F6672')
    straight('CliffStraightA','A'); straight('CliffStraightB','B')
    # Corner: two exposed cliff walls and a chamfered outside corner, solid rear.
    ring_solid('CliffCorner', [(-13,13),(-13,5),(-12,0),(-10.5,-1),(-12,-2),
                              (-13,-8),(-9,-13),(-1,-13),(0,-11.5),(1,-13),(8,-12),(13,-13),(13,13)],
               [26,28,30,27,28,29,28,27,25,27,26,25,27],30,.88,.89,{2,7})
    ring_solid('CliffEnd', [(-6,6),(-6,-3),(-3.5,-6),(1,-5.7),(2,-4.3),(3,-5.8),(6,-3),(5,3),(3.5,6)],
               [22,22,24,23,21,22,21,20,21],24,.83,.86,{3,6})
    ring_solid('RockSmall', [(-6,-1),(-4.7,-3.3),(-.7,-4),(4,-3.4),(6,-.7),(4.4,3.3),(.2,4),(-4.9,2.6)],
               [2.1,2.5,2.6,2.3,1.8,2.0,2.4,2.2],3,.72,.7,{0,4})
    ring_solid('RockMedium', [(-8,-2),(-5.4,-5.5),(-.5,-5.0),(5.8,-4.4),(8,-1.4),(6.7,2.2),
                            (3.8,3.4),(1.2,5.5),(-4.8,4.5),(-7.4,1.5)],
               [2.5,2.7,3.05,2.9,2.1,2.15,2.7,2.5,2.9,2.7],3.3,.79,.65,{0,4,8})
    ring_solid('RockLarge', [(-10,-2.4),(-8,-5.4),(-3.1,-6.5),(-1.4,-5.2),(2.1,-5.7),(7.5,-5),
                            (10,-1.8),(8.6,3.7),(4.3,6.5),(-1.4,5.8),(-7.5,4.7)],
               [2.3,2.8,3.2,2.85,3.1,2.8,2.25,2.6,3.0,3.1,2.7],3.6,.79,.68,{2,5,9})
    scene.unit_settings.scale_length=1
    report=validate()
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'BE_Nature_CliffsRocks_mesh.blend'))
    print('Mesh source saved; original scene and backup preserved.')


def review_scene(name):
    old=bpy.data.scenes.get(name)
    if old: bpy.data.scenes.remove(old)
    scene=bpy.data.scenes.new(name)
    bpy.context.window.scene=scene
    try: scene.render.engine='BLENDER_WORKBENCH'
    except TypeError as err: raise RuntimeError('Workbench unavailable: '+str(err))
    shade=scene.display.shading
    enum_set(shade,'light','STUDIO'); enum_set(shade,'color_type','MATERIAL')
    shade.studio_light=next(x.name for x in bpy.context.preferences.studio_lights if x.name=='paint.sl')
    enum_set(shade,'background_type','WORLD')
    shade.show_shadows=False
    shade.show_cavity=True
    enum_set(shade,'cavity_type','WORLD')
    shade.curvature_ridge_factor=1.15
    shade.curvature_valley_factor=.8
    scene.world=bpy.data.worlds.new(name+'_World')
    scene.world.color=(.17,.19,.22)
    # Keep the installed OCIO defaults: Blender 5.2 exposes these dynamic enums
    # as NONE through RNA, despite its live AgX/None settings.
    scene.render.film_transparent=True
    enum_set(scene.render.image_settings,'file_format','PNG')
    enum_set(scene.render.image_settings,'color_mode','RGBA')
    scene.render.resolution_percentage=100
    return scene


def instance(scene,asset,loc):
    source=bpy.data.objects[PREFIX+asset]
    obj=bpy.data.objects.new('REVIEW_'+scene.name+'_'+asset,source.data)
    scene.collection.objects.link(obj); obj.location=loc
    obj['review_only']=True
    return obj


def marker(scene,loc):
    # Joined simple yellow gauge, exactly 5 studs tall, never an asset.
    verts=[]; faces=[]
    for center,size in [((0,0,2.5),(.4,.4,5)),((0,0,0.12),(2,.6,.24)),((0,0,4.88),(2,.6,.24))]:
        base=len(verts)
        for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]:
            verts.append(tuple(center[k]+(x,y,z)[k]*size[k]/2 for k in range(3)))
        for f in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:
            faces.append(tuple(base+i for i in f))
    mesh=bpy.data.meshes.new('REVIEW_5stud_Mesh'); mesh.from_pydata(verts,[],faces);mesh.update()
    obj=bpy.data.objects.new('REVIEW_5stud_YELLOW_GAUGE',mesh);scene.collection.objects.link(obj)
    obj.location=loc; obj['review_only']=True
    mesh.materials.append(material('REVIEW_Yellow','FFD43B'))


def camera_render(scene,target,direction,scale,width,height,filename):
    data=bpy.data.cameras.new('REVIEW_Camera_'+scene.name)
    obj=bpy.data.objects.new('REVIEW_Camera_'+scene.name,data);scene.collection.objects.link(obj)
    enum_set(data,'type','ORTHO');data.ortho_scale=scale
    obj.location=Vector(target)+Vector(direction).normalized()*300
    obj.rotation_euler=(Vector(target)-obj.location).to_track_quat('-Z','Y').to_euler()
    data.clip_end=1000;scene.camera=obj
    scene.render.resolution_x=width;scene.render.resolution_y=height
    scene.render.filepath=str(PANELS/filename)
    bpy.ops.render.render(write_still=True)


def render():
    PANELS.mkdir(parents=True,exist_ok=True)
    scene=review_scene('REVIEW_CliffLineup')
    for name,x in [('CliffStraightA',-64),('CliffStraightB',-8),('CliffCorner',40),('CliffEnd',70)]:
        obj=instance(scene,name,(x,0,0))
        if name=='CliffCorner': obj.rotation_euler.z=math.radians(35)
    marker(scene,(-33,-8,0))
    camera_render(scene,(0,0,12),(0.18,-1,.5),181,1000,265,'_cliff_lineup.png')
    scene=review_scene('REVIEW_RockLineup')
    for name,x in [('RockSmall',-23),('RockMedium',-4),('RockLarge',20)]:
        instance(scene,name,(x,0,0))
    marker(scene,(36,0,0))
    camera_render(scene,(3,0,1),(0.1,-1,.7),77,1000,200,'_rock_lineup.png')
    scene=review_scene('REVIEW_ABA')
    for name,x in [('CliffStraightA',-48),('CliffStraightB',0),('CliffStraightA',48)]:
        instance(scene,name,(x,0,0))
    marker(scene,(-55,-9,0))
    camera_render(scene,(0,0,12),(0,-1,.38),154,680,210,'_aba_join.png')
    # Keep asset scene pristine at origin; make lineup the opening review scene.
    bpy.context.window.scene=bpy.data.scenes['REVIEW_CliffLineup']
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'BE_Nature_CliffsRocks_mesh.blend'))
    print('Three review panels saved; compose next.')


if globals().get('BE_MODE','build') == 'render':
    render()
else:
    build()
