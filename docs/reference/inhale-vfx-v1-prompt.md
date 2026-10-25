# Inhale VFX concept v1

Generated with the built-in image generation tool. Style source: `.claude/skills/vfx-effect/styles/chunky-cartoon.md`. Concept only; no game code changed.

## Prompt

Use case: stylized-concept.
Create one polished landscape game VFX concept sheet for the Roblox game BANDIT EATER, designed to be implemented as a lightweight real-time effect. Title: "BANDIT EATER — INHALE". Small subtitle: "CHUNKY CARTOON VFX CONCEPT".

Primary idea: a playful Kirby-inspired inhale/suction ability performed by an ORIGINAL blocky Roblox player, NOT by Kirby. Air and a yellow power bandit are being sucked IN toward the player's open mouth. Clear inward motion, never a projectile firing out. This is a visual design proposal, not an actual screenshot or sprite texture.

Main hero panel occupies the upper two-thirds: polished stylized 3D gameplay concept, eye-level three-quarter side camera, complete blue-shirt dark-pants blocky Roblox player on the LEFT facing RIGHT, cheeks slightly puffed and open round mouth. A clearly readable yellow blocky bandit on the RIGHT leans and slides left toward the player, arms flailing comically. Muted grassy low-poly arena with a few faceted gray rocks and green trees in the softly simplified background, daylight with warm highlights. Keep both characters fully visible.

Between characters is ONE clear open suction funnel: a sequence of three or four fat rounded mint crescent/ring segments, broad at the bandit end on the right and diminishing toward the mouth on the left, with a small rounded mint lip-ring near the mouth. Rings are partial/open, with generous clear spaces, so the bandit is visible THROUGH the effect. A couple of thick curved air ribbons and small white cloud puffs curve inward. Few soft rounded five-point mint-white stars drift inward, concentrated toward the mouth; white puffs shrink as they approach. Thick dark-teal shade rims on the mint shapes, soft highlights, modest glow, no black outlines. Dynamic but legible. Suction direction is right-to-left, communicate it with the bandit's lean, inward curls and one small diagram arrow pointing left beneath the funnel, not a beam coming out of the player.

Match the project's chosen chunky-cartoon style: round fat bouncy shapes, soft edges, simple candy colors, squash and stretch, friendly tone. Air palette precisely inspired by #7FE8CF body, #E8FFF8 highlight, #2FAE93 shade, plus white puffs. Bandit palette #FFD93D / #FFF3A0 / #E0A800. Clear contrast against muted green ground. Avoid opaque tornado tubes, realistic smoke, dark smoke, needle-thin streaks, lightning, aggressive explosions, rainbow colors, screen-filling bloom, or giant rings that hide the characters.

Lower third is a clean dark slate design-board strip with three small sequential panels labeled exactly "1  START", "2  PULL", "3  CAPTURE". Same left-facing relationship (player at left facing right). START: small mouth ring and a gathering white puff. PULL: open funnel and bandit moving toward mouth. CAPTURE: funnel compresses into one small rounded star-pop near mouth, captured target disappears, player has slightly puffed cheeks; this is capture/holding, not swallowing or spitting. No power transformation. Show a small 120% to 100% squash-and-stretch silhouette in capture if space allows, without dense text.

A narrow bottom swatch/asset row shows isolated samples labeled "FAT RING", "SOFT PUFF", "ROUND STAR", plus the three mint palette swatches with hex labels. These are examples of reusable components, no complex geometry. Attractive production concept presentation with restrained readable labels, ample spacing, no lengthy prose, no interface HUD, no watermark. The image should look exciting and immediately buildable with a handful of simple meshes and particles, not a cinematic effect that cannot work on a phone.

## Implementation constraints

- Preserve existing hold-F input, 19-stud targeting range, facing/line-of-sight checks, 0.7-second minimum capture time and 2-second maximum inhale window. Server controls capture; G swallow and T spit remain separate.
- Start the visuals immediately; do not add the style's generic windup delay to gameplay. Loop inward motion while the server reports inhaling, and stop on release/cancel/capture.
- Suggested initial visual budget: 4 rounded open-ring meshes, 2 curved ribbon beams, 2 emitters, no lights, roughly 20–40 puffs/stars alive. This is a proposal, not a measured runtime result.
- Use shared neutral-white ring/puff/rounded-star assets recolored with the mint palette. Keep the target silhouette visible and exaggerate inward travel rather than glow. Do not infer a new hitbox from the drawn funnel.
- Capture pop is small and local; no hitstop. Swallow, power gain and star spit require separate effects.
