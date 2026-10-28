"""Writes one mesh-stage brief per held sword into blender/briefs/ (BE_Held<Name>.md).
Run from the repo root: python scripts/make_sword_briefs.py. Designs are the approved sheet
docs/reference/sword-concepts-v1-2026-10-28/sword-lineup.png (owner approved 2026-10-28)."""
from pathlib import Path

REF = 'docs/reference/sword-concepts-v1-2026-10-28/sword-lineup.png'
CONTRACT = """## Mesh-stage contract
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md` (chunky toy-like sword): broad blade, rounded tip, bevelled edges, simple readable guard, nothing needle-thin or realistic. Low-poly flat colours.
- One joined static mesh using the listed material slots (flat Principled colours only; no image textures, no transparency, no glow, no lights). No rig or animation.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- 1 Blender unit = 1 stud. Build Z-up; Roblox(x, y, z) = Blender(x, z, -y). So the blade tip is Blender +Z (Roblox +Y); the blade's wide faces point along Blender +-Y (Roblox Z); blade width runs along X.
- ORIGIN at the right-fist point: 0.45 below the bottom of the guard, on the grip axis (NOT the bounding-box centre). Tip direction +Y (Roblox), pommel at -Y.
- Preserve the live Blender session: make a NEW scene named `<Template>`, work only there, save to `blender/BE_<Template>.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_<Template>_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, a 160px thumbnail, and a crop of the matching sword from the reference image. Report dimensions (Roblox X/Y/Z), triangle count, material slots and topology checks in a few lines.
"""

COMMON = ("Two-handed handle (owner, 2026-10-28): the handle must fit two blocky R15 fists. Measured from the ORIGIN (where the "
          "right fist holds, just under the guard): guard bottom at +0.40, grip from +0.45 down to -1.45 (1.9 long, about 0.32 "
          "thick), pommel from -1.45 to about -1.95. Guard about 1.9 wide and 0.4 thick. Blade from the guard top (about +0.97) to "
          "the tip at about +4.65: about 3.7 long, 1.05 wide and 0.38 thick at the base, soft chamfered edges, rounded blunt tip. "
          "All seven swords share this handle and blade length so one set of two-handed animations fits every sword; each has "
          "its own silhouette and colours. Reference build: blender/BE_HeldSword.blend (base Sword, already built to this layout).")

SWORDS = {
    'HeldSword': dict(
        name='Sword (base)', tris='target 300, max 500',
        slots='`Blade` light silver, `Guard` warm grey, `Grip` navy, `Pommel` silver',
        desc='Plain silver broad blade with a clear centre ridge, a simple curved crossguard with rounded ends, a navy grip with two wrap bands and a round silver pommel. The reliable baseline.'),
    'HeldWindSword': dict(
        name='Wind Sword', tris='target 500, max 800',
        slots='`Blade` pale silver, `Swirl` mint green, `Guard` mint green, `Grip` pale mint, `Pommel` cream',
        desc='Slightly leaf-shaped silver blade with two raised mint swirl channels curling along the flat, a guard shaped like two curled leaves sweeping up, a mint grip wrap and a small cloud-curl pommel.'),
    'HeldEarthSword': dict(
        name='Earth Sword', tris='target 450, max 700',
        slots='`Blade` ochre stone, `Facets` brown stone, `Guard` grey-brown rock, `Grip` leather brown, `Pommel` rock brown',
        desc='Heavy broad blade (1.3 wide) made of big faceted stone chunks stacked along the flat, blunt rounded tip, a chunky rock-slab guard and a rock pommel. Looks carved from the ground, still chunky and rounded, no sharp spikes.'),
    'HeldWaterSword': dict(
        name='Water Sword', tris='target 500, max 800',
        slots='`Blade` bright blue, `Edge` light blue, `Guard` white foam, `Grip` deep blue, `Pommel` blue',
        desc='A rippling wave-shaped blue blade with a gently wavy edge and a small raised droplet shape near the guard, a scalloped foam-white guard made of three rounded lobes each side, deep blue grip and a water-drop pommel.'),
    'HeldFireSword': dict(
        name='Fire Sword', tris='target 550, max 850',
        slots='`Blade` orange, `Core` gold, `Guard` gold, `Grip` dark red, `Pommel` orange-red',
        desc='A blade shaped like one plump flame: rounded flame lobes along the back edge, a taller central tongue forming the tip with a soft blunt end, a gold core stripe, a gold crown-shaped guard with three rounded points, dark red grip and an ember pommel.'),
    'HeldShadowSword': dict(
        name='Shadow Sword', tris='target 500, max 800',
        slots='`Blade` violet, `Edge` lavender, `Guard` grey-lavender, `Grip` dark purple, `Pommel` purple orb',
        desc='A violet blade with a rounded crescent notch cut into the lower back edge near the guard, a lavender highlight edge, a crescent-shaped guard curling upward, a dark purple grip and a round orb pommel.'),
    'HeldMasterSword': dict(
        name='Master Sword', tris='target 600, max 900',
        slots='`Blade` bright silver, `Guard` gold, `Star` blue, `Grip` navy, `Pommel` gold',
        desc='The oversized broad silver blade (1.3 wide, about 4.1 long) with a rounded tip, a broad warm gold winged guard with a rounded blue five-point star inset in the middle, a navy grip with a gold band and a round gold pommel with a small star. The grandest of the set.'),
}


def main():
    out = Path('blender/briefs')
    for template, m in SWORDS.items():
        body = (
            f"# BE_{template} - mesh-stage brief\n\n"
            f"Template: `{template}` (held weapon for {m['name']}). Source: `blender/BE_{template}.blend`.\n"
            f"Approved design (owner approved 2026-10-28; match its silhouette and colours, ignore text and UI): `{REF}` panel \"{m['name'].upper()}\". "
            f"Standalone view and held view are both shown.\n\n"
            f"- Triangle budget: **{m['tris']}**.\n"
            f"- Dimensions: {COMMON}\n"
            f"- Material slots: {m['slots']}.\n"
            f"- Shape: {m['desc']}\n\n"
            + CONTRACT.replace('<Template>', template)
        )
        (out / f'BE_{template}.md').write_text(body, encoding='utf-8')
    print(len(SWORDS), 'sword briefs written')


if __name__ == '__main__':
    main()
