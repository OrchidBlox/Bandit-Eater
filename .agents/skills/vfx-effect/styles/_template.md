# Style: <name> (draft | proven)

One paragraph: what it looks and feels like, and a reference point. Say what it is not.

Helpers: the module that holds this style's constructors (for example `Vfx/<Name>.luau`) and which Kit pieces it builds on.

## Palettes

2 to 3 named palettes with hex values (element or mood), the core colour, and what stays matte. Mirror them in `Vfx.Palettes`.

## Rules

Numbered and testable from a screenshot: shape language, layers of weight, colour, materials, timing, camera and hit feedback, what never to do.

## Assets this style needs

Textures (name, what it looks like, how to make it: grey on black converted to alpha), meshes (Codex briefs), sounds.

## Timing

| Beat | Time | What happens |
| --- | --- | --- |

## Recipes by move type

| The move is | Build it like this |
| --- | --- |
| Projectile | |
| Ray or lance | |
| Ground area | |
| Strike from above | |
| Charge or aura | |
| Hit feedback | |

## Helper API (proposed signatures)

```lua
-- One line per helper: name(args) -> what it returns, and its cleanup rule
```

## Hero spells in this style

Mesh brief notes (shape, triangle budget, glow object), creature and cast-animation notes, and which pieces stay particles.

## Budget changes

Only tighten the shared budget (14 emitters, 700 particles, 3 lights, 12 beams, 40 parts, 6 outlines). Say so here if this style needs less.

## Never

Short list of the things that break the style.

## Style checklist

- [ ] Items the reviewer ticks for this style only

## Approval

Which effect it was tested on, when, and the owner's verdict.
