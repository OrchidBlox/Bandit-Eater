"""Combine Blender review panels with the supplied reference. No asset edits."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json

ROOT=Path(__file__).resolve().parents[2]
R=ROOT/'blender'/'review'
P=ROOT/'blender'/'.codex-tmp'/'cliffs-rocks-review'
BG='#1D242C'
canvas=Image.new('RGB',(1000,920),BG)
draw=ImageDraw.Draw(canvas)
font_path=Path('C:/Windows/Fonts/segoeui.ttf')
bold_path=Path('C:/Windows/Fonts/segoeuib.ttf')
def font(size,bold=False):
    return ImageFont.truetype(str(bold_path if bold else font_path),size)
def text(x,y,s,size=14,color='#DFE6EE',bold=False):
    draw.text((x,y),s,font=font(size,bold),fill=color)
def centered(x,y,s,size=14,color='#DFE6EE'):
    f=font(size);box=draw.textbbox((0,0),s,font=f)
    draw.text((x-(box[2]-box[0])/2,y),s,font=f,fill=color)
def paste(filename,xy,size=None):
    im=Image.open(filename).convert('RGBA')
    if size: im=im.resize(size,Image.Resampling.LANCZOS)
    canvas.paste(im,xy,im)

text(22,12,'BANDIT EATER  /  CLIFFS + ROCKS',23,bold=True)
text(22,42,'MESH REVIEW  •  flat facets / two stone tones / no grass caps',14,'#9FAEBC')
text(700,18,'YELLOW GAUGE = 5 STUDS',15,'#FFD43B',True)
text(700,41,'Review only • excluded from assets',12,'#B7BEC7')
paste(P/'_cliff_lineup.png',(0,67))
stats=json.loads((R/'BE_Nature_CliffsRocks_mesh.validation.json').read_text())['assets']
for x,a,title in zip([145,447,703,870],stats[:4],['STRAIGHT A','STRAIGHT B','CORNER','END']):
    centered(x,326,title,15)
    dims=' × '.join(f'{n:g}' for n in a['dimensions_W_H_D'])
    centered(x,348,f'{dims} studs  /  {a["triangles"]} tris',12,'#A9B7C5')
draw.line((22,380,978,380),fill='#3F4C58',width=1)
text(22,392,'LOW ROCKS',17,bold=True)
text(198,396,'Distinct broad footprints • flattened bases • maximum height 3.6 studs',13,'#A9B7C5')
paste(P/'_rock_lineup.png',(0,418))
for x,a,title in zip([165,415,728],stats[4:],['SMALL','MEDIUM','LARGE']):
    dims=' × '.join(f'{n:g}' for n in a['dimensions_W_H_D'])
    centered(x,611,f'{title}  /  {dims} studs  /  {a["triangles"]} tris',13)
draw.line((22,648,978,648),fill='#3F4C58',width=1)
text(22,660,'A–B–A JOIN TEST',17,bold=True)
text(210,664,'48-stud spacing • matching planar ends • zero gap',12,'#A9B7C5')
text(700,660,'CHOSEN MAP REFERENCE',15,bold=True)
paste(P/'_aba_join.png',(0,692))
ref=ROOT/'docs/reference/concepts-v1-2026-10-24/grassland-arena-v2.png'
paste(ref,(695,692),(300,200))
text(22,894,'Static checks passed. Appearance awaits owner approval. No export or in-game placement.',12,'#9FAEBC')
canvas.save(R/'BE_Nature_CliffsRocks_mesh.png')
print('Saved compact review composite:',R/'BE_Nature_CliffsRocks_mesh.png')
