"""Convert R15 character actions from Blender into Roblox KeyframeSequence files.

Run with Blender (headless), from the repo root:

    blender -b blender/anims/HeroR15.blend --python scripts/export_r15_animations.py -- \
        --rig R15Rig --actions Draw SwingL SwingR --prefix Hero

Writes blender/export/animations/<prefix>_<Action>.rbxmx; upload them with
`python scripts/upload_assets.py <prefix> --include-animations`.

The rig: an armature whose bones are named after the R15 parts (LowerTorso,
UpperTorso, Head, RightUpperArm, ...) with each bone's head at its joint pivot from
scripts/rigs/r15_rest.json, converted to Blender space as (-x, z, y + rootHeight)
(the character faces Blender -Y). Roblox animates an R15 joint with Pose CFrames
equal to the joint's Transform, a rotation in the parent's frame at the pivot; the
game's joints have no rest rotation, so that frame is aligned with the character.
For every sampled frame the script takes each bone's rotation relative to its
parent and its rest pose, expresses it in character-aligned axes, maps Blender axes
to Roblox axes, and writes it as that bone's Pose. Only the LowerTorso pose carries
a translation (the whole body moving, for example a crouch or a step).
"""

import argparse
import json
import sys
from pathlib import Path
from html import escape

import bpy
from mathutils import Matrix, Vector

REPO = Path(__file__).resolve().parent.parent
REST_FILE = REPO / "scripts" / "rigs" / "r15_rest.json"
OUT_DIR = REPO / "blender" / "export" / "animations"

TREE = {
    "HumanoidRootPart": ["LowerTorso"],
    "LowerTorso": ["UpperTorso", "RightUpperLeg", "LeftUpperLeg"],
    "UpperTorso": ["Head", "RightUpperArm", "LeftUpperArm"],
    "RightUpperArm": ["RightLowerArm"],
    "RightLowerArm": ["RightHand"],
    "LeftUpperArm": ["LeftLowerArm"],
    "LeftLowerArm": ["LeftHand"],
    "RightUpperLeg": ["RightLowerLeg"],
    "RightLowerLeg": ["RightFoot"],
    "LeftUpperLeg": ["LeftLowerLeg"],
    "LeftLowerLeg": ["LeftFoot"],
}
LOOPED = {"Idle", "Walk", "Run", "CombatIdle", "CombatWalk"}
# Roblox AnimationPriority tokens: Idle 0, Movement 1, Action 2, Action2 3, Action3 4.
PRIORITY = {"Idle": 0, "CombatIdle": 0, "Walk": 1, "Run": 1, "CombatWalk": 1, "SwingL": 3, "SwingR": 3, "Draw": 4, "TornadoCast": 3, "BladesCast": 3, "BuckshotCast": 3, "SpiralFlameCast": 3, "CradleCast": 3, "WaterballCast": 3, "GroundSlamCast": 3, "TreeCast": 3, "BloomCast": 3, "ThunderKickCast": 3}

# Blender (character faces -Y, right side -X, Z up) -> Roblox (faces -Z, right +X, Y up).
TO_ROBLOX = Matrix(((-1, 0, 0), (0, 0, 1), (0, 1, 0)))


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--rig", default="R15Rig")
    parser.add_argument("--actions", nargs="+", required=True)
    parser.add_argument("--prefix", default="Hero")
    parser.add_argument("--step", type=int, default=1, help="sample every Nth frame")
    parser.add_argument("--slot", help="Blender 5 action slot identifier, when an action has multiple slots")
    return parser.parse_args(argv)


def check_rest(rig, rest):
    """Stop if a bone head is not where r15_rest.json puts its joint."""
    height = rest["rootHeight"]
    bad = []
    for name, info in rest["joints"].items():
        bone = rig.data.bones.get(name)
        if bone is None:
            bad.append(f"{name}: missing")
            continue
        x, y, z = info["pivot"]
        expected = Vector((-x, z, y + height))
        actual = bone.head_local
        if (actual - expected).length > 0.08:
            bad.append(f"{name}: head {tuple(round(v, 3) for v in actual)} expected {tuple(round(v, 3) for v in expected)}")
    if bad:
        raise SystemExit("Rig does not match r15_rest.json:\n  " + "\n  ".join(bad))


def joint_transform(pose_bone, is_root: bool):
    """The bone's Transform as (rotation 3x3 in Roblox axes, translation in Roblox axes)."""
    bone = pose_bone.bone
    rest = bone.matrix_local
    pose = pose_bone.matrix
    if pose_bone.parent:
        parent_rest = pose_bone.parent.bone.matrix_local
        parent_pose = pose_bone.parent.matrix
        local_rest = parent_rest.inverted() @ rest
        local_pose = parent_pose.inverted() @ pose
    else:
        local_rest = rest
        local_pose = pose
    delta = local_rest.inverted() @ local_pose  # in the bone's own rest frame
    rest_rot = rest.to_3x3()
    rotation_arm = rest_rot @ delta.to_3x3() @ rest_rot.inverted()  # character-aligned axes
    rotation = TO_ROBLOX @ rotation_arm @ TO_ROBLOX.transposed()
    translation = Vector((0, 0, 0))
    if is_root:
        translation = TO_ROBLOX @ (pose.translation - rest.translation)
    return rotation, translation


def pose_xml(lines, name, rotation, translation):
    cells = "".join(f"<R{i}{j}>{rotation[i][j]:.6f}</R{i}{j}>" for i in range(3) for j in range(3))
    lines.append('<Item class="Pose"><Properties>')
    lines.append(f'<string name="Name">{name}</string>')
    lines.append(f'<CoordinateFrame name="CFrame"><X>{translation.x:.5f}</X><Y>{translation.y:.5f}</Y><Z>{translation.z:.5f}</Z>{cells}</CoordinateFrame>')
    lines.append('<token name="EasingDirection">0</token>')
    lines.append('<token name="EasingStyle">0</token>')
    lines.append('<float name="Weight">1</float>')
    lines.append("</Properties>")


def select_action_slot(rig, action, identifier=None):
    """Select the intended object's Blender 5 slot; never guess among several."""
    rig.animation_data_create()
    rig.animation_data.action = action
    slots=list(getattr(action, 'slots', []))
    if not slots:
        return None  # legacy single-slot actions
    if identifier:
        matches=[s for s in slots if s.identifier==identifier]
    else:
        matches=[s for s in slots if s.identifier=='OB'+rig.name or getattr(s,'name_display','')==rig.name]
        if not matches and len(slots)==1:
            matches=slots
    if len(matches)!=1:
        raise ValueError('Select an explicit action slot for '+rig.name+': '+str([s.identifier for s in slots]))
    rig.animation_data.action_slot=matches[0]
    return matches[0].identifier


def write_action(rig, action_name, prefix, step, slot_identifier=None):
    action = bpy.data.actions.get(action_name)
    if action is None:
        raise SystemExit(f"Action {action_name} not found")
    select_action_slot(rig, action, slot_identifier)
    scene = bpy.context.scene
    fps = scene.render.fps / scene.render.fps_base
    start, end = (int(round(v)) for v in action.frame_range)
    identity = Matrix.Identity(3)
    lines = ['<roblox version="4">', '<Item class="KeyframeSequence"><Properties>',
             f'<string name="Name">{escape(action_name)}</string>',
             f'<bool name="Loop">{"true" if action_name in LOOPED else "false"}</bool>',
             f'<token name="Priority">{PRIORITY.get(action_name, 2)}</token>', "</Properties>"]
    if step<1:
        raise ValueError('Sampling step must be positive')
    frames = sorted(set(range(start, end + 1, step)) | {end} |
                    {m.frame for m in action.pose_markers if start<=m.frame<=end})
    for frame in frames:
        scene.frame_set(frame)
        lines.append('<Item class="Keyframe"><Properties>')
        lines.append('<string name="Name">Keyframe</string>')
        lines.append(f'<float name="Time">{(frame - start) / fps:.9f}</float>')
        lines.append("</Properties>")
        for marker in action.pose_markers:
            if marker.frame!=frame:
                continue
            name,value=('Footstep',marker.name[len('Footstep_'):]) if marker.name.startswith('Footstep_') else (marker.name,'')
            lines.append('<Item class="KeyframeMarker"><Properties>')
            lines.append(f'<string name="Name">{escape(name)}</string>')
            lines.append(f'<string name="Value">{escape(value)}</string>')
            lines.append('</Properties></Item>')

        def walk(name):
            if name == "HumanoidRootPart":
                pose_xml(lines, name, identity, Vector((0, 0, 0)))
            else:
                rotation, translation = joint_transform(rig.pose.bones[name], name == "LowerTorso")
                pose_xml(lines, name, rotation, translation)
            for child in TREE.get(name, []):
                walk(child)
            lines.append("</Item>")

        walk("HumanoidRootPart")
        lines.append("</Item>")
    lines += ["</Item>", "</roblox>"]
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / f"{prefix}_{action_name}.rbxmx"
    path.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {path} ({len(frames)} keyframes, {(end - start) / fps:.2f} s)")
    return path


def main():
    args = parse_args()
    rest = json.loads(REST_FILE.read_text())
    rig = bpy.data.objects.get(args.rig)
    if rig is None or rig.type != "ARMATURE":
        raise SystemExit(f"Armature {args.rig} not found")
    check_rest(rig, rest)
    for name in args.actions:
        write_action(rig, name, args.prefix, args.step, args.slot)


if __name__ == '__main__':
    main()
