# Hero Sprint on the canonical R15 rig

Owner request (2026-10-25): recreate the supplied Hero Sprint image in Blender using the new R15 rig. This supersedes the native-Luau authoring attempt and the original generated-armature version.

Reference: `docs/reference/run-options-v1/01-hero-sprint.png`. Match the committed forward chest, bent pumping elbows, long opposing leg stride and short flight phase. The concept strip repeats similar silhouettes; the animation must alternate left/right contacts to make a complete running cycle. Reuse the existing white cloud texture on each contact through RunController.

Canonical source: `C:/Users/Kobe/source/repos/R15 - Blener Model/MrXen0_R15RIG_v1.2.blend`. Append into a separate scene, preserve the source file and other live scenes, keep the original bone names, rest action and rig controls. Author in FK with the rig's IK/FK switches keyed. Calibrate its axes before exporting; the old generated-armature exporter is not directly compatible.

Deliver an editable Blender Action, side/three-quarter contact sheet and looping GIF, and a KeyframeSequence exported from the evaluated character pose. Run is 16 frames at 30 fps with a duplicate end pose at frame 17, looped, Movement priority. Markers: `Footstep` with value `Left` at 0 and `Right` at 8/30 seconds. No horizontal root travel. Validate loop equality, intact joints, support-foot height, transform mapping, and the rendered silhouette against the reference.

Only the animation is imported into the existing R15 player. Keep gameplay speed, collision, combat and map untouched. Test the published track, footstep markers, idle/run/jump transitions and server replication in a fresh Studio Play. Record visual limitations honestly; numerical export checks do not establish a visual match.
