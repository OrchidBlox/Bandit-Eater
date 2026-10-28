# BE_PowerSword - mesh-stage brief

Template: `Sword`. Source deliverable after approval: `blender/BE_PowerSword.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - sword.png (physical sword only; old parry concept is superseded). Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **0.9 x 4.0 x 0.55**.
- Triangle target: **650**; hard maximum: **1300**, including relief and bevels.
- Silhouette: One broad toy-like silver sword: thick flat blade, rounded end, bevel ridge, compact chunky crossguard and short grip/pommel. Distinct blade/grip silhouette at phone size. No dual blades, needle point, ornate filigree or embedded slash VFX. Keep guard within total width.
- Axes: Blade points +Y in Roblox, grip toward -Y; blade face in XY and thickness Z. Centered full-asset bounds; runtime rotates/offsets the whole sword.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.Sword`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
