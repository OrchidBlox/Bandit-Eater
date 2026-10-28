# Cartoon cloud sky V3

Generated with the built-in image-generation tool, 2026-10-25. Source: `cartoon-cloud-sky-v3.png`. Runtime cubemap: `assets/sky/cartoon-cloud-v3/`. Original panorama and V2 faces are retained.

## Prompt

Create a production game sky texture: a full 360 by 180 degree equirectangular panorama, 2:1 aspect ratio, seamless longitude, sky ONLY, for a charming low-poly Roblox nature arena with chunky cartoon VFX. Big appealing rounded scalloped cumulus cloud banks with simple clean stylized lobes and broad soft cel-painted shading; cream-white tops, very pale powder-blue undersides. Soft turquoise-blue sky overhead fading to pale #CFE6F0 at horizon. Warm gentle late-afternoon sunlight, bright cheerful tranquil atmosphere, no orange sunset, no harsh glare. Clouds frame distant horizon at the middle of this spherical panorama, with generous clear blue space toward zenith; lower hemisphere pale airy blue with soft distant cloud banks, never dark bottom. Avoid photographic wisps, noisy detail, realistic vapor, dense gray storm clouds, mountains, land, objects, text, water, sun disk, moon, stars, borders or cube-face layout. Uniform sky color at top and bottom poles, left and right edges join seamlessly. This image is the actual sky texture, not a mockup, not a landscape illustration. Elegant readable game-art shapes, polished cartoon adventure-game art.

## Packaging

The existing panorama projection conditions the longitude join and poles, projects all six faces, and applies Roblox's lateral/cap orientations. No separate generation per face. All twelve exported edge pairs matched exactly (maximum channel difference zero).

```powershell
python scripts/prepare_cloud_sky.py --source docs/reference/cartoon-cloud-sky-v3.png --dest assets/sky/cartoon-cloud-v3
python scripts/check_cloud_sky.py --root assets/sky/cartoon-cloud-v3
```
