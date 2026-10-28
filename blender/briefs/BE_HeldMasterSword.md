# BE_HeldMasterSword - mesh-stage brief

Template: `HeldMasterSword` (held weapon for Master Sword). Source: `blender/BE_HeldMasterSword.blend`.
Approved design (owner approved 2026-10-28; match its silhouette and colours, ignore text and UI): `docs/reference/sword-concepts-v1-2026-10-28/sword-lineup.png` panel "MASTER SWORD". Standalone view and held view are both shown.

- Triangle budget: **target 600, max 900**.
- Dimensions: Two-handed handle (owner, 2026-10-28): the handle must fit two blocky R15 fists. Measured from the ORIGIN (where the right fist holds, just under the guard): guard bottom at +0.40, grip from +0.45 down to -1.45 (1.9 long, about 0.32 thick), pommel from -1.45 to about -1.95. Guard about 1.9 wide and 0.4 thick. Blade from the guard top (about +0.97) to the tip at about +4.65: about 3.7 long, 1.05 wide and 0.38 thick at the base, soft chamfered edges, rounded blunt tip. All seven swords share this handle and blade length so one set of two-handed animations fits every sword; each has its own silhouette and colours. Reference build: blender/BE_HeldSword.blend (base Sword, already built to this layout).
- Material slots: `Blade` bright silver, `Guard` gold, `Star` blue, `Grip` navy, `Pommel` gold.
- Shape: The oversized broad silver blade (1.3 wide, about 4.1 long) with a rounded tip, a broad warm gold winged guard with a rounded blue five-point star inset in the middle, a navy grip with a gold band and a round gold pommel with a small star. The grandest of the set.

## Mesh-stage contract
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md` (chunky toy-like sword): broad blade, rounded tip, bevelled edges, simple readable guard, nothing needle-thin or realistic. Low-poly flat colours.
- One joined static mesh using the listed material slots (flat Principled colours only; no image textures, no transparency, no glow, no lights). No rig or animation.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- 1 Blender unit = 1 stud. Build Z-up; Roblox(x, y, z) = Blender(x, z, -y). So the blade tip is Blender +Z (Roblox +Y); the blade's wide faces point along Blender +-Y (Roblox Z); blade width runs along X.
- ORIGIN at the right-fist point: 0.45 below the bottom of the guard, on the grip axis (NOT the bounding-box centre). Tip direction +Y (Roblox), pommel at -Y.
- Preserve the live Blender session: make a NEW scene named `HeldMasterSword`, work only there, save to `blender/BE_HeldMasterSword.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_HeldMasterSword_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, a 160px thumbnail, and a crop of the matching sword from the reference image. Report dimensions (Roblox X/Y/Z), triangle count, material slots and topology checks in a few lines.
