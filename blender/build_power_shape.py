"""One small VFX mesh per invocation. Set MODEL to Droplet, Leaf or ShadowOrb."""
import bpy, math
from pathlib import Path
from mathutils import Vector
root=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
model=globals().get('MODEL','Droplet')
reference=next(s for s in bpy.data.scenes if s.camera and 'Wind' in s.name)
scene=bpy.data.scenes.new('BE_Power'+model+'_Review');bpy.context.window.scene=scene
for o in reference.objects:
    if o.type in {'CAMERA','LIGHT'}:
        c=o.copy();c.data=o.data.copy();scene.collection.objects.link(c)
        if c.type=='CAMERA':scene.camera=c
scene.world=reference.world.copy()
def material(name,color):
    m=bpy.data.materials.new(name);m.use_nodes=True
    n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    n.inputs['Base Color'].default_value=(*color,1);n.inputs['Roughness'].default_value=.4
    return m
colors={'Droplet':(.1,.55,1),'Leaf':(.25,.7,.15),'ShadowOrb':(.45,.12,.75)}
mat=material('BE_'+model,colors[model])
bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,radius=1)
body=bpy.context.object;body.name='BE_Power'+model
for v in body.data.vertices:
    x,y,z=v.co
    if model=='Droplet':
        k=1-.72*max(0,z);v.co=(x*k,y*k*.72,z*(1.7 if z>0 else 1))
    elif model=='Leaf':
        k=1-.3*abs(z);v.co=(x*k*.65,y*.13+.09*z*z,z*1.35)
body.data.materials.append(mat)
for f in body.data.polygons:f.use_smooth=True
if model=='ShadowOrb':
    verts=[];faces=[];rings=24;sides=8
    for j in range(rings+1):
        a=-math.pi*.78+j/rings*math.pi*1.56
        for k in range(sides):
            b=k*math.tau/sides;r=1.08+.18*math.cos(b)
            verts.append((math.cos(a)*r,-.66+math.sin(b)*.18,math.sin(a)*r))
    for j in range(rings):
        for k in range(sides):faces.append((j*sides+k,j*sides+(k+1)%sides,(j+1)*sides+(k+1)%sides,(j+1)*sides+k))
    faces += [tuple(reversed(range(sides))),tuple(rings*sides+k for k in range(sides))]
    mesh=bpy.data.meshes.new('Crescent');mesh.from_pydata(verts,[],faces);mesh.update()
    ob=bpy.data.objects.new('Crescent',mesh);scene.collection.objects.link(ob);mesh.materials.append(material('ShadowHighlight',(.75,.45,1)))
    for f in mesh.polygons:f.use_smooth=True
    ob.select_set(True);body.select_set(True);bpy.context.view_layer.objects.active=body;bpy.ops.object.join()
body.data.calc_loop_triangles();assert len(body.data.loop_triangles)<1500
scene.render.engine='CYCLES';scene.cycles.samples=24
scene.render.resolution_x=350;scene.render.resolution_y=400;scene.render.resolution_percentage=100
scene.camera.data.ortho_scale=3.8
for label,pos in [('Front',(0,-7,.3)),('Angle',(3,-7,2))]:
    scene.camera.location=pos;scene.camera.rotation_euler=(Vector((0,0,.3))-scene.camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(root/f'blender/review/BE_Power{model}_{label}.png');bpy.ops.render.render(write_still=True)
bpy.data.libraries.write(str(root/f'blender/BE_Power{model}.blend'),{scene},fake_user=True)
print(model,len(body.data.loop_triangles),'triangles, mesh review only')
