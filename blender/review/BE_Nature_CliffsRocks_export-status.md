# Approved cliffs/rocks: export and integration complete

The owner approved all seven shapes on 2026-10-24. Their source blend and geometry remain unchanged. All seven FBXs pass shape, base-pivot, dimension, triangle-count and flat-normal round-trip checks.

The exports use two colocated material-face components with Roblox SmoothPlastic colours #8A8F99 and #5F6672. No texture upload is needed. The four cliff and three rock assets were uploaded through scripts/upload_assets.py to experience-owner group 683974855. Asset IDs and hashes are recorded in scripts/asset_ids.json.

Studio imports measured the expected dimensions and zero-height base pivots. PackageLinks were removed; normalized templates live in ServerStorage.MapProps.LowPolyNature. Arena placement uses the approved meshes and archives replaced decoration in ServerStorage.PolishOld/Arena_Nature_v1.

Files: BE_Nature_CliffsRocks_finish.blend, seven FBXs in blender/export, scripts/export_cliffs_rocks.py, [export validation](BE_Nature_CliffsRocks_export.validation.json), and [historical comparator diagnostics](BE_Nature_CliffsRocks_export.diagnostics.json). The export script now also supports the separately approved tree set through export_trees.py.

A first export-validation run stopped at the retry cap. Read-only diagnostics showed RockSmall's dimensions and 46 triangles were unchanged, with sub-microstud coordinate drift. On continuation, a focused fix replaced rounding-bin equality with one-to-one triangle/corner matching at an absolute 0.00001-stud tolerance. Tests reject larger deformation, extra triangles and incorrect duplicate multiplicity. The resumed run passed on its first attempt, reused the existing five files and exported the final two.

See [arena validation](../../docs/nature-arena-validation.md) for Studio checks, screenshots and remaining review gates.
