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

## Power move rollout - 2026-10-26

`Shared.Config.PowerAnimations` registers 36 V2 standing casts and 36 moving variants from `blender/anims/BE_PowerMovesV2.blend`, authored on the canonical MrXen0 rig. All 72 uploaded tracks loaded in fresh Studio Play. Release timing matches Shared.Config.PowerMoves; moving/airborne variants preserve locomotion. Shared swallow uses standing 134771684679502 and moving 99253369218549. Stronger reach and anticipation are implemented; owner gameplay visual review remains pending.

## Two-handed sword set - 2026-10-28 (shared by every sword power)

Authored WITH the sword attached to the canonical MrXen0 rig: `blender/anims/build_sword_rig.py` (both arms in IK; the right IK target carries the wrist and blade direction, the left target sits 0.8 stud down the handle, so both hands are on the grip in every frame; a reach fit keeps the short R15 arms on the grip). Exported through the validated V2 exporter. Sword, Wind/Earth/Water/Fire/Shadow Sword and Master Sword all use these clips (owner, 2026-10-28). Grip (sword relative to the RightHand part) comes from Blender: `blender/review/BE_SwordRig_Sword_grip.json`, used in `SwordController.luau`.

| Clip | Asset ID | Moving (upper body) | Length | Strike |
| --- | --- | --- | --- | --- |
| Ready (loop, Action) | 107881919413642 | 107127975680104 | 48/30 s | - |
| M1_1 horizontal slash | 129293301004480 | 82490956624816 | 18/30 s | 6/30 |
| M1_2 backhand | 130407320980475 | 77362148225584 | 18/30 s | 6/30 |
| M1_3 overhead chop | 105576524921428 | 140518167709606 | 20/30 s | 7/30 |

Runtime: `SwordController` plays Ready (or ReadyMoving while running/airborne) and yields to any other Action-or-higher track; `CombatAnimationController` swaps M1 to these clips for sword powers. Revised the same day: handle lengthened to 1.9 studs so both fists sit on it (left hand one fist below the right), swings pushed wider with more torso commit. Tested in Studio Play: hold, running hold and M1 1-3 chain play the right IDs. The earlier one-handed `BE_SwordM1_Sword` clips (114620290008582 and siblings) are superseded.

## Two-handed sword casts - 2026-10-29

21 casts (7 sword powers x Q/E/R) plus 21 moving upper-body variants, authored on the same two-handed rig as the M1 set: `python blender/anims/build_sword_rig.py -- --casts --export` (separate outputs, `BE_SwordRig_SwordCasts_*`; the shipped M1 and Ready clips are untouched). Each clip is timed to its move's server Delay (length = Delay + 0.5 s, `Release` marker = Delay). Poses: Q horizontal slash, E low draw and rising cut, R wide spin (Sword, Wind, Water), overhead cleave (Earth, Fire, Master) or raised-then-plunging eclipse (Shadow). IDs are in `src/shared/Config/PowerAnimations.luau` (the previous one-handed IDs sit in a comment above each entry). All 42 tracks verified in Studio to load at the configured durations. Pommel dips up to about 0.5 stud into the torso at a few frames, same as the M1 clips; visual review pending.

## Back to a one-hand sword grip - 2026-10-29

Owner decision: swords are held in one hand again. `CombatActions.SwordM1` uses the one-handed `BE_SwordM1_Sword` M1 clips (114620290008582 / 130582779017206 / 90936461621693, moving 95184168951056 / 83617632377530 / 95335351109250) with no ready hold (`SwordController` skips it when the set has none), and all 21 sword casts use their previous one-handed IDs and profiles again. The two-handed IDs are kept in the comment above each cast entry and in the comment in `CombatActions.luau`, so the switch is reversible. The sword meshes still have the lengthened handle and the shared grip. The E casts are the old rising-cut clips; a one-handed lunge clip for the dash-slashes is still to do. Release times of the E casts follow the dash windups.

## One-handed sword M1 set - 2026-10-29

Built from the owner-approved concept (`docs/reference/sword-m1-onehand-concepts-v1-2026-10-29/`, choreography deliberately different from the reference recording): `python blender/anims/build_sword_rig.py -- --onehand --export` (outputs `BE_SwordRig_SwordOneHand_*`). Right hand on the sword (target set relative to the right shoulder), left hand posed freely for balance. Hit 1 rising diagonal (crouch, cut low right to high left), Hit 2 wide backhand (across the chest to a flat sweep right with a half spin), Hit 3 overhead crash (hop back, sword straight up, chop into a deep lunge), plus a looping one-handed carry (Ready, 48 frames) and moving upper-body variants. IDs: M1 72670018414017 / 118829196559938 / 129888720665241, moving 112378455881304 / 120156129228871 / 131711130057198, Ready 122687599909505, ReadyMoving 74205099586374. Same lengths and strike times as before (18/18/20 frames, strike 6/6/7). All eight load in Studio at the right lengths. Pommel and handle dip up to about 0.2 stud into the thigh at a few frames (Hit 2: 0.46 into the torso at frame 7); not seen in 3D yet.

## One-handed sword E lunges and shorter handles - 2026-10-29

- E casts: `python blender/anims/build_sword_rig.py -- --onehand --casts --export` builds seven one-handed dash-slash clips (draw back low, thrust lunge held through the dash, finishing cross cut), outputs `BE_SwordRig_SwordOHE_*`. Wired into the `Sword*_2` entries of `PowerAnimations.luau` (Profile "dash"); the earlier rising-cut IDs are in the comment above each entry. Timed to the server's dash windups (Delay).
- Handles: `blender/lengthen_sword_grip.py <Template> -1.0` took the extra stud back out of all seven `BE_Held*.blend` (grip 0.9 studs again; the script now also finds unprefixed object names). Finished through `blender/finish_power_mesh.py`, FBX uploaded (`BE_PowerMesh_HeldSword` 103458148300625, Wind 73053976761771, Earth 79710038315303, Water 101974404871246, Fire 129901857689289, Shadow 87038439277306, Master 116421334234782) and the templates in `ReplicatedStorage.Assets.Swords` replaced in Studio (Size and PivotOffset from the loaded mesh / 100, palette textures kept). Swords are 5.6 studs long now (Master 6.5: its big pommel hangs about 1.4 below the fist). The place must be saved.
