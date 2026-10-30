# VFX art direction

One look for every spell, so the game stops reading as a pile of separately generated effects. Use this to review a new effect, brief Codex, or judge a bought VFX pack. The numbers (budgets, exposure limits) are in [spell-vfx.md](spell-vfx.md); the per-spell ideas are in [spell-vfx-roster.md](spell-vfx-roster.md).

## The look in one line

**Anime-slick (owner's choice, 2026-10-16):** the clean, chunky, readable base below, plus anime snap: sharp tapered silhouettes, speed streaks, hard-edged two-tone shading, thin dark outlines on hero shapes, and punchy timing (instant hit, short hold, fast settle). Saturated element colours, a bright glowing core on anything that is magic, dark or desaturated mass on anything that is physical. Think Black Clover itself, not photoreal and not rounded cartoon.

## Anime-slick layer (applies to every spell and auto)

1. **Sharp silhouettes.** Hero shapes taper to points: crescents, blades, wedges, teardrops with a hard tip. No soft round blobs except water droplets and orbs, which still get a bright rim.
2. **Speed lines.** Every projectile has 2 to 4 thin hard streaks trailing it (Beams or thin stretched meshes), and every impact has a radial burst of thin lines (6 to 12) that last 0.1 to 0.2 s.
3. **Two-tone cel look.** Solid pieces use two flat tones (body and a darker shade band) plus a white-hot core. No smooth gradients on solids. Particles keep soft textures, but only as support or dust.
4. **Outline on heroes only.** The hero shape gets a thin dark rim (a slightly larger dark copy behind it, 3 to 6% bigger). Support and dust get none.
5. **Impact frame.** On heavy hits, a hard white-or-element-colour shape flash (a star, slash or ring, not the screen) for 2 to 3 frames, plus the existing hit-stop and camera kick. The brightness limit below still applies, so it is a shape, never a full-screen flash.
6. **Snappy timing.** Fast in, small overshoot, quick settle (ease-out with a tiny back). Windups can be slow to build, but the release is instant. The hold at impact is 0.045 s, then everything moves again.
7. **Shared windup glyph.** Every special opens with a magic circle at the caster's feet (the element's two colours, thin runes), 0.3 to 0.6 s, which then flares as the spell is released.
8. **Thin detail is allowed.** The old "bold over busy" rule still holds for the main shape at phone size, but fine linework (runes, streaks, cracks, outlines) is encouraged at the edges and as accents.

## Rules

1. **One idea per move.** Every special is a single sentence ("the ground freezes, then shatters"). One hero shape carries it; everything else supports it. If an element does not help the sentence, cut it.
2. **Hero, support, dust.** Three layers only. *Hero:* one big solid shape (a crystal ring, a meteor, a spike wedge). *Support:* one or two mid layers (a ring, a trail, a glow). *Dust:* tiny sparks and motes. Do not stack four mid layers.
3. **Glow = magic, matte = matter.** Energy pieces (fire core, lightning, light, runes, ice glow) are Neon with a small bright core. Physical pieces (rock, steel, bark) are SmoothPlastic or Metal and get their drama from dust, cracks and smoke, never from glow.
4. **Two colours plus a hot core per element.** Use the element palette below. No third accent colour, no rainbow gradients. Light and Shadow are the only elements allowed a strong contrast pair (gold vs violet).
5. **Contrast makes light readable.** Bright effects need something dark behind them (smoke, scorch, shadow). A flare on a bright floor disappears.
6. **Bold shape, sharp detail.** If a screenshot at phone size does not read, the effect is too detailed. The main shape stays big and simple; thin linework (runes, streaks, outlines) lives at its edges and does not fight it.
7. **Same shading on every solid.** All generated pieces use `Config/SpellVfx.MeshStyle`: SmoothPlastic by default, Neon for energy, Metal for steel, a tint where a baked colour fights its element. New pieces get an entry there before they are used.
8. **Anticipation, impact, aftermath.** Every special has a readable windup (0.3 to 1.0 s), a sharp release, and an aftermath that settles in 1 to 3 s. Autos have no windup but keep a clear impact.
9. **Hit feedback is part of the effect.** Every damaging hit flashes the enemy in the element colour and pulses at the point of impact; specials and crits add camera weight (see Hit feedback below).
10. **Rarity changes size and richness, not style.** Common is small and clean; Epic and above add a second layer and size; Mythic adds darkness or weight. Never a different look.

## Element palette (one source of truth: `SpellVfx.Palettes`)

| Element | Hot core | Body | Notes |
| --- | --- | --- | --- |
| Fire | `#FF7A1E` core, white-yellow centre | `#C8371A` | Dark brown smoke behind. Never a flat orange screen. |
| Water | `#3FA9F5` | `#E6F6FF` foam | Glossy, clean; foam on edges. |
| Wind | `#BFF5E8` | `#FFFFFF` | Thin and fast; leaves and dust show the air. |
| Earth | `#9C7A4E` | `#5E4630` | Dust, cracks and weight; no glow. |
| Plant | `#6CC24A` | `#2F7A2A` | Leaves, thorns, flowers; soft green glow only on the magic. |
| Lightning | `#FFE45C` | `#8A7CFF` | Hard white-yellow core with a violet edge; flickers. |
| Ice | `#A8E6FF` | `#FFFFFF` | Faceted, glassy, cold mist; shatters at the end. |
| Metal | `#C9CED6` | `#6E7480` | Glints and sparks; no glow. |
| Light | `#FFF2B0` | `#FFD24A` | Warm white core, gold body; clean runes. |
| Shadow | `#6A3FA0` | `#1A0F2A` | Dark mass (normal blend) with a violet rim; darkens the screen, never brightens it. |

## Auto attacks (design sheet, 2026-10-16)

The ten autos follow [docs/reference/vfx/auto-attacks-sheet.png](reference/vfx/auto-attacks-sheet.png): a sharp **arrowhead** on a white-hot shaft with the element's own wrap, then a hard star and element burst on impact. Built with `Anime.arrow` (chevron barbs, welded to the projectile holder), `streaks`, `outline` and `hit`.

| Auto | Wrap and flair on the arrow |
| --- | --- |
| Ember Bolt | Flame tongue tail and sparks; orange arrow, gold core |
| Water Jet | Blue arrow with a stream beam and droplets |
| Wind Cutter | Stays a spinning crescent blade (no arrow) with speed streaks and a sliced impact |
| Stone Shot | Stays the rock chunk, with an outline, dust and speed lines |
| Thorn Dart | Green arrow with leaves; vine-and-thorn burst on impact |
| Spark Bolt | Gold arrow with the jagged violet lightning forks trailing |
| Frost Shard | Pale-blue double-chevron crystal arrow, snowflakes, shard burst |
| Steel Shard | Grey double-chevron arrow, glints, spark shower and ring ping |
| Light Ray | Gold arrow with a two-ring halo at the tail, sparkle motes, starburst |
| Shadow Bolt | Dark orb smear with a violet arrow riding it, wisps, ink burst |

## Keep the original motion

When polishing an existing spell with a reference clip, copy the treatment (neon core, thin streaks, hard stars, outlines, mist), never the reference's motion. A lance stays a lance from its rune, a ray stays a ray. `Anime.pillar` is only for spells that already come from above (Thunderstrike). Radiant's Sunburst Lances use `Anime.travelStreaks` along each lance's own path instead. (Owner correction, 2026-10-16.)

## Pillar strike recipe (from the owner's reference reel, 2026-10-16)

The skeleton every big special can use, built with `Client/SpellVfx/Anime`: windup ring on the ground (`windupCircle`), then in one 0.06 s pop a white core, an element-coloured body, thin streak sheets and one rising glass ring (`pillar`), a hard star and spike lines at the base (`impactStar`, `impactLines`), a mist ring (`mist`) and a few dark flecks. Hold 0.14 s, thin away over 0.24 s. Multi-hit spells give the full pillar to one strike (the "hero") and a plain core beam to the others, to stay inside the 40-part budget. Thunderstrike is the first spell built this way.

## Elemental ground rings (design sheet, 2026-10-16)

| Special | Hero shape and rarity signature |
| --- | --- |
| FlameRing | A clockwise wave of tall, leaning two-tone flame wedges at the danger radius; hot cracks, low embers and dark smoke settle behind it. Secret adds a delayed inner flame ring that spirals inward. |
| FrostRing | A clockwise ripple of white-blue crystal clusters at the danger radius over spreading floor frost; the clusters glow, crack and shatter on the slow timer. Secret adds a delayed inner crystal ring and pale centre column. |

## Water specials (design sheet, 2026-10-16)

| Special | Hero shape and rarity signature |
| --- | --- |
| SplashWave | A tall travelling curl built from overlapping crest cards, a glossy blue wave body, white foam, arcing drops and a V-shaped floor wake. Secret adds a taller crest 0.2 s behind with a clean white foam line. |
| Riptide | Layered blue-and-white spiral bands pull visibly into a dark eye while spray holds the authoritative rim. Secret adds a counter-rotating spiral and a thin centre column as the pool drains. |

## Air and earth specials (design sheet, 2026-10-16)

| Special | Hero shape and rarity signature |
| --- | --- |
| GustPush | A tight inward spiral of pale air and lifted leaves snaps into thin white-and-teal radial streaks, curved wind blades and two offset shockwave rings. Secret adds a delayed, slower spiral of curved blades. |
| Rockfall | Each full-radius shadow receives a cracked boulder with tall fall streaks, then orange-gold ground cracks, rubble and settling dust cool into matte earth. Secret briefly raises and orbits a ring of small rocks over each crater. |

## Plant and lightning specials (design sheet, 2026-10-16)

| Special | Hero shape and rarity signature |
| --- | --- |
| VineSnare | Dark thorned vines coil from lime root rings into a floor web, then tighten, flower and wither into leaves and motes. Secret opens one huge centre bloom as the root ends. |
| ChainSpark | Gold-white jagged cores jump through the target chain inside violet arc bodies, with fork cards, target rings and crawling static. Secret returns the final arc to the caster and radiates small bolts from every node. |

## Hit feedback (implemented in `Client/SpellVfx/HitFeedback`)

- Every damaging hit: the enemy flashes in the element colour (a Highlight) and a pulse and a few sparks play at the impact point.
- Specials and crits ("heavy" hits): a stronger flash, a bigger pulse, a short hit-stop feel (a 0.045 s hold, then a camera kick), a small zoom punch, and a coloured damage number. Special hits also knock a (non-boss) enemy back a little.
- A budget stops multi-hit specials from flooding the screen.

## Review checklist for any new effect

- [ ] Can I say what it does in one sentence, and does the main shape show that?
- [ ] At phone size, is the main shape readable in one glance?
- [ ] Hero, support, dust: no more than three layers of weight?
- [ ] Only the element's two colours and a hot core?
- [ ] Anything glowing is magic; anything physical is matte?
- [ ] Is there something dark behind every bright effect?
- [ ] Is the windup readable and the aftermath clean (nothing left behind)?
- [ ] Does it fit the budget and the exposure limits?

## If you buy a VFX pack

The generated pieces are a fallback. A good pack replaces the hero shapes of the best moves and keeps this guide as the rulebook.

- **Look for:** one consistent style across the whole pack (not a mix), real meshes and textures you can recolour (white or grey bases), flipbook sheets for fire, smoke and explosions, and the effects built for Roblox (Beams, ParticleEmitters, MeshParts).
- **Check before buying:** a licence that allows use in a commercial Roblox game and modification; no required attribution you cannot show; the previews are in-engine footage, not renders.
- **Avoid:** packs where every effect has its own colour scheme or heavy baked lighting, and anything that needs scripts that fight the server-authority rule (the server must stay in charge of damage and targets).
- **How we would use it:** pick the 4 to 6 moves players see most (the fire, ice and shadow specials), swap their hero shapes, keep our timing, hit feedback, and server logic.
