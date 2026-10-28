import bpy, math, bmesh
from pathlib import Path
from mathutils import Vector
root=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
old=bpy.context.scene
scene=bpy.data.scenes.new('BE_WindFront_Review');bpy.context.window.scene=scene
for item in old.objects:
    if item.type in {'CAMERA','LIGHT'}:
        clone=item.copy();clone.data=item.data.copy();scene.collection.objects.link(clone)
        if clone.type=='CAMERA':scene.camera=clone
scene.world=old.world.copy()
verts=[];faces=[];steps=40;sides=12
for j in range(steps+1):
    t=j/steps; x=(t-.5)*5; z=.85*math.cos((t-.5)*math.pi)
    radius=.06+.36*math.sin(math.pi*t)**.35
    for k in range(sides):
        a=k*math.tau/sides;verts.append((x,math.sin(a)*radius*.7,z+math.cos(a)*radius))
for j in range(steps):
    for k in range(sides):faces.append((j*sides+k,j*sides+(k+1)%sides,(j+1)*sides+(k+1)%sides,(j+1)*sides+k))
faces.extend([tuple(reversed(range(sides))),tuple(steps*sides+k for k in range(sides))])
mesh=bpy.data.meshes.new('BE_WindFront');mesh.from_pydata(verts,[],faces);mesh.update()
bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
for p in mesh.polygons:p.use_smooth=True
obj=bpy.data.objects.new('BE_WindFront',mesh);scene.collection.objects.link(obj)
mat=bpy.data.materials.new('BE_WindFront_Mint');mat.use_nodes=True
node=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');node.inputs['Base Color'].default_value=(.25,.9,.66,1);node.inputs['Roughness'].default_value=.45;mesh.materials.append(mat)
scene.render.engine='CYCLES';scene.cycles.samples=24
scene.render.resolution_x=480;scene.render.resolution_y=320;scene.render.resolution_percentage=100
camera=scene.camera;camera.data.ortho_scale=6.2
for label,pos in [('Front',(0,-8,.6)),('Angle',(3,-8,3))]:
    camera.location=pos;camera.rotation_euler=(Vector((0,0,.6))-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(root/f'blender/review/BE_WindFront_{label}.png');bpy.ops.render.render(write_still=True)
bpy.data.libraries.write(str(root/'blender/BE_WindFront.blend'),{scene},fake_user=True)
mesh.calc_loop_triangles();print('Wind Front mesh saved',len(mesh.loop_triangles),'triangles')
