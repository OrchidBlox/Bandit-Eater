"""Compose tree mesh review from Blender panels and the two supplied references."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
TMP=ROOT/'blender'/'.codex-tmp'/'trees-review'
OUT=ROOT/'blender'/'review'/'BE_Nature_Trees_mesh.png'
REF=ROOT/'docs'/'reference'/'concepts-v1-2026-10-24'
canvas=Image.new('RGB',(1000,810),'#1D242C');draw=ImageDraw.Draw(canvas)
def font(n,bold=False):return ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if bold else 'segoeui.ttf'),n)
def text(x,y,s,n=14,color='#DFE6EE',bold=False):draw.text((x,y),s,font=font(n,bold),fill=color)
def center(x,y,s,n=14,color='#DFE6EE'):
    f=font(n);box=draw.textbbox((0,0),s,font=f);draw.text((x-(box[2]-box[0])/2,y),s,font=f,fill=color)
def paste(path,xy,size=None,crop=None):
    im=Image.open(path).convert('RGBA')
    if crop:im=im.crop(crop)
    if size:im=im.resize(size,Image.Resampling.LANCZOS)
    canvas.paste(im,xy,im)
text(22,12,'BANDIT EATER  /  BROAD OAK TREES',23,bold=True)
text(22,44,'MESH REVIEW  •  asymmetric clustered crowns / branching trunks / flat facets',14,'#A9B7C5')
text(735,18,'YELLOW GAUGE = 5 STUDS',14,'#FFD43B',True)
text(735,42,'Review only • excluded from assets',12,'#A9B7C5')
paste(TMP/'front.png',(0,68))
for x,title,dim in [(168,'ROUND A  /  BROAD','22 × 27 × 20'),(500,'ROUND B  /  LEAN + SPLIT','20 × 25 × 18'),(830,'ROUND C  /  TALL ASYMMETRIC','24 × 29 × 22')]:
    center(x,478,title,14)
    center(x,503,dim+' studs  /  194 tris total',13,'#A9B7C5')
draw.line((22,539,978,539),fill='#3F4C58')
text(22,551,'SIDE SILHOUETTES',16,bold=True)
text(550,551,'ARENA REFERENCE',14,bold=True)
text(780,551,'LOBBY REFERENCE',14,bold=True)
paste(TMP/'side.png',(0,575))
paste(REF/'grassland-arena-v2.png',(550,580),(210,199),(155,250,365,449))
paste(REF/'lobby-two-leaderboards-v3.png',(780,580),(198,199),(405,145,603,344))
text(550,786,'Reference crops • appearance awaits owner approval',12,'#A9B7C5')
canvas.save(OUT)
print('Saved',OUT)
