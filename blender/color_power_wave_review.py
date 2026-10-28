import bpy,bmesh,json
from pathlib import Path
from mathutils import Vector
ROOT=Path(r"C:\Users\Kobe\source\repos\bandit-eater")
SOURCE=ROOT/'blender'/'BE_PowerWave.blend'
OUT=ROOT/'blender'/'previews'/'BE_PowerWave_color';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
scene=bpy.context.scene
obj=bpy.data.objects['BE_PowerWave']
# Mesh has one420-vertex body shell and seven42-vertex intentional foam relief shells.
mesh=obj.data
adj={v.index:set() for v in mesh.vertices}
for e in mesh.edges:
 a,b=e.vertices;adj[a].add(b);adj[b].add(a)
unseen=set(adj);shells=[]
while unseen:
 stack=[unseen.pop()];shell=set(stack)
 while stack:
  for j in adj[stack.pop()]:
   if j in unseen: unseen.remove(j);shell.add(j);stack.append(j)
 shells.append(shell)
shells.sort(key=len,reverse=True)
assert len(shells)==8 and len(shells[0])==420,[len(s) for s in shells]
for name,color in [('Water_Body',(0.0497,0.4678,1,1)),('Water_Foam',(0.913,0.965,1,1))]:
 mat=bpy.data.materials.new(name);mat.diffuse_color=color;mat.use_nodes=True
 bsdf=mat.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Base Color'].default_value=color;bsdf.inputs['Roughness'].default_value=.42
 mesh.materials.append(mat)
body=shells[0]
for face in mesh.polygons:face.material_index=1 if face.vertices[0] in body else 2
scene.render.resolution_x=640;scene.render.resolution_y=640;scene.cycles.samples=24
cam=scene.camera
for name,loc in [('front',(0,-8,1.8)),('angle',(6,-8,4)),('side',(8,-.3,1.8))]:
 cam.location=loc;cam.rotation_euler=(-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=7
 scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
cam.location=(6,-8,4);cam.rotation_euler=(-cam.location).to_track_quat('-Z','Y').to_euler()
obj['stage']='COLOR MESH PREVIEW ONLY - NO EXPORT';obj['material_note']='Water body and white foam. Geometry unchanged from neutral review.'
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'blender'/'BE_PowerWave_color.blend'))
print('COLOR_SHELLS', [len(s) for s in shells])
