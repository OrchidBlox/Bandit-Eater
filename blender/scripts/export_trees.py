"""Finish the approved tree set through the existing validated static FBX pipeline.
Execute in live Blender; no source file is opened and approved geometry is untouched.
"""
import bpy
import importlib.util
from pathlib import Path
import sys

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater\blender')
spec=importlib.util.spec_from_file_location('be_static_export_pipeline',ROOT/'scripts'/'export_cliffs_rocks.py')
pipeline=importlib.util.module_from_spec(spec)
before_import=(bpy.data.filepath,len(bpy.data.objects))
old_bytecode=sys.dont_write_bytecode
sys.dont_write_bytecode=True
try:
    spec.loader.exec_module(pipeline)
finally:
    sys.dont_write_bytecode=old_bytecode
assert before_import==(bpy.data.filepath,len(bpy.data.objects)),'Import unexpectedly modified Blender'

pipeline.main(
    names=['TreeRoundA','TreeRoundB','TreeRoundC'],
    parts=['LeafBase_6FAE4A','LeafShade_4C8A3A','TrunkBase_7A5236','TrunkShade_62412C'],
    colors=['#6FAE4A','#4C8A3A','#7A5236','#62412C'],
    source_path=ROOT/'BE_Nature_Trees_mesh.blend',
    finish_path=ROOT/'BE_Nature_Trees_finish.blend',
    report_path=ROOT/'review'/'BE_Nature_Trees_export.validation.json',
    temp_path=ROOT/'.codex-tmp'/'trees-finish',
    scene_name='EXPORT_Trees_Approved',
    expected_sizes={'BE_Nature_TreeRoundA':(22,27,20),
                    'BE_Nature_TreeRoundB':(20,25,18),
                    'BE_Nature_TreeRoundC':(24,29,22)},
    expected_triangles=194,
    resume=globals().get('BE_TREE_RESUME',False),
)
