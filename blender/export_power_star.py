"""Finish the approved mesh; run with Blender on BE_PowerStar_Bubbly.blend."""
import bpy
from pathlib import Path
root = Path(__file__).resolve().parents[1]
obj = bpy.context.scene.objects.get('BE_PowerStar_Bubbly_Body')
assert obj is not None, 'Open the approved BE_PowerStar_Bubbly.blend source'
bpy.ops.object.select_all(action='DESELECT')
obj.select_set(True)
bpy.context.view_layer.objects.active = obj
bpy.ops.export_scene.fbx(filepath=str(root/'blender/export/BE_PowerStarBubbly_Body.fbx'),
    use_selection=True, object_types={'MESH'}, axis_forward='-Z', axis_up='Y',
    bake_anim=False, add_leaf_bones=False)
print('Exported approved 1120-triangle Power Star. Normalize Roblox template to 2.8748038 x 2.7506738 x 1.14 studs.')
