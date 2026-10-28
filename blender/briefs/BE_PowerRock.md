# BE_PowerRock - mesh-stage brief

Template: `Rock`. Source deliverable after approval: `blender/BE_PowerRock.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - earth.png; fusion-nature.png. Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **2.2 x 2.0 x 2.1**.
- Triangle target: **450**; hard maximum: **900**, including relief and bevels.
- Silhouette: A weighty, asymmetrical rounded boulder with 8-12 broad readable facets. Bevel chunky corners without turning it into a smooth energy sphere. No cracks thinner than 0.15 studs, needle chips, gravel cloud, or attached effects. Must still read as rock when scaled down to support chips.
- Axes: No directional front; broad stable belly toward -Y in Roblox. Keep silhouette varied from every spin angle.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.Rock`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
