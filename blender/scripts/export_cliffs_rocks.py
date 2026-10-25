"""Export the approved live meshes without opening files or rebuilding shapes.

Splits existing material faces into two colocated components, calls model_tools'
protected FBX export, then validates each file by importing into a temporary scene.
Run in live Blender through MCP, with the approved BE_ASSETS collection loaded.
"""
import bpy
import bmesh
import contextlib
import hashlib
import io
import json
import sys
from collections import Counter
from itertools import permutations
from pathlib import Path

ROOT=Path(r'C:\Users\Kobe\source\repos\bandit-eater\blender')
sys.path.insert(0,str(ROOT))
_old_bytecode=sys.dont_write_bytecode
sys.dont_write_bytecode=True
try:
    import model_tools as mt
finally:
    sys.dont_write_bytecode=_old_bytecode

NAMES=['CliffStraightA','CliffStraightB','CliffCorner','CliffEnd','RockSmall','RockMedium','RockLarge']
PARTS=['Base_8A8F99','Shade_5F6672']
COLORS=['#8A8F99','#5F6672']
SOURCE=ROOT/'BE_Nature_CliffsRocks_mesh.blend'
FINISH=ROOT/'BE_Nature_CliffsRocks_finish.blend'
REPORT=ROOT/'review'/'BE_Nature_CliffsRocks_export.validation.json'
TMP=ROOT/'.codex-tmp'/'cliffs-rocks-finish'
OUT=ROOT/'export'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fingerprint(obj):
    return mt.digest(([(tuple(v.co)) for v in obj.data.vertices],
                      [(tuple(p.vertices),p.material_index,p.use_smooth) for p in obj.data.polygons],
                      [m.name for m in obj.data.materials],
                      [tuple(row) for row in obj.matrix_world]))


def triangle_set(objects):
    result=[]
    for obj in objects:
        obj.data.calc_loop_triangles()
        for tri in obj.data.loop_triangles:
            coords=[obj.matrix_world @ obj.data.vertices[i].co for i in tri.vertices]
            result.append(tuple(sorted(tuple(round(c,4) for c in v) for v in coords)))
    return Counter(result)


def raw_triangles(objects):
    triangles=[]
    for obj in objects:
        obj.data.calc_loop_triangles()
        for tri in obj.data.loop_triangles:
            triangles.append(tuple(tuple(obj.matrix_world @ obj.data.vertices[i].co) for i in tri.vertices))
    return triangles


def triangles_match(left,right,tolerance=1e-5):
    """Perfect one-to-one triangle and corner matching, no rounding bins.

    Each coordinate must differ by <= tolerance studs. Bipartite matching
    preserves multiplicity even where near-coincident triangles share candidates.
    """
    if len(left)!=len(right):return False
    orderings=tuple(permutations(range(3)))
    def close(a,b):
        return any(all(abs(a[i][axis]-b[order[i]][axis])<=tolerance
                       for i in range(3) for axis in range(3)) for order in orderings)
    candidates=[[j for j,b in enumerate(right) if close(a,b)] for a in left]
    if any(not row for row in candidates):return False
    matched={}
    def assign(i,seen):
        for j in candidates[i]:
            if j in seen:continue
            seen.add(j)
            if j not in matched or assign(matched[j],seen):
                matched[j]=i
                return True
        return False
    return all(assign(i,set()) for i in range(len(left)))


def test_triangle_comparator():
    tri=((0.,0.,0.),(1.,0.,0.),(0.,1.,0.))
    below=((0.0000049,0.,0.),(1.,0.0000049,0.),(0.,1.,0.0000049))
    above=((0.00002,0.,0.),(1.,0.,0.),(0.,1.,0.))
    assert triangles_match([tri],[below]),'Sub-tolerance perturbation rejected'
    assert not triangles_match([tri],[above]),'Above-tolerance deformation accepted'
    assert triangles_match([tri,tri],[below,tri]),'Duplicate multiplicity rejected'
    assert not triangles_match([tri,tri],[tri,above]),'Triangle multiplicity lost'
    assert not triangles_match([tri],[tri,tri]),'Extra triangle accepted'
    assert triangles_match([tri],[tuple(reversed(tri))]),'Corner reordering rejected'
    return {'pass':True,'absolute_coordinate_tolerance_studs':1e-5,
            'checks':['sub-tolerance passes','above-tolerance fails','duplicate multiplicity',
                      'extra triangle fails','corner reordering passes']}


def bounds(objects):
    coords=[obj.matrix_world @ v.co for obj in objects for v in obj.data.vertices]
    lo=[min(v[k] for v in coords) for k in range(3)]
    hi=[max(v[k] for v in coords) for k in range(3)]
    return {'min_xyz':[round(v,6) for v in lo],'max_xyz':[round(v,6) for v in hi],
            'W_H_D':[round(hi[k]-lo[k],6) for k in (0,2,1)]}


def connected_components(mesh):
    adj={v.index:set() for v in mesh.vertices}
    for e in mesh.edges:
        a,b=e.vertices;adj[a].add(b);adj[b].add(a)
    unseen=set(adj);count=0
    while unseen:
        count+=1;pending=[unseen.pop()]
        while pending:
            linked=adj[pending.pop()] & unseen
            unseen-=linked;pending.extend(linked)
    return count


def flat_normals(objects):
    # FBX imports set smooth flags while retaining per-corner custom normals.
    # Compare actual corner normals with each flat triangle, allowing FBX normal
    # packing error (dot .9998 is at most 1.15 degrees).
    dots=[obj.data.corner_normals[i].vector.dot(poly.normal)
          for obj in objects for poly in obj.data.polygons for i in poly.loop_indices]
    return {'minimum_corner_to_face_dot':round(min(dots),8),
            'flat_within_normal_quantization':min(dots)>.9998}


def split_faces(source,scene,index,parts=PARTS,colors=COLORS):
    polys=[p for p in source.data.polygons if p.material_index==index]
    used=sorted({i for p in polys for i in p.vertices})
    remap={old:new for new,old in enumerate(used)}
    mesh=bpy.data.meshes.new(source.name+'_'+parts[index]+'_Geometry')
    mesh.from_pydata([tuple(source.data.vertices[i].co) for i in used],[],
                    [tuple(remap[i] for i in p.vertices) for p in polys])
    mesh.materials.append(source.data.materials[index]);mesh.update()
    for p in mesh.polygons:p.use_smooth=False
    obj=bpy.data.objects.new(source.name+'_'+parts[index],mesh)
    scene.collection.objects.link(obj)
    obj.matrix_world=source.matrix_world.copy()
    obj['RobloxColor']=colors[index]
    obj['RobloxMaterial']='SmoothPlastic'
    obj['Role']='Material-face subset; shared base-center pivot'
    return obj


def main(*, names=NAMES, parts=PARTS, colors=COLORS, source_path=SOURCE,
         finish_path=FINISH, report_path=REPORT, temp_path=TMP,
         scene_name='EXPORT_CliffsRocks_Approved', expected_sizes=None,
         expected_triangles=None, resume=None):
    """Shared approved-static-set exporter; defaults retain cliffs/rocks behavior."""
    NAMES,PARTS,COLORS=names,parts,colors
    SOURCE,FINISH,REPORT,TMP=source_path,finish_path,report_path,temp_path
    if resume is None:resume=globals().get('BE_RESUME',False)
    assert len(PARTS)==len(COLORS),'Component/color configuration differs'
    comparator_test=test_triangle_comparator()
    OUT.mkdir(parents=True,exist_ok=True);TMP.mkdir(parents=True,exist_ok=True)
    sources=[bpy.data.objects['BE_Nature_'+n] for n in NAMES]
    before={o.name:fingerprint(o) for o in sources}
    source_sha=sha(SOURCE)
    if REPORT.exists():
        assert source_sha==json.loads(REPORT.read_text())['source_blend_sha256'],'Approved source SHA changed since checkpoint'
    scene=bpy.data.scenes.get(scene_name)
    if not scene:scene=bpy.data.scenes.new(scene_name)
    bpy.context.window.scene=scene
    scene.unit_settings.scale_length=1
    report={'stage':'approved mesh finish/export only','source_blend':str(SOURCE),
            'source_blend_sha256':source_sha,'finish_blend':str(FINISH),
            'axis_forward':'-Y','axis_up':'Z','apply_scale_options':'FBX_SCALE_ALL',
            'apply_unit_scale':True,'Blender_units_per_stud':1,
            'rigs':0,'animations':0,'textures':0,'assets':[],
            'triangle_comparator_test':comparator_test,
            'material_strategy':f'{len(PARTS)} open face subsets reconstruct the original closed solid exactly. '
                                'Keep all colocated with common base pivot. Set each Roblox MeshPart Color '
                                'from component suffix, SmoothPlastic. No textures or SurfaceAppearance.',
            'validation_limit':'Blender FBX round trip verified; Roblox import scale, pivot, colors and orientation still require Studio verification.'}
    try:
        for source in sources:
            if expected_sizes is not None:
                assert bounds([source])['W_H_D']==list(expected_sizes[source.name]),source.name+' approved bounds differ'
            if expected_triangles is not None:
                assert sum(len(p.vertices)-2 for p in source.data.polygons)==expected_triangles,source.name+' approved triangles differ'
            components=[bpy.data.objects.get(source.name+'_'+PARTS[i]) or split_faces(source,scene,i,PARTS,COLORS) for i in range(len(PARTS))]
            assert triangle_set(components)==triangle_set([source]),source.name+' geometry differs'
            model=mt.Model(source.name,parts=PARTS,rig=None,actions=(),root=str(TMP),base_file=str(SOURCE))
            path=OUT/(source.name+'.fbx')
            if not (resume and path.exists()):
                with contextlib.redirect_stdout(io.StringIO()):
                    model.snapshot_base()
                    model.validate_export()
                (Path(model.out)/(source.name+'_Base.fbx')).replace(path)
            item={'name':source.name,'file':str(path),'sha256':sha(path),
                  'triangles':sum(len(p.vertices)-2 for p in source.data.polygons),
                  'bounds':bounds(components),'component_count':len(components),
                  'geometry_matches_approved':True,'components':[]}
            for index,obj in enumerate(components):
                item['components'].append({'name':obj.name,'RobloxColor':COLORS[index],
                    'RobloxMaterial':'SmoothPlastic','triangles':len(obj.data.polygons),
                    'connected_regions':connected_components(obj.data),'bounds':bounds([obj]),
                    'origin_xyz':list(obj.location),'rotation_xyz':list(obj.rotation_euler),
                    'scale_xyz':list(obj.scale),'flat_shaded':all(not p.use_smooth for p in obj.data.polygons)})
            qa=bpy.data.scenes.get('TEMP_FBX_CHECK_'+source.name)
            if qa:
                for obj in list(qa.objects):bpy.data.objects.remove(obj,do_unlink=True)
                bpy.data.scenes.remove(qa)
            qa=bpy.data.scenes.new('TEMP_FBX_CHECK_'+source.name)
            bpy.context.window.scene=qa
            qa.unit_settings.scale_length=1
            with contextlib.redirect_stdout(io.StringIO()):
                bpy.ops.import_scene.fbx(filepath=str(path),use_anim=False)
            imported=[o for o in qa.objects if o.type=='MESH']
            item['fbx_roundtrip']={'mesh_components':len(imported),
                'triangles':sum(len(p.vertices)-2 for o in imported for p in o.data.polygons),
                'bounds':bounds(imported),
                'triangle_positions_match':triangles_match(raw_triangles(imported),raw_triangles([source])),
                'absolute_coordinate_tolerance_studs':1e-5,
                'base_pivots_preserved':all(o.location.length<1e-5 for o in imported),
                'normals':flat_normals(imported),
                'texture_nodes':sum(n.type=='TEX_IMAGE' for o in imported for m in o.data.materials if m and m.use_nodes for n in m.node_tree.nodes)}
            assert len(imported)==len(PARTS),source.name+' FBX component count differs'
            assert item['fbx_roundtrip']['triangle_positions_match'],source.name+' FBX geometry differs'
            assert item['fbx_roundtrip']['base_pivots_preserved'],source.name+' FBX pivots differ'
            assert item['fbx_roundtrip']['normals']['flat_within_normal_quantization'],source.name+' FBX normals differ'
            assert item['fbx_roundtrip']['texture_nodes']==0,source.name+' unexpected texture'
            for obj in list(qa.objects):bpy.data.objects.remove(obj,do_unlink=True)
            bpy.context.window.scene=scene
            bpy.data.scenes.remove(qa)
            item['pass']=True;report['assets'].append(item)
            print('Export OK:',source.name,item['triangles'],'triangles /',len(PARTS),'color components')
        report['source_meshes_unchanged']=before=={o.name:fingerprint(o) for o in sources}
        report['source_blend_unchanged']=sha(SOURCE)==source_sha
        assert report['source_meshes_unchanged'] and report['source_blend_unchanged'],'Approved source changed'
        report['pass']=True
    except Exception as err:
        report['pass']=False;report['error']=str(err)
        raise
    finally:
        bpy.context.window.scene=scene
        REPORT.write_text(json.dumps(report,indent=2))
        bpy.ops.wm.save_as_mainfile(filepath=str(FINISH))
    print('Finished:',len(NAMES),'FBXs,',len(NAMES)*len(PARTS),'color components, source unchanged, round trips pass.')


# MCP exec has no __name__; ordinary direct Python execution is __main__.
# Importing the reusable pipeline must never run an export.
if globals().get('__name__') in (None,'__main__'):
    main()
