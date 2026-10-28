# BE_PowerLeaf - mesh-stage brief

Template: `Leaf`. Source deliverable after approval: `blender/BE_PowerLeaf.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - wind.png; fusion-nature.png, plus owner correction to broad outward wind. Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **0.8 x 0.2 x 1.2**.
- Triangle target: **120**; hard maximum: **300**, including relief and bevels.
- Silhouette: One simple plump leaf with a broad oval belly, softly tapered rounded tip, shallow central fold and short stout stem. Solid two-sided thickness. No micro-veins, jagged serrations, needle stem or flat one-sided card. Recolorable mint support shape, not a new Nature power.
- Axes: Leaf blade lies in Roblox XZ, thickness Y. Tip points -Z; stout stem +Z. Center pivot permits simple tumbling.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.Leaf`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
