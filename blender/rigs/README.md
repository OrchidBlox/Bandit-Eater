# Canonical R15 rig

`MrXen0_R15RIG_v1.2.blend` is the canonical Blender R15 rig for every project in this family (see the repo's CLAUDE.md, "Required R15 rig" and "R15 animation rule"). Keep the file unchanged: copy it into a working `.blend` or append its armature into a new scene, and save project work separately.

- **Rig:** `Roblox_R15`, 141 bones (FK and IK controls for arms and legs, `UpTorso`, `LowTorso`, `TORSO`, `ROOT`, `HEAD`), 16 deform parts, one control bone per Motor6D joint. FK/IK switches are on the `PROPERTIES` bone (`ARM_IK_FK.L/R`, `LEG_IK_FK.L/R`).
- **Source:** MrXen0's free community R15 rig, version 1.2 (credit the author wherever the rig is shown or shipped).
- **Licence:** not recorded in the file. Confirm the author's terms allow keeping a copy in these repos before making any repo public; the repos are private today.
- **Where the owner keeps the original:** `C:\Users\Kobe\source\repos\R15 - Blener Model\` (local only). Scripts and docs look for this repo copy first (`blender/rigs/`) and fall back to that path.
- **Starting a new project from template-game:** the rig is already in `blender/rigs/`; nothing else to download.
