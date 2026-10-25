# V1 placeholder prototype

Source: `bandit-eater-design-doc (1).md`, Part 1. This is a functional greybox for testing, not finished art or final balance.

## Start

Current layout (environment version 11): arena 520 x 380 at Y=180; lobby 156 x 112 at Y=240, centered at X=-20 / Z=12000, away from arena sightlines. Lobby spawn remains 28.2 studs from the arena pad. Each area has six transparent, collidable, queryable boundary parts, including a ceiling and floor. Only these small safety models are Persistent so collision remains available during distant teleports; their invisible floors sit just below the visible floor surfaces. See Roblox's [model streaming documentation](https://create.roblox.com/docs/reference/engine/enums/ModelStreamingMode).

Version 11 checks: all eight player and bandit spawn positions are supported by the resized arena, both boundary models have six persistent parts, and area centers are over 12,000 studs apart. Fresh Play walk-on navigation from the relocated lobby successfully joined the arena at Y=184. Selene and Rojo build pass. Studio was returned to Edit mode after validation.

Connect Studio's Rojo plugin to port **32222**, then press Play. The pilot creates `Workspace.BanditEaterPilot` at runtime. Walk onto the glowing **ARENA** pad in the lobby to join the current round immediately; **Join live arena** on the HUD is an alternative. The server starts 90-second rounds automatically, even without human participants. Bots fill to four total participants and adjust when players join or leave. Between rounds there are eight seconds of results and a 12-second intermission; entering the pad then queues you for the next round. Standing on the pad while your save loads also joins automatically when ready.

## Controls

| Action | Keyboard / mouse | Gamepad |
| --- | --- | --- |
| Basic combo | Left click | RT |
| Dash | Shift | B |
| Bubble shield | C | LB |
| Inhale | Hold F facing a bandit | Hold LT |
| Swallow / copy | G | D-pad down |
| Spit star | T | D-pad right |
| Swap | X | Y |
| Power moves | Q / E / R | X / RB / D-pad up |
| Fuse | V | D-pad left |
| Replace a full slot | 1 / 2 or onscreen buttons | Select onscreen replacement button |
| Jump / movement | Roblox defaults | Roblox defaults |

Touch uses onscreen action buttons and Roblox's default movement/jump controls. Aim with your character's facing direction. Get within 19 studs of a **yellow power bandit**, face it and **hold F for about a second** until it reaches you; a quick tap cancels the pull. Blue fighters (`Bot 1`, etc.) are PvP opponents and cannot be inhaled. The HUD shows INHALING, the target being pulled, and cooldown/no-target feedback. Press **G** to swallow or **T** to spit after capture. Swallow fills the empty slot; when both slots are full, explicitly select a replacement. Fusion is optional and consumes the two ingredients.

## Try this

1. Before joining, confirm the server match timer is already ticking and four bots are fighting. Walk onto the lobby arena pad; confirm immediate entry, three remaining bots, a starter power, health and timer.
2. Use all three moves of each base power; compare Sword's guard with the area-control moves.
3. Inhale at full bandit health, cancel an inhale, swallow, spit, replace either slot, and swap while cooldowns tick.
4. Fuse Sword with each base power, including another Sword. Other pairs must not offer fusion.
5. Check damage reduction and visible shield; signature hits break the bubble. Try a dash into cover.
6. Watch rare and mystery spawns after 20 and 30 seconds. Swallow mystery for a reveal.
7. Get KO'd; respawn with a fresh random base power. End the match, inspect results, return to the lobby.
8. Deal at least 20 damage or complete two inhales to earn coins. Buy/equip Rose or Mint star colors in the lobby. These change color only.
9. Repeat with two real clients. Check score attribution, simultaneous inhaling, mobile controls, and gamepad UI selection.

## Prototype boundaries

- Map, dummies, move effects and UI use basic parts/text. Effects are deliberately reused; final animations, audio and custom art are future polish.
- All six powers and six Sword fusion pairs are available. Move names, values, generic fusion IDs, map dimensions, cosmetic prices and reward amounts are provisional.
- Rare bandits attack faster but grant the same normalized base power. Mystery grants a random base power; neither grants a permanent power.
- Leaderboard shows saved wins for players in this server. A global ordered leaderboard is not implemented.
- Rewards include participation checks, reduced bot-only payouts, diminishing repeated-opponent KO bonuses, and ten boosted eligible matches per UTC day. This is light prototype protection, not a complete anti-cheat system.
- Daily quests and the lobby roadmap remain excluded because the source marks them PROPOSED. No Robux purchase flow is connected.
- Existing ProfileStore handles saved currency, star ownership/equipping, wins/KOs/deaths/matches and an Arena Winner title. Reserved permanent-power fields remain empty; temporary loadouts exist only in server memory.
- With Studio API access disabled, ProfileStore falls back to mock data. Live persistence and concurrent-session behavior require a separate test.

## Code locations

- `src/shared/PilotConfig.luau`: powers, fusion pairs, cosmetic definitions, tuning.
- `src/server/Services/PilotWorld.luau`: replaceable runtime map and dummy assets.
- `src/server/Services/PilotCombat.luau`: server damage, cooldowns, projectiles and defensive actions.
- `src/server/Services/PilotService.luau`: match loop, bots, bandits, inhaling, loadouts, rewards and shop validation.
- `src/client/Controllers/PilotController.luau`: prototype HUD and keyboard/touch/gamepad input.

## Verification

Static checks: Selene reported zero errors, warnings, and parse errors using its cached Roblox API definitions; its online API refresh was unavailable. Rojo build passed.

Studio smoke checks passed: lobby queue and intermission; random starter; three-bot fill; full-health Fire bandit inhale; swallow into the second slot; swap; Sword + Fire fusion; all three fused move cooldowns; malformed move/slot requests; bubble damage reduction and guard-break; swallow resistance; dash immunity; KO scoring; bot respawn; results with a 10-coin participation payout; return to lobby with an empty temporary loadout. Checks used temporary Play-session fixtures, removed when Play stopped.

Full multiplayer, device ergonomics, all power/fusion combinations, mystery/spit presentation, player death/respawn, shopping and persistent-save acceptance still need owner playtesting.

Walk-on entry update: Studio verified a running round with four bots before the player joined. Moving the character onto `ArenaTeleportPad` without a join remote immediately entered that same round, granted a starter power, hid the join button and reduced the bot count to three. No gameplay errors appeared. Selene again reported zero code diagnostics, and Rojo build passed.

Inhale feedback update: input mappings now use explicit input lists, release is handled even when chat gains focus, the server reports inhale/target/rejection status to the HUD, and fighter bots are blue to distinguish them from inhale targets. Selene reported zero code diagnostics and Rojo build passed. Studio was disconnected, so this update still needs a fresh keyboard/touch playtest.
# Environment revision: rectangular arena

2026-10-24: arena floor is 840 x 560 studs (2.009 times the old circular area), with nine low rock formations. Solid grassland replaces the ocean/drop beneath both lobby and arena. The existing lobby anchors remain at their previous coordinates.

Checked in a fresh Studio Play: environment version 6, rectangular floor, nine rocks, six bandit markers, all eight player spawn positions supported by the arena floor, and no Ocean object. Rock tops measure about 2.9-3.6 studs. Selene and Rojo build pass. Desktop inspection confirmed continuous ground surrounding the lobby. Jumping over every rock and a complete perimeter walkthrough remain manual playtests.

The roomier lobby is now built (environment version 8), based on `docs/reference/concepts-v1-2026-10-24/lobby-two-leaderboards-v3.png`. Its 240 x 184 plaza has separate SERVER WINS and SERVER KOs boards, a simplified rectangular teleporter, perimeter gardens and six benches. The cosmetics kiosk is removed and the cosmetics HUD is hidden; existing ownership data remains intact.

Fresh Play verification: both boards populated from the connected player's totals, cosmetics HUD hidden, 25 clear-center-lane ray checks passed, and walking from the spawn onto the new pad automatically joined the active arena match. Selene reports zero errors/warnings and Rojo builds successfully. Multi-player ranking order still needs a multi-client playtest.

