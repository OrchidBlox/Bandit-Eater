# BE_MasterSword - mesh-stage brief

Template: `MasterSword`. Source deliverable after approval: `blender/BE_MasterSword.blend`.
References: `docs/reference/move-concepts-v1-2026-10-26/` - master-sword.png; supersedes old dual-sword fusion panel. Current `Shared.Config.PowerMoves` supersedes obsolete move labels/parry mechanics in concept sheets.

- Intended size (Roblox X/Y/Z studs): **0.9 x 4.0 x 0.55 (runtime signature scale 1.6 gives 1.44 x 6.4 x 0.88)**.
- Triangle target: **900**; hard maximum: **1800**, including relief and bevels.
- Silhouette: Exactly ONE large original heroic blade. Broad silver blade with blunt beveled tip, substantial golden rounded crossguard, navy round guard medallion bearing one chunky five-point gold star, short thick grip and round pommel. No paired swords, franchise-specific silhouette, tiny engraving or needle edges. Mesh stage must establish guard/star relief clearly before color finish.
- Axes: Blade +Y, grip -Y, decorated front faces -Z, blade face XY. Full bounds center pivot. Gold guard and star are intended finish zones; see queue note about current single-MeshPart renderer.

## Mesh-stage contract

Status: brief only, not built or approved. Wait for owner approval of the WindFront mesh before starting the next set; then build one set and present it before continuing. Preserve live unsaved Blender work; use a new scene and save separately. No export, upload or placement in this stage.

Match `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: low-poly broad surfaces, rounded fat silhouette, readable at phone size, restrained complexity. One joined static mesh, neutral white material for first review; no rig, animation, collision, lights, emitters, baked glow or transparency. Apply transforms; positive unit scale; no unapplied modifiers. Put origin at bounding-box center, not feet/base.

Dimensions and axes above are the final Roblox local-space contract for `ReplicatedStorage.Assets.PowerMoves.MasterSword`, read by `PowerMoves.luau`. Blender is Z-up; explicitly map/verify final imported axes rather than trusting FBX defaults (import scale can be 100x). Runtime assigns `Size`, `Color` and SmoothPlastic, clones only one MeshPart, and deletes its children. Author one complete silhouette accordingly.

Review front, side and three-quarter beside a 5-stud R15 scale guide; include 160px thumbnail and 20% squash/stretch silhouette. Report actual dimensions/triangles and topology checks. No floating disconnected fragments except intentional joined relief; normals outward, no zero-area faces. Owner judges reference match before finish.
