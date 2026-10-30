"""Cut a magenta-background asset sheet into separate transparent PNGs.
python scripts/slice_sheet.py <sheet.png> <out_dir> <prefix> [--min-area N] [--size N]
Finds each asset (connected non-magenta region, padded by a small gap so a glow stays whole), keys out the magenta with a
soft edge, removes the magenta tint from outline pixels, crops to the asset and writes <prefix>_01.png, <prefix>_02.png ...
in reading order (top to bottom, left to right). A contact sheet <prefix>_contact.png numbers them for naming."""
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage


def key_out(rgb):
    r, g, b = [rgb[..., i].astype(np.float32) for i in range(3)]
    m = (np.minimum(r, b) - g) / 255.0  # 1.0 on pure magenta, about 0 on neutral colours
    alpha = 1.0 - np.clip((m - 0.50) / 0.30, 0.0, 1.0)
    spill = np.clip(np.minimum(r, b) - g, 0, None) * np.clip(m * 1.6, 0, 1) * 0.92
    r2, b2 = np.clip(r - spill, 0, 255), np.clip(b - spill, 0, 255)
    out = np.stack([r2, g, b2, alpha * 255.0], axis=-1).astype(np.uint8)
    return out, alpha > 0.5


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    opts = {a.split('=')[0]: a.split('=')[1] for a in sys.argv[1:] if a.startswith('--') and '=' in a}
    sheet, out_dir, prefix = Path(args[0]), Path(args[1]), args[2]
    min_area = int(opts.get('--min-area', 2500))
    size = int(opts.get('--size', 256))
    out_dir.mkdir(parents=True, exist_ok=True)
    rgb = np.array(Image.open(sheet).convert('RGB'))
    rgba, solid = key_out(rgb)
    grown = ndimage.binary_dilation(solid, iterations=6)
    labels, count = ndimage.label(grown)
    boxes = []
    for index, sl in enumerate(ndimage.find_objects(labels), 1):
        area = int((solid[sl] & (labels[sl] == index)).sum())
        if area >= min_area:
            boxes.append((sl[0].start, sl[0].stop, sl[1].start, sl[1].stop, index))
    # reading order: group by row using the median box height
    boxes.sort(key=lambda b: b[0])
    rows, current = [], []
    for box in boxes:
        if current and box[0] > np.mean([c[0] for c in current]) + 0.5 * np.median([c[1] - c[0] for c in boxes]):
            rows.append(current)
            current = []
        current.append(box)
    if current:
        rows.append(current)
    ordered = [box for row in rows for box in sorted(row, key=lambda b: b[2])]
    thumbs = []
    for n, (y0, y1, x0, x1, index) in enumerate(ordered, 1):
        piece = rgba[y0:y1, x0:x1].copy()
        piece[..., 3][labels[y0:y1, x0:x1] != index] = 0
        image = Image.fromarray(piece, 'RGBA')
        bbox = image.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
        image = image.crop(bbox)
        image.save(out_dir / f'{prefix}_{n:02}.png')
        thumbs.append(image)
    cell = 190
    cols = 5
    contact = Image.new('RGBA', (cols * cell, ((len(thumbs) + cols - 1) // cols) * cell), (60, 70, 95, 255))
    draw = ImageDraw.Draw(contact)
    for n, image in enumerate(thumbs):
        t = image.copy()
        t.thumbnail((cell - 20, cell - 36))
        x, y = (n % cols) * cell + (cell - t.width) // 2, (n // cols) * cell + 22
        contact.alpha_composite(t, (x, y))
        draw.text(((n % cols) * cell + 6, (n // cols) * cell + 4), f'{n + 1:02}  {image.width}x{image.height}', fill=(255, 255, 255, 255))
    contact.save(out_dir / f'{prefix}_contact.png')
    print(f'{len(thumbs)} assets from {sheet.name} -> {out_dir}')


if __name__ == '__main__':
    main()
