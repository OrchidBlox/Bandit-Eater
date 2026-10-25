# Bandit Eater cloud sky

Approved generated panorama: `docs/reference/concepts-v1-2026-10-24/cloud-sky-panorama.png`.

`scripts/prepare_cloud_sky.py` reprojects it into these six 1024px Roblox skybox faces, conditioning the longitude join and poles. `preview.jpg` is the unfolded cube. The checked adjacent edges match exactly.

Uploaded image IDs are recorded in `asset-ids.json` and `src/shared/PilotSkyConfig.luau`. Roblox processing completed for all six images on 2026-10-24. Studio client asset fetch statuses were verified as Success for all six, and `Lighting.PilotCloudSky` was activated in the current Play session. A full in-game visual review is still needed.

`PilotSkyController` preloads the images without blocking gameplay and keeps the existing sky until all six are available. It checks for up to five minutes, then leaves the fallback sky if an asset is unavailable. Restart Play to run the loader again.

Roblox format reference: https://create.roblox.com/docs/environment/skybox
