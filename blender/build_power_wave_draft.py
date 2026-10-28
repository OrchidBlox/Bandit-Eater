"""Headless mesh-stage only. Does not access or change the live Blender process."""
import bpy, bmesh, math, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
OUT=ROOT/'blender'/'previews'/'BE_PowerWave'; OUT.mkdir(parents=True,exist_ok=True)
TARGET=ROOT/'blender'/'BE_PowerWave.blend'
if TARGET.exists(): raise RuntimeError('Preserve existing BE_PowerWave.blend; choose a revision path')
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene
scene.name='BE_PowerWave_MeshReview'
profile=[(.75,0),(.65,.65),(.4,1.6),(0,2.5),(-.4,2.9),(-.9,3),(-1.2,2.75),(-1.25,2.35),(-1.05,2.15),(-.8,2.2),(-.72,2.4),(-.85,2.5),(-.65,2.5),(-.4,2.25),(-.35,1.8),(-.45,1.2),(-.8,.65),(-1.3,.2),(-1.45,.05),(-.3,0)]
# Rounded cyclic silhouette, including open inner scoop rather than a torus.
curve=[]
for i in range(len(profile)):
 p0,p1,p2,p3=[Vector(profile[j%len(profile)]) for j in (i-1,i,i+1,i+2)]
 for j in range(3):
  t=j/3
  curve.append(.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t))
verts=[]
rings=[(-2.5,.15),(-2.35,.65),(-1.75,.97),(0,1),(1.75,.97),(2.35,.65),(2.5,.15)]
for x,s in rings:
 for y,z in curve:
  verts.append((x, (y+.35)*s-.35, (z-1.25)*s+1.25))
n=len(curve); faces=[]
for r in range(len(rings)-1):
 for i in range(n): faces.append((r*n+i,r*n+(i+1)%n,(r+1)*n+(i+1)%n,(r+1)*n+i))
faces.extend([tuple(reversed(range(n))),tuple((len(rings)-1)*n+i for i in range(n))])
mesh=bpy.data.meshes.new('Wave_Curl_Geometry'); mesh.from_pydata(verts,[],faces); mesh.update()
obj=bpy.data.objects.new('BE_PowerWave',mesh); scene.collection.objects.link(obj)
bpy.context.view_layer.objects.active=obj; obj.select_set(True)
# Broad rounded foam relief intersects the heavy curling ledge. Joined intentional relief.
for i,x in enumerate([-1.95,-1.3,-.65,0,.65,1.3,1.95]):
 z=2.78-.25*(abs(x)/1.95)**2
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=1,location=(x,-.88,z))
 puff=bpy.context.object; puff.name='CrestScallop'
 puff.scale=(.47,.3,.32 if i%2 else .28)
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 puff.select_set(False)
obj.select_set(True)
for item in scene.objects:
 if item.type=='MESH': item.select_set(True)
bpy.context.view_layer.objects.active=obj; bpy.ops.object.join()
# One static mesh, exact centered5wide x1.5deep x3high Blender axes.
coords=[v.co.copy() for v in obj.data.vertices]
lo=Vector(tuple(min(v[i] for v in coords) for i in range(3))); hi=Vector(tuple(max(v[i] for v in coords) for i in range(3)))
center=(lo+hi)/2; extent=hi-lo; goal=Vector((5,1.5,3))
for v in obj.data.vertices:
 v.co=Vector(tuple((v.co[i]-center[i])*goal[i]/extent[i] for i in range(3)))
bm=bmesh.new(); bm.from_mesh(obj.data); bmesh.ops.triangulate(bm,faces=list(bm.faces)); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(obj.data); bm.free()
for poly in obj.data.polygons: poly.use_smooth=True
mat=bpy.data.materials.new('Neutral_White_Review'); mat.diffuse_color=(.76,.8,.84,1); mat.use_nodes=True
bsdf=mat.node_tree.nodes.get('Principled BSDF'); bsdf.inputs['Base Color'].default_value=(.76,.8,.84,1); bsdf.inputs['Roughness'].default_value=.48
obj.data.materials.append(mat)
obj['stage']='MESH REVIEW ONLY - NOT APPROVED OR EXPORTED'; obj['travel_axis']='Blender -Y; Roblox -Z'; obj['roblox_dimensions']='5 x 3 x 1.5'
obj.data.calc_loop_triangles(); bm=bmesh.new(); bm.from_mesh(obj.data)
report={'triangles':len(obj.data.loop_triangles),'vertices':len(obj.data.vertices),'dimensions_blender':list(goal),'dimensions_roblox':[5,3,1.5],'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),'zero_area_faces':sum(f.calc_area()<1e-9 for f in bm.faces),'modifiers':len(obj.modifiers),'scale':list(obj.scale),'intentional_relief_shells':7}
bm.free(); assert report['triangles']<=1500 and report['nonmanifold_edges']==0 and report['zero_area_faces']==0,report
(OUT/'validation.json').write_text(json.dumps(report,indent=2))
# Render-only review collection. Asset remains a single mesh object.
review=bpy.data.collections.new('REVIEW_ONLY');scene.collection.children.link(review)
def move_review(o):
 for c in list(o.users_collection): c.objects.unlink(o)
 review.objects.link(o)
scene.render.engine='CYCLES'; scene.cycles.samples=24
scene.render.resolution_x=640; scene.render.resolution_y=640; scene.render.resolution_percentage=100
scene.world=bpy.data.worlds.new('ReviewWorld'); scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.13,.17,.22,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.5
for name,loc,energy,size in [('Key',(1,-5,7),850,5),('Fill',(-5,-2,3),550,4),('Rim',(3,4,5),900,4)]:
 data=bpy.data.lights.new(name,'AREA');o=bpy.data.objects.new(name,data);review.objects.link(o);o.location=loc;data.energy=energy;data.shape='DISK';data.size=size;o.rotation_euler=(Vector((0,0,0))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-1.52));floor=bpy.context.object;floor.name='ReviewFloor';move_review(floor)
fmat=bpy.data.materials.new('ReviewFloor');fmat.diffuse_color=(.12,.16,.2,1);floor.data.materials.append(fmat)
camdata=bpy.data.cameras.new('ReviewCamera');cam=bpy.data.objects.new('ReviewCamera',camdata);review.objects.link(cam);scene.camera=cam;camdata.type='ORTHO';camdata.ortho_scale=7
# 5-stud scale guide, segmented R15-proportion block mannequin, not an authored rig.
def cube(name,loc,scale):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.scale=scale;move_review(o)
 return o
for name,loc,scale in [('GuideHead',(3.55,.4,2.98),(.75,.65,.75)),('GuideTorso',(3.55,.4,1.78),(1.05,.55,1.55)),('GuideLegL',(3.25,.4,-.36),(.42,.48,2.24)),('GuideLegR',(3.85,.4,-.36),(.42,.48,2.24)),('GuideArmL',(2.85,.4,1.68),(.35,.45,1.55)),('GuideArmR',(4.25,.4,1.68),(.35,.45,1.55))]:
 cube(name,loc,scale)
# Hide guide except scale plate.
guide=[o for o in review.objects if o.name.startswith('Guide')]
for o in guide:o.hide_render=True
def render(name,loc,target=(0,0,0),ortho=7):
 cam.location=loc;cam.rotation_euler=(Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler();camdata.ortho_scale=ortho;scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
render('front',(0,-8,1.8));render('side',(8,-.3,1.8));render('angle',(6,-8,4))
for o in guide:o.hide_render=False
render('scale',(8,-12,6),(1,0,.8),9)
for o in guide:o.hide_render=True
obj.scale=(1.2,1,.8);render('squash',(6,-8,4));obj.scale=(.8,1,1.2);render('stretch',(6,-8,4));obj.scale=(1,1,1)
# Save clean neutral review with angle camera; no file export.
cam.location=(6,-8,4);cam.rotation_euler=(-cam.location).to_track_quat('-Z','Y').to_euler()
for o in bpy.context.selected_objects:o.select_set(False)
obj.select_set(True);bpy.context.view_layer.objects.active=obj
bpy.ops.wm.save_as_mainfile(filepath=str(TARGET))
print('WAVE_REPORT',json.dumps(report))
