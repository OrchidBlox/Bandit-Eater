"""Reproject the approved equirectangular panorama into Roblox cubemap faces."""
from pathlib import Path
import argparse

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=Path, default=ROOT / "docs/reference/concepts-v1-2026-10-24/cloud-sky-panorama.png")
parser.add_argument("--dest", type=Path, default=ROOT / "assets/sky/cloud-panorama-v2")
args = parser.parse_args()
SOURCE, DEST = args.source, args.dest
DEST.mkdir(parents=True, exist_ok=True)
pixels = np.asarray(Image.open(SOURCE).convert("RGB"), dtype=np.float32).copy()
h, w, _ = pixels.shape
# Condition the generated panorama's longitude join and poles before projection.
# Both sides meet at the same colour; fade the correction out over 3% of width.
band = max(2, w // 32)
join = (pixels[:, 0] + pixels[:, -1]) / 2
left, right = pixels[:, 0].copy(), pixels[:, -1].copy()
for i in range(band):
    weight = (1 - i / band) ** 2
    pixels[:, i] += (join - left) * weight
    pixels[:, -1-i] += (join - right) * weight
for pole, step in ((0, 1), (h-1, -1)):
    colour = pixels[pole].mean(axis=0)
    for i in range(max(2, h // 32)):
        weight = (1 - i / max(2, h // 32)) ** 2
        row = pole + step * i
        pixels[row] = pixels[row] * (1-weight) + colour * weight

size = 1024
a, b = np.meshgrid(np.linspace(-1, 1, size), np.linspace(1, -1, size))
one = np.ones_like(a)
# Projection coordinates, not Roblox property names. Roblox reverses the lateral
# face labels relative to this inside-facing convention and rotates the caps.
# https://devforum.roblox.com/t/custom-skyboxes-101/2849003
faces = {
    "SkyboxFt": (a, b, -one), "SkyboxBk": (-a, b, one),
    "SkyboxRt": (one, b, a), "SkyboxLf": (-one, b, -a),
    "SkyboxUp": (a, one, b), "SkyboxDn": (a, -one, -b),
}
preview = Image.new("RGB", (size*4, size*3), (35, 40, 50))
positions = {"SkyboxUp": (1,0), "SkyboxLf": (0,1), "SkyboxFt": (1,1),
             "SkyboxRt": (2,1), "SkyboxBk": (3,1), "SkyboxDn": (1,2)}
for name, (x,y,z) in faces.items():
    length = np.sqrt(x*x+y*y+z*z)
    u = (np.arctan2(x, -z)/(2*np.pi)+0.5)*(w-1)
    v = (0.5-np.arcsin(y/length)/np.pi)*(h-1)
    x0, y0 = np.floor(u).astype(int), np.floor(v).astype(int)
    x1, y1 = np.minimum(x0+1,w-1), np.minimum(y0+1,h-1)
    dx, dy = (u-x0)[...,None], (v-y0)[...,None]
    output = ((pixels[y0,x0]*(1-dx)+pixels[y0,x1]*dx)*(1-dy)
              +(pixels[y1,x0]*(1-dx)+pixels[y1,x1]*dx)*dy)
    face = Image.fromarray(np.clip(output,0,255).astype(np.uint8))
    px, py = positions[name]
    preview.paste(face, (px*size,py*size))
    export_name = {"SkyboxRt": "SkyboxLf", "SkyboxLf": "SkyboxRt"}.get(name, name)
    if name == "SkyboxUp":
        face = face.transpose(Image.Transpose.ROTATE_90)
    elif name == "SkyboxDn":
        face = face.transpose(Image.Transpose.ROTATE_270)
    face.save(DEST / f"{export_name}.png")
preview.thumbnail((1600,1200))
preview.save(DEST / "preview.jpg")
print(f"Prepared six {size}x{size} faces in {DEST}")
