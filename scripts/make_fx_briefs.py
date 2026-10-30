"""Writes one short mesh-stage brief per move-effect mesh into blender/briefs/ (BE_Fx<Name>.md).
Run from the repo root: python scripts/make_fx_briefs.py. Edit the table, not the generated briefs."""
from pathlib import Path

REF = 'docs/reference/move-concepts-v1-2026-10-26/'
CONTRACT = """## Mesh-stage contract (all models)
- Style: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`: fat rounded silhouette, low-poly broad surfaces, soft blunt tips, nothing needle-thin, readable at phone size. Soft flat shading, no realism.
- One joined static mesh, neutral white (one material) unless the brief lists material slots. No rig, animation, collision, lights, emitters, baked glow, transparency, or image textures.
- Apply all transforms; positive unit scale; no unapplied modifiers; normals outward; no zero-area faces; no floating fragments.
- Origin at the bounding-box centre. 1 Blender unit = 1 stud. Build Z-up; the Roblox mapping is Roblox(x, y, z) = Blender(x, z, -y), so Blender +Z is Roblox up (Y) and Blender +Y is Roblox -Z (forward/travel). Dimensions above are Roblox X (width) / Y (up) / Z (depth).
- Preserve the live Blender session: make a NEW scene named `<Template>`, work only there, save to `blender/BE_<Template>.blend`. No export, upload or placement in this stage.
- Review: ONE composite PNG (about 800px) saved to `blender/review/BE_<Template>_Review.png`: front, side and three-quarter views beside a 5-stud R15 scale guide, plus a 160px thumbnail. Report actual dimensions, triangle count and topology checks in a few lines.
"""

MESHES = {
    'FxTornadoBands': dict(
        title='Wind R Cyclone: tornado bands',
        ref=['wind.png (row R CYCLONE, RELEASE and IMPACT panels)'],
        size='9 x 11 x 9', tris='target 1400, max 2200',
        desc='One tall, plump tornado made of THREE thick intertwined spiral bands wound around a vertical axis (about 1.3 turns each), narrower at the bottom and broad at the top like the concept. Each band is a fat rounded ribbon (about 1.6 studs thick, 2.4 wide) with blunt rounded ends, and clear gaps between the bands so the three-band spiral reads. No funnel skin, no needle tips, no debris. The spin axis is Roblox Y, exactly centred so runtime can rotate it around Y.'),
    'FxVortexSpiral': dict(
        title='Wind E Vortex: ground spiral',
        ref=['wind.png (row E VORTEX, RELEASE and IMPACT panels)'],
        size='8 x 3.2 x 8', tris='target 900, max 1500',
        desc='A small low ground spiral: two thick rounded ribbons winding inward and rising slightly toward the centre, like a shallow funnel, with a clear outer rim ring. Ribbons about 1.2 studs wide and 0.7 thick, blunt rounded ends. The spin axis is Roblox Y.'),
    'FxGustCurl': dict(
        title='Wind Q Gust: curled air projectile',
        ref=['wind.png (row Q GUST, RELEASE panel)'],
        size='3 x 3 x 3.6', tris='target 600, max 1000',
        desc='A compact fat curled air projectile: a plump ball of air with two thick spiral ridges curling around it and one short rounded curl trailing behind. Reads as a swirl even from behind. Travel direction is Roblox -Z; the trailing curl points toward +Z. Not a beam, no spikes.'),
    'FxStoneTall': dict(
        title='Earth E Stone Field: tall chunky stone',
        ref=['earth.png (row E STONE FIELD, RELEASE and IMPACT panels)'],
        size='3.4 x 5 x 3.2', tris='target 280, max 450',
        desc='One chunky faceted stone like the tall boulders in the concept: wide at the base, slightly tapering, a lumpy flat-ish top, big flat facets (8 to 12), rounded bevelled edges, a little asymmetry. It sits as if half buried: the bottom is flat. No cracks, moss or pebbles. REWORK NOTE: the first build was a smooth tapered slab. Make it a lumpy BOULDER: irregular, asymmetric silhouette (one side bulging, the top leaning and uneven), 9 to 12 large flat facets of different sizes, deeply bevelled rounded edges, wider and rounder at the base than a column. It must read as a stone from every side, not a box or pillar.'),
    'FxGroundCrack': dict(
        title='Earth R Quake: ground crack',
        ref=['earth.png (row R QUAKE, WINDUP and RELEASE panels)'],
        size='12 x 0.25 x 12', tris='target 350, max 600',
        desc='A flat jagged crack pattern radiating from the centre: 7 to 9 main cracks, each with a few short branches, about 0.35 stud wide with pointed taper ends, in one flat sheet about 0.25 stud thick. Crack lines only: leave the space between the cracks EMPTY (no disc).'),
    'FxWhirlpoolBasin': dict(
        title='Water E Whirlpool: swirling basin',
        ref=['water.png (row E WHIRLPOOL, RELEASE and IMPACT panels)'],
        size='10 x 0.9 x 10', tris='target 1300, max 2000',
        desc='A shallow broad basin: a thick raised rounded lip around the edge, a slightly dipped interior carved with three thick spiral swirl arms turning inward (rounded raised ridges 0.2 high), and a small dip at the centre, like the concept blue pool with white swirl arms. Flat bottom. The spin axis is Roblox Y (centred). Two material slots: `Water` (basin and arms) and `Foam` (rim lip).'),
    'FxTidalWave': dict(
        title='Water R Tidal Wave: curling wave',
        ref=['water.png (row R TIDAL WAVE, RELEASE and IMPACT panels)'],
        size='12 x 7 x 6', tris='target 1800, max 2600',
        desc='One broad plump curling wave, wider than tall: a gentle sloping back (toward Roblox +Z), a tall rounded crest that curls OVER toward the travel direction (-Z) with a hollow barrel underneath, a row of thick rounded foam scallops along the crest lip and chunky foam blobs along the base. The ends taper into rounded points. Flat base. Two material slots: `Water` (body) and `Foam` (scallops and blobs). Keep the barrel open (see-through from the side). REWORK NOTE: the first build read as an open scoop with a row of ball-shaped teeth. Make it ONE plump wave: a thick rounded back that rises into a fat curling crest, a deep but clearly closed-in barrel, and the foam as 5 to 7 BIG fat cloud-like scallops fused into the crest lip and a thick foam band along the base, merged with the body (no separate floating spheres, no row of teeth). Smooth, inflated look. REWORK NOTE (owner review 2026-10-29): the first build was too faceted and crystal-like. Build it from smooth rounded forms: sculpt with a Subdivision Surface modifier (level 1 or 2), shade smooth, then APPLY the modifier and decimate to the triangle budget. Silhouette must be soft, plump and toy-like, like inflated foam, with no flat crystal facets, no sharp ridges and no spikes.'),
    'FxFlameBlob': dict(
        title='Fire E Flame Field: squat flame blob',
        ref=['fire.png (row E FLAME FIELD, RELEASE panel)', 'fusion-arcane.png (Fire E)'],
        size='2.6 x 2.8 x 2.2', tris='target 350, max 600',
        desc='A squat, rounded, bouncy flame blob: wide bulbous base, three short fat rounded lobes on top (tallest in the middle), a soft hump, no thin tongues. Cute and friendly like the small flames in the concept. Flat bottom, base 2.6 wide. REWORK NOTE (owner review 2026-10-29): the first build was too faceted and crystal-like. Build it from smooth rounded forms: sculpt with a Subdivision Surface modifier (level 1 or 2), shade smooth, then APPLY the modifier and decimate to the triangle budget. Silhouette must be soft, plump and toy-like, like inflated foam, with no flat crystal facets, no sharp ridges and no spikes. Think of three overlapping soft jelly bulbs, not a gem.'),
    'FxFlameGeyser': dict(
        title='Fire R Eruption: flame geyser',
        ref=['fire.png (row R ERUPTION, RELEASE and IMPACT panels)'],
        size='7 x 12 x 6', tris='target 1300, max 2000',
        desc='A single big rounded flame geyser: a wide stable base, one tall central column with a plump rounded top, and four to six fat rounded side lobes of different heights fused to it (like the concept), blunt soft tips, no thin spikes, no smoke. Slightly flattened front to back (Roblox Z). Flat bottom. Centred on X and Z so runtime can scale it up from the ground. REWORK NOTE (owner review 2026-10-29): the first build was too faceted and crystal-like. Build it from smooth rounded forms: sculpt with a Subdivision Surface modifier (level 1 or 2), shade smooth, then APPLY the modifier and decimate to the triangle budget. Silhouette must be soft, plump and toy-like, like inflated foam, with no flat crystal facets, no sharp ridges and no spikes. Think of a cluster of fat rounded flame lobes, like inflated candy, with a smooth bulbous base.'),
    'FxBladeChunky': dict(
        title='Sword R Blade Storm: chunky blade',
        ref=['sword.png (row R BLADE STORM, RELEASE panel)'],
        size='2.2 x 7 x 1.2', tris='target 500, max 900',
        desc='One fat stylised sword like the white orbiting blades in the concept: thick rounded blade with a soft blunt tip, a short chunky crossguard, a rounded grip and a round pommel. Blade about 1.4 wide and 0.7 thick, guard 2.2 wide. Axis: tip toward Roblox +Y, grip toward -Y. Two material slots: `Blade` and `Hilt`.'),
    'FxChunkyCrescent': dict(
        title='Shadow R Nightfall and slashes: chunky crescent',
        ref=['shadow.png (row R NIGHTFALL, RELEASE panel)', 'sword.png (row Q SLASH, RELEASE panel)'],
        size='6 x 6 x 1.8', tris='target 600, max 1000',
        desc='A thick plump crescent (a fat C) like the big violet crescent in the Nightfall concept: the arc is about 2 studs wide at the middle, tapering to soft ROUNDED tips, thickness 1.8, smooth rounded cross-section. The crescent lies in the Roblox X-Y plane with the convex outer edge on +X and the opening toward -X; the thin dimension is Roblox Z.'),
    'FxRibbonLoop': dict(
        title='Shadow E Snare: looping ribbon',
        ref=['shadow.png (row E SHADOW SNARE, RELEASE panel)'],
        size='6 x 8 x 4', tris='target 1100, max 1800',
        desc='One thick glossy rounded ribbon tube (diameter about 1.0 stud, round cross-section) that rises from a small base, curls into a figure-eight style double loop and finishes in a soft rounded end, like the purple ribbon in the concept. Smooth and plump, no flat tape, no thin ends: end caps are rounded. One continuous tube.'),
    'FxRingStack': dict(
        title='Shadow E Snare: coiled ring stack',
        ref=['shadow.png (row E SHADOW SNARE, IMPACT panel)'],
        size='4.6 x 2.8 x 4.6', tris='target 450, max 800',
        desc='Three fat donut rings stacked like a soft coil around a hole in the middle (a 1.4 stud opening), widest at the bottom (4.6) and narrower toward the top (3.4), each ring about 0.95 stud thick, slightly overlapping so they read as one wound stack. Centred on X and Z so a character can stand in the opening.'),
}


def main():
    out = Path('blender/briefs')
    for name, m in MESHES.items():
        template = name[2:]
        refs = '; '.join(REF + r for r in m['ref'])
        body = (
            f"# BE_{name} - mesh-stage brief\n\n"
            f"Template: `{template}` (will live at `ReplicatedStorage.Assets.PowerMoves.{template}`). Source: `blender/BE_{name}.blend`.\n"
            f"Move: {m['title']}.\n"
            f"Reference images (approved concepts; match their shapes, proportions and chunky-cartoon feel, ignore the concept's text and UI): {refs}\n\n"
            f"- Final size (Roblox X x Y x Z studs): **{m['size']}**.\n"
            f"- Triangle budget: **{m['tris']}**.\n"
            f"- Shape: {m['desc']}\n\n"
            + CONTRACT.replace('<Template>', name)
        )
        (out / f'BE_{name}.md').write_text(body, encoding='utf-8')
    print(len(MESHES), 'briefs written')


if __name__ == '__main__':
    main()
