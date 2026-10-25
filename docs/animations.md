# Animations

The published animation IDs the game uses.

**Publish every animation under the experience's owner.** If the game belongs to a group, publish under the group. Roblox won't play animations owned by a different account, and they fail silently.

## Automated pipeline (preferred)

Convert the Blender actions and upload them with `scripts/export_animations.py` and `scripts/upload_assets.py`. See [asset-pipeline.md](asset-pipeline.md). **Name each variant's MeshPart after the Blender armature**, or Root movement won't play.

## How to publish by hand (fallback)

1. Import the model FBX into Studio (Import 3D). Its actions land in `ServerStorage → RBX_ANIMSAVES → <Model>`.
2. Right-click an action → **Save to Roblox…** → name it `<Model>_<Action>` → choose the owner (group or account).
3. Paste the ID below and tell Claude.

Variants that share one skeleton share one set of animations, so publish only one variant's.

## Hero Sprint (R15)

Source: [BE_HeroSprint.blend](../blender/anims/BE_HeroSprint.blend). Rig `BE_HeroSprint_R15`, 15 bones. [Looping preview](../blender/review/BE_HeroSprint_Run.gif) and [pose sheet](../blender/review/BE_HeroSprint_Run.png). The review proxy is not imported; only the animation plays on the existing avatar.

| Action | Frames | Loop | Used for | Asset ID | Status |
| --- | ---: | --- | --- | --- | --- |
| Run | 1-17 at 30 fps; frame 17 duplicates frame 1 | yes | Hero Sprint with subtle bounce; Movement priority | 95948628269299 | Group-owned; fresh Studio Play passed |

The loop lasts 16/30 seconds. `Footstep` markers: `Left` at 0 seconds, `Right` at 8/30 seconds. There is no damage/strike frame for this locomotion clip. Runtime playback scales by actual horizontal speed / 16; at the game's unchanged 20 studs/s this is 1.25x. Foot support travel was authored at 15.6 studs/s, approximately 19.5 studs/s at that playback speed.

Registered in `src/shared/Config/Animations.luau`; `RunController` handles run/stop/air/death transitions and marker-driven white puffs. Existing Animate handles idle/jump/fall. Puff texture: `rbxassetid://71229989533127`.

R15 export (separate from the skinned-mesh pipeline above):

```powershell
blender -b blender/anims/BE_HeroSprint.blend --python scripts/export_r15_animations.py -- --rig BE_HeroSprint_R15 --actions Run --prefix BE_HeroSprint
python scripts/upload_assets.py BE_HeroSprint --only '*.rbxmx' --include-animations
```

The exported RBXMX is generated/ignored; source, exporter, neutral rest data, validation report and uploaded ID/hash are tracked. [Runtime validation and limits](hero-sprint-validation.md).
