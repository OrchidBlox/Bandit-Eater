"""Mesh-stage Power Star. Execute in Blender; preserves existing scenes."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector

ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
scene = bpy.data.scenes.new('BE_PowerStar_Review')
bpy.context.window.scene = scene
verts = []
for y in (-.35, .35):
    for i in range(10):
        a = math.pi / 2 + i * math.pi / 5
        r = 1.5 if i % 2 == 0 else .78
        verts.append((math.cos(a)*r, y, math.sin(a)*r))
faces = [tuple(reversed(range(10))), tuple(range(10,20))]
faces += [(i, (i+1)%10, (i+1)%10+10, i+10) for i in range(10)]
mesh = bpy.data.meshes.new('BE_PowerStar_Body')
mesh.from_pydata(verts, [], faces); mesh.update()
obj = bpy.data.objects.new('BE_PowerStar_Body', mesh)
scene.collection.objects.link(obj)
bpy.context.view_layer.objects.active = obj; obj.select_set(True)
bevel = obj.modifiers.new('Soft chunky edges','BEVEL'); bevel.width=.13; bevel.segments=3
bpy.ops.object.modifier_apply(modifier=bevel.name)
mat = bpy.data.materials.new('BE_PowerStar_Gold'); mat.diffuse_color=(1,.65,.12,1)
mat.use_nodes=True
bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
bsdf.inputs['Base Color'].default_value=(1,.65,.12,1); bsdf.inputs['Roughness'].default_value=.55
obj.data.materials.append(mat)
mesh=obj.data; mesh.calc_loop_triangles()
assert len(mesh.loop_triangles)<1500
scene.render.engine='CYCLES'; scene.cycles.samples=24
scene.render.resolution_x=480; scene.render.resolution_y=480; scene.render.resolution_percentage=100
scene.world=bpy.data.worlds.new('BE_PowerStar_World'); scene.world.use_nodes=True
next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND').inputs[0].default_value=(.12,.15,.20,1)
for name,location,power,size in [('Key',(-3,-4,5),650,5),('Fill',(4,-2,2),400,4),('Rim',(1,3,4),700,3)]:
    data=bpy.data.lights.new(name,'AREA'); data.energy=power; data.shape='DISK'; data.size=size
    light=bpy.data.objects.new('BE_PowerStar_'+name,data); scene.collection.objects.link(light); light.location=location
    light.rotation_euler=(Vector((0,0,0))-light.location).to_track_quat('-Z','Y').to_euler()
data=bpy.data.cameras.new('BE_PowerStar_Camera'); camera=bpy.data.objects.new(data.name,data)
scene.collection.objects.link(camera); scene.camera=camera; data.type='ORTHO'; data.ortho_scale=3.9
review=ROOT/'blender/review'; review.mkdir(exist_ok=True)
for label,position in [('Front',(0,-7,0)),('Angle',(4,-7,2)),('Side',(7,-.2,0))]:
    camera.location=position; camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(review/f'BE_PowerStar_{label}.png'); bpy.ops.render.render(write_still=True)
camera.location=(4,-7,2); camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler()
bpy.data.libraries.write(str(ROOT/'blender/BE_PowerStar.blend'),{scene},fake_user=True)
(review/'BE_PowerStar_validation.json').write_text(json.dumps({'triangles':len(mesh.loop_triangles),'dimensions':list(obj.dimensions),'stage':'mesh-review','exported':False},indent=2))
print('Power Star mesh saved; triangles:',len(mesh.loop_triangles))
