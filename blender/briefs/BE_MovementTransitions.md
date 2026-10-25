# Movement transitions

Approved reference: `docs/reference/movement-transitions-v1.png`. Owner authorized Blender animation and integration after viewing the concept. Preserve approved V5 run (`116051034967244`, 0.8-second loop) and physical movement rules.

Use the original `MrXen0_R15RIG_v1.2.blend` R15 rig in a separate scene, preserving source file, hierarchy, meshes and rest controls. Author five non-looping clips at Movement priority: Start, Stop, Takeoff, LandRun, LandIdle. Start and LandRun should hand off into V5's first contact pose; Stop and LandIdle recover to neutral. Takeoff must react immediately to the game's jump rather than delaying physical movement for anticipation.

Target short responsive clips, approximately 0.2-0.3 seconds: forward weight shift and push-off on start; braking plant and torso settle on stop; extension and airborne lift on takeoff; visible compression and recovery on landing. Keep the game style's broad readable silhouettes, bent elbows and strong leg drive. The concept is a pose guide, not a literal fixed sequence when gameplay interrupts it.

Render the actual rig from two angles, inspect the contact sheet and decoded GIF frames, export evaluated deform poses with finite orthonormal matrices and preserved joint lengths. Use honest status reporting for visual review versus runtime validation. Do not change gameplay speed, jump velocity, hitboxes, combat or map. Test rapid starts/stops, takeoff/landing while moving or stationary, interruption and cleanup. Keep cloud emission gated to eligible contacts.
