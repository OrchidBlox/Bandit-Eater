from pathlib import Path
import bpy, math, json
from mathutils import Vector
ROOT=Path(r'C:/Users/Kobe/source/repos/bandit-eater')
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
parts=[]
def mat(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);return m
silver=mat('Silver',(.72,.82,.93));edge=mat('BrightEdge',(.9,.95,1));gold=mat('BlueGray',(.25,.37,.49));navy=mat('Navy',(.035,.08,.17))
def finish(o,name,material,bevel=0):
 o.name=name;o.data.materials.append(material);bpy.context.view_layer.objects.active=o
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:
  mod=o.modifiers.new('RoundedToyEdges','BEVEL');mod.width=bevel;mod.segments=1
  bpy.ops.object.modifier_apply(modifier=mod.name)
 parts.append(o);return o

def prism(name,points,depth,material,bevel=.06,y=0):
 n=len(points);verts=[(x,y+sign*depth/2,z) for sign in (-1,1) for x,z in points]
 faces=[tuple(reversed(range(n))),tuple(range(n,n*2))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o)
 return finish(o,name,material,bevel)
def cube(name,loc,size,material,bevel):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.scale=size;return finish(o,name,material,bevel)
# Broad blade has a softened pointed tip and stepped shoulder, no sharpened needle.
prism('Blade',[(-.62,1.45),(.62,1.45),(.85,2.02),(.70,4.68),(.30,5.30),(0,5.48),(-.30,5.30),(-.70,4.68),(-.85,2.02)],.24,silver,.07)
# Narrow ridge gives readable silver facets from oblique angles.
prism('BladeRidge',[(-.10,1.62),(.10,1.62),(.10,4.70),(0,5.20),(-.10,4.70)],.04,edge,.018,y=-.147)
prism('Guard',[(-1.34,1.37),(-1.25,1.76),(-.69,1.70),(-.36,1.55),(.36,1.55),(.69,1.70),(1.25,1.76),(1.34,1.37),(.63,1.25),(-.63,1.25)],.46,gold,.09)
cube('Grip',(0,0,.73),(.42,.38,1.22),navy,.08)
cube('Pommel',(0,0,.12),(.65,.5,.25),gold,.08)
bpy.ops.object.select_all(action='DESELECT')
for o in parts:o.select_set(True)
bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join();o=bpy.context.object;o.name='BE_PowerSword_Base'
o.scale=(.68,.85,.73)
bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
o.data.calc_loop_triangles();tris=len(o.data.loop_triangles);assert tris<=1000,tris
# Reserve palette UV cells now; no texture/export at mesh stage.
uv=o.data.uv_layers.new(name='PaletteUV')
for poly in o.data.polygons:
 for li in poly.loop_indices:uv.data[li].uv=((poly.material_index+.5)/len(o.data.materials),.5)
scene=bpy.context.scene;scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='MATERIAL';scene.display.shading.show_shadows=False;scene.display.shading.show_cavity=True;scene.display.shading.cavity_type='WORLD';scene.render.film_transparent=True
scene.render.resolution_x=400;scene.render.resolution_y=600;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
data=bpy.data.cameras.new('PowerSwordReview');cam=bpy.data.objects.new(data.name,data);scene.collection.objects.link(cam);scene.camera=cam;cam.data.type='ORTHO';cam.data.ortho_scale=4.7
folder=ROOT/'blender/review';folder.mkdir(exist_ok=True)
for name,direction in [('front',(0,-1,0)),('angle',(1,-2,.8))]:
 center=Vector((0,0,1.99));cam.location=center+Vector(direction).normalized()*15;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(folder/f'BE_PowerSword_{name}.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'blender/BE_PowerSword.blend'))
(folder/'BE_PowerSword.validation.json').write_text(json.dumps({'triangles':tris,'mesh_objects':1,'dimensions':list(o.dimensions),'stage':'mesh only; no export or upload','materials':[m.name for m in o.data.materials],'modifiers':len(o.modifiers)},indent=2));print('PowerSword mesh',tris,'triangles')
