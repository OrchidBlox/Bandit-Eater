# Approved jump concept animation set

Owner request: animate and add it lets also image generate dash.

References: docs/reference/regular-jump-concept-v1.png and double-jump-concept-v1.png. Snappy action on canonical original MrXen0 R15 rig in isolated scene, original unchanged. Preserve V5 run and current landing transitions.

- Takeoff: 10/30 seconds nonloop; crouch, three-frame launch, brief extension hold, tucked apex. Actual jump physics begins immediately; no artificial anticipation delay.
- DoubleJump: 12/30 seconds nonloop; airborne, tuck, strong asymmetric second kick held two frames, stretch then hold rise until actual descent. AirBurst=Both marker at 4/30 seconds for presentation puff; physics impulse remains server authoritative at input acceptance.
- Fall: 12/30 seconds loop; balanced descending pose, no root travel. Runtime follows actual vertical velocity and landing, not a fixed flight duration.

No damage/strike marker; no root motion trajectory, weapons or extra mesh. In-game grounding owns landing timing; existing LandIdle/LandRun are preserved. Inspect side/three-quarter renders and evaluated-deform export before upload.
