# Animations

The published animation IDs the game uses.

## Current movement transitions (2026-10-25)

V5 remains the approved run (`116051034967244`, 0.8 seconds at normal speed). The earlier Hero Sprint sections below are revision history.

| Clip | Asset ID | Duration |
| --- | --- | --- |
| Start | 104271079454951 | 8/30 s |
| Stop | 135962042925895 | 8/30 s |
| Takeoff | 75446304601768 | 6/30 s |
| LandRun | 123339471651713 | 6/30 s |
| LandIdle | 85449026426804 | 8/30 s |

All five are group-owned, nonlooping Movement tracks. Start and LandRun end at the exact V5 first pose. Landing clips emit `Landing=Both` at time zero; runtime requires a healthy grounded character and emits one existing cloud per foot. Starts/stops can be interrupted immediately by jumping or changed movement intent. Default Animate retains idle and freefall; movement physics are unchanged.

[Blender source](../blender/anims/BE_MovementTransitions.blend), [preview](../blender/review/BE_MovementTransitions.gif), and [validation](movement-transitions-validation.md).

**Publish every animation under the experience's owner.** If the game belongs to a group, publish under the group. Roblox won't play animations owned by a different account, and they fail silently.

## Automated pipeline (preferred)

Convert the Blender actions and upload them with `scripts/export_animations.py` and `scripts/upload_assets.py`. See [asset-pipeline.md](asset-pipeline.md). **Name each variant's MeshPart after the Blender armature**, or Root movement won't play.

## How to publish by hand (fallback)

1. Import the model FBX into Studio (Import 3D). Its actions land in `ServerStorage → RBX_ANIMSAVES → <Model>`.
2. Right-click an action → **Save to Roblox…** → name it `<Model>_<Action>` → choose the owner (group or account).
3. Paste the ID below and tell Claude.

Variants that share one skeleton share one set of animations, so publish only one variant's.

## Hero Sprint (R15)

Current source: [BE_HeroSprint_MrXen0.blend](../blender/anims/BE_HeroSprint_MrXen0.blend), authored on the owner's original `MrXen0_R15RIG_v1.2.blend` rig. [Looping preview](../blender/review/BE_HeroSprint_MrXen0.gif) and [reference comparison](../blender/review/BE_HeroSprint_MrXen0.png). The original rig and mesh are preserved; only the animation plays on the existing avatar.

| Action | Frames | Loop | Used for | Asset ID | Status |
| --- | ---: | --- | --- | --- | --- |
| Run | 1-17 at 30 fps; frame 17 duplicates frame 1 | yes | Hero Sprint: forward chest, pumping arms, alternating stride; Movement priority | 110375300869114 | Group-owned; fresh Studio playback and server replication checked 2026-10-25 |

The loop lasts 16/30 seconds. `Footstep` markers: `Left` at 0 seconds, `Right` at 8/30 seconds. There is no damage/strike frame for this locomotion clip. Runtime playback scales by actual horizontal speed / 16; at the game's unchanged 20 studs/s this is 1.25x. Foot support travel was authored at 15.6 studs/s, approximately 19.5 studs/s at that playback speed.

Registered in `src/shared/Config/Animations.luau`; `RunController` handles run/stop/air/death transitions and marker-driven white puffs. Existing Animate handles idle/jump/fall. Puff texture: `rbxassetid://71229989533127`.

Rebuild using `blender/anims/build_hero_sprint_mrxeno.py` in the live Blender Python context. Its `MRX_MODE` modes are `author`, `render`, and `export`; export reads evaluated deform-bone matrices. It appends the canonical rig into an isolated scene and saves project work separately. Do not use the old generated-armature exporter on this rig.

```powershell
python blender/anims/build_hero_sprint_mrxeno.py --compose
python scripts/upload_assets.py BE_HeroSprintMrXen0 --only '*.rbxmx' --include-animations
```

The exported RBXMX is generated/ignored; source, builder/exporter, neutral rest data, validation report and uploaded ID/hash are tracked. Original generated-rig ID `95948628269299` and interim native-Luau ID `79021053592583` are superseded. [Runtime validation and limits](hero-sprint-validation.md).

## Approved V4 replacement (2026-10-25)

Current run ID: `77124463468180`. Source: `blender/anims/BE_HeroSprint_MrXen0_V4.blend`; preview: `blender/review/BE_HeroSprint_V4.gif`. Authored cycle is 24/30 seconds, with duplicate frame25 and Footstep Left0 / Right0.4. Config BaseSpeed20 preserves the approved preview cadence at normal WalkSpeed20. Fresh Studio Play and server observation confirmed Length0.8, Speed1, Loop=true; both foot emitters were created. Selene and Rojo passed. Owner in-game visual review pending. Earlier IDs and timing above are historical. No public place publish or push.

## Current V5 (2026-10-25)

Approved dramatic revision: `116051034967244`. Source `blender/anims/BE_HeroSprint_MrXen0_V5.blend`; builder `revise_hero_sprint_v5.py`; exporter `export_hero_sprint_v5.py`; preview `blender/review/BE_HeroSprint_V5.gif`. Same 0.8-second cycle, BaseSpeed20, Footstep Left0/Right0.4. Broader arm swings, stronger torso rotation and higher airborne stretch. Export checks, Selene and Rojo passed; fresh Studio Play/server verified new track at Length0.8, Speed1 and Loop=true. Both foot emitters created. Owner in-game visual review pending; no public place publish. V4 and earlier sections are historical.

## Jump concept animations - 2026-10-25

These supersede the earlier Takeoff asset; V5 run and existing landing clips remain unchanged.

| Clip | Asset ID | Duration | Loop |
| --- | --- | --- | --- |
| Takeoff | 113531311551794 | 10/30 s | no |
| DoubleJump | 103031167309210 | 12/30 s | no |
| Fall | 139218872313289 | 12/30 s | yes |

Source: `blender/anims/BE_JumpConcepts.blend`; builder `build_jump_concepts.py`. All are Movement priority on the original MrXen0 R15 rig. DoubleJump emits `AirBurst=Both` at 4/30 seconds, with server-approval gating and a bounded missing-marker fallback. Rising endpoints may hold until descent; contact always interrupts into LandRun/LandIdle. No animation root motion drives the physical jump.

Preview: [pose sheet](../blender/review/BE_JumpConcepts.png) and [motion](../blender/review/BE_JumpConcepts.gif). Numerical export checks passed; canonical rig and V5 hashes unchanged. Fresh Studio keyboard test loaded all seven transition clips with zero failed loads/fallbacks and observed Takeoff -> Fall -> LandIdle and DoubleJump -> Fall -> LandIdle. One airborne extra jump was accepted, a third press was rejected; landing rearmed it. Holding Space did not consume an extra airborne jump (default repeated ground jumps remain). Mobile/gamepad, remote-client VFX and broad avatar-proportion visual acceptance remain pending. Studio Play was stopped after testing.

Dash and M1 were implemented after this jump update; current assets are below.

## Dash and M1 V2 — 2026-10-25

Source: `blender/anims/BE_CombatActionsV2.blend`, builder `build_combat_actions_v2.py`; [pose sheet](../blender/review/BE_CombatActionsV2.png), [motion](../blender/review/BE_CombatActionsV2.gif). Uses the unchanged canonical MrXen0 rig. Supersedes the tighter first combat pass.

| Clip | Asset ID | Duration | Marker time |
| --- | --- | --- | --- |
| M1 left jab | 124340796371674 | 18/30 s | Strike 6/30 |
| M1 right cross | 137589820930478 | 18/30 s | Strike 6/30 |
| M1 rising uppercut | 97511758227791 | 20/30 s | Strike 7/30 |
| Moving jab | 99026701617574 | 18/30 s | Strike 6/30 |
| Moving cross | 132325822094557 | 18/30 s | Strike 6/30 |
| Moving uppercut | 140611227228767 | 20/30 s | Strike 7/30 |
| Dash | 108163526893560 | 15/30 s | Burst 2/30; Brake 11/30 |

All are nonlooping Action priority. Moving/airborne variants mute lower-body poses to preserve locomotion. Full extension holds three frames. Measured forward fist reach improved from 1.90/1.61/0.71 to 2.92/3.01/2.41 studs. Dash now uses a lower asymmetric burst, changing glide pose and longer recovery; server travel is 20 studs with an eased stop. Config: `src/shared/Config/CombatActions.luau`. Fresh mouse/keyboard tests loaded all seven V2 clips at expected lengths with zero failed loads or fallback markers. [Validation and remaining acceptance](combat-actions-validation.md).
