# BE_PowerDroplet - mesh-stage brief

Template: `Droplet`. Source deliverable after approval: `blender/BE_PowerDroplet.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - water.png. Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **1.7 x 1.7 x 2.7**.
- Triangle target: **500**; hard maximum: **1000**, including relief and bevels.
- Silhouette: A plump water drop, with a large bulbous leading body and short soft tapered trailing tail. Tail ends rounded, not needle-sharp. Solid thickness and readable three-quarter volume; no flat billboard or sphere substitution. Trailing mini-drops are runtime support, not embedded geometry.
- Axes: Long axis Roblox Z: bulb leads at -Z; rounded trailing tip points +Z. Upright cross section with +Y top.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.Droplet`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
