"""Finish, upload and list Codex-built Fx meshes in one go.

  python scripts/finish_fx_batch.py FxWindCrescent FxAirfrontFan ...

For each name: runs blender/finish_power_mesh.py headless (FBX export), uploads the FBX with scripts/upload_assets.py, and
prints a Luau table {TemplateName = assetId} to paste into a Studio install script (template = name without the Fx prefix).
Skips names whose .blend or review image is missing."""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BLENDER = r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe"


def main(names):
    ids = {}
    for name in names:
        if not (ROOT / "blender" / f"BE_{name}.blend").exists():
            print("skip (no .blend)", name, file=sys.stderr)
            continue
        wrapper = ROOT / ".codex-tmp" / f"fin_{name}.py"
        wrapper.write_text(f"MODEL='{name}'\nexec(open(r'{ROOT / 'blender' / 'finish_power_mesh.py'}').read())\n")
        run = subprocess.run([BLENDER, "-b", "--factory-startup", "--python", str(wrapper)], capture_output=True, text=True)
        if '"exported": true' not in run.stdout:
            print("finish failed", name, run.stdout[-300:], run.stderr[-300:], file=sys.stderr)
            continue
        up = subprocess.run([sys.executable, str(ROOT / "scripts" / "upload_assets.py"), "BE_PowerMesh", "--only", f"*{name}.fbx", "--force", "--json"],
                            capture_output=True, text=True, cwd=ROOT)
        try:
            result = json.loads(up.stdout[up.stdout.index("{"):])
        except Exception:
            print("upload failed", name, up.stdout[-300:], up.stderr[-300:], file=sys.stderr)
            continue
        for _, asset in result.items():
            ids[name[2:]] = asset
    print("local ids = {" + ", ".join(f'{k}={v}' for k, v in ids.items()) + "}")


if __name__ == "__main__":
    main(sys.argv[1:])
