# Power Moves V2 — stronger combat posing

Owner feedback: V1 casts felt small and rigid. Preserve V1; author V2 on unchanged canonical MrXen0 rig in headless Blender. Ten reused archetypes across 36 move clips: push, throw, wave, raise, slash, rising, slam, stomp, ritual and spin. Kit-specific timing/pose variations remain documented reuse.

V2 emphasizes counter-rotating hips/chest, 30–70 degree knee compression, extended arm reach, wide sword arcs, raised heavy anticipation, decisive leaning release, two-frame release hold, overshoot and recovery. All Release markers remain exactly equal to current PowerMoves.Delay, including fractional frames; total duration remains Delay+.5. Stronger posing does not alter damage, range or cooldown.

Grounded compression needs a vertical LowerTorso pose adjustment; it is derived from evaluated foot bottoms each sample. Horizontal root travel is zero, and there is no gameplay displacement or animation-driven flight. Moving variants mute root/legs and retain forceful torso/head/arms. Stationary fullbody casts retain grounded leg work; footsteps must not fire from cast clips.

Entry fade .05s, exit .10s are integration starting points. Higher-priority combat, dash, death, respawn and cancellation interrupt. Server remains authoritative for release effects. These transitions require live game review after upload; Blender previews do not establish runtime feel.

Initial review covers Gust, Quake, Tidal Wave, Traveling Slash, Grand Cleave and Shadow Snare. Root reviews this actual rig sheet before complete export. Commands: Blender -b --factory-startup --python blender/anims/build_power_moves_v2.py -- --preview --render (six representatives); omit --preview and add --export for all36 plus36Moving. Compose with system Python same script --compose (add --preview for six). No live Blender session edits.
