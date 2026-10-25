# Hero Sprint run and footstep puffs

Owner selected Hero Sprint (option 1) with a little Bouncy Runner (option 3) bounce, then requested Blender animation and game integration. Reference boards: [run options](reference/run-options-v1/README.md). Animation style: snappy action. Puffs reuse the approved chunky-cartoon cloud image.

## Scope

- R15 in-place run, Movement priority, 16-frame loop at 30 fps. Moderate forward lean, opposite arm/leg pumps, small vertical hip bounce, torso counter-rotation.
- Footstep markers named `Footstep`, values `Left` and `Right`, at frames 1 and 9. Small white puffs only at grounded moving contacts, using `rbxassetid://71229989533127`.
- Existing default Animate remains responsible for idle, jump, fall and other states. Movement speed, collision, combat and arena/lobby layout are unchanged. R6 retains the default animation.
- Client starts the local player's custom track on the existing server-created Animator; other clients can observe the replicated track and handle its markers locally. No new remote is needed. See [Roblox Animator replication](https://create.roblox.com/docs/reference/engine/classes/Animator) and [animation events](https://create.roblox.com/docs/animation/events).

## Source and rig

The neutral rest data in `scripts/rigs/r15_rest.json` was reconstructed from the live R15 character's AnimationConstraint attachments using forward kinematics, not its moving part poses. Fifteen joints, identity attachment rotations. This avoids capturing the default idle pose as the rig rest pose. No appearance or physical rig changes are imported into the player.

The R15 exporter starts from the existing clover-ascension `scripts/export_r15_animations.py`, adapted locally for marker export and reusable invocation. The original file in clover-ascension is unchanged.

## Validation status

Completed on 2026-10-24:

- [Blender source](../blender/anims/BE_HeroSprint.blend), [pose sheet](../blender/review/BE_HeroSprint_Run.png), [looping preview](../blender/review/BE_HeroSprint_Run.gif), [export report](../blender/review/BE_HeroSprint_Run.validation.json). 17 sampled keys over 16/30 seconds, 15 bones plus HumanoidRootPart, exact first/last pose equality, finite/orthonormal pose matrices, Movement priority, loop flag and exactly two alternating markers. Blender support-foot clearance error below 0.000001 stud; 0.16-stud vertical bounce; 14-degree torso lean; no horizontal root animation.
- Uploaded animation `rbxassetid://95948628269299`. Marketplace confirms type Animation (24), creator group 683974855. New config and controller verified synced through Rojo before fresh Play.
- Actual D-key running in the lobby moved the character about 36 studs in 1.8 seconds at unchanged WalkSpeed 20. Custom track loaded with Length 0.53333336, Movement priority and Looped=true. Server observed the same published track playing at 1.25x, confirming owner-client-to-server replication.
- Nine sequential foot contacts were observed Left/Right/Left/Right/Left/Right/Left/Right/Left, with nine emitted puffs. Steady-speed contact spacing approximately 0.21 seconds. Two emitters maximum per character, zero new parts/lights/beams. Emitters are reused, not spawned every frame.
- Idle count stayed at 13 emitted across the idle test, with no custom playing track. Jump/freefall stopped the track; a fresh monitor recorded 9 airborne samples and zero airborne emissions. Landed movement resumed the run automatically.
- Death removed both emitters and the character binding; connections dropped from 10 idle to 7 player/global listeners. Respawn restored one character binding and 10 idle connections. Running after respawn emitted four new puffs and recreated exactly two emitters. Controller Stop returned 0 bindings/tracks/emitters/connections; Start restored exactly one binding/10 idle connections. No failed loads.
- The animation and initial puff treatment were visually inspected in the live lobby. The final puff readability adjustment moves its center 0.22 stud above the foot bottom, uses white tint, size 0.35->1.1->1.25 and lifetime 0.3-0.4 seconds, avoiding floor clipping. Runtime/jump/respawn tests passed with this adjustment. A repeat grass-area screenshot was blocked by the minimized Studio window/input guard, so final visual tuning of that adjustment still needs owner review.
- Selene: 0 errors/warnings/parse errors (cached Roblox API); Rojo build passed. Console contained only existing Studio DataStore API-disabled warnings and the unrelated asset 203785492 type mismatch, plus the test camera reset notice.
- Arena/lobby protected snapshot unchanged. All temporary camera, sampling and teardown scripts existed only in Play and were removed by stopping Play. Studio was left in Edit. This feature requires no Studio-only asset template: it is restored by Rojo source plus the published animation ID.

Limits: full second-client observer testing, mobile visual/performance testing and extreme avatar proportion testing have not been performed. Local playback, server receipt, default-appearance R15 movement, marker gating and lifecycle cleanup were tested. No public game publish or Git push was performed.
