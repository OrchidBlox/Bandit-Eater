# Bandit Eater: Game Design Document (Roblox)

Source of truth for development. Luau, Rojo project structure, VS Code/GitHub workflow, and server-authoritative gameplay.

## Scope and approval

- **V1: build now.** One continuous PvPvE map, not timed matches.
- **V2: approved roadmap direction, not authorization to implement early.** Currency-based permanent base starter unlocks and cosmetic mastery.
- **V3: future candidates and keep-or-delete decisions.** Nothing is authorized for implementation.
- Items marked OPEN or PROPOSED require developer approval before assuming behavior. Suggested tuning is not a locked value.
- Latest rules below supersede earlier round-based, separate-PvE-zone, weakening, unlock-meter, permanent-fusion, and cosmetic-only-monetization proposals.

# PART 1: V1 — ROUNDLESS PvPvE PILOT

## 1. Pitch and style

A cartoon action brawler where players fight each other, inhale bandits to copy powers, spit stars, and fuse compatible powers.

One-line pitch: “Inhale bandits, steal their powers, and fuse them while fighting other players.”

Visual direction: low-poly nature, chunky cartoon VFX, exaggerated animations, readable silhouettes, and clearly telegraphed attacks. PvPvE means players fight both players and NPC bandits; this is not a separate PvE game.

## 2. World and session loop

One compact continuous combat map with a safe lobby/spawn area. No rounds, queue, match timer, winner screen, or match payouts.

1. Spawn with one random base starter in slot 1; slot 2 is empty.
2. Enter the combat zone and fight players.
3. Inhale a bandit; swallow for a temporary power or spit as a star.
4. Swap powers or optionally fuse a valid pair.
5. Earn currency through meaningful combat participation and approved objectives.
6. On KO, lose current temporary powers/fusions and respawn with a fresh random base starter.
7. Keep currency, cosmetics, and saved stats.

Permanent starter selection is V2, not V1. Bandits provide local activity and powers; player combat remains the main event.

OPEN: exact safe-area boundaries, damage protection, spawn protection, and rules preventing safe-zone abuse.

## 3. Controls and universal defense

- M1: basic attack combo.
- Dash: brief i-frames on cooldown.
- Jump, inhale, swallow, spit, and swap.
- Q/E/R: three power moves, all unlocked immediately.
- Mobile and gamepad support.
- No bubble shield/block. No shield guard-break system.
- Catch eligible incoming attacks from the front during a brief timed inhale window. Holding indefinitely does not provide continuous protection.
- Missing gives no protection and triggers a cooldown before another catch attempt. It does not freeze or stun the player; movement and dash remain available under their normal rules.
- Melee, rear attacks, and uncatchable attacks can still hit during inhale. No general inhale invulnerability.

OPEN: catch-window duration, cooldown, input bindings/state transitions, how bandit and projectile inhaling share controls/cooldowns, and capacity while already holding a bandit/star. The earlier 0.4-second catch window was illustrative only.

## 4. Powers and two combat slots

Launch base roster: **Wind, Earth, Water, Fire, Sword, Shadow**. Inhale is universal, never a seventh power.

Each power has:

1. A fast low-cooldown attack.
2. Utility/control, not merely another dash.
3. A large signature on a longer cooldown.

Every base power has at least one clearly recognizable inhaleable attack. Sword has a small traveling slash; ordinary melee swings are not inhaleable. Use shape and animation as well as color for readability.

- Two match-held combat slots; one active, one benched.
- Swap has a short cooldown; approximately 1–2 seconds is suggested tuning.
- Cooldowns keep ticking while benched.
- Duplicate powers allowed, including Sword + Sword.
- Empty slot fills on swallow.
- **Swallow automatically activates the newly acquired power.** If Fire is active and the second slot is empty, swallowing Sword fills that empty slot and makes Sword active; Fire becomes benched. Swap returns to Fire.
- Keep slot positions fixed: change the active-slot selection rather than moving powers between slots. Preserve existing cooldowns when activation changes.
- After a full-slot replacement, the newly swallowed power also becomes active; the other retained power stays benched. This does not resolve which replacement UX to use.
- Temporary loadouts are never saved as owned powers.

**OPEN replacement UX:** original rule asks which slot to replace when both are full. Proposed simpler alternative: swallow replaces the active power and immediately activates the new power, shows “Swallow → Replace [power]” before confirmation, and allows swapping before swallowing to select the other replacement target. The benched power remains untouched. Spitting preserves both powers. Confirm one approach before implementation; avoid assuming a replacement menu is required.

## 5. Bandits: lightly interactive, no weakening

- Yellow dummy-like shared model with distinct power accessories and tells.
- Stay near their spawn and target the nearest player within a short aggression range.
- One clearly telegraphed ability each; no chasing across the map or complex combat AI.
- **Nearly instant inhale at full health. No weakening, damage threshold, or stagger requirement.**
- Clear suction/reaction animation makes collection readable and satisfying.
- Low damage, capped population, respawn timers, and restrained effects.
- PROPOSED: use the power's move 1 with roughly 0.4–0.6 seconds of telegraph.
- PROPOSED: slightly more Sword spawns, staggered respawns, and effects smaller than player signatures.
- OPEN: aggression range, population, spawn distribution, respawn rates, and final attack tuning.

Rare/stronger unique powers are **not in V1 or V2**. They are later-only candidates and may only ever grant temporary powers.

PROPOSED: prototype without combat bots. Round-based bot fill is removed; whether low-population play needs bots remains a playtest decision.

## 6. Swallow and star spit

- A paid base unlock grants starter eligibility only, not exclusivity, extra slots, stronger stats, or a fusion.
- Clearly preview and describe purchases.
- Buying starter access gives reliable choice; do not assume normalized stats eliminate that advantage.
- Keep free unlock pacing reasonable and bandits accessible; do not make desirable spawns artificially rare to push purchases.
- Currency purchase packs are not automatically approved by approving direct power purchases. Decide separately.
- Suggested cosmetic offerings: star skins/trails, emotes, victory poses; more categories need content planning.
- No sale of stronger rare powers, fusion starters, or extra combat slots.
- Season passes remain later candidates until production capacity is proven.
- OPEN: product catalog, prices, direct purchase versus currency purchase implementation, and duplicate purchase handling.

## 5. Saving and onboarding

Save owned base IDs, selected starter, per-power cosmetic mastery, currency, cosmetics, and stats. Remove the superseded base unlock-progress-meter concept; no separate PvE loadouts or permanent fusion inventory.

Server validates purchases, ownership, starter selection, mastery, and rewards. Handle purchases reliably and idempotently using Roblox's appropriate server purchase lifecycle. Save milestones promptly with retries/session locking.

Clearly explain: “Own a base power to choose it as your starter. Bandits give temporary powers. Fusions last for this life.”

PROPOSED: lobby training area to try the six base powers before spending currency. Do not build until approved.

## 6. Build order and acceptance

1. Resolve initial free starter, selection/respawn lifecycle, unlock costs, and reward pacing.
2. Currency-based base collection and ownership UI.
3. Selected starter integrated with two-slot combat.
4. Cosmetic mastery for base powers and temporary fusions.
5. Approved paid starter products and cosmetic shop additions.
6. Purchase/save reliability, onboarding, mobile testing, and fairness checks.

Acceptance: players understand ownership versus current powers; beginners can earn unlocks without winning; bought powers remain obtainable temporarily by everyone; bandits/fusion remain useful after collection; cosmetic mastery provides long-term goals without inflated unlock grind.

# PART 3: V3 — FUTURE CANDIDATES

Nothing here is approved for implementation. Expansion candidates need approval and evidence of player demand. Keep-or-delete entries are unresolved decisions, including entries recommended for deletion.

## A. Expansion candidates

**Rare unique stronger powers:** later-only and temporary-only if added. Never permanent unlocks, starter choices, or purchases. Acquisition is through rare dummy spawns. Spawn rules, duration/KO expiry, counterplay, fusion eligibility, and anti-snowball safeguards require approval; do not assume these powers are balanced sidegrades.


| Feature | Prerequisite |
|---|---|
| Bandit King boss ladder | Proven PvE loop; meaningful boss combat beyond immediate collection |
| Additional base powers | Sustainable releases, distinct identity, readable inhaleable attack |
| Curated additional fusions | Individually approved recipes; no every-pair requirement |
| Bandit archetypes | Distinct readable encounters; candidates include Brawler, Runner, Tank, Thrower, Summoner |
| 1v1 without bandits | Sufficient players to support another queue |
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
| Open-world PvP toggle / flagged arena zone | Adds scope and complex immunity rules; current design uses one mixed PvP/NPC arena |
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

V1 proves roundless PvPvE combat. V2 adds currency-based base starter unlocks and cosmetic mastery on the same map. Fusions stay temporary. V3 expands only where playtesting and player demand support it.

