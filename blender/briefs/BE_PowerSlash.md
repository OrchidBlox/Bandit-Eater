# BE_PowerSlash - mesh-stage brief

Template: `Slash`. Source deliverable after approval: `blender/BE_PowerSlash.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - sword.png; fusion-nature.png; fusion-arcane.png; master-sword.png. Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **4.0 x 3.0 x 0.8**.
- Triangle target: **650**; hard maximum: **1300**, including relief and bevels.
- Silhouette: A single thick rounded crescent ribbon with a broad middle and softly capped ends. Friendly foam-like volume, not razor tips or a flat plane. Distinct from the WindFront wide air bow and the inward Inhale crescent. Designed for silver and elemental recoloring; no baked flames or leaves.
- Axes: Broad silhouette in Roblox XY; thickness on Z; open crescent faces +X when viewed from +Z. Traveling motion is along -Z. Show all three axes in review so local sweep rotations remain predictable.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.Slash`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
