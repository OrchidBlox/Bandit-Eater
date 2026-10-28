# Bandit Eater: Game Design Document (Roblox)

Source of truth for development. Luau, Rojo project structure, VS Code/GitHub workflow, and server-authoritative gameplay.

## Scope and approval

- **V1: build now.** One continuous PvP map with roaming power-star pickups, not timed matches.
- **V2: approved roadmap direction, not authorization to implement early.** Currency-based permanent base starter unlocks and cosmetic mastery.
- **V3: future candidates and keep-or-delete decisions.** Nothing is authorized for implementation.
- Items marked OPEN or PROPOSED require developer approval before assuming behavior. Suggested tuning is not a locked value.
- The approved roaming-star and active/bench rules supersede bandit NPCs, fixed pickup spawns and earlier swallow replacement proposals.
- Latest rules below supersede earlier round-based, separate-PvE-zone, weakening, unlock-meter, permanent-fusion, and cosmetic-only-monetization proposals.

# PART 1: V1 - ROUNDLESS PvP / POWER-STAR PILOT

## 1. Pitch and style

A cartoon action brawler where players fight each other, inhale bouncing power stars to acquire powers, spit stars, and fuse compatible powers.

One-line pitch: “Chase bouncing stars, swallow their powers, and fuse them while fighting other players.”

Visual direction: low-poly nature, chunky cartoon VFX, exaggerated animations, readable silhouettes, and clearly telegraphed attacks. Player combat is the focus. Roaming power stars replace the NPC bandit collection/combat loop; stars are pickups, not enemies.

### Shared power emblems (owner approved, 2026-10-26)

Use one recognizable emblem per power as a shared visual language across roaming power stars, active/bench slot displays, swallow/equip effects, move icons and fusion previews. Reuse the same symbol and power palette across these contexts instead of designing unrelated icons for each screen or effect.

- Emblems follow the chunky-cartoon style: bold rounded silhouettes, simple readable shapes, soft shade-color outlines and restrained highlights. They must remain distinguishable at small phone sizes and without relying on color alone.
- The approved swallow concept establishes Fire as a flame and Water as a drop. Final artwork and the remaining power/fusion symbols remain open to visual iteration; approval of this system does not lock every emblem design.
- A move icon may combine the power emblem with its own action silhouette so Q/E/R remain distinguishable. Fusion previews should communicate the ingredients and result clearly; the resulting fusion needs a recognizable identity rather than a crowded stack of symbols.
- Keep emblem identity consistent while adapting size, background and brief animation to the context. Slot labels and active/bench placement must remain clear; color alone must not indicate which power is equipped.
- Use the existing power identity as the common reference for emblem assets and palettes. Emblem animation is presentation only and never changes power ownership, slot rules, cooldowns or hitboxes.

**Status:** approved design direction, not a completed reusable asset library or runtime integration. The owner may revise the artwork later. Reference: [Power Swallow animation + VFX concept](reference/move-concepts-v1-2026-10-26/power-swallow.png).

## 2. World and session loop

One compact continuous combat map with a safe lobby/spawn area. No rounds, queue, match timer, winner screen, or match payouts.

**Owner decision, 2026-10-28: no more "arena" matches.** The combat map is a **constant free-for-all (FFA)** that is always running. A player enters it by **stepping on the pad in the lobby, which teleports them into the FFA**; there is no "Join live arena" or "Join next round" flow, no intermission, no Match/Results phases and no match timer. "Arena" is retired as a game term (it only survives in older wording, asset names and code identifiers such as `ArenaTeleportPad`); say "the FFA" or "the combat zone". Players join and leave the FFA at any time, and the loop below runs continuously.

**Implementation status:** the current build still runs the legacy match/intermission/results cycle, a "Join live arena" button and fighter bots. Replacing it with the constant FFA (pad teleport, always-on combat, respawn into the FFA, removal of the round, scoring and results UI) is a design change that still needs to be built; it is not part of the effects and animation work in progress.

1. Spawn with one random base starter in slot 1; slot 2 is empty.
2. Step on the lobby pad to teleport into the FFA and fight players.
3. Find a roaming power star, inhale it, then swallow for a temporary power or spit it as a projectile.
4. Swap powers or optionally fuse a valid pair.
5. Earn currency through meaningful combat participation and approved objectives.
6. On KO, lose current temporary powers/fusions and respawn with a fresh random base starter.
7. Keep currency, cosmetics, and saved stats.

Permanent starter selection is V2, not V1. Bouncing power stars encourage movement and provide temporary powers; player combat remains the main event.

OPEN: exact safe-area boundaries, damage protection, spawn protection, and rules preventing safe-zone abuse.

## 3. Controls and universal defense

- M1: basic attack combo.
- Dash: 20-stud forward burst with collision checks, easing into recovery; 3-second cooldown and 0.2-second i-frames. Presentation lasts 0.5 seconds, with movement from 2/30 to 11/30 seconds.
- Jump, inhale, swallow, spit, and swap.
- **Double jump (owner approved, 2026-10-25): one normal ground jump plus exactly one extra jump while airborne.** The extra jump is consumed on use and resets on landing; it cannot refresh repeatedly in midair. Use the normal jump input again for the extra jump on keyboard, mobile, and gamepad.
- The extra jump should feel strong and playful, with a distinct upward kick/tuck animation and a white cloud puff beneath the player. This deliberate airborne jump burst is separate from grounded footstep/landing puffs. Exact jump height, impulse, and animation timing remain playtest tuning. Runtime double jump is implemented for playtesting: one server-approved extra impulse, landing reset, dedicated takeoff/double-jump/fall clips and cloud burst. Fresh Studio keyboard testing passed; mobile/gamepad and owner visual acceptance remain pending.
- Q/E/R: three power moves, all unlocked immediately.
- Mobile and gamepad support.
- No bubble shield/block. No shield guard-break system.
- Catch eligible incoming attacks from the front during a brief timed inhale window. Holding indefinitely does not provide continuous protection.
- Missing gives no protection and triggers a cooldown before another catch attempt. It does not freeze or stun the player; movement and dash remain available under their normal rules.
- Melee, rear attacks, and uncatchable attacks can still hit during inhale. No general inhale invulnerability.

OPEN: catch-window duration, cooldown, input bindings/state transitions, how pickup-star and incoming-projectile inhaling share controls/cooldowns, and capacity while already holding a star/projectile. The earlier 0.4-second catch window was illustrative only.

## 4. Powers and two combat slots

Launch base roster: **Wind, Earth, Water, Fire, Sword, Shadow**. Inhale is universal, never a seventh power.

Each power has:

1. A fast low-cooldown attack.
2. Utility/control, not merely another dash.
3. A large signature on a longer cooldown.

Every base power has at least one clearly recognizable inhaleable attack. Sword has a small traveling slash; ordinary melee swings are not inhaleable. Use shape and animation as well as color for readability.

- Two life-held combat slots: slot 1 is active; slot 2 is benched.
- Swap exchanges active and benched powers, with a short cooldown; approximately 1-2 seconds is suggested tuning.
- Cooldowns keep ticking while benched. Moving a power between slots never refreshes its cooldowns.
- Duplicate powers allowed, including Sword + Sword.
- **Swallow automatically places the new power in active slot 1 and moves the previous active power into slot 2.** If Fire is active, swallowing Sword makes Sword active and benches Fire.
- **When both slots are full, the old benched power is replaced.** Example: Fire active + Water benched -> swallow Sword -> Sword active + Fire benched; Water is discarded.
- If no power is active, the new power fills the active slot; an empty previous active slot adds no benched power.
- Preview which benched power will be lost before the player swallows. No slot-replacement selection menu is needed for this approved rule.
- Spitting preserves both equipped powers. Temporary loadouts are never saved as owned powers.

This owner-approved rule (2026-10-25) supersedes fixed-slot activation, selectable replacement, and the proposed active-only replacement that preserved the old bench. Preserve retained powers' cooldowns and do not use swallowing or swapping to reset cooldowns.

### Fusion design principle (owner direction, 2026-10-28; internal, not shown to players)

Most fusions are built as **element + item**: an element (Fire, Water, Shadow, Wind, Earth, and later ones such as Light) combined with an item (Sword now; bombs, bows and similar later). Each item gives the fusion its held object, M1 combo and move shapes, and the element supplies the palette and effects, as the current Sword + element kits already do. A few **rare fusions** are allowed to break this pattern (for example element + element, or something unique); they are exceptions, not the rule.

Intent for later monetization (V2, when currency-based power purchases are designed): **items cost more than elements**, because items carry most of the fusions. This does not change the V1 rules above, authorizes no purchase or economy work now, and the exact prices remain OPEN. Light, Bomb and Bow are not in the launch roster (Bomb is already listed as a shelved power candidate in Part 3); any new element or item still needs owner approval before it is built.

## 5. Roaming power stars (replaces bandit NPCs)

**Official pickup name (owner confirmed, 2026-10-26): Power Stars.** Use "Power Star" for one ability pickup and "Power Stars" for multiple pickups in player-facing text, onboarding, UI and asset descriptions. Players inhale and swallow Power Stars to obtain powers. A fired/spat star projectile must remain visually and contextually distinct from a roaming Power Star pickup.

**Owner approved, 2026-10-25:** remove the bandit NPC concept from the current game loop. Powers come from bouncing stars that spawn randomly around the arena and move around it, not fixed spawn pads or KO drops. The project name remains Bandit Eater pending a separate naming decision.

- Stars use the six base powers: Wind, Earth, Water, Fire, Sword, Shadow. Each has a recognizable color and symbol; do not rely on color alone.
- Spawn at random valid, reachable locations inside the playable combat arena. Spread spawns across the map so random placement does not leave large areas empty. Avoid the safe lobby, solid scenery, inaccessible surfaces and out-of-bounds locations.
- Gentle bounces and slow movement make stars playful to chase without becoming a chore. They roam rather than merely bobbing at a fixed spawn point. Keep them within the arena and recover stuck/out-of-bounds stars.
- Inhaling reliably draws a nearby eligible star toward the player. Nearly instant collection; no health, weakening, stagger, NPC attack, or damage requirement.
- Swallow the held star for its temporary power, or spit it as a projectile. A map pickup and a fired projectile must remain visually and mechanically distinguishable.
- Collected stars are replenished after a delay at new random valid positions. Use a capped population, balanced map coverage and restrained effects so combat remains readable.
- Server owns spawn selection, power identity, pickup claims and respawn timing; two players cannot collect the same star.
- OPEN tuning: population, power distribution, bounce height, movement speed, inhale timing/range, respawn delay and recovery thresholds. No exact values are locked by this approval.

Rare/stronger unique powers are **not in V1 or V2**. They are later-only candidates and may only ever grant temporary powers.

PROPOSED: prototype without combat bots. Round-based bot fill is removed; whether low-population play needs separate fighter bots remains a playtest decision. These are distinct from the removed power-bandit NPCs.

**Implementation status:** design change only; current bandit runtime and old swallow-slot behavior still need replacement. The earlier V1 audit describes the pre-star implementation and its bandit/slot recommendations are superseded by this section.

## 6. Swallow and star spit

### Swallow presentation (owner accepted for now, 2026-10-26)

Use the [five-stage concept](reference/move-concepts-v1-2026-10-26/power-swallow.png) as the current animation/VFX direction: **Gather -> Gulp -> Power Pop -> Equip -> Ready**. A separate pose-only strip in the image guides animation authoring. The owner may change the look later; exact durations and frame counts are not locked.

1. **Gather:** draw the already-held power star toward the mouth with a small inward motion and white puffs.
2. **Gulp:** tilt the head back slightly, raise the shoulders and compress the pose through joints; shrink the star into the mouth.
3. **Power Pop:** lift the chest and open the arms in a small grounded rebound. Briefly show the swallowed power's emblem near the torso, with a compact colored accent, white puffs and rounded stars.
4. **Equip:** communicate that the new power is active and the previous active power moves to the bench. The concept's Fire/Water example is illustrative; use the actual power identities. If both slots were full, discard the old bench as specified in section 4.
5. **Ready:** fade the emblem flourish and return smoothly to the appropriate movement or combat pose.

Use one shared swallow animation with power-specific emblems and palettes. Keep the character readable and the VFX close to the torso. Feet remain grounded in the reference poses; do not freeze movement or add a movement lock solely to force the reference pose. The concept's slot-update diagram explains the rule; it does not require permanent floating UI over the player. The torso accent is not a shield, invulnerability indicator, damage burst or new gameplay buff.

**Status:** visual concept approved as a starting point; animation, shared emblem assets and runtime swallow presentation still need implementation and in-game review. Spitting continues to preserve both equipped powers.

> Document integrity note (2026-10-25): this section currently jumps into purchase rules, and the Part 2 heading/earlier sections are absent. The following existing text is preserved pending recovery of the intended revision. Do not treat the misplaced purchase/save/build-order text as permission to implement V2 in V1. See [V1 implementation audit](v1-design-audit.md).

- A paid base unlock grants starter eligibility only, not exclusivity, extra slots, stronger stats, or a fusion.
- Clearly preview and describe purchases.
- Buying starter access gives reliable choice; do not assume normalized stats eliminate that advantage.
- Keep free unlock pacing reasonable and power stars accessible; do not make desirable spawns artificially rare to push purchases.
- Currency purchase packs are not automatically approved by approving direct power purchases. Decide separately.
- Suggested cosmetic offerings: star skins/trails, emotes, victory poses; more categories need content planning.
- No sale of stronger rare powers, fusion starters, or extra combat slots.
- Season passes remain later candidates until production capacity is proven.
- OPEN: product catalog, prices, direct purchase versus currency purchase implementation, and duplicate purchase handling.

## 5. Saving and onboarding

Save owned base IDs, selected starter, per-power cosmetic mastery, currency, cosmetics, and stats. Remove the superseded base unlock-progress-meter concept; no separate PvE loadouts or permanent fusion inventory.

Server validates purchases, ownership, starter selection, mastery, and rewards. Handle purchases reliably and idempotently using Roblox's appropriate server purchase lifecycle. Save milestones promptly with retries/session locking.

Clearly explain: “Own a base power to choose it as your starter. Power stars give temporary powers. Fusions last for this life.”

PROPOSED: lobby training area to try the six base powers before spending currency. Do not build until approved.

## 6. Build order and acceptance

1. Resolve initial free starter, selection/respawn lifecycle, unlock costs, and reward pacing.
2. Currency-based base collection and ownership UI.
3. Selected starter integrated with two-slot combat.
4. Cosmetic mastery for base powers and temporary fusions.
5. Approved paid starter products and cosmetic shop additions.
6. Purchase/save reliability, onboarding, mobile testing, and fairness checks.

Acceptance: players understand ownership versus current powers; beginners can earn unlocks without winning; bought powers remain obtainable temporarily by everyone; power stars/fusion remain useful after collection; cosmetic mastery provides long-term goals without inflated unlock grind.

# PART 3: V3 — FUTURE CANDIDATES

Nothing here is approved for implementation. Legacy bandit-specific ideas below are archived candidates superseded by the power-star direction; they do not authorize reintroducing NPC bandits. Expansion candidates need approval and evidence of player demand. Keep-or-delete entries are unresolved decisions, including entries recommended for deletion.

## A. Expansion candidates

**Rare unique stronger powers:** later-only and temporary-only if added. Never permanent unlocks, starter choices, or purchases. If later approved, acquisition would use rare power-star spawns, not dummy NPCs. Spawn rules, duration/KO expiry, counterplay, fusion eligibility, and anti-snowball safeguards require approval; do not assume these powers are balanced sidegrades.


| Feature | Prerequisite |
|---|---|
| Bandit King boss ladder | Proven PvE loop; meaningful boss combat beyond immediate collection |
| Additional base powers | Sustainable releases, distinct identity, readable inhaleable attack |
| Curated additional fusions | Individually approved recipes; no every-pair requirement |
| Bandit archetypes | Distinct readable encounters; candidates include Brawler, Runner, Tank, Thrower, Summoner |
| 1v1 without power-star pickups | Sufficient players to support another queue |
| Team modes | Readability and coordination testing |
| Spectating | Demonstrated demand |
| Seasonal ranked PvP | Stable balance, population, matchmaking, and abuse controls |
| Cosmetic shiny variants | Preserve silhouettes and warning readability |
| Bandit Hunts and events | Sustainable content schedule built on proven gameplay |
| Separate PvE zone / larger world | Deferred from V2; keep or delete before planning another zone |

Shelved power candidates: Ice, Speed, Shock, Bomb. Shelved fusion concepts include Steam, Blaze Dash, Plasma, Napalm, Ice Slide, Freeze Shock, Frost Mine, Frostbrand, Lightning Dash, Rocket Jump, Blitz Slash, Chain Blast, Thunder Blade, Exploding Blade, Inferno, Blizzard, Sonic, Storm, and Mega Bomb. None are implementation commitments.

## B. Keep or delete before development

| Idea | Concern / recommendation |
|---|---|
| Every power fuses with every power and itself | Recommend delete; curated recipes avoid quadratic content growth |
| New power every 2–3 weeks | Recommend delete as a promise; release when ready |
| Expanded permanent loadouts | V2 permits one unlocked base starter only; broader starting loadouts need separate evaluation |
| Saved plus temporary arena slots | Control complexity and excess options; preserve two-slot main arena initially |
| Third/fourth equipped slots | Deferred; no extra combat slots in current design |
| Paid fourth slot | Recommend delete; sells combat flexibility |
| Mastery-gated signatures | Recommend delete; complete movesets available immediately |
| Mastery move variants | Fairness/readability cost; cosmetic mastery first |
| Tier 3 evolved fusions | Recipe/balance complexity; original Mastery 5 ingredient gate is also unapproved |
| Lure Shards and shop | Extra economy needs a demonstrated purpose |
| Specific, rare, and mystery lures | Determine whether targeted/random encounters improve collection |
| Paid lures/luck potions | Unapproved; evaluate fairness and randomness separately from direct base-starter purchases |
| VIP daily mystery bandit | Recommend delete power-access benefit; cosmetic perks can be considered |
| Mystery pity system | Only needed if random permanent collection is approved |
| Fully random vs missing-power-weighted rewards | Resolve together with permanent mystery system |
| Open-world PvP toggle / flagged arena zone | Adds scope and complex immunity rules; current design uses one constant PvP FFA map with roaming power-star pickups |
| Party-instanced bandits | Define ownership and rewards first |
| Elemental advantages | Potentially frustrating hard counters; test first |
| Inhale streak rewards | May encourage rushing/farming; original ~10-second window not approved |
| Seasonal pass | Requires sustainable cosmetics production |
| Daily login streaks | Consider forgiving return rewards instead of missed-day penalties |
| Fusion showdown | Could split queues; consider a temporary event |
| Top fusion this hour board | Establish player value before building |

If paid random acquisition is ever reconsidered, review current Roblox paid-random-item requirements before implementation. Rates, odds, pity, and telemetry remain undefined until the underlying system is approved.

## C. Open design questions

1. What original world, characters, factions, and story define Bandit Eater?
2. Should long-term PvE emphasize collection, bosses, or both?
3. Does permanent progression need rare powers?
4. Would any future mode justify expanding beyond one chosen base starter and two combat slots?
5. Which additions justify their ongoing development cost?

## Roadmap principle

V1 proves roundless PvP with randomly spawning, gently bouncing power stars. V2 adds currency-based base starter unlocks and cosmetic mastery on the same map. Fusions stay temporary. V3 expands only where playtesting and player demand support it.

