"""Shared steps for building a model from a base .blend, so a Codex run (or you)
does not re-write them every time.

Use it when several models share one rigged base file: variants, skins, a
family of props or characters. The base keeps the shape, rig and animations;
each model changes only the look. The per-model script then supplies only what
is unique (colours, details) and calls this module for everything else. Copy
this file to the repo as it is; never edit it per model, fix it here.

Run inside Blender (the Blender MCP's execute_blender_code, or `blender -b`):

    import sys; sys.path.insert(0, r'<repo>\\blender')
    import model_tools as mt
    m = mt.Model('Shop_Crate',                       # prefix of every object, material and collection
                 parts=['Body', 'Trim'],             # meshes that are exported (suffixes)
                 rig='Rig',                          # armature suffix, or None for static props
                 actions=['Idle', 'Open'],           # actions that must survive unchanged
                 bones=19)                           # bone count to protect, or None
    m.snapshot_base()                                # BEFORE any change
    m.recolor({'Paint': 'A3161E', 'Metal': 'C29A52'})
    ...                                              # model-specific work (add details to the high-detail collection)
    m.bake()                                         # Color + OpenGL Normal onto <prefix>_Body
    m.validate_export()                              # checks the base is untouched, exports the FBX
    m.preview([...])                                 # review images + one composite, saves the .blend

Every step prints one SUMMARY line and raises an AssertionError with a clear
message on failure. Nothing else prints.

Conventions it relies on (set them up in the base file):
  objects     <prefix>_<part> for each exported part and <prefix>_<rig>
  collection  <prefix>_HighDetail: hidden, holds the detailed meshes the bake reads
  material    <prefix>_Body has two Image Texture nodes labelled "Color" and "Normal" (the bake targets)
  materials   <prefix>_<name> for each name passed to recolor()
Everything is for Roblox: 1 unit = 1 stud, FBX Forward -Y / Up Z, matte
(no emission, no metallic), normals are OpenGL.
"""

import bpy
import contextlib
import hashlib
import io
import json
import os
from mathutils import Vector

DEFAULT_ROOT = os.path.dirname(os.path.abspath(__file__))


def srgb(hex_colour):
    """'A3161E' -> a linear RGBA tuple for Blender."""
    c = [int(hex_colour[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in c) + (1,)


def digest(x):
    return hashlib.sha256(repr(x).encode()).hexdigest()


class Model:
    def __init__(self, name, parts, rig='Rig', actions=(), bones=None, root=DEFAULT_ROOT,
                 base_file=None, bake_exclude=()):
        self.P = name
        self.parts = list(parts)
        self.rig = rig
        self.actions = list(actions)
        self.bones = bones
        self.root = root
        self.out = os.path.join(root, 'export')
        self.tex = os.path.join(self.out, 'textures')
        self.state_path = os.path.join(root, name + '_Validation.json')
        self.base_file = base_file
        self.bake_exclude = tuple(bake_exclude)  # suffixes of high-detail meshes the bake must skip
        os.makedirs(self.tex, exist_ok=True)

    # ---- helpers ---------------------------------------------------------
    def obj(self, suffix):
        return bpy.data.objects[self.P + '_' + suffix]

    def show(self, o, shown=True):
        o.hide_set(not shown)
        o.hide_viewport = not shown
        o.hide_render = not shown

    def _sha(self, path):
        with open(path, 'rb') as f:
            return hashlib.sha256(f.read()).hexdigest()

    def fingerprint(self):
        """Hashes of everything the shared animations depend on."""
        result = {}
        for suffix in self.parts:
            o = self.obj(suffix)
            result[suffix] = digest((
                [(tuple(v.co), [(g.group, g.weight) for g in v.groups]) for v in o.data.vertices],
                [tuple(f.vertices) for f in o.data.polygons],
                [tuple(l.uv) for uv in o.data.uv_layers for l in uv.data],
                [g.name for g in o.vertex_groups],
                [tuple(r) for r in o.matrix_world],
            ))
        if self.rig:
            rig = self.obj(self.rig)
            result['rig'] = digest([(b.name, b.parent.name if b.parent else None,
                                     [tuple(r) for r in b.matrix_local], b.length) for b in rig.data.bones])
            actions = []
            for a in bpy.data.actions:
                curves = []
                for layer in a.layers:
                    for strip in layer.strips:
                        for bag in strip.channelbags:
                            for f in bag.fcurves:
                                curves.append((f.data_path, f.array_index, [
                                    (tuple(k.co), tuple(k.handle_left), tuple(k.handle_right), k.interpolation)
                                    for k in f.keyframe_points]))
                actions.append((a.name, curves))
            result['actions'] = digest(actions)
        return result

    # ---- 1. protect the base --------------------------------------------
    def snapshot_base(self):
        """Call once, before any change. validate_export() compares against it."""
        state = {'before': self.fingerprint()}
        if self.base_file:
            state['base_sha'] = self._sha(self.base_file)
        with open(self.state_path, 'w') as f:
            json.dump(state, f)
        print('SUMMARY: base snapshot saved.')

    # ---- 2. colours ------------------------------------------------------
    def recolor(self, colours, roughness=None, default_roughness=.5):
        """colours: {material suffix: hex}. Matte only: no metallic, no emission."""
        roughness = roughness or {}
        for suffix, hex_colour in colours.items():
            m = bpy.data.materials[self.P + '_' + suffix]
            c = srgb(hex_colour)
            m.diffuse_color = c
            n = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
            n.inputs['Base Color'].default_value = c
            n.inputs['Metallic'].default_value = 0
            n.inputs['Roughness'].default_value = roughness.get(suffix, default_roughness)
            n.inputs['Emission Color'].default_value = (0, 0, 0, 1)
            n.inputs['Emission Strength'].default_value = 0
        print('SUMMARY: recoloured', ', '.join(colours))

    # ---- 3. bake ---------------------------------------------------------
    def bake(self, samples=16, cage_extrusion=.085, max_ray_distance=.12, margin=12, size=1024):
        """Bakes the high-detail collection onto <prefix>_Body: Color (sRGB) and
        Normal (tangent, OpenGL) to export/textures/<prefix>_Color.png and _Normal.png.
        If the bake picks up nearby geometry (dark streaks), lower cage_extrusion and max_ray_distance."""
        scene = bpy.context.scene
        scene.render.engine = 'CYCLES'
        scene.cycles.samples = samples
        col = bpy.data.collections[self.P + '_HighDetail']
        col.hide_viewport = False
        col.hide_render = False
        bpy.ops.object.select_all(action='DESELECT')
        body = self.obj('Body')
        self.show(body)
        if self.rig:
            self.obj(self.rig).data.pose_position = 'REST'
        skip = tuple(self.P + '_' + s for s in self.bake_exclude)
        for o in col.objects:
            if o.type == 'MESH' and o.name not in skip:
                self.show(o)
                o.select_set(True)
        body.select_set(True)
        bpy.context.view_layer.objects.active = body
        b = scene.render.bake
        b.use_selected_to_active = True
        b.cage_extrusion = cage_extrusion
        b.max_ray_distance = max_ray_distance
        b.margin = margin
        b.use_pass_direct = False
        b.use_pass_indirect = False
        b.use_pass_color = True
        b.normal_space = 'TANGENT'
        b.normal_r, b.normal_g, b.normal_b = 'POS_X', 'POS_Y', 'POS_Z'  # OpenGL normals
        nt = body.data.materials[0].node_tree
        nodes = {n.label: n for n in nt.nodes if n.type == 'TEX_IMAGE'}
        assert 'Color' in nodes and 'Normal' in nodes, 'Body material needs image nodes labelled Color and Normal'
        for label, kind in (('Color', 'DIFFUSE'), ('Normal', 'NORMAL')):
            im = bpy.data.images.new(self.P + '_' + label, size, size, alpha=False)
            im.colorspace_settings.name = 'sRGB' if label == 'Color' else 'Non-Color'
            nodes[label].image = im
            for n in nt.nodes:
                n.select = False
            nodes[label].select = True
            nt.nodes.active = nodes[label]
            # Disconnect the Body's own normal input while baking normals.
            links = [l for l in nt.links if l.to_node.type == 'BSDF_PRINCIPLED' and l.to_socket.name == 'Normal']
            saved = [(l.from_socket, l.to_socket) for l in links]
            for l in links:
                nt.links.remove(l)
            bpy.ops.object.bake(type=kind)
            for a, z in saved:
                nt.links.new(a, z)
            im.filepath_raw = os.path.join(self.tex, self.P + '_' + label + '.png')
            im.file_format = 'PNG'
            im.save()
            assert os.path.getsize(im.filepath_raw) > 5000, label + ' texture came out empty'
        for o in col.objects:
            o.hide_set(True)
            o.hide_render = True
        col.hide_viewport = True
        col.hide_render = True
        print('SUMMARY: Color and OpenGL Normal baked at', size)

    # ---- 4. validate and export -----------------------------------------
    def validate_export(self, hide_after=()):
        """Checks nothing the animations depend on changed, then exports <prefix>_Base.fbx
        (the parts and the rig). hide_after: part suffixes to hide again afterwards."""
        with open(self.state_path) as f:
            state = json.load(f)
        after = self.fingerprint()
        changed = [k for k, v in state['before'].items() if after[k] != v]
        assert not changed, 'Protected base data changed: ' + str(changed)
        if self.base_file:
            assert self._sha(self.base_file) == state['base_sha'], 'the base file was modified'
        if self.rig and self.bones:
            assert len(self.obj(self.rig).data.bones) == self.bones, f'rig must keep its {self.bones} bones'
        assert all(bpy.data.actions.get(n) for n in self.actions), 'a protected action is missing'
        names = ([self.rig] if self.rig else []) + self.parts
        bpy.ops.object.select_all(action='DESELECT')
        for s in names:
            o = self.obj(s)
            o.hide_viewport = False
            o.hide_set(False)
            o.select_set(True)
        bpy.context.view_layer.objects.active = self.obj(names[0])
        if self.rig:
            self.obj(self.rig).data.pose_position = 'POSE'
        props = bpy.ops.export_scene.fbx.get_rna_type().properties
        for key, val in (('apply_scale_options', 'FBX_SCALE_ALL'), ('axis_forward', '-Y'),
                         ('axis_up', 'Z'), ('path_mode', 'AUTO')):
            assert val in [i.identifier for i in props[key].enum_items], key + ' value not supported by this Blender'
        path = os.path.join(self.out, self.P + '_Base.fbx')
        with contextlib.redirect_stdout(io.StringIO()):
            bpy.ops.export_scene.fbx(
                filepath=path, use_selection=True, object_types={'ARMATURE', 'MESH'},
                apply_scale_options='FBX_SCALE_ALL', axis_forward='-Y', axis_up='Z', apply_unit_scale=True,
                add_leaf_bones=False, bake_anim=True, bake_anim_use_all_actions=True,
                bake_anim_use_nla_strips=False, bake_anim_use_all_bones=True, path_mode='AUTO')
        assert os.path.getsize(path) > 10000, 'FBX export came out empty'
        for s in hide_after:
            self.show(self.obj(s), False)
        triangles = {s: sum(len(f.vertices) - 2 for f in self.obj(s).data.polygons) for s in self.parts}
        state.update({'protected_data_unchanged': True, 'triangles': triangles, 'fbx': path,
                      'textures': [os.path.join(self.tex, self.P + '_' + s + '.png') for s in ('Color', 'Normal')]})
        with open(self.state_path, 'w') as f:
            json.dump(state, f, indent=2)
        print('SUMMARY: exported', path, 'triangles:', triangles)

    # ---- 5. review images ------------------------------------------------
    def preview(self, views, show=None, size=(520, 620), save=True):
        """views: [(name, camera location, action or None, frame, ortho scale), ...]
        Renders each view and tiles them into one <prefix>_Review.png (one image to look at).
        show: part suffixes to make visible for the renders (default: all parts)."""
        import numpy as np
        w, h = size
        scene = bpy.context.scene
        scene.render.engine = 'CYCLES'
        scene.cycles.samples = 32
        scene.render.resolution_x, scene.render.resolution_y = w, h
        scene.render.resolution_percentage = 100
        scene.render.image_settings.file_format = 'PNG'
        scene.world.color = (.22, .22, .22)
        scene.view_settings.view_transform = 'AgX'
        old = bpy.data.collections.get(self.P + '_Preview')
        if old:
            for o in list(old.objects):
                bpy.data.objects.remove(o, do_unlink=True)
            bpy.data.collections.remove(old)
        col = bpy.data.collections.new(self.P + '_Preview')
        scene.collection.children.link(col)
        cam_data = bpy.data.cameras.new(self.P + '_PreviewCamera')
        cam = bpy.data.objects.new(cam_data.name, cam_data)
        col.objects.link(cam)
        scene.camera = cam
        cam_data.type = 'ORTHO'
        for i, (loc, power, lsize) in enumerate([((-3, -4, 5), 420, 4), ((4, -1, 2), 280, 3), ((0, 4, 4), 500, 3)]):
            d = bpy.data.lights.new(self.P + '_PreviewLight' + str(i), 'AREA')
            d.energy, d.shape, d.size = power, 'DISK', lsize
            o = bpy.data.objects.new(d.name, d)
            col.objects.link(o)
            o.location = loc
            o.rotation_euler = (Vector((0, 0, 0)) - o.location).to_track_quat('-Z', 'Y').to_euler()
        for s in (show if show is not None else self.parts):
            self.show(self.obj(s))
        rig = self.obj(self.rig) if self.rig else None
        if rig:
            rig.data.pose_position = 'POSE'
        images = []
        for name, loc, action, frame, scale in views:
            if rig and action:
                rig.animation_data.action = bpy.data.actions[action]
                if rig.animation_data.action.slots:
                    rig.animation_data.action_slot = rig.animation_data.action.slots[0]
            scene.frame_set(frame)
            bpy.context.view_layer.update()
            cam.location = loc
            cam.rotation_euler = (Vector((0, 0, 0)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
            cam_data.ortho_scale = scale
            scene.render.filepath = os.path.join(self.root, self.P + '_Review_' + name + '.png')
            with contextlib.redirect_stdout(io.StringIO()):
                bpy.ops.render.render(write_still=True)
            images.append(scene.render.filepath)
        rows = []
        for path in images:
            im = bpy.data.images.load(path, check_existing=False)
            arr = np.empty(w * h * 4, dtype=np.float32)
            im.pixels.foreach_get(arr)
            rows.append(arr.reshape(h, w, 4))
            bpy.data.images.remove(im)
        composite = bpy.data.images.new(self.P + '_Review', w * len(rows), h, alpha=True)
        composite.pixels.foreach_set(np.concatenate(rows, axis=1).ravel())
        composite.filepath_raw = os.path.join(self.root, self.P + '_Review.png')
        composite.file_format = 'PNG'
        composite.save()
        if save:
            bpy.ops.wm.save_as_mainfile(filepath=os.path.join(self.root, self.P + '.blend'))
        print('SUMMARY: review composite saved:', composite.filepath_raw)
