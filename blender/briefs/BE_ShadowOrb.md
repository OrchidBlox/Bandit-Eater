# BE_ShadowOrb - mesh-stage brief

Template: `ShadowOrb`. Source deliverable after approval: `blender/BE_ShadowOrb.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - shadow.png. Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **2.0 x 2.0 x 2.0**.
- Triangle target: **700**; hard maximum: **1400**, including relief and bevels.
- Silhouette: A plump rounded violet orb with a large thick crescent-shaped recess/relief on its forward face. Make the moon notch visible through geometry and broad shading, not an eye or black hole. Friendly solid volume, blunt transitions. No dark smoke, spines, thin rings or horror details. Distinguish from a generic colored ball in silhouette/three-quarter view.
- Axes: Moon motif front faces -Z in Roblox; +Y up. Centered globe. Reusable scale for descending hero support; the Nightfall crescent itself can reuse Slash later.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.ShadowOrb`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
