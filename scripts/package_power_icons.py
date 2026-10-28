"""Package the approved transparent atlas into padded individual sprites."""
from pathlib import Path
from PIL import Image
import shutil

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(r'C:\Users\Kobe\.codex\generated_images\01a16faf-ccaa-7c31-b556-1677b619a1f4\exec-355fcb99-cbb1-48c0-94d4-c11da863cd5f.png')
ATLAS = ROOT/'docs/reference/move-concepts-v1-2026-10-26/power-emblems-transparent.png'
if not ATLAS.exists():
    shutil.copyfile(SOURCE, ATLAS)
im = Image.open(ATLAS).convert('RGBA')
names = ['Wind','Earth','Water','Fire','Sword','Shadow','Sword_Wind','Sword_Earth','Sword_Water','Sword_Fire','Sword_Shadow','Sword_Sword']
# Atlas layout is visually verified; rows have deliberately different heights.
xs = [0, .35, .67, 1]
ys = [0, .225, .45, .70, 1]
out = ROOT/'blender/export/textures'
out.mkdir(parents=True,exist_ok=True)
for i,name in enumerate(names):
    r,c=divmod(i,3)
    box=(round(xs[c]*im.width),round(ys[r]*im.height),round(xs[c+1]*im.width),round(ys[r+1]*im.height))
    icon=im.crop(box); bounds=icon.getchannel('A').getbbox()
    assert bounds, name
    icon=icon.crop(bounds); icon.thumbnail((448,448),Image.Resampling.LANCZOS)
    canvas=Image.new('RGBA',(512,512))
    canvas.alpha_composite(icon,((512-icon.width)//2,(512-icon.height)//2))
    canvas.save(out/f'BE_PowerIcons_{name}.png')
print('Packaged 12 transparent 512px icons.')
