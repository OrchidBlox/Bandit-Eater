# V1 design versus current implementation - 2026-10-25

Scope: source review against `bandit-eater-design-doc (1).md`. This is a removal/change plan, not a claim that cleanup or double jump has been implemented. No gameplay code, saved data, map anchors or assets changed in this review.

## Confirmed removals for the revised V1

| Remove or replace | Current evidence | Required treatment |
| --- | --- | --- |
| Timed matches, results, intermission and round resets | `PilotConfig.luau:3`; `PilotService.luau:561` (`runMatches`) | Replace with continuous combat. Remove phase-based combat shutdown and periodic loadout/map resets. Preserve KO/respawn and bandit respawning without match-ID gating. |
| Round queue and timer/results UI | `PilotService.luau:111` (`joinMatch`); `PilotController.luau:125`, `:140`, `:167` | Arena pad can remain an immediate entrance. Remove queued/next-round behavior, countdown and results screen; remove Match-only input gating as part of the continuous-state conversion. |
| Match payouts, win bonus and first-ten-match multiplier | `PilotService.luau:397` (`payout`) | Remove round-based reward calculation. Replace with approved participation/objective rewards only after amounts and anti-farming rules are settled. KOs currently save through payout, so move stat accounting before removing it. Preserve existing currency. |
| New match-win/title awards and win-based presentation | `PilotService.luau:430`, `:483`; `PilotController.luau:126`, `:164`; `EnvironmentLobby.luau:91` | Retire Arena Winner earning and round-win UI. Keep both protected leaderboard models; choose a roundless metric for the wins board. Preserve historical saved wins/titles unless a separate migration is approved. |
| Universal bubble block and shield guard-break | `PilotCombat.luau:32`, `:172`; `PilotController.luau:74`, `:89`; shield values in `PilotConfig.luau` | Remove Block input, bubble effect, shield reduction and heavy-hit shield break. Do not remove ordinary damage/stun or all defensive power utility as collateral cleanup. |
| Round-based combat-bot fill | `PilotService.luau:90` (`fillBots`), calls in arena entry and round loop; `PilotConfig.BotFill` | Remove the round-fill system. The doc's broader suggestion to prototype without any bots is PROPOSED; whether standalone low-population bots remain is a separate decision. Yellow power bandits stay. |

## Behavior that needs changing or adding

- **Swallow must activate the acquired slot.** `PilotService.luau:264` writes `Slots[slot]` but does not set `actor.Slot = slot`. Keep slot positions and existing cooldowns. Full-slot replacement choice is still OPEN; do not silently replace the current selection UI with a new rule.
- **Timed frontal projectile catching is missing.** `PilotCombat.Projectile` only resolves collisions/damage; `PilotService.inhale` targets bandits. Catch window, cooldown, capacity and eligibility are OPEN. Sword currently has a melee-only move 1, so its required inhaleable traveling slash also needs design/integration.
- **Dash is blocked during inhale.** `PilotCombat.luau:143` rejects all Ready actions while `actor.Inhaling`; the revised doc keeps dash available under its normal rules. `PilotService.luau:494` also slows inhale to 8 studs/s; confirm intended suction/catch movement behavior instead of treating that old value as locked. Do not invent a miss stun.
- **Bandit collection has an old minimum hold.** `PilotConfig.InhaleDuration = 0.7`, plus distance/hold checks in `PilotService.inhale`, should be reconciled with nearly instant full-health collection. No health weakening threshold was found in this path, so there is no weakening system to remove here.
- **Lobby starter lifecycle differs.** Spawn reset chooses a random starter, but inactive CharacterAdded/round cleanup clear slots. The revised flow says spawn with one base starter and reset on KO. Resolve safe-area protection before changing when combat becomes enabled.
- **Double jump is now approved in the design only.** Add one extra airborne jump, consumed once and rearmed on landing, with a dedicated animation/puff and cross-device input. Current transitions cover takeoff and landing, not the extra jump mechanic.

## Review before deleting

- **Rare and Mystery timed spawns:** `PilotService.luau:575-587` still adds these old variants. They are not documented as approved V1 content. Current Rare uses the base roster and a faster attack cadence, not a unique rare power; do not mislabel it as an implemented stronger unique-power system. Recommend disabling both variant schedules for the six-base-bandit pilot, pending clarification of the missing doc sections.
- **Sword Guard and swallow protection:** these use `actor.Protection`, separate from universal Shield. The doc removes universal bubble block but does not establish that every power defense is forbidden. Swallow protection rules are unavailable in the incomplete section; do not delete these by assumption.
- **Fusions:** current code supports Sword plus each base, including itself. The doc allows compatible curated fusions but its detailed V1 fusion section is absent. Do not delete all fusions or declare every existing recipe approved; recover the intended recipe list.
- **Cosmetic shop:** UI is hidden, but `Shop` requests and three star skins remain. Saving cosmetics remains part of V1. Decide whether to disable the hidden purchasing endpoint during the pilot; do not wipe owned cosmetics.

## Document repairs and safe implementation order

The source doc goes from V1 section 6 (Swallow and star spit) directly into purchase rules, then sections 5 and 6 with V2 ownership/build order, then Part 3. There is no Part 2 heading. Recover the intended revision before implementing its missing fusion, star, economy or V2 details. `docs/game-design.md` is an empty template, not an alternate source of truth. `CLAUDE.md` still mentions the removed bubble block in its animation set and incorrectly says DataService does not exist; update those instructions with the eventual implementation cleanup.

1. Convert session lifecycle and UI to continuous combat together; preserve pad, bounds, leaderboard anchors, KO respawn and data.
2. Remove universal Block and round-based bot fill; settle low-population bot policy.
3. Fix swallow activation; design the still-open catch details before replacing defense.
4. Implement the separately approved double jump with animation transitions and server validation.
5. Replace reward/stat writes atomically so the removal of payout does not silently stop currency or KO persistence. Decide new board metric and variant spawns.

Validation for that future implementation: fresh Studio Play, pad entry at any time, uninterrupted combat beyond the old 90-second limit, KO/reset, saved currency/stats, input parity, mobile/gamepad jump, one extra jump per landing, rejected repeated airborne requests, and no old Block/round UI. This review itself was static; no runtime modifications or Play test were required.
