"""Finish the owner-approved bushes/flowers through the validated static pipeline."""
import bpy
import importlib.util
from pathlib import Path
import sys

ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater\blender')
spec = importlib.util.spec_from_file_location('be_static_export_pipeline', ROOT/'scripts'/'export_cliffs_rocks.py')
pipeline = importlib.util.module_from_spec(spec)
old_bytecode = sys.dont_write_bytecode
sys.dont_write_bytecode = True
try:
    spec.loader.exec_module(pipeline)
finally:
    sys.dont_write_bytecode = old_bytecode

for names, parts, colors, label in [
    (['BushA', 'BushB'], ['Base_6FAE4A', 'Shade_4C8A3A'], ['#6FAE4A', '#4C8A3A'], 'Bushes'),
    (['FlowerClump'], ['Stem_4C8A3A', 'Petal_F2E7CC'], ['#4C8A3A', '#F2E7CC'], 'Flowers'),
]:
    sizes = {'BE_Nature_BushA': (4, 2, 3), 'BE_Nature_BushB': (5, 2.4, 4),
             'BE_Nature_FlowerClump': (2, 1.2, 2)}
    pipeline.main(
        names=names, parts=parts, colors=colors,
        source_path=ROOT/'BE_Nature_Undergrowth_mesh.blend',
        finish_path=ROOT/'BE_Nature_Undergrowth_finish.blend',
        report_path=ROOT/'review'/('BE_Nature_'+label+'_export.validation.json'),
        temp_path=ROOT/'.codex-tmp'/'undergrowth-finish',
        scene_name='EXPORT_Undergrowth_Approved', expected_sizes=sizes,
        expected_triangles=60, resume=globals().get('BE_UNDERGROWTH_RESUME', False),
    )
