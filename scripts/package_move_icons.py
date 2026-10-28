"""Slice generated move-icon sheets into runtime cards, preserving original artwork."""
from pathlib import Path
from PIL import Image
import shutil
root=Path(__file__).resolve().parents[1]
refs=root/'docs/reference/move-concepts-v1-2026-10-26'
generated=Path(r'C:\Users\Kobe\.codex\generated_images\01a16faf-ccaa-7c31-b556-1677b619a1f4')
sets=[('base-move-icons','exec-ece2af0a-306d-4a03-8a54-faa30b791d8c.png',['Wind','Earth','Water','Fire','Sword','Shadow'],[0,270,500,735,980,1230,1536]),
      ('fusion-move-icons','exec-9a76f673-adac-4bba-a1d4-bbf6bac2a48d.png',['Sword_Wind','Sword_Earth','Sword_Water','Sword_Fire','Sword_Shadow','Sword_Sword'],[0,230,465,730,935,1185,1536])]
for name,source,powers,rows in sets:
    dest=refs/(name+'.png')
    if not dest.exists():shutil.copyfile(generated/source,dest)
    im=Image.open(dest).convert('RGBA')
    for row,power in enumerate(powers):
        for col in range(3):
            box=(round(col*im.width/3),round(rows[row]*im.height/1536),round((col+1)*im.width/3),round(rows[row+1]*im.height/1536))
            card=im.crop(box).resize((256,256),Image.Resampling.LANCZOS)
            card.save(root/f'blender/export/textures/BE_MoveIcons_{power}_{col+1}.png')
print('Packaged36 ability cards')
