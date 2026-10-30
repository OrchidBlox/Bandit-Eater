"""Lumpy chunky boulder for Earth E Stone Field (replaces Codex's slab). Run headless:
Blender -b --factory-startup --python blender/build_fx_stone.py
Roblox size 3.4 x 5 x 3.2 (X, Y up, Z), flat bottom, 11 big irregular facets, seeded so it always builds the same stone.
Saves blender/BE_FxStoneTall.blend (object BE_FxStoneTall, one neutral material)."""
import bmesh
import bpy
import math
import random
from mathutils import Vector

random.seed(7)
bpy.ops.wm.read_factory_settings(use_empty=True)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=1, radius=1.0)  # 80 triangles: big facets
for v in bm.verts:
    n = v.co.normalized()
    # lumpy outline: random push per vertex, a lean, a fatter base than top
    push = 1.0 + random.uniform(-0.22, 0.28)
    v.co = n * push
    v.co.x *= 1.0 + 0.1 * math.sin(v.co.z * 2.3)
    v.co.x += 0.18 * v.co.z  # lean
    taper = 1.12 - 0.22 * (v.co.z + 1) / 2
    v.co.x *= taper
    v.co.y *= taper
bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.05, segments=1, affect='EDGES')
me = bpy.data.meshes.new('BE_FxStoneTall')
bm.to_mesh(me)
bm.free()
obj = bpy.data.objects.new('BE_FxStoneTall', me)
bpy.context.scene.collection.objects.link(obj)
bpy.context.view_layer.objects.active = obj
obj.select_set(True)

# Fit to 3.4 (X) x 3.2 (Y depth) x 5 (Z up), flat buried bottom.
xs, ys, zs = [v.co.x for v in me.vertices], [v.co.y for v in me.vertices], [v.co.z for v in me.vertices]
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
for v in me.vertices:
    v.co.x = (v.co.x - (max(xs) + min(xs)) / 2) / (max(xs) - min(xs)) * 3.4
    v.co.y = (v.co.y - (max(ys) + min(ys)) / 2) / (max(ys) - min(ys)) * 3.2
    v.co.z = (v.co.z - min(zs)) / (max(zs) - min(zs)) * 5.0
for v in me.vertices:
    if v.co.z < 0.45:
        v.co.z = 0.0  # flatten the bottom so it sits half buried
for p in me.polygons:
    p.use_smooth = False
mat = bpy.data.materials.new('Stone')
mat.use_nodes = True
next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED').inputs['Base Color'].default_value = (1, 1, 1, 1)
me.materials.append(mat)
bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
obj.location = (0, 0, 0)
me.calc_loop_triangles()
print('SUMMARY stone', [round(d, 2) for d in obj.dimensions], len(me.loop_triangles), 'tris')
bpy.ops.wm.save_as_mainfile(filepath=r'C:\Users\Kobe\source\repos\bandit-eater\blender\BE_FxStoneTall.blend')

# Quick review render (front and three-quarter) to blender/review.
scene = bpy.context.scene
scene.render.engine = 'BLENDER_WORKBENCH'
scene.display.shading.light = 'STUDIO'
scene.display.shading.color_type = 'SINGLE'
scene.display.shading.single_color = (0.78, 0.74, 0.68)
scene.render.resolution_x, scene.render.resolution_y = 700, 420
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam'))
scene.collection.objects.link(cam)
scene.camera = cam
cam.data.type = 'ORTHO'
cam.data.ortho_scale = 8.5
for name, loc in (('front', (0, -12, 0)), ('tq', (8, -9, 6))):
    cam.location = Vector(loc)
    cam.rotation_euler = (Vector((0, 0, 0)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
    scene.render.filepath = rf'C:\Users\Kobe\source\repos\bandit-eater\.codex-tmp\stone_{name}.png'
    bpy.ops.render.render(write_still=True)
