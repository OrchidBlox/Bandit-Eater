"""Compact review of undergrowth meshes, scale and supplied map references."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
TMP=ROOT/'blender'/'.codex-tmp'/'undergrowth-review'
REF=ROOT/'docs'/'reference'/'concepts-v1-2026-10-24'
OUT=ROOT/'blender'/'review'/'BE_Nature_Undergrowth_mesh.png'
canvas=Image.new('RGB',(1000,770),'#1D242C');draw=ImageDraw.Draw(canvas)
def font(n,bold=False):return ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if bold else 'segoeui.ttf'),n)
def text(x,y,s,n=14,color='#DFE6EE',bold=False):draw.text((x,y),s,font=font(n,bold),fill=color)
def center(x,y,s,n=14,color='#DFE6EE'):
    f=font(n);box=draw.textbbox((0,0),s,font=f);draw.text((x-(box[2]-box[0])/2,y),s,font=f,fill=color)
def paste(path,xy,size=None,crop=None):
    im=Image.open(path).convert('RGBA')
    if crop:im=im.crop(crop)
    if size:im=im.resize(size,Image.Resampling.LANCZOS)
    canvas.paste(im,xy,im)
text(22,12,'BANDIT EATER  /  UNDERGROWTH',23,bold=True)
text(22,45,'MESH REVIEW  •  low grouped planting / closed solid geometry / flat two-tone surfaces',13,'#A9B7C5')
text(750,18,'YELLOW GAUGE = 5 STUDS',13,'#FFD43B',True)
text(750,42,'Review only • excluded from assets',12,'#A9B7C5')
paste(TMP/'lineup.png',(0,76))
for x,title,dim in [(215,'BUSH A','4 × 2 × 3'),(500,'BUSH B','5 × 2.4 × 4'),(738,'FLOWER CLUMP','2 × 1.2 × 2')]:
    center(x,402,title,15)
    center(x,428,dim+' studs  /  60 tris',13,'#A9B7C5')
draw.line((22,463,978,463),fill='#3F4C58')
text(22,477,'FLOWER DETAIL',16,bold=True)
text(370,477,'ARENA REFERENCE',15,bold=True)
text(683,477,'LOBBY PLANTING REFERENCE',15,bold=True)
paste(TMP/'flower.png',(0,507))
paste(REF/'grassland-arena-v2.png',(370,515),(300,200))
paste(REF/'lobby-two-leaderboards-v3.png',(683,515),(300,200),(4,325,454,625))
text(370,731,'Sparse clusters • appearance awaits owner approval',12,'#A9B7C5')
canvas.save(OUT);print('Saved',OUT)
