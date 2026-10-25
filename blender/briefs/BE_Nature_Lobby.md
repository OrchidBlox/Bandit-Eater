# Low-poly nature lobby — approved asset reuse

2026-10-24 owner request: "lobby needs the same love". The approved arena establishes the style; reuse its uploaded tree and rock meshes. Reference: `docs/reference/concepts-v1-2026-10-24/lobby-two-leaderboards-v3.png`.

Keep the compact 156 x 112 layout, two boards, simple cyan gate and clear central plaza. Natural muted greens #6FAE4A/#4C8A3A, stone #8A8F99/#5F6672, wood #7A5236, warm cream paving. Flat-shaded SmoothPlastic props; textured Grass on plain-part garden surfaces. Existing golden light remains: ClockTime 16.5, Brightness 2.5, Ambient #7D8FA0, OutdoorAmbient #A0B0C0, Atmosphere density .3/haze 1/color #D6E8F0, bloom .3, contrast .05.

| Set | Placement / size | Mesh budget |
| --- | --- | --- |
| Approved TreeRoundA/B/C | Four existing corner gardens, scale .85; two portal-side gardens at .65. Base sizes 22x27x20, 20x25x18, 24x29x22 | 194 triangles each |
| Approved RockSmall/Medium/Large | Six existing rock gardens, fitted within beds; heights roughly 2–3 studs | 46/58/64 triangles |
| BushA / BushB / FlowerClump | Grouped along bed edges, cream blooms facing plaza. Base sizes 4x2x3, 5x2.4x4, 2x1.2x2 | 60 each; use only after explicit mesh approval |
| Existing benches, fence and lamps | Keep layouts; smooth surfaces and coherent wood/stone colors | Retained plain-part construction; new mesh sets deferred |
| Floors, paving, planters | Plain parts; warm paving, textured grass, low stone garden borders | No mesh conversion |

Preserve all named anchors and all board descendants, ArenaFloor, BanditClearings, LobbyFloor, PilotLobbySpawn, ArenaTeleportPad, every InvisibleBounds, Elevation=180, LobbyLift=60. Archive replaced decoration under ServerStorage.PolishOld.Lobby_Nature_v1. Stage replacements before changing live parents. One Studio recording for lobby placement. Validate anchors, approach sightlines, portal entry and phone readability. No arena geometry changes.
