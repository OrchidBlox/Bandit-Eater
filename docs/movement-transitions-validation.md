# Movement transitions validation - 2026-10-25

Implemented the approved concept in five actions on the original MrXen0 R15 rig, in a separate scene. Canonical rig and V5 source hashes remain unchanged. Builder: `blender/anims/build_movement_transitions.py`; source, previews and numeric report are under `blender/anims` and `blender/review`.

## Checked

- Evaluated deform exports contain valid joint mappings. Start/LandRun final and Stop initial transforms equal the V5 first frame exactly.
- Reviewed actual-rig contact sheet and decoded preview frames. Authored-frame source foot clearance passes; retargeted avatar box estimate reaches 0.030 studs below ground. This is not a claim of perfect continuous foot clearance. Supplementary subframe helper failed and was not used as evidence.
- Uploaded five RBXMX assets under the experience owner and configured their IDs; see `animations.md`.
- Selene: zero errors/warnings using cached Roblox API; Rojo build passed.
- Fresh Studio Play with synchronized code loaded all five tracks, no load failures or fallbacks. Real keyboard input produced Start -> Run -> Stop, Takeoff -> LandIdle, and Takeoff -> LandRun -> Run.
- Rapid direction changes and jump during startup produced two recorded interruptions without a stuck transition.
- Recorded sample sequence had zero puff increments during Jumping/Freefall. Four landings emitted eight landing puffs, using two reused emitters. Respawn added one expected grounded landing.
- Controller Stop returned zero connections, tracks, emitters and bound characters. Death/respawn rebound one character with five loaded transitions and two emitters. Running still worked afterward.
- Server Animator received the V5 run and a nonlooping LandIdle track at Movement priority. This checks replication to the server, not a second observing client.
- Inspected the actual avatar's stationary landing compression in Studio. Temporary pose/camera/debug scripts existed only in Play; stopped Play to remove them.

## Remaining visual acceptance

Owner should judge transition feel during regular play. Multiple clients, every avatar proportion, slopes/ledges and combat animation overlap were not exhaustively tested. Higher-priority Action tracks retain precedence by the priority configuration; live combat overlap was not tested here. No movement speed, jump physics, map or gameplay balance changed.

The animation skills in `.claude` and `.agents` now require applicable movement transitions, interruption handling, grounded contact effects and in-game validation. The template-game skill mirrors were also updated in the preceding concept task.
