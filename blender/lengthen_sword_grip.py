"""Lengthen a held sword's handle so two blocky R15 fists fit on it (owner: two-handed grip, 2026-10-28).
Run: Blender -b --factory-startup --python blender/lengthen_sword_grip.py -- <Template> [extra_studs]
Moves the pommel down by EXTRA and stretches the grip to match; blade and guard are untouched, the origin stays
at the upper grip (where the right fist sits). Saves the .blend in place after writing a .pre-grip backup once."""
import sys, shutil
from pathlib import Path
import bpy
import bmesh

ROOT = Path(r'C:\Users\Kobe\source\repos\bandit-eater')
args = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
TEMPLATE = args[0] if args else 'HeldSword'
EXTRA = float(args[1]) if len(args) > 1 else 1.0
path = ROOT / 'blender' / f'BE_{TEMPLATE}.blend'
backup = path.with_suffix('.pre-grip.blend')
if not backup.exists():
    shutil.copy2(path, backup)

bpy.ops.wm.open_mainfile(filepath=str(path))
obj = next(o for o in bpy.data.objects if o.type == 'MESH' and o.name.startswith(f'BE_{TEMPLATE}'))
me = obj.data
names = [m.name.split('.')[0] for m in me.materials]
grip_index = names.index('Grip')
pommel_index = names.index('Pommel')
bm = bmesh.new()
bm.from_mesh(me)
grip_verts, pommel_verts = set(), set()
for face in bm.faces:
    if face.material_index == grip_index:
        grip_verts.update(face.verts)
    elif face.material_index == pommel_index:
        pommel_verts.update(face.verts)
top = max(v.co.z for v in grip_verts)
bottom = min(v.co.z for v in grip_verts)
for v in pommel_verts - grip_verts:
    v.co.z -= EXTRA
for v in grip_verts:
    if v in pommel_verts:
        v.co.z -= EXTRA  # shared seam with the pommel
    else:
        # stretch the grip so its bottom meets the moved pommel; the top (under the guard) stays put
        v.co.z = top - (top - v.co.z) * (top - bottom + EXTRA) / (top - bottom)
bm.to_mesh(me)
bm.free()
me.update()
z = [v.co.z for v in me.vertices]
bpy.ops.wm.save_mainfile(filepath=str(path))
print(f'SUMMARY {TEMPLATE}: grip {round(bottom - EXTRA, 2)}..{round(top, 2)} (was {round(bottom, 2)}..{round(top, 2)}), overall {round(min(z), 2)}..{round(max(z), 2)}')
