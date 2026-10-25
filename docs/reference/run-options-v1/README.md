# Run animation options

Five concept boards generated with the built-in image tool, following Bandit Eater's blocky characters, low-poly nature setting and snappy action direction. All include small rounded white footstep clouds matching the existing puff sprite (`rbxassetid://71229989533127`).

- [1. Hero Sprint](01-hero-sprint.png)
- [2. Low Sprinter](02-low-sprinter.png)
- [3. Bouncy Runner](03-bouncy-runner.png)
- [4. Scrappy Dash](04-scrappy-dash.png)
- [5. Powerhouse Run](05-powerhouse-run.png)

These are visual options, not authored animation keyframes. The small pose rows illustrate the intended feel; exact opposite-limb alternation, planted feet and loop continuity must be authored and validated on the R15 rig after selection.

Footstep behavior for the selected run: one small puff on each alternating grounded foot contact; brief expansion and fade behind the runner; none while idle, jumping or falling. Reuse the existing puff image. No running animation or footstep-effect code has been changed as part of these concept boards.

Exact generation prompts: [prompts.json](prompts.json).

Selected: option 1 Hero Sprint with a little option 3 bounce. [Blender implementation and validation](../../hero-sprint-validation.md).
