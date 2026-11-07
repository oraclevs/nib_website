import 'site_content.dart';
import 'motion_capabilities.dart';

const motionWorkflowGuides = <DocArticle>[
  DocArticle(
    packageId: 'motion',
    id: 'water',
    title: 'Water surfaces',
    summary: 'Render decorative water over a bounded Flutter subtree, with visible sampling status and an honest fallback.',
    evidence: 'MotionNib/motion/lib/src/water/nib_water_surface.dart; MotionNib/motion/lib/src/water/nib_water_controller.dart; MotionNib/motion/test/water/nib_water_live_test.dart',
    sections: [
      DocSection(
        id: 'availability',
        heading: 'Stable API and bounded rendering',
        paragraphs: [
          'NibWaterSurface, NibWaterController, sampling policies, quality settings, material optics and bubble emission are available in nib_motion 0.3.5. They are not waiting for 0.3.6. Water is part of the stable public API. It renders a decorative 2D/2.5D approximation; it does not simulate a fluid volume.',
          'Use the live example to disturb a bounded surface. Its status comes from onStatus. Refractive means the surface bound a sampled image and shader; fallback means direct content or outlines without refraction. Neither status measures GPU completion, display latency or sustained frame rate.',
        ],
      ),
      DocSection(
        id: 'ownership',
        heading: 'Give the surface one controller and finite bounds',
        paragraphs: [
          'Create NibWaterController once in State and dispose it with that State. One surface drives one controller. Empty drops are useful for a continuous surface; individual droplets use stable IDs and receiver-local logical pixels. Do not tick the same controller from a second surface.',
          'Put the artwork or widgets to sample in background. Keep readable controls in child or outside the surface. The surface owns its shader and images. Its background must not recursively contain the water surface.',
        ],
        blocks: [
          DocLink(
            'Open the complete water example',
            '/playground/guide-motion-water-example',
          ),
        ],
      ),
      DocSection(
        id: 'sampling',
        heading: 'Choose freshness and cost deliberately',
        paragraphs: [
          'NibWaterSampling.legacy is the default asynchronous snapshot path. live samples child layers during scene composition. static caches artwork until invalidation. throttled samples at sampleInterval. For independently composited background animations, backgroundChanges can provide explicit invalidation.',
          'NibWaterQuality bounds the sampled input texture by pixel count, estimated RGBA bytes and texture dimensions. It does not bound every engine allocation or total GPU memory. Non-legacy paths use device-relative quality and NibWaterMaterial; captureScale belongs to the legacy path.',
          'Pause, TickerMode, app backgrounding and reduced motion suspend or reduce work according to the surface policy. Profile a sustained interaction in a consumer release/profile build on the intended device. A successful web build alone is not rendering evidence.',
        ],
      ),
      DocSection(
        id: 'interaction',
        heading: 'Keep the optical and input spaces distinct',
        paragraphs: [
          'Choose NibWaterInteraction.disturb for travelling disturbances or drag for moving a droplet. Do not combine two pointer owners for the same surface. The example also offers a keyboard-accessible Disturb button and Reset action.',
          'Only the designated Flutter background is sampled. Platform views and pixels outside that subtree are unsupported. Refraction clamps at the image edges; pad artwork when the composition requires it. Optical distortion does not inverse-warp hit targets. Foreground controls retain their normal semantics and geometry.',
          'Browser and physical-device parity, long-running GPU cost and platform-view capture are not established by this preview. Read the selected path before describing a recording as refraction.',
        ],
        blocks: [
          DocLink('Shader and glass limits', '/docs/motion/shaders'),
          DocLink('Profile a real screen', '/docs/motion/performance'),
          DocLink(
            'Published water API',
            'https://pub.dev/documentation/nib_motion/0.3.5/nib_motion/NibWaterSurface-class.html',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'debugging',
    title: 'Debugging and spring tuning',
    summary: 'Tune a real spring, inspect motion values, and replay entrances without changing your production interaction.',
    evidence: 'MotionNib/motion/doc/debug-tools.md; MotionNib/motion/lib/src/debug/nib_spring_tuner.dart; MotionNib/motion/test/runtime/helpers_tuner_test.dart',
    sections: [
      DocSection(
        id: 'tuner',
        heading: 'Tune one response at a time',
        paragraphs: [
          'NibSpringTuner compares duration/bounce and mass/stiffness/damping with a real SpringSolver preview, step-response curve and copyable configuration. Use it during development, then put the selected NibSpringDescription in the transition that owns the interaction.',
          'The live springs guide lets you retarget while moving. Compare travel distance and interruption as well as overshoot; a spring that feels good for a short press may be too loose for a large panel.',
        ],
        code: "// In a development panel.\nNibSpringTuner(\n  onChanged: (spring) => debugPrint('\$spring'),\n)",
        blocks: [DocLink('Try the spring controls', '/docs/motion/springs')],
      ),
      DocSection(
        id: 'inspect',
        heading: 'Inspect values before changing timing',
        paragraphs: [
          'NibMotionDebugger and NibMotionRegistry expose registered motion values and activity. NibPerfOverlay gives development feedback; Flutter DevTools and frame timings are needed to separate build, layout, paint and raster cost.',
          'If nothing moves, first inspect the target, reduced-motion policy, active ticker mode and controller ownership. A paint offset does not move a layout slot. A stale key can make Flutter reuse the wrong item after reordering.',
        ],
        blocks: [
          DocLink(
            'Troubleshoot a concrete symptom',
            '/docs/motion/troubleshooting',
          ),
        ],
      ),
      DocSection(
        id: 'replay',
        heading: 'Replay without losing application state',
        paragraphs: [
          'NibHotReloadReplay listens to reassemble and fires a descendant replay signal in debug mode. It does nothing in a release build. Use NibMotionReplaySignal and NibMotionReplayScope for an explicit replay action; a new key remounts a widget and resets its State.',
          'NibTimelineScrubber and NibTimelineDragScrubber seek a timeline. Scrubbing cancels pending play timers. Verify cancellation and disposal when leaving the screen, then test the same action with reduced motion.',
        ],
        blocks: [
          DocLink('Timeline playback and seeking', '/docs/motion/timeline'),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'migration',
    title: 'Migrating an existing animation',
    summary: 'Move one interaction from implicit widgets or an AnimationController to state targets, while preserving layout and ownership.',
    evidence: 'MotionNib/motion/doc/migration.md; MotionNib/motion/doc/interruption.md; MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    sections: [
      DocSection(
        id: 'start-small',
        heading: 'Keep the screen, change one interaction',
        paragraphs: [
          'Keep your state management, layout and business callbacks. Select a small animation with a clear endpoint and keyboard action. Replace its paint animation, compare the behavior, then decide whether more of the screen benefits.',
          motionReleaseNote,
        ],
      ),
      DocSection(
        id: 'concepts',
        heading: 'Map responsibility before syntax',
        paragraphs: [
          'These are Flutter concepts, not automatic source translations. Existing AnimationControllers remain useful when another API requires an Animation<double>.',
        ],
        blocks: [
          DocTable(
            headers: [
              'Existing responsibility',
              'NibMotion entry point',
              'Keep in mind',
            ],
            rows: [
              [
                'Implicit target change',
                'NibMotion + animate: NibAnim(...)',
                'x/y are paint offsets, not layout constraints.',
              ],
              [
                'Controller-driven start/stop',
                'NibMotionController',
                'Create once; dispose the owner.',
              ],
              [
                'Tween timing',
                'NibTransition(duration:, curve:)',
                'A spring instead uses physical settling.',
              ],
              [
                'Gesture position and release',
                'NibDragConfig + MotionValue',
                'Keep bounds and velocity in local pixels.',
              ],
              [
                'A timed multi-step sequence',
                'NibKeyframe / NibTimeline',
                'Use explicit starts for reproducible seeks.',
              ],
              [
                'Removed list item',
                'NibPresence + stable keys + exit',
                'Application state still owns membership.',
              ],
              [
                'Measured layout change',
                'NibMotion(layout:) + NibLayoutScope',
                'Respect the documented geometry limits.',
              ],
            ],
          ),
        ],
      ),
      DocSection(
        id: 'verify',
        heading: 'Test interruption before migrating the next screen',
        paragraphs: [
          'Change the target again before settling. Navigate away while motion runs. Check focus, hit targets, reduced motion, controller cleanup and final state. Avoid replaying by changing a key unless you intend to reset local State.',
          'Effects from other libraries may combine several properties. Compose NibAnim fields or keyframes for the same job; do not assume a matching preset name has identical timing or lifecycle behavior.',
        ],
        blocks: [
          DocLink(
            'Build the first state-driven animation',
            '/docs/motion/first-animation',
          ),
          DocLink('Controller ownership', '/docs/motion/controllers'),
          DocLink(
            'Accessibility and reduced motion',
            '/docs/motion/accessibility',
          ),
        ],
      ),
      DocSection(
        id: 'applications',
        heading: 'Explore the complete example application',
        paragraphs: [
          'The NibMotion gallery includes 29 examples: the original 21 demos, Daily Focus, two quick starts and five additional examples. It is included with the published 0.3.6 release. Its README has local launch instructions.',
        ],
        blocks: [
          DocLink(
            'Review the 29-example gallery and launch instructions',
            'https://github.com/oraclevs/nib_motion/blob/v0.3.6/example/README.md',
          ),
        ],
      ),
    ],
  ),
];
