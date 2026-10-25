"""Check all 12 joins after decoding Roblox's face orientation."""
from pathlib import Path
import numpy as np
from PIL import Image

root = Path(__file__).resolve().parents[1] / "assets/sky/cloud-panorama-v2"
raw = {key: np.asarray(Image.open(root / f"Skybox{key}.png")).astype(int)
       for key in ("Ft", "Bk", "Rt", "Lf", "Up", "Dn")}
# Convert the Roblox layout back to an inside-facing cube for edge comparisons.
front, back, right, left = raw["Ft"], raw["Bk"], raw["Lf"], raw["Rt"]
up, down = np.rot90(raw["Up"], -1), np.rot90(raw["Dn"], 1)
joins = [
    (left[:, -1], front[:, 0]), (front[:, -1], right[:, 0]),
    (right[:, -1], back[:, 0]), (back[:, -1], left[:, 0]),
    (front[0], up[-1]), (right[0], up[::-1, -1]),
    (back[0], up[0, ::-1]), (left[0], up[:, 0]),
    (front[-1], down[0]), (right[-1], down[:, -1]),
    (back[-1], down[-1, ::-1]), (left[-1], down[::-1, 0]),
]
errors = [int(np.abs(a-b).max()) for a,b in joins]
assert max(errors) <= 1, f"Broken cube edges: {errors}"
print(f"All 12 Roblox cube joins match; maximum channel difference: {max(errors)}")
