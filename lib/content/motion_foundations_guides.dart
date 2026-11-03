import 'site_content.dart';
import 'motion_capabilities.dart';

const motionFoundationsGuides = <DocArticle>[
  DocArticle(
    packageId: 'motion',
    id: 'introduction',
    title: 'Introduction',
    summary: 'A unified Flutter motion system for state transitions, physics, layout, scroll, orchestration and visual effects.',
    evidence: 'MotionNib/motion/lib/src/core/nib_anim.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart; MotionNib/motion/lib/src/core/nib_transition.dart',
    sections: [
      DocSection(
        id: 'one-motion-model',
        heading: 'Carry an interaction from input to pixels',
        paragraphs: [
          'NibMotion connects targets, reactive motion values and drivers in one model. A dragged card can hand its velocity to inertia or a spring. A scroll position can drive opacity and translation together. Layout, presence and timelines build on those same values rather than requiring a separate animation model for each behavior.',
          'Begin with initial, animate and a transition on one widget. Controllers and lower-level solvers are available when your interaction needs them. Continuous paint updates can avoid rebuilding the child every frame; text content changes and application state still rebuild where needed.',
          motionReleaseNote,
          'NibComponents is a separate UI library that depends on NibMotion. NibGenUI is a separate, unpublished structured-UI preview. Neither is required to animate an existing Flutter widget.',
        ],
        blocks: [DocLink('Install NibMotion', '/docs/motion/installation')],
      ),
      ...motionCapabilities,

      DocSection(
        id: 'before-you-start',
        heading: 'Begin with a Flutter widget you already understand',
        paragraphs: [
          'You need a Flutter app and a widget whose state can change. NibMotion does not replace Row, Column, Stack, or a state manager. Flutter still decides where the child belongs in layout. NibMotion paints an offset, scale, rotation, opacity, or decoration as that state changes. A card translated with x still occupies its original layout slot, which matters when another widget sits beside it.',
          'Import package:nib_motion/nib_motion.dart and place NibMotion around one child. Give the child a stable identity while you change targets. For a first experiment, use a colored box rather than a whole route; it is easier to see which visual property is moving.',
        ],
      ),
      DocSection(
        id: 'model',
        heading: 'State describes the destination',
        paragraphs: [
          'NibMotion wraps an ordinary child. Its initial value is the entrance state; animate is the target when application state changes. Both accept a NibAnim or a named variant. Leave initial out to start at the neutral NibAnim.identity state.',
          'NibAnim properties are nullable. An omitted property stays untouched by that state. x and y are logical pixel offsets from the child’s natural position; opacity runs from zero to one; rotate, rotateX, and rotateY use turns, where one turn is a full rotation. Keep the child’s layout and hit target useful at both endpoints.',
        ],
        code: "NibMotion(\n  initial: const NibAnim(opacity: 1, x: -36, scale: 0.9),\n  animate: NibAnim(opacity: 1, x: _moved ? 38 : -38, scale: 1),\n  transition: NibTransition.springGentle,\n  child: const Icon(Icons.touch_app),\n)",
        api: [
          DocApiEntry(
            name: 'initial',
            type: 'NibAnim or String?',
            defaultValue: 'NibAnim.identity',
            description: 'Entrance state or named variant.',
          ),
          DocApiEntry(
            name: 'animate',
            type: 'NibAnim or String?',
            defaultValue: 'null',
            description: 'Current target or named variant.',
          ),
          DocApiEntry(
            name: 'child',
            type: 'Widget',
            defaultValue: 'required',
            description:
                'The Flutter widget painted through the motion wrapper.',
          ),
        ],
      ),
      DocSection(
        id: 'read-the-example',
        heading: 'Read the three lines that control movement',
        paragraphs: [
          'In this small target-state example, initial places the icon 36 logical pixels left of its natural position at 90 percent size. animate reads _moved, a boolean kept in State, and chooses either x: 38 or x: -38 at full size. Opacity stays at one. NibMotion drives the specified paint properties; it does not animate unrelated properties left null in NibAnim.',
          'The first appearance is an entrance, not an instruction to keep restarting. When the button changes _moved with setState, the same NibMotion heads toward the new target from its current painted state. springGentle is the timing rule here. Without an explicit transition, the default is a 300 ms easeInOut tween unless an ancestor configuration changes it. Continue to Start with motion for a working entrance and Your first animation for a stateful interaction.',
        ],
      ),
      DocSection(
        id: 'response',
        heading: 'Transition describes the journey',
        paragraphs: [
          'NibTransition chooses a fixed-duration tween or a physical spring. The default is a 300 ms easeInOut tween unless an ancestor NibMotionConfig supplies another default. Setting spring selects spring physics; duration and curve then stop controlling that movement.',
          'In Your first animation, try changing the target twice before it settles. A rebuild supplies the next destination; NibMotion owns the per-property drivers and moves from its current painted values.',
        ],
      ),
      DocSection(
        id: 'values',
        heading: 'Use MotionValue for direct data flow',
        paragraphs: [
          'MotionValue is a ValueListenable whose changes can reach NibMotion’s render object without rebuilding the child on every animation frame. Derived values can map one source into several paint properties. The creator must dispose externally owned values and their derived listeners.',
          'For a first screen, you rarely need to create one. Start with application state and animate; NibMotion creates its own values. Reach for an external MotionValue when another changing source, such as a slider or scroll position, should drive paint continuously. This distinction keeps the first example small and gives you a clear owner for disposal later.',
        ],
      ),
      DocSection(
        id: 'try-it',
        heading: 'Choose the next step',
        paragraphs: [
          'After Installation, Start with motion introduces a finite entrance. Your first animation then connects Save and Undo actions to an interruptible spring. Those lessons include live controls and runnable source; this introduction explains how the pieces fit together.',
          'Install only nib_motion to animate existing Flutter widgets. Add nib_components when you also want the accompanying UI controls; it is a separate package, not a prerequisite for this guide.',
        ],
      ),
      DocSection(
        id: 'when-it-surprises-you',
        heading: 'Three checks when the result looks wrong',
        paragraphs: [
          'If nothing moves, check that animate differs from the current value and that reduced motion is not active. If an entrance keeps replaying, check whether a changing key is remounting the widget. If nearby content does not move out of the way, remember that x and y are paint offsets; use layout animation when the child’s actual layout position changes.',
          'The starter lessons separate entrance timing from state-driven interaction. From there, Springs explains interruption, Keyframes explains a timed sequence, and Motion values explains continuous input.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'installation',
    title: 'Installation',
    summary:
        'Install the hosted package and inspect the version your app uses.',
    evidence: 'MotionNib/motion/pubspec.yaml; MotionNib/motion/lib/nib_motion.dart; MotionNib/motion/CHANGELOG.md',
    sections: [
      DocSection(
        id: 'prerequisites',
        heading: 'Start from a working Flutter app',
        paragraphs: [
          'Run flutter doctor and make sure your app already builds on the platform you care about. Open the app’s pubspec.yaml at its project root; that is the directory where flutter pub add belongs. The command updates the dependency declaration and lockfile for that app. It does not change another Flutter project in the workspace.',
          'If you only want animation, add nib_motion. nib_components is a separate package that depends on motion, but it is not required for the first tutorial. A direct motion dependency makes the API you use explicit in your app’s manifest.',
        ],
      ),
      DocSection(
        id: 'add',
        heading: 'Add the package',
        paragraphs: [
          'Run the package manager from your Flutter app, then import the public barrel. These Motion guides target the hosted 0.3.5 API. The separate 0.3.6 documentation and gallery candidate is still under review.',
        ],
        code: "flutter pub add nib_motion\nflutter pub get\nflutter pub deps --style=compact",
      ),
      DocSection(
        id: 'import',
        heading: 'Use public exports',
        paragraphs: [
          'Import package:nib_motion/nib_motion.dart for NibMotion, NibAnim, transitions, values, gestures, layout, presence, and the other exported widgets. Application code should not import lib/src files: that bypasses the package’s public surface.',
        ],
        code: "import 'package:nib_motion/nib_motion.dart';",
      ),
      DocSection(
        id: 'first-build',
        heading: 'Prove the import in a small screen',
        paragraphs: [
          'After the package resolves, put the public import at the top of a Dart file with a Flutter widget. Wrap a visible child in NibMotion, give it initial opacity zero and animate opacity one, and run the app. The child should appear when the entrance starts. If it appears immediately, check the system’s reduced-motion setting before assuming the import failed.',
          'Use flutter analyze and your app’s test or run command after adding the widget. Compilation verifies the API available in your resolved archive. Then use flutter pub deps --style=compact and pubspec.lock to record the actual nib_motion version. These guides are checked against 0.3.5; compare your lockfile when following an older tutorial.',
        ],
        code: "import 'package:flutter/material.dart';\nimport 'package:nib_motion/nib_motion.dart';\n\n// Inside a build method:\nNibMotion(\n  initial: const NibAnim(opacity: 0),\n  animate: const NibAnim(opacity: 1),\n  child: const Text('Installed and moving'),\n)",
      ),
      DocSection(
        id: 'compatibility',
        heading: 'Check the resolved graph',
        paragraphs: [
          'The published 0.3.5 package requires Flutter 3.29 or newer and Dart 3.0 or newer. Check the constraints in the exact version you resolve, then compile a copied example against your own SDK. A web build or widget test does not establish physical-device rendering behavior.',
          'Read the changelog before moving between hosted and candidate versions. The preview uses the 0.3.5 implementation. The 0.3.6 candidate is not a published release.',
        ],
      ),
      DocSection(
        id: 'resolution-problems',
        heading: 'If installation or compilation fails',
        paragraphs: [
          'First read the solver error instead of changing version ranges blindly. It names the package or SDK constraint that could not be satisfied. Compare that requirement with flutter --version, your pubspec.yaml, and pubspec.lock. The 0.3.5 archive declares a Flutter 3.29 floor; inspect the archive you actually resolved.',
          'If an import is red after a successful pub get, check its spelling and make sure the Dart file belongs to the app whose pubspec was changed. Use the package barrel, not a lib/src path. If a copied recipe mentions an unavailable constructor parameter, compare it with the version in your lockfile; these guides target 0.3.5.',
        ],
      ),
      DocSection(
        id: 'after-installation',
        heading: 'Move to a stateful example',
        paragraphs: [
          'The opacity entrance confirms package resolution, but it does not teach retargeting. Continue to Start with motion for a staged entrance, then Your first animation for a responsive state change. A package can compile on one target while shader rendering or touch behavior still needs device testing, so keep those later checks separate from installation.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: "getting-started",
    title: "Start with motion",
    summary: "Build a short, staged entrance from opacity, vertical travel and timing.",
    evidence: 'MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    sections: [
      DocSection(
        id: "first-step",
        heading: "Let one widget arrive",
        paragraphs: [
          "Wrap a headline in NibMotion. initial describes its first appearance; animate describes its resting state. The preview starts each line slightly lower and transparent, then brings it to its normal position.",
          "Start with the small wrapper below. Use the preview’s Copy minimal example for a complete Flutter app.",
        ],
        code: "NibMotion(\n  initial: const NibAnim(opacity: 0, y: 18),\n  animate: const NibAnim(opacity: 1, y: 0),\n  transition: const NibTransition(\n    duration: Duration(milliseconds: 480),\n    curve: Curves.easeOutCubic,\n  ),\n  child: const Text('A little motion. A clear beginning.'),\n)",
      ),
      DocSection(
        id: "retarget",
        heading: "Give the content an order",
        paragraphs: [
          "The headline leads and the supporting details follow. Each wrapper uses the same 480 ms transition, with delay increased by 90 ms per item. The preview plays once; Replay entrance explicitly starts a new entrance.",
          "Delay belongs to this timed entrance. Use a spring for an interaction whose destination can change while it is moving; the next lesson builds that interaction.",
        ],
      ),
      DocSection(
        id: "state-and-identity",
        heading: "Know what causes a new entrance",
        paragraphs: [
          "A normal parent rebuild keeps the same NibMotion element. Changing its animate value updates the target. Changing its key creates a fresh element and replays initial.",
          "Replay entrance changes a generation key deliberately. Do not use a changing timestamp as a key for ordinary state updates: that would discard the current motion.",
        ],
      ),
      DocSection(
        id: "try-the-sample",
        heading: "Change one thing at a time",
        paragraphs: [
          "Try y: 36 for a longer entrance or remove the per-item delay to let all details arrive together. Keep opacity: 1 and y: 0 as the explicit endpoint.",
          "Translation affects painting, not the layout slot. Leave enough room for travel and keep interactive controls outside the moving content while learning.",
        ],
      ),
      DocSection(
        id: "troubleshoot-first",
        heading: "If the entrance is not visible",
        paragraphs: [
          "Reduced motion should show the complete card immediately. Otherwise confirm that initial and animate differ and that the wrapper is newly mounted.",
          "An entrance that has already finished stays finished on an ordinary rebuild. Use Replay entrance or a new key only when a replay is intended.",
        ],
      ),
      DocSection(
        id: "next",
        heading: "Continue with a stateful interaction",
        paragraphs: [
          "Your first animation turns a bookmark into a responsive Save and Undo interaction. It uses a persistent spring target instead of a staged entrance.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: "first-animation",
    title: "Your first animation",
    summary: "Make saving an idea feel responsive with one state value and an interruptible spring.",
    evidence: 'MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    sections: [
      DocSection(
        id: "place-the-state",
        heading: "Let application state own the bookmark",
        paragraphs: [
          "Keep bool saved = false in the owning State. The button changes it with setState. The same boolean selects the icon, confirmation text and motion target.",
          "Keep the Save idea button outside the animated wrapper, giving pointer and keyboard users a stable action target.",
        ],
      ),
      DocSection(
        id: "source",
        heading: "Describe the two states",
        paragraphs: [
          "Saving lifts, enlarges and tilts the bookmark. Undo restores all three properties. The NibMotion wrapper stays mounted, so repeated actions retarget its current motion.",
        ],
        code: "// Keep this field in State: bool saved = false;\nNibMotion(\n  animate: NibAnim(\n    y: saved ? -10 : 0,\n    scale: saved ? 1.15 : 1,\n    rotate: saved ? -.035 : 0,\n  ),\n  transition: NibTransition.springGentle,\n  child: Icon(saved ? Icons.bookmark : Icons.bookmark_border),\n)\n// In a button callback: setState(() => saved = !saved);",
      ),
      DocSection(
        id: "read-properties",
        heading: "Read numbers in their units",
        paragraphs: [
          "y is a logical pixel offset: -10 lifts the bookmark ten pixels. scale: 1.15 enlarges it by fifteen percent. rotate is measured in turns; -.035 is a small counterclockwise tilt.",
          "The icon change is ordinary Flutter state. NibMotion animates the position, scale and rotation around it.",
        ],
      ),
      DocSection(
        id: "properties",
        heading: "Give every changing property an endpoint",
        paragraphs: [
          "Both branches explicitly set y, scale and rotate. A nullable field omitted from a target does not request a reset. Use NibAnim.identity when you want explicit neutral transform and opacity values.",
          "The spring controls settling. A duration does not control a transition that has a spring configured.",
        ],
      ),
      DocSection(
        id: "verify",
        heading: "Undo before it settles",
        paragraphs: [
          "Press Save idea, then Undo save while the bookmark is moving. Try several quick alternations. The text should always match the final saved state and the icon should settle at the corresponding target.",
          "Enable reduced motion. The same final bookmark and confirmation must remain visible without travel.",
        ],
      ),
      DocSection(
        id: "change-one-property",
        heading: "Tune the response",
        paragraphs: [
          "Try scale: 1.05 for a quieter response, or y: -18 for more lift. Change one value at a time and repeat the quick Save and Undo test.",
          "Keep a stable key. A new key would remount the animation instead of letting the existing spring respond to the new state.",
        ],
      ),
      DocSection(
        id: "first-errors",
        heading: "Check state before timing",
        paragraphs: [
          "If the icon changes but does not move, confirm the two targets differ and reduced motion is off. If the label is wrong, inspect the host state update before changing animation parameters.",
          "Next, use Springs for physical tuning, Transitions for fixed timing, or Layout animations when neighboring widgets should reflow.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'springs',
    title: 'Springs and interruption',
    summary: 'Keep an interaction responsive when its destination changes. Learn the spring model, tune its response, and handle interruption correctly.',
    evidence: 'MotionNib/motion/lib/src/physics/spring_description.dart; MotionNib/motion/lib/src/physics/spring_solver.dart; MotionNib/motion/lib/src/core/nib_transition.dart; MotionNib/motion/lib/src/core/nib_motion_controller.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    relatedRecipeId: 'spring-retarget',
    sections: [
      DocSection(
        id: 'mental-model',
        heading: 'Spring model',
        paragraphs: [
          'A spring follows a destination from its current position and velocity. Use it for selection indicators, draggable objects, or panels that can reverse while moving. The user can change their mind before the animation finishes. A timed transition is a better fit when several events must occupy fixed intervals.',
          'Stiffness pulls toward the target, damping resists motion, and mass changes inertia. The solver advances a Flutter SpringSimulation on a ticker and writes the result into a MotionValue. The simulation settles at a numerical tolerance; it does not have a guaranteed millisecond finish time.',
          'NibTransition uses a spring when spring is non-null. Its duration and curve do not control that spring movement. Keyframe sequences have a different timed contract; see Keyframes before mixing the two models.',
        ],
        blocks: [
          DocLink('Compare timed transitions', '/docs/motion/transitions'),
        ],
      ),
      DocSection(
        id: 'initial-target',
        heading: 'Initial state and target',
        paragraphs: [
          'Create a Flutter app and add nib_motion. This complete example needs no website helpers or assets. NibMotion starts at initial and responds when animate changes. Keep the same widget key so a new target reaches the running animation instead of replacing its state.',
          'Press Change target, then press it again before the square arrives. The square reverses from its current position. The reserved 260-pixel lane leaves room for the 160-pixel travel and square. A transform changes the painted position without reserving a new layout slot.',
        ],
        code: "import 'package:flutter/material.dart';\nimport 'package:nib_motion/nib_motion.dart';\n\nvoid main() => runApp(const MaterialApp(home: SpringLesson()));\n\nclass SpringLesson extends StatefulWidget {\n  const SpringLesson({super.key});\n  @override\n  State<SpringLesson> createState() => _SpringLessonState();\n}\n\nclass _SpringLessonState extends State<SpringLesson> {\n  bool right = false;\n  @override\n  Widget build(BuildContext context) => Scaffold(\n    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [\n      SizedBox(width: 260, height: 96, child: Align(\n        alignment: Alignment.centerLeft,\n        child: NibMotion(\n          initial: const NibAnim(x: 0),\n          animate: NibAnim(x: right ? 160 : 0),\n          transition: const NibTransition(spring: NibSpringDescription(\n            mass: 1, stiffness: 180, damping: 18,\n          )),\n          child: const SizedBox(width: 48, height: 48,\n            child: ColoredBox(color: Colors.amber)),\n        ),\n      )),\n      FilledButton(\n        onPressed: () => setState(() => right = !right),\n        child: const Text('Change target'),\n      ),\n    ])),\n  );\n}",
        blocks: [
          DocLink(
            'Installation and package versions',
            '/docs/motion/installation',
          ),
        ],
      ),
      DocSection(
        id: 'parameters',
        heading: 'Parameters',
        paragraphs: [
          'Change one coefficient while keeping the target distance constant. More damping reduces oscillation; higher stiffness usually makes the response start faster. Mass affects both acceleration and settling, so changing it can also change overshoot. Values are simulation coefficients, not measurements of a physical object on screen.',
          'The constructor validates finite values in debug mode. Mass and stiffness must be positive; damping may be zero. Zero damping can keep an animation oscillating and is unsuitable when later work waits for settlement. toFlutter substitutes safe defaults for invalid unchecked values in release mode; validate external settings before constructing the description.',
        ],
        api: [
          DocApiEntry(
            name: 'mass',
            type: 'double',
            defaultValue: '1.0',
            description: 'Positive, finite inertia coefficient.',
          ),
          DocApiEntry(
            name: 'stiffness',
            type: 'double',
            defaultValue: '100.0',
            description: 'Positive, finite attraction coefficient.',
          ),
          DocApiEntry(
            name: 'damping',
            type: 'double',
            defaultValue: '10.0',
            description:
                'Finite resistance coefficient, greater than or equal to zero.',
          ),
        ],
      ),
      DocSection(
        id: 'choose-values',
        heading: 'Presets and configuration',
        paragraphs: [
          'Use a named description as a starting point. These are actual NibSpringDescription constants. The preview’s Balanced option is a local recipe setting of mass 1, stiffness 180 and damping 18; it is not another package preset.',
          'NibTransition(spring: description), NibTransition.of(description), and NibMotion(spring: description) select a spring. Do not supply both NibMotion.spring and NibMotion.transition. NibTransition.springGentle, springSnappy and springWobbly are convenient constants.',
          'NibTransition.springWith(duration: ..., bounce: ...) converts a perceptual duration and bounce into coefficients at mass 1. Defaults are 500 ms and bounce 0. Duration must be at least 1 ms; bounce is strictly between -1 and 1. Zero bounce is critically damped; positive values oscillate; negative values are overdamped. Perceptual duration is not a completion deadline.',
        ],
        blocks: [
          DocTable(
            headers: ['Description', 'Mass', 'Stiffness', 'Damping'],
            rows: [
              ['gentle', '1', '120', '14'],
              ['snappy', '1', '300', '20'],
              ['wobbly', '1', '180', '12'],
              ['stiff', '1', '400', '28'],
            ],
          ),
        ],
        code: "final response = NibTransition.springWith(\n  duration: const Duration(milliseconds: 450),\n  bounce: 0.25,\n);\n// Or: const NibTransition(spring: NibSpringDescription.gentle)",
      ),
      DocSection(
        id: 'retarget',
        heading: 'Retargeting',
        paragraphs: [
          'Changing animate on the same NibMotion retargets its active values. A SpringSolver starts from the current MotionValue position and carries its velocity unless another starting state is supplied. Do not replace the widget key or reconstruct an externally owned MotionValue for each target change.',
          'The playground lets you change distance and all three coefficients. Press Send right and then Send left while the tile is still moving. You should see a continuous reversal. Higher damping can make that reversal less oscillatory, but it does not make the target change instantaneous.',
        ],
        blocks: [
          DocList([
            DocListItem(
              'Try the default response, then reverse it mid-flight.',
            ),
            DocListItem(
              'Increase damping and repeat the same gesture.',
              children: [
                DocListItem(
                  'Keep distance and stiffness unchanged so the comparison has one variable.',
                ),
                DocListItem(
                  'Watch the path immediately after reversal and the final settling response.',
                ),
              ],
            ),
            DocListItem(
              'Enable reduced motion and repeat; the chosen destination must remain clear.',
            ),
          ], ordered: true),
          DocLink(
            'Open mid-flight spring retarget',
            '/playground/spring-retarget',
          ),
        ],
      ),
      DocSection(
        id: 'experiment',
        heading: 'Velocity',
        paragraphs: [
          'NibMotionController.velocityOf(NibProperty.x) reads the current x velocity in logical pixels per second. Other properties use their own value units per second. This is a live value, not a screen refresh-rate or performance measurement.',
          'For direct SpringSolver use, a nonzero initialVelocity overrides inherited velocity. The current API treats initialVelocity: 0 as the default: with no from value it still inherits MotionValue.velocity. To start at rest deliberately, pass from: value.value or reset the value’s velocity. This distinction matters when switching from a drag or another driver.',
          'Calling controller.set(target) jumps immediately and resets property velocity unless keepVelocity is true. Use it for a deliberate snap or reset, not for ordinary continuous retargeting.',
        ],
        blocks: [
          DocLink(
            'Motion values and driver ownership',
            '/docs/motion/motion-values',
          ),
        ],
      ),
      DocSection(
        id: 'completion',
        heading: 'Completion and cancellation',
        paragraphs: [
          'Awaiting SpringSolver.animateTo or NibMotionController.start waits until its operation resolves. Resolution also happens when motion is superseded, stopped, or its widget is disposed. The Future alone does not prove that the requested target was reached.',
          'SpringSolver.onComplete runs when that simulation settles. A controller listener is a general change notification and can also run after set or stop. Keep business state separate from animation state; do not use a notification as proof that a save, upload, or purchase succeeded.',
          'If asynchronous UI work follows a start call, check mounted and a request generation after awaiting. Increment the generation on a new request or stop. For workflows that require arrival, also verify the current target and position or use the appropriate driver completion callback.',
        ],
        note: 'An animation completing is presentation feedback. Application success must come from application state.',
      ),
      DocSection(
        id: 'spring-mistakes',
        heading: 'Ownership and lifecycle',
        paragraphs: [
          'The minimal declarative example needs no controller: NibMotion owns and disposes its internal drivers. For imperative control, create NibMotionController once in State, pass it to the widget, and dispose it with that State. Recreating a controller in build loses the existing attachment.',
          'controller.stop freezes attached properties at their current values. Retained velocity can be reused by the next spring; set the same position without keepVelocity when you want a fresh start. If you create a SpringSolver and MotionValue yourself, stop and dispose the solver first, then dispose the value and any derived listeners you own.',
          'An offscreen ticker, a disposed widget and a paused preview have different lifecycle meanings. Test route departure and rapid repeated input. Do not assume that hiding a widget has disposed an external driver.',
        ],
        blocks: [
          DocLink(
            'Controller start, set, stop and sequence',
            '/docs/motion/controllers',
          ),
        ],
      ),
      DocSection(
        id: 'safety',
        heading: 'Accessibility',
        paragraphs: [
          'NibMotion respects the system reduced-motion setting and NibMotionConfig. With reduced motion enabled, its target is applied immediately. Keep labels, focus and the final selected state useful without travel or overshoot. The recipe’s buttons provide a keyboard and touch alternative to dragging.',
          'The documentation stays still while you read. Replay starts an intentional demonstration; Pause and Reduce motion are separate choices. Test the final state with motion disabled before relying on movement to communicate meaning.',
        ],
        blocks: [
          DocLink(
            'Reduced motion and accessible feedback',
            '/docs/motion/accessibility',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'keyframes',
    title: 'Keyframes',
    summary: 'Define the states of one motion sequence along normalized time.',
    evidence: 'MotionNib/motion/lib/src/core/nib_keyframe.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    sections: [
      DocSection(
        id: 'one-sequence',
        heading: 'Follow three tracks on one clock',
        paragraphs: [
          'Each tile in this example has a list of NibKeyframe values. A keyframe records one tile’s state at a normalized position: 0 is the start, 0.5 is halfway, and 1 is the end. The three NibMotion widgets start together and use the same 2.4 second duration, so their positions stay coordinated.',
          'Choose Scatter, Cross or Align to inspect the exact values at that stage. Amber moves across the top, teal crosses below it, and sage changes scale before the three form a row. The labels, colors and positions make each track easy to follow. The excerpt below is the amber track; Copy runnable example includes all three tracks and their controls.',
        ],
        code: "NibMotion(\n  keyframes: const [\n    NibKeyframe(at: 0, value: NibAnim(x: -72, y: -52, rotate: -0.16)),\n    NibKeyframe(at: 0.5, value: NibAnim(x: 72, y: -48, rotate: 0.12)),\n    NibKeyframe(at: 1, value: NibAnim(x: 62, y: 12, rotate: 0)),\n  ],\n  transition: const NibTransition(duration: Duration(milliseconds: 2400)),\n  child: const Icon(Icons.star),\n)",
        api: [
          DocApiEntry(
            name: 'at',
            type: 'double',
            defaultValue: 'required',
            description: 'Normalized progress position from 0.0 to 1.0.',
          ),
          DocApiEntry(
            name: 'value',
            type: 'NibAnim',
            defaultValue: 'required',
            description: 'This one child’s state at the progress position.',
          ),
          DocApiEntry(
            name: 'curve / spring',
            type: 'Curve? / NibSpringDescription?',
            defaultValue: 'null / null',
            description:
                'Shape the incoming segment; they are mutually exclusive.',
          ),
        ],
      ),
      DocSection(
        id: 'place-a-track',
        heading: 'Put one list on each moving child',
        paragraphs: [
          'A NibKeyframe list belongs to one NibMotion child. The amber excerpt puts that tile at x: -72, y: -52 at progress zero; sends it across the top to x: 72, y: -48 at halfway; and settles it near x: 62, y: 12 at one. Its rotate values are turns, so -0.16 and 0.12 tilt it in opposite directions before zero restores an upright endpoint.',
          'The live scene contains three such lists and three controllers. Sharing a duration makes them cross together; it does not mean there is one keyframe list for all three tiles. Copy runnable example shows the whole State, including the controllers and disposal. If you only need one child, the excerpt is sufficient inside your own build method.',
        ],
      ),
      DocSection(
        id: 'segments',
        heading: 'Shape each segment',
        paragraphs: [
          'The engine finds the two points around the current progress, normalizes progress inside that segment, then interpolates NibAnim properties. The curve on the upcoming keyframe shapes the segment arriving there; otherwise it uses the transition curve. A spring description on that upcoming keyframe can instead be sampled as a curve over the segment. A keyframe cannot set both curve and spring.',
          'The overall sequence still uses NibTransition.duration. Supplying NibTransition.spring for the whole sequence does not turn the controller into a spring; its curve and duration path drives playback. This distinction matters when copying an older reference that says spring keyframes are unsupported.',
        ],
      ),
      DocSection(
        id: 'time-and-easing',
        heading: 'Change time without changing the route',
        paragraphs: [
          'The default preview duration is 2.4 seconds. Move the duration slider toward 1.2 seconds and replay: Scatter, Cross, and Align still occur at progress 0, 0.5, and 1, but the interval between them shrinks. At 4.8 seconds those same states take longer. An at value is a fraction of the sequence, not a timestamp in milliseconds.',
          'Between two neighboring keyframes, the implementation normalizes progress for that segment and interpolates NibAnim values. The next keyframe’s curve changes how its incoming segment eases. A spring on that keyframe is sampled as a segment curve; it can overshoot that keyframe before the segment ends. Curve and spring on the same keyframe are mutually exclusive. The overall controller remains timed by NibTransition.duration, even if an individual segment samples a spring response.',
        ],
      ),
      DocSection(
        id: 'replay',
        heading: 'Replay and reduced motion',
        paragraphs: [
          'Replay calls start(keyframes: ..., transition: ...) on each NibMotionController. Selecting a stage first calls stop(), then set() with that stage’s state, so inspecting positions does not remount the tiles. Changing duration replays all three tracks using the new timing. Each controller is disposed with its State.',
          'Reduced motion shows Align immediately and disables the travel controls. Each tile keeps its identity and label at the endpoint. Your app can also replay an entrance by changing its key, but that deliberately recreates the element and its local state.',
        ],
      ),
      DocSection(
        id: 'keyframe-checks',
        heading: 'Inspect stages before trusting playback',
        paragraphs: [
          'Use the stage buttons to pause at Scatter, Cross, and Align. Check that every tile ends in a useful position and that labels remain distinct. Then replay and watch whether the crossings obscure a required control. A transform can move painted content without changing its original layout slot, so the scene reserves enough room for travel.',
          'If a child seems to jump, check that the list describes the same property at the important stages and that its key is stable. If it seems to ignore a spring transition, remember the whole keyframe path uses a timed controller; put spring on an incoming NibKeyframe segment when you want that sampled feel. Next learn Timeline when several independent children need offset start times rather than merely shared progress.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'motion-values',
    title: 'Motion values',
    summary: 'Connect changing data directly to paint properties.',
    evidence: 'MotionNib/motion/lib/src/values/motion_value.dart; MotionNib/motion/lib/src/values/derived_motion_value.dart; MotionNib/motion/lib/src/core/nib_motion_values.dart',
    relatedRecipeId: 'linked-objects',
    sections: [
      DocSection(
        id: 'put-values-in-state',
        heading: 'Create values once in State',
        paragraphs: [
          'Put the progress MotionValue in a State field, not inside build. Build can run for unrelated reasons; creating a new value there would discard the current position and leave old listeners behind. Create the two derived values from that source in fields or initState. The live example starts progress at 0.5, so x begins halfway between -62 and 62 and opacity halfway along 0.3 to 1.',
          'In build, pass those derived objects to NibMotionValues(translateX: x, opacity: opacity). The render layer listens to the values. A Slider can use a ValueListenableBuilder to display the current thumb value; its onChanged writes progress.value. That ValueListenableBuilder rebuilds the slider for its label, while the animated child’s paint path does not need a new child build on every progress update.',
        ],
      ),
      DocSection(
        id: 'source',
        heading: 'Create one source value',
        paragraphs: [
          'MotionValue<T> is a ValueListenable and ChangeNotifier. Setting value notifies listeners synchronously when the value changes; assigning the same value sends no notification. A plain assignment resets recorded velocity to zero. The live slider owns one MotionValue<double> and sets it from user input.',
          'Use transform for a general mapping or mapRange for piecewise linear numeric mapping. mapRange needs at least two stops and clamps outside the input range by default. Its result is another MotionValue that updates when the source changes.',
        ],
        code: "final progress = MotionValue<double>(0.5);\nfinal x = progress.mapRange([0, 1], [-62, 62]);\nfinal opacity = progress.mapRange([0, 1], [0.3, 1]);",
        api: [
          DocApiEntry(
            name: 'value',
            type: 'T',
            defaultValue: 'constructor initial',
            description: 'Notifies listeners synchronously when it changes.',
          ),
          DocApiEntry(
            name: 'transform',
            type: 'DerivedMotionValue<S, T>',
            defaultValue: 'none',
            description: 'Map source changes with a function.',
          ),
          DocApiEntry(
            name: 'mapRange',
            type: 'DerivedMotionValue<double, double>',
            defaultValue: 'clamp: true',
            description: 'Piecewise linear mapping with at least two stops.',
          ),
        ],
      ),
      DocSection(
        id: 'connect',
        heading: 'Feed the render object',
        paragraphs: [
          'NibMotionValues accepts external values such as translateX, opacity, rotate, color, and borderRadius. For a property you supply, NibMotion reads your value instead of driving its internal spring or tween for that property. The child does not need a build on each value tick.',
          'The source and both derived values belong to the creating State. NibMotion listens to them but never disposes them; dispose the derived listeners and then the source when that State leaves.',
        ],
        code: "NibMotion(\n  motionValues: NibMotionValues(translateX: x, opacity: opacity),\n  child: const FlutterLogo(),\n)",
      ),
      DocSection(
        id: 'follow-one-change',
        heading: 'Trace one slider movement',
        paragraphs: [
          'Drag the live slider toward its right edge. It writes a value near one to progress. mapRange converts that to an x offset near 62 logical pixels and opacity near one. Drag toward zero and the tile moves left while fading toward 0.3. Both outputs are derived from the same source, so they stay synchronized without two independent setState fields.',
          'mapRange accepts matching input and output stop lists with at least two finite positions; input stops must increase strictly. It linearly interpolates between neighboring stops and clamps outside the input range by default. Use transform when the relationship is not a piecewise numeric range. A simple boolean target is usually clearer with animate.',
        ],
      ),
      DocSection(
        id: 'measure',
        heading: 'Check the full frame',
        paragraphs: [
          'The paint path avoids rebuilding the child for each MotionValue change. It does not make a heavy shader, clip, or large composited scene free. Profile build and raster time separately in the target app before claiming a frame budget.',
        ],
      ),
      DocSection(
        id: 'release-values',
        heading: 'Dispose the values you created',
        paragraphs: [
          'A derived MotionValue subscribes to its source. Dispose both derived values before disposing progress in State.dispose, then call super.dispose. NibMotion owns its internal values, but it does not dispose the external objects supplied through NibMotionValues. The same ownership rule applies if scroll or gesture code holds an external value.',
          'If the slider still appears to drive a removed screen, a value or listener probably outlived its State. Check subscriptions and route disposal. If the tile does not move, verify you passed translateX rather than a new unused value, and that your source assignment differs from its previous value. A repeated assignment of the same value intentionally sends no listener notification.',
        ],
      ),
      DocSection(
        id: 'what-to-learn-next',
        heading: 'Use the value where it helps',
        paragraphs: [
          'Try making opacity constant while leaving translateX linked. Then map three input stops, such as 0, 0.5, and 1, to make the middle position distinct. Keep the source in zero-to-one units and x in logical pixels so the mapping is easy to inspect. Scroll motion shows another producer of MotionValues; Performance explains how to measure the whole rendered frame instead of inferring speed from this small example.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'presence',
    title: 'Presence',
    summary: 'Keep a removed keyed child until its exit completes.',
    evidence: 'MotionNib/motion/lib/src/presence/nib_presence.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    relatedRecipeId: 'presence-reflow',
    sections: [
      DocSection(
        id: 'own-the-list',
        heading: 'Let application state own membership',
        paragraphs: [
          'NibPresence does not decide which items exist. Keep the collection in the parent StatefulWidget, call setState when an item is added or removed, and build NibPresence.children from the current collection. In the live example, the list begins with integers 1, 2, and 3. Add appends a new integer; Remove deletes the last one from the source list. The presence wrapper compares old and new keys to find what left.',
          'The code excerpt assumes items is that State collection and ItemTile is your normal Flutter widget. ValueKey(item.id) must represent the same logical item on every rebuild. Do not use the current list index as the key when items can be inserted or reordered; the index describes a slot, not an item identity.',
        ],
      ),
      DocSection(
        id: 'identity',
        heading: 'Give each child a stable key',
        paragraphs: [
          'NibPresence compares child keys from one build to the next. Every direct child needs a unique non-null key. A keyed NibMotion child needs an exit NibAnim to animate before removal; without exit, it leaves immediately.',
        ],
        code: "NibPresence(\n  children: [\n    for (final item in items)\n      NibMotion(\n        key: ValueKey(item.id),\n        exit: const NibAnim(opacity: 0, x: -40),\n        child: ItemTile(item: item),\n      ),\n  ],\n)",
        api: [
          DocApiEntry(
            name: 'children',
            type: 'List<Widget>',
            defaultValue: 'required',
            description: 'Direct children with unique non-null keys.',
          ),
          DocApiEntry(
            name: 'exitLayout',
            type: 'NibExitLayout',
            defaultValue: 'sync',
            description:
                'Keep the slot until exit; pop reflows siblings immediately.',
          ),
          DocApiEntry(
            name: 'onChildExit',
            type: 'ValueChanged<Key>?',
            defaultValue: 'null',
            description: 'Called after a departing child leaves the tree.',
          ),
        ],
      ),
      DocSection(
        id: 'exit-state',
        heading: 'Define a visible exit',
        paragraphs: [
          'An exit NibAnim is the destination after removal. The live tile uses opacity zero and y: -20, so it moves upward and fades while leaving. Its initial state, opacity zero and y: 20, is an entrance for a newly added item. Its animate state is NibAnim.identity, the resting appearance between those two paths.',
          'Because the exiting widget stays mounted for the transition, painting can continue after the source list no longer contains it. NibPresence blocks pointer events, focus, and semantics on that departing element. This prevents a stale button from receiving another action during its fade. Use onChildExit if the host needs a callback after actual removal; it is distinct from the moment your collection changes.',
        ],
      ),
      DocSection(
        id: 'during-exit',
        heading: 'What happens while it leaves',
        paragraphs: [
          'The exiting element remains mounted until its exit Future finishes. NibPresence wraps it in IgnorePointer, ExcludeFocus, and ExcludeSemantics during that period. Its onChildExit callback runs after removal. Add and remove a tile in the live example to inspect this lifecycle.',
          'Re-adding the same key during exit cancels the pending removal and restores the animator toward its resting state. Use keys for persistent item identity, not a changing list index.',
        ],
      ),
      DocSection(
        id: 'reflow',
        heading: 'Choose the layout behavior',
        paragraphs: [
          'NibExitLayout.sync keeps an exiting child’s layout slot until it leaves. NibExitLayout.pop lets siblings reflow immediately and paints the leaver at captured bounds. The pop path has geometry limits with transformed and clipped ancestors; test it in the actual layout before a critical interaction.',
        ],
      ),
      DocSection(
        id: 'try-presence',
        heading: 'Test the lifecycle, not just the fade',
        paragraphs: [
          'Press Add, wait until tile 4 settles, then press Remove. Watch where the fourth tile goes and whether the row keeps its gap until it leaves. The default sync exit keeps that slot. Press Add and Remove quickly next: the component should still identify items by their keys rather than by whichever slot is last at that instant.',
          'For a list that should close its gap immediately, use NibExitLayout.pop or the NibPresence.layout factory, which combines pop with layout motion for the remaining children. That path uses captured geometry and has limits under complex transforms or clipping. Check hit testing and focus after an exit, especially when an overlay is involved.',
        ],
      ),
      DocSection(
        id: 'presence-mistakes',
        heading: 'Why an item may disappear or jump',
        paragraphs: [
          'No exit target means immediate removal. A missing or duplicate direct-child key causes a Flutter error. A changing key makes the same logical item look new on every build. If siblings jump instead of moving, remember that presence by itself controls lifetime; layout motion is a separate feature.',
          'If a removed child remains visible longer than expected, a spring may still be waiting to meet its completion tolerance. Do not force a short timer that removes it before its own exit finishes. Continue to Layout and presence together when the gap and sibling movement must be choreographed.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'gestures',
    title: 'Gestures',
    summary: 'Respond to press, hover, focus, and direct manipulation.',
    evidence: 'MotionNib/motion/lib/src/core/nib_motion_widget.dart; MotionNib/motion/lib/src/gestures/drag_handler.dart; MotionNib/motion/lib/src/gestures/nib_draggable.dart',
    relatedRecipeId: 'bounded-drag',
    sections: [
      DocSection(
        id: 'choose-a-gesture',
        heading: 'Start with a temporary state',
        paragraphs: [
          'Use whileTap for a pressed response, whileHover for pointer presence, and whileFocus for keyboard focus. Each is a NibAnim target overlaid while that interaction is active. A focus treatment needs to remain visible on a control that keyboard users can actually reach; adding whileFocus to an unfocusable decoration will not create a keyboard action.',
          'In the live example, the tile shrinks to scale 0.9 while pressed and grows to 1.08 on hover or drag. The ordinary animate.x target comes from the Move right button. That target is independent of the temporary scale response, so the tile can move toward a new destination while its interaction feedback changes.',
        ],
      ),
      DocSection(
        id: 'states',
        heading: 'Use the right temporary state',
        paragraphs: [
          'NibMotion accepts whileTap, whileHover, whileFocus, and whileDrag as NibAnim overrides. When states overlap, drag has priority over tap, then hover, then focus. When the interaction ends, reverseTransition can use a different response for the trip home.',
          'Hover is a pointer affordance; it is not the only way to expose an action. The live example pairs horizontal dragging with a Move right button so keyboard and touch users can reach the same endpoint.',
        ],
        code: "NibMotion(\n  whileTap: const NibAnim(scale: 0.9),\n  whileHover: const NibAnim(scale: 1.08),\n  whileDrag: const NibAnim(scale: 1.08),\n  drag: const NibDragConfig(axis: Axis.horizontal),\n  child: const Icon(Icons.drag_indicator),\n)",
        api: [
          DocApiEntry(
            name: 'axis',
            type: 'Axis?',
            defaultValue: 'null',
            description: 'Null allows free drag; otherwise lock one axis.',
          ),
          DocApiEntry(
            name: 'constraints',
            type: 'Rect?',
            defaultValue: 'null',
            description: 'Offset bounds relative to the resting position.',
          ),
          DocApiEntry(
            name: 'releaseMode',
            type: 'NibDragReleaseMode',
            defaultValue: 'springBack',
            description: 'Spring back, coast with inertia, or stay at release.',
          ),
        ],
      ),
      DocSection(
        id: 'bound-the-drag',
        heading: 'Add direct manipulation deliberately',
        paragraphs: [
          'Passing NibDragConfig to NibMotion.drag enables dragging. axis: Axis.horizontal ignores vertical movement. The live configuration uses Rect.fromLTRB(-70, 0, 70, 0): those left and right numbers are offsets from the resting position in the receiving widget’s local logical pixels, not screen coordinates. springBack sends the dragged offset home when the pointer releases.',
          'With elastic true, movement beyond constraints gets resistance rather than a hard clamp; elasticFactor defaults to 0.2. snapPoints, when supplied, take precedence over releaseMode and pick a destination offset. onDragEnd receives a Velocity in receiver-local logical pixels per second in 0.3.5. Keep it in the same coordinate system if you use it to seed another motion.',
        ],
        code: "drag: const NibDragConfig(\n  axis: Axis.horizontal,\n  constraints: Rect.fromLTRB(-70, 0, 70, 0),\n  releaseMode: NibDragReleaseMode.springBack,\n)",
      ),
      DocSection(
        id: 'drag',
        heading: 'Bound a drag in local units',
        paragraphs: [
          'NibDragConfig sets axis, optional Rect constraints, elasticity, and a release mode. springBack is the default release mode; inertia coasts and stay keeps the released offset. snapPoints are receiver-local offsets. In 0.3.5, release velocity is reported in receiver-local logical pixels per second so position and velocity use the same coordinate space.',
          'NibDraggable is a separate wrapper for a drag without NibMotion’s state API. NibPinch handles scaling and NibSwipeDismiss handles threshold-based removal. Choose one gesture owner for the same pointer stream.',
        ],
      ),
      DocSection(
        id: 'limits',
        heading: 'Verify the full interaction',
        paragraphs: [
          'Test hit targets while moving and after release, especially under nonuniform scaling or nested transforms. Perspective and near-singular transforms are not in the current verified drag contract. Confirm focus and semantics still expose an equivalent action.',
        ],
      ),
      DocSection(
        id: 'try-gesture',
        heading: 'Compare drag and button input',
        paragraphs: [
          'Drag the tile to either edge and let go. It should follow your horizontal movement within its bounds and then spring back. Hover or press it and watch scale change. Now use Move right: the same screen reaches another target without requiring a drag. Navigate to the button with a keyboard and confirm it works there too.',
          'In an app, put a meaningful action behind the control, not behind the animation alone. If releasing the drag commits a choice, provide a visible control that commits the same choice and a label that explains the outcome. A gesture effect without an accessible action is only decoration.',
        ],
      ),
      DocSection(
        id: 'gesture-errors',
        heading: 'Debug the space and the gesture owner',
        paragraphs: [
          'If a drag seems offset from the finger, inspect transformed ancestors and the configured local bounds. If a scroll view and tile both want the same pan gesture, choose which element should own it; do not layer two competing drag handlers over the same target. NibDraggable is a separate wrapper for direct dragging, while NibPinch and NibSwipeDismiss solve different gestures.',
          'Check the painted position, hit target, focus, and semantics during movement. A test that merely completes without throwing does not establish that the user can still reach the tile. For complex geometry, read the platform limits before relying on a transformed drag in a critical flow.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'scroll-motion',
    title: 'Scroll motion',
    summary: 'Reveal content on entry or map scroll position to paint values.',
    evidence: 'MotionNib/motion/lib/src/scroll/nib_scroll_reveal.dart; MotionNib/motion/lib/src/scroll/nib_scroll_motion.dart; MotionNib/motion/lib/src/scroll/scroll_motion_bridge.dart',
    relatedRecipeId: 'viewport-reveal',
    sections: [
      DocSection(
        id: 'which-tool',
        heading: 'Choose entry or continuous progress',
        paragraphs: [
          'Use NibScrollReveal when a child should react once it becomes visible. Its initial and animate values describe two states; amount is the visible fraction needed to trigger, and once controls whether leaving the viewport restores the hidden state. This is a good fit for a card entering a list.',
          'Use NibScrollMotion or ScrollMotionBridge when position itself should drive a value continuously, such as a header fading over the first 200 logical pixels of scroll. A reveal checks a visibility threshold; a bridge tracks offset. NibParallax is a convenience for a factor-based offset, where zero pins the layer and one follows the scroll movement one-to-one.',
        ],
      ),
      DocSection(
        id: 'reveal',
        heading: 'Trigger on viewport entry',
        paragraphs: [
          'NibScrollReveal wraps a child in viewport-driven NibMotion. Its default initial state fades from opacity zero and y: 32; animate defaults to identity. once defaults to true and amount defaults to 0.2, meaning roughly one fifth of the widget must be visible before activation.',
          'Scroll inside the framed window in the live example. The final card uses once: false, so it can reveal again after leaving and re-entering that viewport. Use a one-time reveal for content that should stay visible after first exposure.',
        ],
        code: "NibScrollReveal(\n  once: false,\n  amount: 0.2,\n  child: const Text('In view'),\n)",
        api: [
          DocApiEntry(
            name: 'initial',
            type: 'NibAnim',
            defaultValue: 'opacity: 0, y: 32',
            description: 'State before the child enters the viewport.',
          ),
          DocApiEntry(
            name: 'once',
            type: 'bool',
            defaultValue: 'true',
            description: 'Keep the revealed state after the first entry.',
          ),
          DocApiEntry(
            name: 'amount',
            type: 'double',
            defaultValue: '0.2',
            description: 'Fraction of the child that must be visible.',
          ),
        ],
      ),
      DocSection(
        id: 'viewport',
        heading: 'Use the actual viewport',
        paragraphs: [
          'A nested scrolling panel has its own viewport. Test entry and exit by scrolling that panel, not only the page around it. Avoid hiding essential text until a scroll gesture occurs; reduced motion should still reveal the final content.',
        ],
      ),
      DocSection(
        id: 'try-the-viewport',
        heading: 'Scroll the framed panel',
        paragraphs: [
          'The live example contains a 160-pixel-high ListView inside the documentation page. Drag inside that framed list. The last card starts outside its viewport and reveals when it enters. Drag back out and in again: because the example sets once: false, it returns to its initial state on exit and can replay. Change once to true in a copied example to keep the card visible after its first reveal.',
          'Scroll the outer page without touching the inner list. Its last card remains below the inner viewport, so the outer scroll alone cannot reveal it. Visibility is checked against both the screen and enclosing scroll viewports. Testing only the page scroll can therefore miss a nested-view problem. Keep required content accessible even if the reveal never fires.',
        ],
      ),
      DocSection(
        id: 'link',
        heading: 'Map an existing ScrollController',
        paragraphs: [
          'NibScrollMotion takes a ScrollController and gives its builder a ScrollMotionBridge. The bridge exposes scrollX and scrollY MotionValues. Map a range of scrollY into opacity or position, then pass the derived value through NibMotionValues.',
          'NibScrollMotion owns its bridge, but the application still owns the ScrollController. If you construct ScrollMotionBridge directly, dispose it yourself. NibParallax offers a simpler factor-based offset: zero pins the child and one follows scrolling one-to-one.',
        ],
      ),
      DocSection(
        id: 'drive-from-offset',
        heading: 'Own the scroll controller and derived value',
        paragraphs: [
          'For a continuously fading header, create a ScrollController in your State and attach it to the actual ListView. Create a ScrollMotionBridge from that controller, then derive opacity from bridge.scrollY with mapRange([0, 200], [1, 0]). Pass that derived value through NibMotionValues(opacity: ...). These numbers mean fully visible at offset zero and transparent at 200 logical pixels.',
          'NibScrollMotion can create and dispose the bridge for its builder, but a mapRange value you create from the bridge is still your derived value to manage. If you own the bridge directly, dispose the derived value first, then the bridge, then the ScrollController. Creating a new derived value on every build can leave listeners behind.',
        ],
        code: "final controller = ScrollController();\nlate final bridge = ScrollMotionBridge(controller: controller);\nlate final opacity = bridge.scrollY.mapRange([0, 200], [1, 0]);\n\n// In build, attach controller to the scroll view and pass opacity to:\nNibMotion(motionValues: NibMotionValues(opacity: opacity), child: header)\n\n// In dispose: opacity.dispose(); bridge.dispose(); controller.dispose();",
      ),
      DocSection(
        id: 'scroll-errors',
        heading: 'Check the right controller and lifetime',
        paragraphs: [
          'If nothing changes, check that the same ScrollController is attached to the scrolling widget and the bridge. If the motion jumps, inspect the mapRange stops and whether clamping is appropriate. If a removed screen still has scroll listeners, inspect the disposal order and any derived values created inside builder callbacks.',
          'The value path avoids rebuilding the animated child for each scroll tick, but it does not make a large page free to rasterize. The next lesson on Motion values explains derived values in isolation; Accessibility covers the endpoint when motion is reduced.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'accessibility',
    title: 'Accessibility',
    summary:
        'Keep the state change clear when motion is reduced or input differs.',
    evidence: 'MotionNib/motion/lib/src/core/reduced_motion.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart; MotionNib/motion/lib/src/presence/nib_presence.dart',
    sections: [
      DocSection(
        id: 'design-the-endpoint',
        heading: 'Design the outcome before the travel',
        paragraphs: [
          'Decide what the UI means when the motion finishes. A completed task should have a label, icon, or state that remains visible without watching the animation. In the live example, Complete changes the tile to a checkmark and turns the button into Reset. The horizontal travel adds expression; the checkmark and button label carry the outcome.',
          'If a gesture moves an object to indicate acceptance, provide another path to accept it and a persistent result. A hover-only clue will not reach touch or keyboard users. Motion should reinforce a state change, not be the sole record that it happened.',
        ],
      ),
      DocSection(
        id: 'reduced',
        heading: 'Apply the endpoint immediately',
        paragraphs: [
          'NibMotionConfig resolves reduced motion from an explicit test override, then its inherited reducedMotion value, then MediaQuery.disableAnimations. When reduction is active, NibMotion sets the target immediately instead of running intermediate frames. The result must still be legible without seeing the path.',
          'The live example shows a checkmark and Reset action after Complete. Toggle its local switch and repeat; an active system preference keeps reduction on. NibMotionProvider can set an application default transition and whether to respect reduced motion.',
        ],
      ),
      DocSection(
        id: 'configure-policy',
        heading: 'Read the motion preference correctly',
        paragraphs: [
          'NibMotionConfig checks an explicit global override first, an inherited reducedMotion value second, and MediaQuery.disableAnimations last. The global override is intended for tests. A host can wrap a subtree in NibMotionConfig(reducedMotion: true, child: ...) when it has a policy, or allow the system setting to flow through when reducedMotion is null.',
          'The live switch uses the system preference as a floor: if the system requests reduced motion, its local toggle cannot turn travel back on. When reduction is true, NibMotion sets the target immediately. This does not remove the semantic result or disable the action.',
        ],
        code: "NibMotionConfig(\n  reducedMotion: MediaQuery.disableAnimationsOf(context),\n  child: NibMotion(\n    animate: NibAnim(x: complete ? 46 : -46),\n    child: const Icon(Icons.check),\n  ),\n)",
      ),
      DocSection(
        id: 'input',
        heading: 'Keep an equivalent action',
        paragraphs: [
          'A drag-only card has no obvious keyboard path. Pair the gesture with a button or another focusable control that reaches the same state. Hover feedback should add clarity without carrying essential information.',
          'During a NibPresence exit, the departing child is excluded from focus and semantics. Test where focus moves after removal and whether a screen reader announces the new state in the host screen.',
        ],
      ),
      DocSection(
        id: 'timing',
        heading: 'Do not gate the task on animation',
        paragraphs: [
          'Startup warm-up can delay an entrance briefly and NibMotionGate can hold it until a splash screen is removed. These affect the visual path; the task should remain understandable at the final state. Physical screen-reader checks still belong to release validation.',
        ],
      ),
      DocSection(
        id: 'test-the-task',
        heading: 'Test the whole path with and without travel',
        paragraphs: [
          'First use Complete and Reset with motion enabled. Confirm the button remains operable while the tile moves. Then turn on reduced motion and repeat. The tile should reach each endpoint immediately and the labels should still explain what happened. Move keyboard focus through the controls and check that the visible focus indicator is not lost under a transform.',
          'During a presence exit, the departing child is excluded from pointer, focus, and semantics. That avoids a stale action, but the host still has to decide where focus goes next and how a screen reader hears the updated collection. A widget test can inspect semantics; a physical screen-reader run remains a separate release check.',
        ],
      ),
      DocSection(
        id: 'access-mistakes',
        heading: 'Avoid timing as a requirement',
        paragraphs: [
          'Do not require a user to wait for an entrance before they can understand a page. The default entrance warm-up lasts up to 400 ms near app start, and a NibMotionGate may hold entrances under a preserved splash screen. The destination and action must make sense if travel is skipped entirely.',
          'If an animation appears still in testing, check the reduced-motion preference before changing durations. If it appears to run under a system preference, inspect whether an ancestor NibMotionConfig set reducedMotion to false. Continue to Gestures for equivalent input paths and Presence for focus behavior while items leave.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'transitions',
    title: 'Transitions',
    summary: 'Choose a timed tween or a spring, then set the return behavior.',
    evidence: 'MotionNib/motion/lib/src/core/nib_transition.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    sections: [
      DocSection(
        id: 'compare-two-paths',
        heading: 'Compare the same target side by side',
        paragraphs: [
          'The live preview changes two tiles between the same left and right x offsets. The first uses NibTransition.springSnappy. The second uses a 450 ms easeInOutCubic tween. Tap Move right, then tap Move left before either tile finishes. Both receive the same new destination, but one is physically retargeted while the other follows a fixed-duration easing curve.',
          'A timed transition promises a duration for each trip; it does not promise that repeated taps will feel like continuous velocity. A spring has no fixed finish time, but it can preserve velocity at a new target. Choose based on the interaction, not on which tile is visually busier.',
        ],
      ),
      DocSection(
        id: 'place-a-transition',
        heading: 'Set timing on the NibMotion that owns the target',
        paragraphs: [
          'In a StatefulWidget, keep a boolean target in State and pass NibAnim(x: right ? 22 : -22) to NibMotion.animate. Pass a NibTransition to that same widget. Change the boolean from a button with setState; the button does not need to start an AnimationController. Use another NibMotion with the same target and a different transition when comparing behavior, as the preview does.',
          'duration is a Duration, such as 450 milliseconds. curve is a Flutter Curve. delay is another Duration and applies before either tween or spring starts. A spring description selects the spring path even if duration and curve are also present in the object; do not treat those fields as spring limits.',
        ],
      ),
      DocSection(
        id: 'timed',
        heading: 'Use fixed time when timing matters',
        paragraphs: [
          'NibTransition without a spring is a tween: duration defaults to 300 ms, curve to easeInOut, and delay to zero. Choose an explicit duration for a deliberately timed entrance or a sequence with a known beat. Negative durations and delays are invalid; animation entry points validate them in debug builds and clamp them in release builds.',
        ],
        code: "const NibTransition(\n  duration: Duration(milliseconds: 450),\n  curve: Curves.easeOutCubic,\n)",
        api: [
          DocApiEntry(
            name: 'duration',
            type: 'Duration',
            defaultValue: '300 ms',
            description: 'Total tween duration; ignored by a spring driver.',
          ),
          DocApiEntry(
            name: 'curve',
            type: 'Curve',
            defaultValue: 'easeInOut',
            description: 'Tween easing; ignored by a spring driver.',
          ),
          DocApiEntry(
            name: 'delay',
            type: 'Duration',
            defaultValue: 'zero',
            description: 'Wait before starting either transition type.',
          ),
          DocApiEntry(
            name: 'spring',
            type: 'NibSpringDescription?',
            defaultValue: 'null',
            description: 'Selects spring physics when supplied.',
          ),
        ],
      ),
      DocSection(
        id: 'spring',
        heading: 'Use spring physics for retargeting',
        paragraphs: [
          'A non-null spring changes the transition type to spring and makes duration and curve irrelevant to the physical driver. NibTransition.springGentle, springSnappy, and springWobbly are presets. NibTransition.springWith converts a perceptual duration and bounce into a spring description.',
          'delay still postpones the start. A controller Future may resolve after the motion looks settled because the simulation waits for numerical tolerance. Do not disable input until that Future ends unless the action truly depends on completion.',
        ],
      ),
      DocSection(
        id: 'return',
        heading: 'Control the way back',
        paragraphs: [
          'NibMotion.reverseTransition applies when a temporary tap, hover, focus, drag, or in-view state ends. exitTransition applies when NibPresence removes a child. A parent transition’s delayChildren and staggerChildren affect descendants that inherit a named variant; they do not create a global delay for every arbitrary child.',
        ],
      ),
      DocSection(
        id: 'return-and-exit',
        heading: 'Give temporary and exit states their own return',
        paragraphs: [
          'NibMotion.reverseTransition lets a press, hover, focus, drag, or in-view state return differently from how it entered. For example, a button can compress with a slower response and release quickly. NibMotion.exitTransition is used when an ancestor NibPresence removes the child. These are separate from the main animate transition.',
          'delayChildren and staggerChildren on a parent transition schedule descendants inheriting a named variant. They are not a general timer applied to all descendants. Use the Variants and stagger lesson when you need that propagation; use Timeline when independent controllers need their own start offsets.',
        ],
      ),
      DocSection(
        id: 'transition-errors',
        heading: 'When timing seems ignored',
        paragraphs: [
          'If changing duration does nothing, check whether spring is non-null. If a return feels wrong, check reverseTransition rather than only the main transition. If an exiting child ignores exit timing, verify it has an exit NibAnim, a stable key, and an ancestor NibPresence.',
          'Negative durations and delays are invalid inputs. A debug build reports them; release code clamps them to zero. Supply valid positive values rather than depending on that fallback. Test with reduced motion too: the endpoint should remain clear when neither timing path runs.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'variants-stagger',
    title: 'Variants and stagger',
    summary: 'Name related states and schedule children that inherit them.',
    evidence: 'MotionNib/motion/lib/src/variants/nib_variants.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart; MotionNib/motion/lib/src/list/nib_motion_list.dart',
    sections: [
      DocSection(
        id: 'parent-and-child',
        heading: 'Put names on both levels',
        paragraphs: [
          'Define a small named map for the parent, such as closed and open. Give the parent NibMotion an animate string chosen from that map. Inside it, each child NibMotion has its own variants map with the same names but may have different NibAnim values. Leave the child animate parameter null so it reads the propagated parent name.',
          'The live example has one parent state and three children. The parent changes opacity; each child changes opacity and x. Press Open list and watch the three rows arrive in order. Press Close list and observe the return. A child with an explicit animate target would ignore the inherited name and could remain visible when the parent closes.',
        ],
        code: "const childStates = <String, NibAnim>{\n  'closed': NibAnim(opacity: 0, x: -18),\n  'open': NibAnim(opacity: 1, x: 0),\n};\n\nNibMotion(\n  variants: parentStates,\n  animate: open ? 'open' : 'closed',\n  transition: const NibTransition(staggerChildren: Duration(milliseconds: 75)),\n  child: Column(children: [\n    for (final item in items)\n      NibMotion(key: ValueKey(item.id), variants: childStates, child: ItemTile(item)),\n  ]),\n)",
      ),
      DocSection(
        id: 'names',
        heading: 'Name each state once',
        paragraphs: [
          'NibVariants is a map from a string name to NibAnim. NibMotion.initial and animate can use a name instead of a literal NibAnim. A parent propagates its resolved variant name to descendant NibMotion widgets that have matching variants and no explicit animate value.',
          'Use an explicit animate value on a child when it should ignore the inherited name. Keep all names present in the relevant map; a missing name cannot describe a target.',
        ],
        code: "const states = <String, NibAnim>{\n  'closed': NibAnim(opacity: 0, y: 12),\n  'open': NibAnim(opacity: 1, y: 0),\n};\nNibMotion(\n  variants: states,\n  animate: expanded ? 'open' : 'closed',\n  child: content,\n)",
        api: [
          DocApiEntry(
            name: 'variants',
            type: 'Map<String, NibAnim>?',
            defaultValue: 'null',
            description: 'Named states available to this NibMotion.',
          ),
          DocApiEntry(
            name: 'animate',
            type: 'NibAnim or String?',
            defaultValue: 'null',
            description: 'Literal target, named target, or inherited variant.',
          ),
        ],
      ),
      DocSection(
        id: 'stagger',
        heading: 'Delay inherited children',
        paragraphs: [
          'A parent NibTransition can set delayChildren before the first descendant starts and staggerChildren per descendant index in build order. Those timings apply to children resolving animate from the propagated variant. NibMotionList offers a separate list API: staggerDelay defaults to 50 ms and can run forward or reverse.',
          'Use stable keys when items reorder. Without them, stagger can play on a newly mounted item instead of the existing visual item. NibMotionList presenceEnabled requires unique child keys because it uses NibPresence.',
        ],
        api: [
          DocApiEntry(
            name: 'delayChildren',
            type: 'Duration',
            defaultValue: 'zero',
            description:
                'Parent variant delay before the first inheriting child.',
          ),
          DocApiEntry(
            name: 'staggerChildren',
            type: 'Duration',
            defaultValue: 'zero',
            description: 'Extra delay per inheriting descendant index.',
          ),
          DocApiEntry(
            name: 'NibMotionList.staggerDelay',
            type: 'Duration',
            defaultValue: '50 ms',
            description: 'List wrapper delay between consecutive children.',
          ),
        ],
      ),
      DocSection(
        id: 'calculate-the-delay',
        heading: 'Understand what stagger changes',
        paragraphs: [
          'In the live example, delayChildren adds 30 ms before the first inheriting child. staggerChildren adds 75 ms per child index in build order. The rows therefore start at distinct times while each still uses its own transition to travel between named states. Stagger shifts start times; it does not change each child’s target or multiply the parent’s duration.',
          'Try removing staggerChildren in a copied example. The three rows should begin together. Restore it, then reverse the order of the child widgets while keeping their keys; the start order follows their new build order. If an item is re-created with a new key, it may also replay its entrance, which is a separate identity issue.',
        ],
      ),
      DocSection(
        id: 'motion',
        heading: 'Keep the list readable',
        paragraphs: [
          'Large stagger windows can delay information. Keep labels and hit targets usable while children enter, and verify the full list with reduced motion. The package jumps to final targets when reduction is active.',
        ],
      ),
      DocSection(
        id: 'pace-and-access',
        heading: 'Do not make content wait for decoration',
        paragraphs: [
          'Staggering a long list can postpone the last item by hundreds of milliseconds. Keep the task usable while entries arrive, and test the final state with reduced motion. A name change should still communicate open or closed through labels and accessibility state, not only through fading rows.',
          'Once this parent-child model is clear, Timeline is the next tool for independent elements that start at named offsets. It schedules controllers rather than relying on inherited variant names.',
        ],
      ),
      DocSection(
        id: 'variant-errors',
        heading: 'Check names and inheritance first',
        paragraphs: [
          'A child cannot resolve a propagated name missing from its variants map. Keep closed and open spelled the same in the parent and children. If a child never follows the parent, inspect whether its animate parameter is explicitly set. If it jumps or restarts during reorder, inspect its key.',
          'NibMotionList provides a shorter path for a plain list entrance with staggerDelay, which defaults to 50 ms. Set presenceEnabled only when each child has a unique key and exit behavior is needed. For a menu whose parent and children have related named states, the variant scope explains the relationship more clearly.',
        ],
      ),
    ],
  ),
];
