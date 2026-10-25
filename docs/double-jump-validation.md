# Double jump - implementation and validation

Implemented 2026-10-25. Press the normal jump control again after leaving the ground. One extra jump is available per landing, including after walking off a ledge. Initial tuning: 50 studs/s upward velocity with horizontal velocity preserved; 0.12 seconds minimum observed airborne time; 0.1 seconds grounded to reset.

Server validates current character, health, permitted movement state, unanchored root, not seated/platform-standing or combat-stunned, grounded raycast, request interval and unused charge. Charge is consumed before broadcasting approval. Respawn creates fresh state, initially unavailable until grounded. Disconnect removes per-player state. This validates the extra-jump request, not a general character movement anti-cheat.

The client uses the existing cross-device JumpRequest and release latch; holding the original button should not consume the extra jump. The owning client applies the approved velocity for network-owned character simulation. RunController replays the existing Takeoff asset and emits one puff from each foot on server approval, distinct from grounded footstep markers. Existing idle/run/freefall/landing transitions are retained. No new Blender animation is claimed.

Code checks: Selene and Rojo build. Runtime testing remains pending under the repository's code-run boundary; no Studio MCP was used for this implementation.

## Playtest checklist

- Space, controller A, and mobile jump: tap once, release, tap again airborne; observe one upward kick and cloud burst.
- Hold the first press: no automatic extra jump. Repeated airborne presses: no third jump.
- Land, then repeat: extra jump restored. Verify slopes, moving platforms, ledges and low ceilings.
- Death/respawn, character replacement, seated/swimming/climbing states and stun: no stale approvals or illicit recharge.
- Remote spam/another character/grounded request rejected; two clients observe approved effects.
- Review latency and jump height in combat. Mobile multi-touch and device-specific jump button release need hands-on verification.

API reference: [UserInputService JumpRequest](https://create.roblox.com/docs/reference/engine/classes/UserInputService#JumpRequest) documents repeated signals for a single request; the implementation therefore latches until release.

## Follow-up: authored jump clips

Replaced reused takeoff presentation with dedicated Takeoff/DoubleJump/Fall assets; see `animations.md`. Fresh Studio testing now passed for keyboard regular jump, double jump, rejected third airborne press, landing recharge, and held-button guard. Clips loaded without errors/fallbacks. Device and multiplayer effect checks above remain pending. No claim that every abuse/latency scenario has been validated.
