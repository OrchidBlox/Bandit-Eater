# Corrected Roblox cloud sky

This supersedes `../cloud-panorama`. The first export used inside-facing cube labels directly, which reversed Roblox's left/right assignment and oriented its caps incorrectly. Texture loading alone did not reveal that defect.

`scripts/prepare_cloud_sky.py` now converts the projection to Roblox's layout: swap left/right labels, rotate the projected upper face 90 degrees counterclockwise and lower face clockwise. Those rotations are relative to our own projection coordinates; they differ from the Jaxry source coordinate system described in Roblox's guide.

Reference: https://devforum.roblox.com/t/custom-skyboxes-101/2849003

Run `python scripts/check_cloud_sky.py` to verify all twelve joins using Roblox's face orientation. All twelve matched with zero channel difference. `preview.jpg` shows the unfolded projection before the Roblox storage rotations.

Only the cap textures required new uploads. The lateral texture IDs were reassigned. `asset-ids.json` matches `src/shared/PilotSkyConfig.luau`.

Verified on 2026-10-24: all six client fetch statuses Success; corrected IDs applied in the running Play session. A desktop view of the arena horizon was inspected and showed continuous clouds. A complete camera sweep was not performed while the user was playing.
