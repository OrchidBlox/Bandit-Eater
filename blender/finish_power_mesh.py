"""Finish ONE approved mesh per invocation; preserve source and other live scenes.
Set MODEL to Droplet, Leaf, ShadowOrb, Flame, Wave, Sword or MasterSword, or to any new BE_<MODEL>.blend (Fx*, Held*).
"""
import bpy,json
from pathlib import Path
root=Path(r'C:\Users\Kobe\source\repos\bandit-eater')
model=globals().get('MODEL','Droplet')
sources={
 'Droplet':('BE_PowerDroplet.blend','BE_PowerDroplet'),
 'Leaf':('BE_PowerLeaf.blend','BE_PowerLeaf'),
 'ShadowOrb':('BE_PowerShadowOrb.blend','BE_PowerShadowOrb'),
 'Flame':('BE_PowerFlame.blend','Flame'),
 'Wave':('BE_PowerWave_color.blend','BE_PowerWave'),
 'Sword':('BE_PowerSword.blend','BE_PowerSword_Base'),
 'MasterSword':('BE_MasterSword.blend','BE_MasterSword_Base'),
}
filename,name=sources.get(model,(f'BE_{model}.blend',f'BE_{model}'))
with bpy.data.libraries.load(str(root/'blender'/filename),link=False) as (source,target):
    target.scenes=source.scenes[:1]
scene=target.scenes[0];bpy.context.window.scene=scene
obj=next(o for o in scene.objects if o.type=='MESH' and (o.name.startswith(name) or (name.startswith('BE_') and o.name.startswith(name[3:]))))
bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
if not model.startswith('Held'):  # held weapons keep their grip-centre origin
    bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY',center='BOUNDS');obj.location=(0,0,0)
materials=[m for m in obj.data.materials if m]
palette=model in {'Sword','MasterSword','Wave','ShadowOrb'} or len(materials)>1
mat=bpy.data.materials.new('BE_PowerMesh_'+model+'_Runtime');mat.use_nodes=True
bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bsdf.inputs['Roughness'].default_value=.55
bsdf.inputs['Base Color'].default_value=(1,1,1,1)
if palette:
    colors=[]
    for old in materials:
        node=next((n for n in old.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None) if old.use_nodes else None
        colors.append(tuple(node.inputs['Base Color'].default_value) if node else tuple(old.diffuse_color))
    uv=obj.data.uv_layers.active or obj.data.uv_layers.new(name='Palette')
    for polygon in obj.data.polygons:
        x=(min(polygon.material_index,len(colors)-1)+.5)/len(colors)
        for loop in polygon.loop_indices:uv.data[loop].uv=(x,.5)
    image=bpy.data.images.new('BE_PowerMesh_'+model+'_Color',width=len(colors)*8,height=8,alpha=True)
    image.pixels=[v for _ in range(8) for color in colors for _ in range(8) for v in color]
    image.filepath_raw=str(root/f'blender/export/textures/BE_PowerMesh_{model}_Color.png');image.file_format='PNG';image.save()
    node=mat.node_tree.nodes.new('ShaderNodeTexImage');node.image=image;node.interpolation='Closest'
    mat.node_tree.links.new(node.outputs['Color'],bsdf.inputs['Base Color'])
obj.data.materials.clear();obj.data.materials.append(mat)
for polygon in obj.data.polygons:polygon.material_index=0
obj.name='BE_PowerMesh_'+model
bpy.ops.export_scene.fbx(filepath=str(root/f'blender/export/BE_PowerMesh_{model}.fbx'),
 use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',bake_anim=False,
 add_leaf_bones=False,path_mode='COPY',embed_textures=True)
finished=root/'blender/finished';finished.mkdir(exist_ok=True)
bpy.data.libraries.write(str(finished/f'BE_PowerMesh_{model}.blend'),{scene},fake_user=True)
obj.data.calc_loop_triangles()
report={'model':model,'triangles':len(obj.data.loop_triangles),'materials':len(obj.data.materials),
 'dimensions_blender':list(obj.dimensions),'palette':palette,'exported':True}
(root/f'blender/review/BE_PowerMesh_{model}_export.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report))
