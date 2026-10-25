# Bandit Eater: Game Design Doc (Roblox)

Use this as the source of truth for building the game. Build in Luau, Rojo project structure, server-authoritative logic. Part 1 is the V1 pilot and is what to build now. Part 2 is the long-term vision: do NOT build anything from Part 2 until the developer approves it. Where something is marked OPEN or PROPOSED, ask the developer before assuming.

---

# PART 1: V1 PILOT (BUILD THIS)

## 1. Pitch
Kirby-style battlegrounds game. Genre: Fighting / Action (PvP). Subgenre: free-for-all arena brawler with an ability-collection mechanic. Players inhale bandits (yellow dummy-looking NPCs, each themed on one power), swallow them to copy their power, optionally fuse powers, and spit star projectiles at opponents.

One-line pitch: "A Kirby-style battlegrounds game where you inhale bandits, steal their powers, and fuse them."

## 2. V1 Scope
A **lobby + free-for-all PvP arena**. All powers come from inhaling arena bandits (or the random starter power) and are **temporary** (that match only). Permanent powers, saved slots, mastery, and the open world are added later as the game grows (see Part 2).

## 3. Match Loop
1. Spawn into the arena with one random starter power.
2. Fight with M1, dash, bubble shield, and power moves.
3. Inhale an arena bandit (easy). Swallow it to get its power, or spit it as a star projectile.
4. Optionally fuse (Sword fusions only at launch).
5. Win or lose, earn PvP currency. On a KO, respawn with a fresh random starter power.
6. Between matches, spend currency on cosmetics in the lobby.

## 4. Lobby
- Queue/join button for the arena. The arena fills with bots when population is low so matches always start.
- Leaderboard and cosmetics shop.
- PROPOSED: a short roadmap note in the lobby ("permanent powers coming soon").
- PROPOSED: daily quests tied to arena play (e.g. "inhale 5 fire bandits").

## 5. Controls
Universal moves (every player, not tied to any power):
- **M1:** regular basic attack combo.
- **Dash:** brief i-frames, on a cooldown.
- **Bubble shield block (developer decision):** blocking pops up a transparent bubble shield around the player for a short time that reduces damage taken (it does not negate it). The bubble is see-through and visible to opponents so it reads clearly. PROPOSED tuning: about 1 second duration, a cooldown so it cannot be held forever, about 60-70% damage reduction, and guard-break (heavy hits and signature moves can pop the bubble early and leave the player briefly exposed). All values tunable.
- **Inhale** and **spit** (see Section 7), **swap** (between the two temp slots), **jump**.
- Power moves on Q, E, R (mobile buttons and gamepad mapped too).

Mobile UI: M1, dash, block, inhale, swap, jump, plus 3 power-move buttons and a small icon for the benched power. Keep the layout compact (dash/block/jump near the thumb, the three power moves grouped). PROPOSED: let players move and resize buttons, hide swap until the player holds two powers, and show the fuse button only when fusing is possible. Test the layout early.

## 6. Powers, Moves, and Slots
- **Launch roster (developer decision), 6 base powers:** Wind, Earth, Water, Fire, Sword, Shadow. Design everything data-driven so adding a power later needs only new data.
- Inhale is NOT a power. It is the universal core mechanic every player has. There is no "Eat" power.
- Each power has 3 moves on Q, E, R, **all unlocked in V1**:
  1. Move 1: fast, low cooldown power attack.
  2. Move 2: utility/control (trap, shield, area control, projectile). Not just a plain dash, since dash is universal.
  3. Move 3, Signature: big, long cooldown.
- **Two temporary slots.** Only ONE power is active at a time; the other is benched. One swap key switches them, with a short swap cooldown (1-2 seconds). Cooldowns keep ticking while a power is benched.
- **Starter power (developer decision):** every player spawns with one random base power in temp slot 1. Temp slot 2 starts empty and is filled by inhaling a bandit. A fresh random starter power on every respawn. Stats are PvP-normalized, so the starter is as strong as any other power. Show a short first-match prompt: "Inhale a bandit to get a second power."
- Two copies of the same power can be held (needed for the Sword + Sword fusion).
- If both slots are full on swallow, the player chooses which power to replace.
- Temporary powers never touch saved data.

## 7. Inhale, Swallow, and Spit
- Hold a button to inhale. Bandits in a cone in front of the player are pulled in. Players are exposed while pulling, which is the intended risk. No invulnerability while pulling.
- **Bandits can be inhaled right away (developer decision):** no weakening or stagger is needed, so a bandit can be inhaled at full health. The risk is being exposed while pulling, plus the inhale cooldown.
- After inhaling: **swallow** (copy its power into a temp slot) or **spit** (fire a **star** projectile).
- **Spit as a weapon:** the star can hit opponents (PvP-tuned damage and cooldown).
- **Star cosmetic (developer idea):** the star's look is planned as a changeable, possibly paid cosmetic (skins, colors, trails). Cosmetic variants must never change the star's hitbox, size, speed, or damage, and must not hide telegraphs.
- **Inhale cooldown:** a small cooldown so players cannot chain-inhale every bandit and snowball.
- **Post-swallow protection (developer decision):** after a successful swallow, about 0.3-0.5 seconds of 50% damage resistance (NOT full i-frames), with a visible flash or pulse. It is tied to the inhale cooldown so it cannot be chained. Percentage and duration are tunable.

## 8. Fusion (Sword-only at launch)
- **Fusion works in temp mode (developer decision):** a player holding two temp powers can choose to fuse them into a temporary fusion. Fusion is optional, never automatic. Fusing consumes both powers and puts the fused result in one slot, freeing the other.
- **Sword is the only power that fuses at launch (developer decision):** Sword + one other power, plus Sword + Sword (6 fusions). The fuse option only appears when the player holds Sword plus another power (which can be a second Sword).
- Fusions (proposed names):
  - Fire + Sword = Flame Blade
  - Water + Sword = Tide Blade
  - Wind + Sword = Gale Blade
  - Earth + Sword = Quake Blade
  - Shadow + Sword = Shadow Blade
  - Sword + Sword = Master Blade (an upgraded Sword)
- Fusion order does not matter. Fusions are sidegrades, not strict upgrades.
- **No Fusion Book (developer decision):** there is no fusion book or discovery list. While in the arena, a player who holds two abilities that can be fused simply gets the option to fuse them.
- **Workload plan (PROPOSED):** each fusion takes move 1 from one parent and move 2 from the other (reusing animations and effects) and adds one new signature move, so V1 needs about 6 new signature moves. Keep fusions data-driven (a Fusions module keyed by sorted pair of power ids) so a new pair needs only data plus one signature move.

## 9. Arena Bandits
- All bandits share the same yellow dummy-like base model, themed on their power (a look and tell that match the power, e.g. flames for Fire, a blade for Sword), so players know what they will copy.
- Each bandit uses ONLY ONE ability (developer decision). Proposed: the power's Move 1, with a clear telegraph (about 0.4-0.6 seconds) and low damage, so the power is readable before inhaling and the AI stays simple.
- Bandits attack all players and target the nearest player, not the match leader.
- **Rare and mystery variants** spawn on the arena's own timers (more often than they would in an open world, since arena powers are temporary). They also use a single ability (a stronger or faster version). The mystery bandit plays a slot-machine style reveal after the swallow and lands on a random temp power. Rare arena powers are sidegrades with PvP-normalized stats.
- Limit how many bandits are alive, use respawn timers, keep bandit damage low so players mostly fight each other, and keep power-ups sidegrades so the match leader does not snowball.
- PROPOSED: spawn Sword bandits slightly more often so fusion shows up regularly.
- Bandits also help with low population by keeping matches busy.

## 10. Arena and Match Rules
- Launch mode: free-for-all on one arena map. Short matches (about 1-2 minutes).
- PvP stats are normalized for everyone (levels, gear, grind do not matter).
- Per-move PvP multipliers for damage, cooldown, and stun length, so powers can be tuned independently.
- Cap stun/freeze duration and add short stun immunity after being stunned (no chain-locks).
- Losing costs nothing: no power loss, no progress loss.
- Fill empty arenas with bots so matches always start.
- Match flow: timer, scoring, respawns, results screen, currency payout.

## 11. Rewards, Saved Data, and Monetization (V1)
- **Rewards for win or loss:** PvP currency (winners earn more, losers still earn a smaller amount), plus cosmetics and titles. No power-affecting rewards.
- **PROPOSED saved data:** PvP currency, cosmetics, stats/leaderboard. Reason: V1 needs a reason to return even though powers are not saved.
- **Light anti-abuse (agreed direction):** daily cap on boosted rewards (normal rate after), AFK check with a minimum participation requirement (damage dealt or inhales) to earn, and reduced rewards for repeated fights against the same opponent or against bots.
- **Monetization:** cosmetics only in V1 (star skins as a paid option, plus PROPOSED inhale effects, auras, and bandit skins). Nothing purchasable changes PvP outcomes.

## 12. Technical Notes
- Luau, Rojo project layout, VS Code and GitHub workflow.
- All gameplay (inhale, swallow, fuse, damage, cooldowns, slot changes) is validated on the server. The client only sends input and plays effects.
- Data-driven definitions: a Powers module and a Fusions module with move data (damage, cooldown, effect ids). Adding content means adding data.
- Player data saved in V1: currency, cosmetics, stats. **Forward compatibility:** reserve empty fields in the player data schema for saved slots, owned powers, and mastery, so adding permanent powers later is an extension, not a rewrite. DataStore saves with retry/session locking.

## 13. V1 Build Order
1. Lobby, queue, and teleport to the arena (with bot fill).
2. Player controller: M1, dash, bubble shield block.
3. Inhale and spit, plus arena bandit AI.
4. Power and move framework with the 6 powers (temp slots, random starter power).
5. Fusion option in the arena (offered when two held abilities can fuse).
6. Free-for-all match flow: timer, scoring, respawns, results, currency payout.
7. Cosmetics shop, leaderboard, daily quests.
8. Mobile layout, onboarding (first 60 seconds), balance pass.

## 14. Playtest and Tuning Checklist
- Prototype acceptance test: a new player understands the controls within 60 seconds, and fighting plus inhaling with one power is fun for 5 minutes with no rewards attached.
- Tune: bubble shield duration, cooldown, and damage reduction; post-swallow protection; inhale cooldown; bandit count, damage, and respawn timers; starter power randomness; Sword bandit spawn rate.
- Watch: free-for-all chaos with bandits attacking, bot fill quality at low population, mobile button layout, day-1 return rate before spending on ads.

---

# PART 2: LATER (NOT IN V1, DO NOT BUILD UNTIL APPROVED)

## L1. Permanent Powers and Saved Slots
- Players start with 2 saved power slots. Powers absorbed from open-world bandits are permanent and persist between servers (saved to DataStore, saved immediately on absorb and on fuse).
- Planned progression: 3rd slot by level/quest, 4th slot as a gamepass (more options, not more power).
- Fusing consumes both powers and puts the result in one slot.
- Open-world bandits are instanced per player (or per party), no kill stealing, matched to player level. Powers only come from bandits, never from other players.
- Arena spawn loadout (developer decision): players enter the arena with their permanent saved powers and can also pick up temporary powers from arena bandits. Temp powers live in separate temp slots. The swap key cycles through saved slots plus temp slots.
- Opt-in "Bandit Mode" PvP toggle in the open world (visible overhead marker). Flagged players mid-bandit-fight or mid-inhale are immune to PvP in the open world only. Consider merging the arena into a flag-only PvP zone on the main map.

## L2. Power Mastery (APPROVED concept)
- Every power, base and fused, levels 0-10 through use (everything starts at 0). Mastery is saved per power id and persists even when the power is not held, is consumed in a fusion, or is re-absorbed. Fused powers start at 0 mastery (no inheritance).
- Moves 1 and 2 unlocked at the start, signature (move 3) unlocked at Mastery 1. Mastery 0 to 1 should be quick (about 5 minutes of use), with the locked signature shown alongside a progress bar.
- Mastery unlocks cosmetic effects, titles, and sidegrade move variants. It never raises PvP stats (PvP stays normalized).
- In PvP, all three moves are available regardless of mastery. Mastery EXP comes from bandit farming at a base rate and from PvP at a boosted rate (about 2x as a starting value). Temporary arena powers earn no mastery EXP; only permanently owned powers do.

## L3. Lure Shards and Lures (open world only)
- Lure Shards are earned from bandit farming (base rate) and PvP (boosted rate, win-streak bonuses, pity-timer boost; losers still earn a smaller amount).
- Lures are bought with shards and spawn a personal bandit that the player still has to beat and inhale (currency never grants a power directly). Open world only; never used in the arena.
  - Specific Lure: a normal bandit of a power the player chooses.
  - Rare Lure: a harder rare bandit.
  - Mystery Lure: the RNG mystery bandit (small chance of a rare power or ready-made fusion).
- Mystery bandit includes a pity timer (guaranteed rare after X spawns without one). OPEN: fully random vs weighted toward powers the player does not own.
- If shards or lures can ever be bought with Robux, check Roblox's paid random item rules (odds disclosure) before shipping.
- Keep all rates in config values and log telemetry.

## L4. Open-World Bandit Combat
- Bandits are not weakened before inhaling (developer decision); they can be inhaled right away. The earlier stagger-bar idea is dropped.
- Bandit archetypes (open world only, since arena bandits use one ability): Brawler, Runner, Tank (armor broken by heavy hits), Thrower/Sniper, Summoner. Rare bandits combine archetypes and have phases.
- Elemental interactions so power choice matters. Inhale streaks (consecutive inhales within about 10 seconds give bonus rewards).
- Game feel: hit-stop, optional camera shake, knockback, damage numbers, inhale pull VFX, swallow pop effect.

## L5. Expanded Powers and Fusions
- Add new base powers over time (one every 2-3 weeks), seasonal/event/rare-only powers. A new power adds a fusion with every existing power plus its own double (N powers means N(N+1)/2 fusions).
- Shelved power ideas from the earlier roster: Ice, Speed, Shock, Bomb. Earlier fusion ideas: Steam, Blaze Dash, Plasma, Napalm, Ice Slide, Freeze Shock, Frost Mine, Frostbrand, Lightning Dash, Rocket Jump, Blitz Slash, Chain Blast, Thunder Blade, Exploding Blade, plus doubles (Inferno, Blizzard, Sonic, Storm, Mega Bomb).
- Evolved fusions (Tier 3): fuse a fusion with a base power or another fusion, requiring Mastery 5+ in the ingredients. Launch with a small hand-picked set (about 6).

## L6. Endgame and Retention
- Bandit King boss ladder (PvE zones with boss bandits whose signature mechanics reward specific powers; cosmetics and titles).
- Rare Shiny fusion variants (cosmetic only).
- Daily/weekly Bandit Hunts, daily login streak, limited-time event bandits, mastery milestones.
- Seasonal ranked PvP with resets, exclusive cosmetics and titles. Leaderboards for ranked PvP and boss ladder.

## L7. Later Modes
- 1v1 (planned as a bandit-free mode), team modes, "fusion showdown" (random fusion for everyone), spectator view, and a "top fusion this hour" leaderboard.

## L8. Later Monetization (no PvP pay-to-win)
- 4th slot as a gamepass; luck potions (time-limited, capped, pity timer still applies, show odds); seasonal pass with free and premium tracks; optional VIP (cosmetic perks plus an extra daily mystery bandit); more cosmetics (spit trails, auras, bandit skins, swallow animations).

## L9. Later Open Questions
1. Mystery bandit: fully random or weighted toward missing powers?
2. Core fantasy and story/factions?
3. Endgame: fusion collection, boss ladder, ranked PvP, or all three?
4. Evolved fusions: approve as part of the endgame?
5. Players with many permanent fusions may have more options than new players in the free-for-all. Fusions are meant to be sidegrades; test this in balance passes.
