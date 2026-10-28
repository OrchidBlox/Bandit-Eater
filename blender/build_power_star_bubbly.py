"""Bubbly silhouette revision, isolated from the approved V1 source."""
import bpy, math, bmesh, json
from pathlib import Path
from mathutils import Vector
root=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
old=bpy.context.scene
scene=bpy.data.scenes.new('BE_PowerStar_Bubbly_Review')
bpy.context.window.scene=scene
for item in old.objects:
    if item.type in {'CAMERA','LIGHT'}:
        clone=item.copy(); clone.data=item.data.copy(); scene.collection.objects.link(clone)
        if clone.type=='CAMERA': scene.camera=clone
scene.world=old.world.copy()
contour=[]
for i in range(10):
    a=math.pi/2+i*math.pi/5; r=1.5 if i%2==0 else .82
    contour.append(Vector((math.cos(a)*r,math.sin(a)*r)))
# Corner cutting rounds the outline itself, not only the extrusion edges.
for _ in range(3):
    contour=[q for i,a in enumerate(contour) for q in (a*.75+contour[(i+1)%len(contour)]*.25,a*.25+contour[(i+1)%len(contour)]*.75)]
factor=1.5/max(p.y for p in contour)
contour=[p*factor for p in contour]
n=len(contour); verts=[]; faces=[]
# One continuous inflated surface with a wide nearly-flat emblem center.
rings=[(.42,-.56),(.78,-.49),(.96,-.29),(1,0),(.96,.29),(.78,.49),(.42,.56)]
for scale,depth in rings:
    verts.extend([(p.x*scale,depth,p.y*scale) for p in contour])
for j in range(len(rings)-1):
    for i in range(n): faces.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
for ring,depth in [(0,-.57),(len(rings)-1,.57)]:
    center=len(verts); verts.append((0,depth,0))
    for i in range(n): faces.append((center,ring*n+i,ring*n+(i+1)%n))
mesh=bpy.data.meshes.new('BE_PowerStar_Bubbly_Body');mesh.from_pydata(verts,[],faces);mesh.update()
bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj)
for p in mesh.polygons:p.use_smooth=True
mat=bpy.data.materials.new('BE_PowerStar_Bubbly_Gold');mat.use_nodes=True
node=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
node.inputs['Base Color'].default_value=(1,.62,.08,1);node.inputs['Roughness'].default_value=.4
mesh.materials.append(mat);mesh.calc_loop_triangles()
assert len(mesh.loop_triangles)<=1500
scene.render.engine='CYCLES';scene.cycles.samples=32
scene.render.resolution_x=400;scene.render.resolution_y=400;scene.render.resolution_percentage=100
camera=scene.camera;camera.data.ortho_scale=3.9
for label,pos in [('Front',(0,-7,0)),('Angle',(4,-7,2)),('Side',(7,-.2,0))]:
    camera.location=pos;camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(root/f'blender/review/BE_PowerStar_Bubbly_{label}.png')
    bpy.ops.render.render(write_still=True)
camera.location=(4,-7,2);camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler()
bpy.data.libraries.write(str(root/'blender/BE_PowerStar_Bubbly.blend'),{scene},fake_user=True)
(root/'blender/review/BE_PowerStar_Bubbly_validation.json').write_text(json.dumps({'triangles':len(mesh.loop_triangles),'stage':'mesh-review','previous_source_preserved':True},indent=2))
print('Bubbly star saved:',len(mesh.loop_triangles),'triangles')
