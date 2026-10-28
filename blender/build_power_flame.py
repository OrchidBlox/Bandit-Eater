"""One mesh-stage chunky three-lobed flame. Headless only; no export or upload."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(r'C:/Users/Kobe/source/repos/bandit-eater')
scene=bpy.data.scenes.new('BE_PowerFlame_MeshStage')
bpy.context.window.scene=scene
# Asymmetrical rounded three-lobed outline, clockwise, with broad rounded base.
control=[(0,.02),(-.5,.04),(-.85,.23),(-1,.58),(-.92,.98),(-.8,1.33),(-.66,1.57),(-.48,1.54),(-.35,1.28),(-.25,1.62),(-.1,2.1),(.12,2.38),(.28,2.28),(.3,1.9),(.43,1.6),(.55,1.78),(.73,1.91),(.9,1.7),(1,1.28),(.94,.88),(.86,.46),(.61,.15)]
def cr(p0,p1,p2,p3,t):
 return .5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t)
outline=[]
for i in range(len(control)):
 ps=[Vector(control[j%len(control)]) for j in (i-1,i,i+1,i+2)]
 for k in range(3):outline.append(cr(*ps,k/3))
center=Vector((0,1.05));N=len(outline);verts=[]
# Seven contour rings; front/back domed faces keep silhouette fat, not flat.
for j in range(1,8):
 a=-math.pi/2+j*math.pi/8;scale=math.cos(a);depth=.65*math.sin(a)
 for p in outline:
  q=center+(p-center)*scale;verts.append((q.x,depth,q.y))
faces=[]
for j in range(6):
 for i in range(N):
  a=j*N+i;b=j*N+(i+1)%N;c=(j+1)*N+(i+1)%N;d=(j+1)*N+i
  faces.append((a,b,c,d))
for ring,depth,reverse in [(0,-.65,True),(6,.65,False)]:
 cap=len(verts);verts.append((center.x,depth,center.y))
 for i in range(N):
  a=ring*N+i;b=ring*N+(i+1)%N
  faces.append((cap,b,a) if reverse else (cap,a,b))
mesh=bpy.data.meshes.new('Flame');mesh.from_pydata(verts,[],faces);mesh.update()
obj=bpy.data.objects.new('Flame',mesh);scene.collection.objects.link(obj)
# Normalize exact final Roblox dimensions X/Y/Z via Blender X/Z/Y, center origin.
lo=Vector(tuple(min(v.co[k] for v in mesh.vertices) for k in range(3)));hi=Vector(tuple(max(v.co[k] for v in mesh.vertices) for k in range(3)));mid=(lo+hi)/2
size=hi-lo;desired=Vector((2,1.3,2.4))
for v in mesh.vertices:v.co=Vector(tuple((v.co[k]-mid[k])*desired[k]/size[k] for k in range(3)))
import bmesh
bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(mesh);bm.free()
# Round the concave crown valleys; avoid radial fan pinching on the hero face.
bpy.context.view_layer.objects.active=obj;obj.select_set(True)
m=obj.modifiers.new('RoundVolume','REMESH');m.mode='VOXEL';m.voxel_size=.065;m.use_smooth_shade=True
bpy.ops.object.modifier_apply(modifier=m.name)
m=obj.modifiers.new('SoftValleys','SMOOTH');m.factor=.7;m.iterations=6
bpy.ops.object.modifier_apply(modifier=m.name)
obj.data.calc_loop_triangles();m=obj.modifiers.new('PhoneBudget','DECIMATE');m.ratio=min(1,1250/len(obj.data.loop_triangles))
bpy.ops.object.modifier_apply(modifier=m.name)
mesh=obj.data
lo=Vector(tuple(min(v.co[k] for v in mesh.vertices) for k in range(3)));hi=Vector(tuple(max(v.co[k] for v in mesh.vertices) for k in range(3)));mid=(lo+hi)/2;size=hi-lo
for v in mesh.vertices:v.co=Vector(tuple((v.co[k]-mid[k])*desired[k]/size[k] for k in range(3)))
for p in mesh.polygons:p.use_smooth=True
mat=bpy.data.materials.new('NeutralMeshStage');mat.diffuse_color=(.72,.74,.77,1);obj.data.materials.append(mat)
scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='SINGLE';scene.display.shading.single_color=(.72,.74,.77)
scene.display.shading.show_shadows=True;scene.display.shading.show_cavity=True
scene.render.resolution_x=800;scene.render.resolution_y=800;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.film_transparent=True
camdata=bpy.data.cameras.new('FlameReview');cam=bpy.data.objects.new('FlameReview',camdata);scene.collection.objects.link(cam);scene.camera=cam;camdata.type='ORTHO';camdata.ortho_scale=3.1
review=ROOT/'blender/review';review.mkdir(exist_ok=True)
for name,position in [('Front',(0,-8,.1)),('Angle',(4,-7,2.6))]:
 cam.location=position;cam.rotation_euler=(-cam.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(review/f'BE_PowerFlame_{name}.png');bpy.ops.render.render(write_still=True)
mesh.calc_loop_triangles();bm=bmesh.new();bm.from_mesh(mesh)
report={'mesh_stage_only':True,'triangles':len(mesh.loop_triangles),'dimensions_blender':[round(x,5) for x in obj.dimensions],'dimensions_roblox':[2,2.4,1.3],'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),'objects':1,'modifiers':len(obj.modifiers),'source':'BE_PowerFlame.blend','exported':False,'uploaded':False}
bm.free();assert report['triangles']<1500;assert report['nonmanifold_edges']==0
(review/'BE_PowerFlame.validation.json').write_text(json.dumps(report,indent=2))
bpy.data.libraries.write(str(ROOT/'blender/BE_PowerFlame.blend'),{scene},fake_user=True,compress=True)
print(json.dumps(report))
