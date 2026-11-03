import 'site_content.dart';

const motionAdvancedGuides = <DocArticle>[
  DocArticle(
    packageId: 'motion',
    id: 'layout-animations',
    title: 'Layout animations',
    summary:
        'Animate a keyed child from its old measured place to its new one.',
    evidence: 'MotionNib/motion/doc/layout.md; MotionNib/motion/lib/src/layout/nib_layout.dart; MotionNib/motion/lib/src/layout/nib_layout_scope.dart',
    relatedRecipeId: 'keyed-reorder',
    sections: [
      DocSection(
        id: 'before-you-start',
        heading: 'Start with state and identity',
        paragraphs: [
          'Use layout motion when Flutter itself changes a child’s size or position: a row is reordered, a filter removes a card, or a details panel expands. Keep the data change in ordinary widget state. Layout motion observes the before and after rectangles; it does not decide where a widget belongs. A translation inside animate changes paint position, not the parent’s layout, so that is a different job.',
          'Each moving item needs a stable key based on its data identity, such as ValueKey(item.id). An index key follows the slot when the order changes, which can make the animation follow the wrong item. Keep the NibLayoutScope above both the old and new placements when using a shared layoutId. For simple reflow a scope is useful because it defines the measurement space, although a box layout can work without one.',
        ],
      ),
      DocSection(
        id: 'flip',
        heading: 'Measure, invert, play',
        paragraphs: [
          'NibMotion(layout:) uses FLIP: it measures before and after a layout change, paints from the old visual bounds, and animates the difference away. NibLayout.position changes position; NibLayout.size changes size; NibLayout.both handles both. Use stable keys so a reordered child remains the same element.',
          'In the live example, Move first to end updates the Row’s order. NibLayoutScope supplies the measurement space; each keyed tile uses layout: NibLayout.position. New children need an entrance animation if they should move in, because there is no previous layout to invert.',
        ],
        code: "// In build(); items comes from State.\nNibLayoutScope(\n  child: Row(\n    children: [\n      for (final item in items)\n        NibMotion(\n          key: ValueKey(item.id),\n          layout: NibLayout.position,\n          layoutTransition: NibTransition.springGentle,\n          child: ItemTile(item: item),\n        ),\n    ],\n  ),\n)",
        api: [
          DocApiEntry(
            name: 'layout',
            type: 'NibLayout',
            defaultValue: 'inherit',
            description:
                'Position, size, both, none, or a scope-provided default.',
          ),
          DocApiEntry(
            name: 'layoutSizeMode',
            type: 'NibLayoutSizeMode',
            defaultValue: 'scale',
            description:
                'Scale size changes; clip reveals final-layout content.',
          ),
          DocApiEntry(
            name: 'layoutId',
            type: 'Object?',
            defaultValue: 'null',
            description:
                'Shared identity for detached-to-mounted handoff in one scope.',
          ),
        ],
      ),
      DocSection(
        id: 'walkthrough',
        heading: 'Build and inspect a reorder',
        paragraphs: [
          'In the example above, changing items causes Row to calculate new offsets. The keyed NibMotion for each surviving item remains mounted, measures the new offset, and initially paints at its old visual position. layoutTransition then returns the painted offset to zero. The spring controls how this return feels; it does not change Row’s final order. NibLayout.position leaves the child’s measured size alone. Choose both only if the item’s own dimensions also change.',
          'Open the keyed-reorder demo and move one item to the end. Then change the key to the loop index in a local copy: notice that Flutter now treats the old slot as the continuing element. Restore the data key. Next try layoutSizeMode: NibLayoutSizeMode.clip on a card that expands. Its new content is laid out at final size and revealed by a clip rather than stretched. On shrink, old pixels cannot be retained because the new child has already laid out smaller.',
        ],
        api: [
          DocApiEntry(
            name: 'layoutTransition',
            type: 'NibTransition?',
            defaultValue: 'springGentle',
            description: 'Spring or tween for returning measured layout channels to identity; delay holds the old visual bounds.',
          ),
          DocApiEntry(
            name: 'onLayoutAnimationStart',
            type: 'VoidCallback?',
            defaultValue: 'null',
            description:
                'Called when this child begins a measured layout animation.',
          ),
          DocApiEntry(
            name: 'onLayoutAnimationComplete',
            type: 'VoidCallback?',
            defaultValue: 'null',
            description: 'Called on completion, not for a run superseded by a newer layout change.',
          ),
        ],
      ),
      DocSection(
        id: 'size',
        heading: 'Choose how size changes look',
        paragraphs: [
          'The default size mode scales the child during a size transition. NibLayoutSizeMode.clip reveals content at its final layout size through an animated clip. This can keep text from stretching, but clipping is visible by design.',
          'layoutId links a recently detached source to a newly mounted destination inside the same scope. It is a handoff through retained snapshot geometry, not a transition between two widgets that remain live at once.',
        ],
      ),
      DocSection(
        id: 'interruptions',
        heading: 'Handle retargeting and removal',
        paragraphs: [
          'If state changes again while a FLIP is playing, the widget retargets from its current painted position and velocity. Do not wait for a previous onLayoutAnimationComplete before applying a legitimate new order: the superseded run does not report completion. If your host needs one callback for an entire list update, use the aggregate NibPresence or NibLayoutGroup callbacks and identify the batch in your own state.',
          'A new item has no old rectangle. Give it an initial and animate state if an entrance matters. A removed item needs NibPresence and an exit state if it should remain visible while leaving. A detached layoutId is retained only briefly, so build the destination during the same state change rather than across an asynchronous fetch. For a scrolling lazy list, only mounted items have old geometry; an item that leaves cache extent cannot animate back from its former offscreen placement.',
        ],
      ),
      DocSection(
        id: 'geometry',
        heading: 'Know the measured space',
        paragraphs: [
          'The 0.3.5 source has numeric regressions for selected affine transforms. Perspective and near-singular transforms, rotated reorder, and pop exits that need cross-space ancestor clipping remain outside its verified geometry contract. Test scrolling parents, hit targets, focus, and semantics in the actual screen.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'layout-presence',
    title: 'Layout and presence together',
    summary: 'Let siblings reflow while a removed item completes its exit.',
    evidence: 'MotionNib/motion/lib/src/presence/nib_presence.dart; MotionNib/motion/lib/src/layout/nib_layout_defaults.dart; MotionNib/motion/doc/layout.md',
    relatedRecipeId: 'presence-reflow',
    sections: [
      DocSection(
        id: 'composition',
        heading: 'Combine identity and measurement',
        paragraphs: [
          'Presence tracks whether a keyed child still belongs in the collection. Layout motion tracks the changed position of children that remain. NibPresence.layout composes both: it wraps children in a layout scope, defaults child layout to position, and defaults exitLayout to pop.',
          'The simpler NibPresence constructor defaults to a Stack when no layoutBuilder is supplied. Give it a Row, Column, or Wrap builder when the parent layout matters. Every direct child still needs a unique non-null key.',
        ],
      ),
      DocSection(
        id: 'working-example',
        heading: 'Remove a chip without closing the gap abruptly',
        paragraphs: [
          'Keep the chip IDs in State and build the children from that list. NibPresence.layout supplies a Wrap or Column, the layout scope, position motion for children that inherit it, and pop exits by default. The example gives each NibMotion a stable key and a visible exit target. Removing an ID changes the source list immediately; presence keeps that old keyed child alive only until its exit finishes. Its siblings take their final places at once and animate their movement.',
          'Start with sync if a departing row must still hold its slot while it fades. Choose pop when an immediate reflow is important, such as dismissing a tag from a dense group. For a custom grid or unusual parent, use NibPresence with layoutBuilder and explicitly choose exitLayout. Its default container is Stack, which will not reproduce a Row or Wrap layout.',
        ],
        code: "// In build(); tags comes from State.\nNibPresence.layout(\n  axis: NibPresenceAxis.wrap,\n  spacing: 8,\n  runSpacing: 8,\n  children: [\n    for (final tag in tags)\n      NibMotion(\n        key: ValueKey(tag.id),\n        exit: const NibAnim(opacity: 0, scale: 0.85),\n        child: Chip(label: Text(tag.label)),\n      ),\n  ],\n)",
        api: [
          DocApiEntry(
            name: 'axis',
            type: 'NibPresenceAxis',
            defaultValue: 'column',
            description: 'Choose Column, Row, or Wrap for the layout factory.',
          ),
          DocApiEntry(
            name: 'exitLayout',
            type: 'NibExitLayout',
            defaultValue: 'pop in layout factory; sync in base constructor',
            description:
                'Controls when the departing child releases its layout slot.',
          ),
          DocApiEntry(
            name: 'stagger',
            type: 'Duration',
            defaultValue: 'Duration.zero',
            description:
                'Delay between children in the same enter or exit batch.',
          ),
        ],
      ),
      DocSection(
        id: 'reflow',
        heading: 'Choose when the gap closes',
        paragraphs: [
          'With sync exits, the departing child keeps its slot until the exit ends. With pop exits, siblings close the gap immediately while the departing child is painted at captured bounds. An exiting child is excluded from pointer, focus, and semantics, so it cannot keep acting as a stale control.',
          'Use a visible exit state on each NibMotion that should linger. A child without exit is removed immediately. Add and remove repeatedly to check callback ordering and interruption in the host list.',
        ],
      ),
      DocSection(
        id: 'events',
        heading: 'Read callbacks as lifecycle events',
        paragraphs: [
          'onChildEnter reports additions after the first build; initial children are already present. onChildExit reports that a removed child has actually left the tree, after its exit when one exists. onChildMove reports a layout animation beginning on a keyed NibMotion. The aggregate onAnimationStart and onAnimationComplete cover exits and moves, with one completion after all work in the batch finishes or is superseded. Entrance animations belong to the children and are outside that aggregate.',
          'Try the presence-reflow demo, remove two items, then add one of those keys back during its exit. Watch the gap and callback order. Re-addition returns that keyed child to the layout flow and cancels the exit. An exiting child is excluded from pointer hits, focus, and semantics while it is only a visual remnant; keep the remaining controls available to keyboard and screen-reader users. Dispose or navigate away during a delayed exit in a test so no stale callback mutates a closed screen.',
          'A common mistake is to use an exit callback to remove the same item from the source collection. Presence only sees an exit after the collection has already stopped supplying that key. Remove it from source state first; use onChildExit for follow-up work that truly depends on the visual departure. If a whole batch must finish before another visual phase begins, use the aggregate completion callback and check that the owning State still exists.',
        ],
      ),
      DocSection(
        id: 'limits',
        heading: 'Check transforms and clips',
        paragraphs: [
          'Captured exit geometry crosses coordinate spaces. The 0.3.5 source tests selected scaled and rotated cases, but perspective, near-singular transforms, rotated reorder, and ancestor clips spanning different spaces have scoped limits. Use the documented geometry contract before relying on pop exits in a transformed overlay.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'performance',
    title: 'Performance',
    summary: 'Measure build, layout, paint, raster, and retention separately.',
    evidence: 'MotionNib/motion/doc/performance.md; MotionNib/motion/lib/src/core/render_nib_motion.dart; MotionNib/motion/lib/src/values/motion_value.dart',
    relatedRecipeId: 'linked-objects',
    sections: [
      DocSection(
        id: 'paint',
        heading: 'Understand the fast path',
        paragraphs: [
          'A MotionValue notification can make RenderNibMotion mark paint dirty without rebuilding the child on each frame. This is a property of the package path, not a promise that every assembled screen is cheap. Opacity may change compositing needs; blur, clips, shadows, and shader effects add their own work.',
          'The live slider makes this data path visible. It does not collect frame timings. A smooth debug preview cannot establish a production frame budget.',
        ],
      ),
      DocSection(
        id: 'profile',
        heading: 'Profile a representative screen',
        paragraphs: [
          'Use a profile build on target hardware. Record SDK, renderer, device, frame count, build duration, raster duration, and retained memory separately. Scroll, interrupt animations, and dispose repeated screens while collecting the trace.',
          'A pure-Dart parser or MotionValue benchmark measures computation. It cannot stand in for Flutter layout, rasterization, GPU presentation, or physical touch latency.',
        ],
      ),
      DocSection(
        id: 'measurement-plan',
        heading: 'Make the comparison fair',
        paragraphs: [
          'Choose one real screen and one repeatable interaction first, such as moving a keyed card ten times while a list scrolls. Keep device, SDK, build mode, renderer, workload, and item count fixed between a baseline and a candidate. Warm up the shader and widget paths before sampling. Record raw frame timings and the number of samples; a handful of frames cannot support a precise high percentile. Run the same gesture after every code change so a smoother recording is tied to a concrete edit.',
          'Flutter’s build, layout, and raster timings answer different questions. A MotionValue write may skip rebuilding its child but still ask a render object to paint. A layout FLIP still begins with a real layout change from the host. Blur or a fragment shader may be dominated by raster work. If the Flutter frame graph shows raster spikes, reducing Dart allocation alone is unlikely to solve the visible hitch.',
        ],
      ),
      DocSection(
        id: 'budget',
        heading: 'Check what stays alive',
        paragraphs: [
          'Controllers, externally owned MotionValues, and manually created bridges need disposal. Layout snapshots and presence exits can retain geometry until a transition finishes. Compare a stable idle state before and after repeated create-dispose cycles rather than only measuring a single animation.',
        ],
      ),
      DocSection(
        id: 'retention-exercise',
        heading: 'Check churn and ownership',
        paragraphs: [
          'Use linked-objects to see how one value can drive another, then put the same interaction inside a route that is repeatedly opened and closed. Create the external MotionValue in State, remove any manual listener, and dispose the value after the widgets that read it leave the tree. Take a heap snapshot at a settled idle point, repeat many route cycles, let exits and timers finish, and take another idle snapshot. Compare retained instances, not just peak memory during the animation.',
          'For layoutId handoffs, snapshots are intentionally kept for a short window after detachment. A single retained snapshot immediately after removal is expected. Growth that continues after the snapshot window and garbage collection needs investigation. Measure detached-snapshot timer allocation under sustained churn separately; the cleanup regression proves release behavior, not that allocation cost is negligible. Record the profile trace and candidate revision with the observation.',
        ],
      ),
      DocSection(
        id: 'diagnose',
        heading: 'Match a symptom to the pipeline',
        paragraphs: [
          'If the frame spends time building, look for parent setState calls that rebuild too much of the screen or many per-item keys changing together. If layout is high, inspect expanding children, intrinsic measurement, and lazy-list churn. If raster is high, isolate clips, opacity layers, blur, shadows, and shaders one at a time. If memory climbs, check external controllers, values, subscriptions, and an exit that never reaches completion. Profile on target hardware before deciding a threshold or announcing a speedup.',
          'When comparing a proposed optimization, preserve the unmodified baseline workload and run it again after the change. A new device temperature, browser backend, build mode, or list length can erase the meaning of the comparison. Keep pure-Dart computation timings separate from Flutter frames and from display presentation. If a change reduces one timing but worsens interaction correctness or retained state, it is not a useful win for that screen.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'api',
    title: 'API reference',
    summary: 'Find the public entry point for a concrete animation job.',
    evidence: 'MotionNib/motion/lib/nib_motion.dart; MotionNib/motion/llms.txt',
    sections: [
      DocSection(
        id: 'first-choice',
        heading: 'Pick the smallest useful entry point',
        paragraphs: [
          'For a button that fades or moves between two known states, begin with NibMotion and NibAnim. NibAnim describes target properties such as opacity, x, y, scale, and rotation. NibTransition describes timing: a spring uses mass, stiffness, and damping; a tween uses duration and curve. Keep the resting target in animate and let Flutter state decide when to change it. A controller is useful only when an event must command an animation independently of a build.',
          'If you need an item to move because Row, Column, or Wrap changed its layout, use layout and stable keys. If an item is removed but needs an exit, place keyed children under NibPresence. These two families can work together, but an ordinary NibAnim translation will not update the parent’s layout slot. The layout and presence guides show where each wrapper belongs.',
        ],
        code: "// In build().\nNibMotion(\n  initial: const NibAnim(opacity: 0, y: 12),\n  animate: const NibAnim(opacity: 1, y: 0),\n  transition: const NibTransition(duration: Duration(milliseconds: 300)),\n  child: const Text('Ready'),\n)",
      ),
      DocSection(
        id: 'core',
        heading: 'Start with the public barrel',
        paragraphs: [
          'Import package:nib_motion/nib_motion.dart. NibMotion, NibAnim, NibTransition, NibSpringDescription, MotionValue, and NibMotionValues cover most state-to-paint interactions. NibMotionController is optional when a host needs imperative start, stop, set, or sequence.',
          'NibMotion accepts a required child, initial and animate states, temporary gesture states, keyframes, viewport state, layout options, and an optional controller. Only add the features the interaction needs.',
        ],
      ),
      DocSection(
        id: 'families',
        heading: 'Choose the matching family',
        paragraphs: [
          'NibPresence handles removal; NibLayoutScope and layout options handle measured movement; NibScrollReveal and NibScrollMotion connect visibility and scroll position. NibText, NibDrawPath, NibPathMotion, NibTimeline, and route widgets solve different kinds of sequencing.',
          'The barrel also exports shaders, presets, physics drivers, and debug overlays. Most apps should use the higher-level widgets before constructing a SpringSolver or RenderNibMotion directly.',
        ],
      ),
      DocSection(
        id: 'value-or-widget',
        heading: 'Decide who owns changing values',
        paragraphs: [
          'When a value changes every frame or follows input directly, a MotionValue can connect the input to painting without rebuilding the child for each tick. It has a current value, listeners, and velocity for numeric motion. NibMotionValues maps external values to NibMotion properties; the caller creates and disposes those external values. A controller, by contrast, tells one or more widgets to begin, stop, or sequence an animation and exposes the first attached widget’s property value when needed.',
          'For path drawing and path following, choose NibDrawPath or NibPathMotion and their own controllers. For text, use NibText for units, NibTextReveal for a block clip, and NibTypewriter for discrete character changes. For scroll-linked progress, start from the scroll family. Each public family has different ownership and update rules; avoid building directly on a render object until the higher-level widget is demonstrably inadequate.',
        ],
      ),
      DocSection(
        id: 'reading-reference',
        heading: 'Use the generated reference as a map',
        paragraphs: [
          'The API browser lists declarations exported by the public package barrel, with their source documentation and member signatures. Search for a type after you know the behavior you want, then read its constructor defaults and callbacks in context. A signature tells you that a parameter exists; it cannot explain how layout space, cancellation, or accessibility behave. This guide links those decisions to the deeper topic pages.',
          'As a practice task, build the small fade above, then replace the tween with NibTransition.springGentle and compare interruption while toggling the parent state. Next inspect NibMotionController in the API browser and decide whether the use case actually needs start() or if a changing animate value is simpler. Run the snippet against the exact dependency graph in your pubspec.lock; the 0.3.6 gallery candidate is separate from the hosted 0.3.5 API.',
        ],
      ),
      DocSection(
        id: 'boundaries',
        heading: 'Check ownership and version',
        paragraphs: [
          'The widget owns its internal animation values. The caller owns a controller, a MotionValue passed through NibMotionValues, and a directly created ScrollMotionBridge. Read the guide for that family before wiring disposal.',
          'These Motion guides target published 0.3.5. Version 0.3.6 remains a review candidate. Check pubspec.lock when comparing an older example or API reference.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'platform-limits',
    title: 'Platform limits',
    summary: 'Separate source behavior, tested geometry, and device evidence.',
    evidence: 'MotionNib/motion/pubspec.yaml; MotionNib/motion/doc/layout.md; MotionNib/motion/doc/performance.md; RELEASE_CANDIDATE_REPORT.md',
    sections: [
      DocSection(
        id: 'sdk',
        heading: 'Check the package constraints',
        paragraphs: [
          'The published 0.3.5 pubspec declares Flutter 3.29 or newer and Dart 3.0 or newer. Hosted archives can carry different constraints. Resolve the exact archive or path package used by your app, and run analysis and tests under that SDK rather than inferring support from source inspection alone.',
        ],
      ),
      DocSection(
        id: 'runtime-check',
        heading: 'Check your actual dependency and renderer',
        paragraphs: [
          'A pubspec constraint declares what may resolve; pubspec.lock records what did resolve for an application. Start with flutter --version and the lockfile, then run flutter pub get, flutter analyze, and the relevant tests under the oldest SDK you claim to support. Repeat with the current stable SDK. A newer test tool can fail even if library source could run on an older SDK, so record test-tool and runtime constraints separately.',
          'For Flutter web, identify the renderer or Wasm backend used by the served release build. A Wasm test runner proves its test module executed in Wasm, but it does not identify the backend of a separately built site. Inspect the served build, exercise text, navigation, and shader assets there, and note the browser version. Desktop emulation of a mobile viewport is useful for layout checks but is not a physical mobile browser result.',
        ],
      ),
      DocSection(
        id: 'geometry',
        heading: 'Stay inside the measured geometry',
        paragraphs: [
          'Selected scaled and rotated affine cases have regression tests. Perspective, near-singular transforms, rotated reorder, and pop exits requiring preservation of a clip across coordinate spaces remain outside the verified contract. A transform can alter both paint and hit behavior, so check both.',
        ],
      ),
      DocSection(
        id: 'geometry-checklist',
        heading: 'Test the interaction that depends on geometry',
        paragraphs: [
          'For a reorder, record where an item is painted, which child receives a tap during movement, where focus goes after the move, and what a screen reader announces. For a drag, compare the reported release velocity with movement in the receiving widget’s local logical pixels per second. For a pop exit, check clipping and hit testing while the old visual remains over the new layout. Numeric widget tests are more informative than a test that only avoids an exception.',
          'Near-zero scale can make coordinate conversion unstable. Perspective transforms and rotated reorder are not within the 0.3.5 verified layout and reorder contract. If your application requires one of those combinations, keep a simpler interaction for now or establish an application-specific test on the target platform. Do not infer support for every transform from the passing uniform-scale regression.',
        ],
      ),
      DocSection(
        id: 'exercise',
        heading: 'Build an evidence note for one screen',
        paragraphs: [
          'Take the keyed-reorder demo into the screen where your app will use it. Record the candidate package revision, Flutter version, target device, renderer, and exact steps to move an item during a scroll. Save a short recording and any logs. Repeat with reduced motion enabled and verify that the final order, focus, and tap target remain correct. This note gives a reviewer a concrete result to accept or a reproducible limit to investigate.',
          'When the required device is unavailable, keep the check pending. A software-rendered widget test can verify final positions and callbacks; it cannot substitute for physical touch or a GPU shader result. Write the scenario and expected observations so another tester can run the same interaction later. If the product chooses to exclude a platform or transform combination, record that scope decision explicitly instead of treating an unexecuted test as a pass.',
        ],
      ),
      DocSection(
        id: 'hardware',
        heading: 'Keep device gates distinct',
        paragraphs: [
          'Widget tests, software rendering, and a compiled APK cannot certify physical touch, GPU shader output, screen-reader operation, or iOS Safari. Record actual launches and interactions for those targets when they become available. Treat any missing physical result as a pending gate or an explicitly scoped support limit.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'troubleshooting',
    title: 'Troubleshooting',
    summary:
        'Trace a still or misplaced animation to state, identity, and space.',
    evidence: 'MotionNib/motion/lib/src/core/nib_motion_widget.dart; MotionNib/motion/lib/src/layout/nib_layout_scope.dart; MotionNib/motion/CHANGELOG.md',
    sections: [
      DocSection(
        id: 'known-runtime-limits',
        heading: 'Known runtime issues under review',
        paragraphs: [
          'The gallery audit reproduced a second-ticker assertion when reduced motion is toggled repeatedly around NibGradientText. It also observed NibPathMotion pause/play restarting the clock, and opaque shimmer children covering the sweep. These are reported separately from website navigation and copy-code checks. No library patch is hidden in this documentation change.',
          'NibGlass can use a frosted fallback in the browser. That is supported behavior, not evidence of shader refraction. NibTextReveal accepts a controller but the current implementation does not attach it; remounting replays the reveal and also resets local State.',
        ],
        blocks: [
          DocLink(
            'Review the gallery audit and reproductions',
            'https://github.com/oraclevs/nib_motion/blob/feat/interactive-showcase-0.3.6/doc/maintainers/showcase-audit.md',
          ),
        ],
      ),

      DocSection(
        id: 'triage',
        heading: 'Reduce the problem to one moving child',
        paragraphs: [
          'First put a single NibMotion around a fixed-size child with an obvious initial and animate difference, such as opacity zero to one. If that moves, restore the original interaction one layer at a time: parent state, presence, scope, scrolling parent, clip, and transforms. At each step write down whether the child built with a new key, changed its target, or changed only paint. This separates a missing state update from a geometry problem.',
          'A spring’s duration and curve do not determine its settling. If motion seems late, inspect the transition’s spring, delay, and any entrance gate. If a controller command does nothing, verify that the NibMotion using it is mounted and attached when start() runs. A controller can be shared across widgets, so a surprising extra animation may mean another child is attached to the same handle.',
        ],
      ),
      DocSection(
        id: 'still',
        heading: 'When nothing moves',
        paragraphs: [
          'First check that animate differs from the current value, reduced motion is not active, and the entrance gate has released. A first-frame entrance can wait during the default warm-up; a later state change should still retarget. Inspect the resolved NibTransition: a spring ignores duration and curve.',
        ],
      ),
      DocSection(
        id: 'identity',
        heading: 'When a child jumps or exits at the wrong time',
        paragraphs: [
          'List and presence behavior depend on stable unique keys. A new key remounts a child and can replay its entrance. A missing exit state removes a NibPresence child immediately. For shared layoutId handoff, keep both endpoints in the same NibLayoutScope and do not expect two live widgets with one ID to morph between each other.',
        ],
      ),
      DocSection(
        id: 'layout-debug',
        heading: 'Trace layout and exit errors',
        paragraphs: [
          'When a reordered item travels from the wrong place, print its data ID and key before looking at timing. Stable data keys are essential. Keep the old and new layoutId endpoints under one NibLayoutScope; the old endpoint must detach shortly before the new one mounts. Two live widgets with the same layoutId do not create a morph. If a size transition stretches text, try clip mode and accept that it reveals final-layout content rather than preserving the old pixels.',
          'When an exit never appears, check that the removed direct child has a unique non-null key and an exit target, or that the container supplies an exit override. With the base NibPresence constructor, also supply layoutBuilder when a list should lay out as a Row or Column; its default is Stack. Check exitLayout: sync holds the slot, whereas pop releases it immediately. On re-addition during an exit, the same key returns to the active flow.',
        ],
      ),
      DocSection(
        id: 'graph',
        heading: 'When a copied example does not compile',
        paragraphs: [
          'Check the package version and Flutter SDK in pubspec.lock, then compare the public constructor with the API browser for that version. These Motion guides target the hosted 0.3.5 API. Prefer the public barrel and run the example in a small app against the same dependency graph.',
        ],
      ),
      DocSection(
        id: 'finish-debug',
        heading: 'Verify the fix at the boundary',
        paragraphs: [
          'After changing code, repeat the failing sequence with a rapid second change and with disposal during motion. Record numeric painted position and hit target when geometry was the symptom; record callback order when lifecycle was the symptom. If the failure occurs only on a device or browser, include its renderer, Flutter version, and a short capture. A passing debug widget test does not establish a GPU or physical-touch result.',
          'For a callback that fires too early or never fires, identify which animation owns it. A child entrance, a layout FLIP, a presence exit, and an aggregate presence batch have different completion rules. Record the old and new keys, mounted status, target values, and event order in one minimal reproduction. That log usually narrows the failure faster than changing transition duration at random.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'controllers',
    title: 'Controllers',
    summary: 'Drive one or more NibMotion widgets from an imperative event.',
    evidence: 'MotionNib/motion/lib/src/core/nib_motion_controller.dart; MotionNib/motion/lib/src/core/nib_motion_widget.dart',
    sections: [
      DocSection(
        id: 'ownership',
        heading: 'Create the handle in State',
        paragraphs: [
          'NibMotionController attaches to each NibMotion receiving it. The same controller can drive several widgets. Create it in the owning State, pass it through controller, and dispose it in State.dispose; NibMotion does not take ownership of the external handle.',
        ],
        code: "class FadeLogo extends StatefulWidget {\n  const FadeLogo({super.key});\n  @override\n  State<FadeLogo> createState() => _FadeLogoState();\n}\n\nclass _FadeLogoState extends State<FadeLogo> {\n  final controller = NibMotionController();\n\n  @override\n  Widget build(BuildContext context) => Column(children: [\n    NibMotion(controller: controller, child: const FlutterLogo()),\n    TextButton(\n      onPressed: () => controller.start(\n        target: const NibAnim(opacity: 0),\n      ),\n      child: const Text('Fade'),\n    ),\n  ]);\n\n  @override\n  void dispose() {\n    controller.dispose();\n    super.dispose();\n  }\n}",
        api: [
          DocApiEntry(
            name: 'controller',
            type: 'NibMotionController?',
            defaultValue: 'null',
            description: 'Externally owned handle attached to this widget.',
          ),
          DocApiEntry(
            name: 'dispose()',
            type: 'void',
            defaultValue: 'caller action',
            description:
                'Release the external controller from the owning State.',
          ),
        ],
      ),
      DocSection(
        id: 'walkthrough',
        heading: 'Follow one command from button to pixels',
        paragraphs: [
          'In the example, State owns the controller for as long as the route owns the button and logo. NibMotion attaches its animator during its lifecycle. Pressing Fade asks each attached widget to animate toward opacity zero and returns a Future that completes when the animation settles or is superseded. The callback is a command result, not a guarantee that the widget is still on screen when it resolves. Check mounted before changing State after awaiting it.',
          'set(target) jumps to the target immediately. By default it clears each property’s velocity; keepVelocity: true preserves momentum for a following start. stop() freezes the current values and resolves the pending animation Future. motionValueOf(property) reports the first attached widget’s live value, so it is unsuitable as an aggregate reading when one controller drives several children. velocityOf reports units per second for that property.',
        ],
      ),
      DocSection(
        id: 'commands',
        heading: 'Choose the right command',
        paragraphs: [
          'start(target:) animates to a NibAnim; start(keyframes:) plays one keyframe sequence; start() replays the widget’s entrance. Only one of target and keyframes may be supplied. set applies a target immediately, stop freezes the current values, and repeat toggles the loop.',
          'sequence runs NibMotionSequenceStep values in order, waiting for each animation and optional wait before the next step. The returned Future is useful for ordering work. A spring can look settled before its Future resolves.',
        ],
        api: [
          DocApiEntry(
            name: 'start()',
            type: 'Future<void>',
            defaultValue: 'replay entrance',
            description: 'Optionally take target or keyframes, never both.',
          ),
          DocApiEntry(
            name: 'set(target)',
            type: 'void',
            defaultValue: 'none',
            description: 'Apply a NibAnim immediately.',
          ),
          DocApiEntry(
            name: 'stop()',
            type: 'void',
            defaultValue: 'none',
            description: 'Freeze attached widgets at current values.',
          ),
        ],
      ),
      DocSection(
        id: 'sequence-caveat',
        heading: 'Coordinate sequences with the host lifecycle',
        paragraphs: [
          'NibMotionSequenceStep has a required target, an optional transition, and an optional wait after that step. sequence awaits each start and wait in order. The implementation does not expose a separate sequence-cancellation token: stop resolves the current animation but the sequence can continue to its next step. If the screen may leave midway, keep a host generation or mounted check around the orchestration and do not assume stop cancels future steps.',
          'Exercise this with two steps: fade to 0, wait briefly, then fade to 1. Trigger the sequence twice quickly and navigate away during the wait. Decide whether overlapping requests should be ignored, restarted, or serialized in your screen logic. Dispose the controller in State.dispose. A controller whose widget detached has no pixels to drive, and a disposed controller should not be reused by a newly mounted screen.',
          'Calling start with no target and no keyframes replays the attached widget’s entrance. Calling it with both target and keyframes violates the API assertion. When several widgets share the controller, start returns after all attached animators’ Futures resolve, so the slowest one determines when an await continues. Keep the controller scoped to widgets that should genuinely move together; use separate handles when independent cancellation or timing matters. If no widget is attached yet, start has nothing to drive.',
        ],
      ),
      DocSection(
        id: 'scope',
        heading: 'Prefer declarative state for ordinary changes',
        paragraphs: [
          'A changing animate value is enough for most UI state. Reach for a controller when the host must replay, stop, or coordinate a sequence from an external event. If a controller is replaced, the old one detaches; dispose any controller no longer owned by the screen.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'timeline',
    title: 'Timeline',
    summary:
        'Schedule several controllers on one clock and scrub known states.',
    evidence: 'MotionNib/motion/lib/src/timeline/nib_timeline.dart; MotionNib/motion/lib/src/timeline/nib_timeline_entry.dart; MotionNib/motion/lib/src/timeline/nib_animation_sequence.dart',
    sections: [
      DocSection(
        id: 'time-model',
        heading: 'Understand the shared clock',
        paragraphs: [
          'Construct the timeline after the controllers exist and the participating NibMotion widgets can attach. An absolute at is measured from each play() call, not from app startup. A relative after entry starts when its reference finishes, including transition delay and modeled spring settling; withStart aligns with the reference start. Relative references resolve in input order, so a label must already have been declared when it is used. The resolved entries are then sorted by start time.',
          'The example schedules title at zero and subtitle at 150 ms. Each entry invokes its controller independently, so the two can overlap. Give each controller to the corresponding mounted NibMotion. Store both controllers and the timeline in the owning State and dispose them when that State leaves. Avoid constructing a fresh timeline inside build, where a rebuild would discard the old schedule while its commands are still active.',
        ],
      ),
      DocSection(
        id: 'entries',
        heading: 'Schedule entries across elements',
        paragraphs: [
          'NibTimeline takes NibTimelineEntry values and sorts their resolved start offsets. Each entry drives a NibMotionController toward a NibAnim target. at is a Duration from play start; NibTimelineEntry.after can follow the previous entry or a named label, while withStart can align to a named start with an offset.',
          'Relative references must point to entries already defined in the input list. The constructor rejects duplicate labels and unknown or later references. For a single controller’s sequential changes, NibAnimationSequence is the simpler fluent API.',
        ],
        code: "// In State, after creating both controllers.\nfinal timeline = NibTimeline([\n  NibTimelineEntry(\n    controller: titleController,\n    target: const NibAnim(opacity: 1),\n    at: Duration.zero,\n  ),\n  NibTimelineEntry(\n    controller: subtitleController,\n    target: const NibAnim(opacity: 1),\n    at: const Duration(milliseconds: 150),\n  ),\n]);",
        api: [
          DocApiEntry(
            name: 'controller',
            type: 'NibMotionController',
            defaultValue: 'required',
            description: 'The element driven by this entry.',
          ),
          DocApiEntry(
            name: 'target',
            type: 'NibAnim',
            defaultValue: 'required',
            description: 'State to reach when the entry runs.',
          ),
          DocApiEntry(
            name: 'at',
            type: 'Duration',
            defaultValue: 'required',
            description: 'Absolute offset from timeline play start.',
          ),
          DocApiEntry(
            name: 'from',
            type: 'NibAnim?',
            defaultValue: 'null',
            description: 'Optional start state for precise scrubbing.',
          ),
        ],
      ),
      DocSection(
        id: 'scrub',
        heading: 'Scrub with explicit starts',
        paragraphs: [
          'seek clamps a fraction into zero through one, cancels pending play timers, and applies each entry’s state at that point. An explicit from gives a known start state. Without it, the implementation derives the start of each targeted property from an earlier entry on the same controller or from the attached widget’s initial state. An entry can step only where no usable start can be derived. NibTimeline.progress records the last seek position and is not advanced by play.',
          'Pause and stop cancel pending timers but leave animations that already started running. If pending entries are canceled, the Future from that play call can remain incomplete; do not await it as a cancellation signal. Dispose the timeline and each controller owned by the host. A playing spring can take longer to report completion than it appears to settle.',
        ],
      ),
      DocSection(
        id: 'scrub-exercise',
        heading: 'Build a seekable introduction',
        paragraphs: [
          'Add from: const NibAnim(opacity: 0) to each example entry and attach a Slider that calls timeline.seek(value). Move it to 0, 0.5, and 1. The slider’s fraction maps to the timeline’s total duration, which is the latest entry end, not just the last start. At 0.5, one element may have finished while another is still moving. Compare that with play(), which dispatches actual timed animations and does not update timeline.progress on each frame.',
          'Then add a third entry using NibTimelineEntry.after(reference: a label) and a negative offset so it overlaps the previous end. Verify that the label appears earlier in the input list; duplicate or forward labels throw at construction. Exercise a second play during the first one: pending timers from the older run are canceled before all entries are rescheduled. If the screen can close during this work, avoid treating an incomplete play Future as a signal to update disposed State.',
        ],
      ),
      DocSection(
        id: 'use',
        heading: 'Keep the sequence proportional',
        paragraphs: [
          'Use separate controllers when independent elements need different start times. Keep the primary action available even if the sequence is skipped by reduced motion. Test replay, interruption, and route disposal before using a timeline for navigation or form completion.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'text-motion',
    title: 'Text motion',
    summary: 'Choose between animated units, typing, a gradient sweep, and a whole-block reveal.',
    evidence: 'MotionNib/motion/lib/src/text/nib_text.dart; MotionNib/motion/lib/src/text/nib_text_config.dart; MotionNib/motion/lib/src/text/nib_typewriter.dart; MotionNib/motion/lib/src/text/nib_text_gradient.dart; MotionNib/motion/lib/src/text/nib_text_reveal.dart',
    sections: [
      DocSection(
        id: 'choose-text-primitive',
        heading: 'Choose what actually changes',
        paragraphs: [
          'Start with the content job. NibText wraps separate units in NibMotion, so use it when letters, words, or explicit lines should each enter with their own timing. NibTypewriter changes the number of visible characters at discrete timer ticks. NibGradientText keeps the full string laid out and moves a gradient over its painted glyphs. NibTextReveal keeps the whole child laid out and uncovers it with a clip. These are four different behaviors, not four names for the same animation.',
          'A heading that must be readable immediately may need a static Text instead. For a short decorative heading, try NibText with a modest word stagger. For a loading placeholder, do not make a typewriter imply that real data is arriving one character at a time. Choose an effect only after deciding whether users need the complete words at the start, during the effect, or at the end.',
          'All examples below belong inside a Flutter build method unless they explicitly show a State owner. Import package:nib_motion/nib_motion.dart and the Flutter widget or material library used by the surrounding screen. When an example refers to a variable such as phrase or show, that variable comes from the host widget’s state.',
        ],
      ),
      DocSection(
        id: 'character-units',
        heading: 'Animate perceived characters',
        paragraphs: [
          'NibTextUnit.character is the default. NibText splits the string into an approximation of grapheme clusters and gives each animated unit a NibMotion child. The splitter keeps UTF-16 surrogate pairs and common combining marks, joiners, skin-tone modifiers, and flag pairs together. It is intentionally dependency-free and is not a complete Unicode grapheme algorithm. Test unfamiliar scripts and emoji sequences before claiming exact per-character treatment.',
          'The first example fades each unit in from 10 logical pixels below its final position. initial is the start state, animate is the target, and staggerDelay adds 35 ms between unit starts. Without animate, the unit remains at initial and no entrance occurs. For longer text, per-character mode creates many children; switch to words or a whole-block reveal when that cost or reading pattern is wrong.',
        ],
        code: '''
NibText(
  'Hello 👋',
  config: const NibTextConfig(
    unit: NibTextUnit.character,
    initial: NibAnim(opacity: 0, y: 10),
    animate: NibAnim.identity,
    staggerDelay: Duration(milliseconds: 35),
  ),
)
''',
      ),
      DocSection(
        id: 'word-units',
        heading: 'Keep spaces and move words',
        paragraphs: [
          'NibTextUnit.word splits on whitespace. A run of spaces remains plain, unanimated text between animated word widgets; it is not counted as another stagger step. This is useful for a short slogan because the words remain recognizable while the animation progresses. It also means a string with irregular spaces preserves those spaces rather than normalizing the copy.',
          'Place the example in build and adjust the sentence at different viewport widths. The parent uses Wrap for character and word modes, so words may wrap differently from a single Text paragraph. textAlign changes Wrap alignment, while overflow applies to each unit’s Text rather than providing one overflow rule for the entire assembled sentence. Use ordinary Text for long body copy, selection, and exact paragraph flow.',
        ],
        code: '''
NibText(
  'Move with intention',
  textAlign: TextAlign.center,
  config: const NibTextConfig(
    unit: NibTextUnit.word,
    initial: NibAnim(opacity: 0, y: 14),
    animate: NibAnim.identity,
    staggerDelay: Duration(milliseconds: 80),
  ),
)
''',
      ),
      DocSection(
        id: 'line-units',
        heading: 'Use explicit lines, not visual wraps',
        paragraphs: [
          'NibTextUnit.line splits at newline characters in the source string. It does not inspect where a Text widget happens to wrap at a narrow width. The resulting animated units are placed in a Column. Use explicit lines for a two-line title or a planned verse where line boundaries are part of the content. If a responsive title needs different line breaks at different widths, choose the string for that width in the host widget.',
          'Try the example at phone and desktop widths. Changing textAlign affects the Column cross-axis alignment, but it cannot make an overlong line fit. A line may still wrap inside its own Text. Check that the visual order and screen-reader order stay sensible when you swap the line text or font size.',
        ],
        code: '''
NibText(
  'Build a little.\\nMake it move.',
  textAlign: TextAlign.center,
  config: const NibTextConfig(
    unit: NibTextUnit.line,
    initial: NibAnim(opacity: 0, x: -18),
    animate: NibAnim.identity,
    staggerDelay: Duration(milliseconds: 140),
  ),
)
''',
      ),
      DocSection(
        id: 'stagger-origins',
        heading: 'Change where the stagger begins',
        paragraphs: [
          'staggerFrom has four choices. start delays animated unit i by i × staggerDelay. end delays it by (count − 1 − i) × staggerDelay. center starts at the middle and spreads outward; for an even count the two middle units have equal delay. random assigns repeatable pseudorandom delays within the overall window, so it is a shuffled entrance rather than a new random order on every frame. Only animated units count: the spaces between words do not.',
          'In the playground, use the same phrase and delay while changing start, end, center, and random. Do not change several settings at once if you want to understand the order. A large stagger multiplied by a long sentence can delay the last unit well beyond the point where a heading should be readable. For essential text, keep the total wait short or present the complete text outside the animation.',
        ],
        code: '''
NibText(
  'One two three four',
  config: const NibTextConfig(
    unit: NibTextUnit.word,
    initial: NibAnim(opacity: 0),
    animate: NibAnim.identity,
    staggerDelay: Duration(milliseconds: 90),
    staggerFrom: NibTextStaggerFrom.center,
  ),
)
''',
      ),
      DocSection(
        id: 'composed-motion',
        heading: 'Combine properties on each unit',
        paragraphs: [
          'A NibAnim can change several properties in the same unit. The example combines opacity, vertical translation, scale, and a small Z rotation. x and y are logical-pixel offsets from the natural position; scale 1 is normal size; rotate is measured in turns, so 0.02 is 7.2 degrees, not 0.02 radians. NibAnim.identity restores all of those properties to their resting values.',
          'Begin with opacity and y, then add scale, then rotation. Watch legibility and the visual center as properties combine. Avoid a large blur or rotation on text users must read while it moves. A composed unit animation is still one transition per unit. NibText does not expose a separate transition for each property through NibTextConfig, so split elements into separate widgets if their timing truly needs to differ.',
        ],
        code: '''
NibText(
  'Small moves add up',
  config: const NibTextConfig(
    unit: NibTextUnit.word,
    initial: NibAnim(opacity: 0, y: 16, scale: 0.92, rotate: 0.02),
    animate: NibAnim.identity,
    staggerDelay: Duration(milliseconds: 70),
  ),
)
''',
      ),
      DocSection(
        id: 'spring-vs-tween',
        heading: 'Choose a tween or a spring',
        paragraphs: [
          'With config.transition omitted, the current NibText widget builds a 400 ms tween for each unit. The NibTextConfig comment that describes a spring default is stale; the widget implementation is the source of this behavior. Supply NibTransition(duration:, curve:) for predictable timing, or a transition with spring: NibSpringDescription.gentle for velocity-based settling. A spring’s duration and curve do not determine its path.',
          'NibText builds each unit transition from the supplied duration, curve, and spring, but replaces transition.delay with the calculated stagger delay. A delay supplied on config.transition therefore is not an extra initial wait. Put a delay in the host’s mounting logic or another wrapper if the whole text must start later. Compare a 250 ms tween and a gentle spring with the same word stagger; interrupt by changing the host content and check whether the new mount or existing element should replay.',
        ],
        code: '''
NibText(
  'Timing changes the mood',
  config: const NibTextConfig(
    unit: NibTextUnit.word,
    initial: NibAnim(opacity: 0, y: 12),
    animate: NibAnim.identity,
    staggerDelay: Duration(milliseconds: 65),
    transition: NibTransition(
      spring: NibSpringDescription.gentle,
    ),
  ),
)
''',
      ),
      DocSection(
        id: 'typewriter',
        heading: 'Type, blink, delete, and repeat',
        paragraphs: [
          'NibTypewriter reveals one approximated grapheme at each speed interval, 50 ms by default. It uses Timer.periodic and setState because the actual content length changes. delay waits before typing begins. cursor defaults to a vertical bar; null removes it. cursorBlinkInterval defaults to 530 ms and controls the visibility toggle when the cursor is active. If repeat is true, the widget pauses briefly at full text, deletes at deleteSpeed (or speed when null), then types again without another onComplete call.',
          'onComplete runs once per mounted widget after the first full reveal, not once per repeat loop. In the current implementation, the last character appears on one tick and completion is checked at the next tick. Updating text on the same mounted widget changes the internal grapheme list and clamps the revealed count; it does not automatically restart typing from zero. Use a deliberate new key if a new phrase must begin from empty, and manage the host’s business completion independently of the decorative typing effect.',
        ],
        code: '''
NibTypewriter(
  'Ready when you are.',
  speed: const Duration(milliseconds: 45),
  cursor: '▍',
  cursorBlinkInterval: const Duration(milliseconds: 450),
  delay: const Duration(milliseconds: 200),
  repeat: false,
  onComplete: () {
    // Optional visual follow-up; keep essential actions available earlier.
  },
)
''',
      ),
      DocSection(
        id: 'gradient',
        heading: 'Sweep color over already visible text',
        paragraphs: [
          'NibGradientText lays out the complete string once and masks a Gradient onto the glyphs. Its style supplies font metrics, but the style color is ignored because the gradient colors paint the letters. duration is 2000 ms for one sweep by default, repeat is true, and direction chooses left-to-right or right-to-left travel. The direction parameter does not set the paragraph’s text direction; layout uses the ambient Directionality.',
          'Try repeat: false for an introduction that settles at the final gradient position. A repeating gradient is decorative and keeps a ticker active while mounted. Under reduced motion the ticker stops and a static gradient frame remains. Keep sufficient contrast at every part of the sweep, including when the text sits over a changing background. A changing gradient can cost raster time because painting uses a layer and mask; profile the finished screen if many labels use it.',
        ],
        code: '''
NibGradientText(
  'A little color',
  gradient: const LinearGradient(
    colors: [Color(0xFF02569B), Color(0xFF54C5F8)],
  ),
  duration: const Duration(seconds: 2),
  repeat: true,
  direction: TextDirection.ltr,
)
''',
      ),
      DocSection(
        id: 'reveal',
        heading: 'Wipe an entire block from an edge',
        paragraphs: [
          'NibTextReveal takes any child, not only Text, and clips the whole laid-out child from factor zero to one. left shows a growing clip from the left edge, right from the right, up grows from the bottom edge, and down grows from the top. Those physical edge choices do not automatically mirror for RTL; choose the enum from Directionality when the writing direction should change the entrance edge.',
          'The reveal starts on mount. duration defaults to 500 ms, delay to zero, and curve to easeInOut. Its implementation uses an AnimationController tween, despite an outdated comment mentioning SpringSolver. Reduced motion shows the full child immediately. The public controller parameter is currently unconnected: passing a NibMotionController does not attach it and start() cannot replay this reveal. Remounting with a new key can replay an entrance, but treat that as a new widget lifecycle. Test a reduced-motion change during a pending delay because the delayed callback is mounted-guarded rather than canceled.',
        ],
        code: '''
NibTextReveal(
  direction: NibTextRevealDirection.up,
  duration: const Duration(milliseconds: 550),
  child: const Text('The whole line appears together'),
)
''',
      ),
      DocSection(
        id: 'layered-combinations',
        heading: 'Layer effects when they serve one message',
        paragraphs: [
          'A reveal can wrap NibGradientText: the outer clip controls when the full glyphs become visible, while the inner gradient has its own ticker and duration. These clocks are independent. Build the gradient child first, then wrap it, and test reduced motion so the complete phrase stays visible as a static gradient. This combination is a useful heading treatment, but it does not certify every renderer or every shader-like blend on every browser.',
          'A NibMotion container can hold NibTypewriter. The container moves once from its initial state while the inner typewriter advances content at timer intervals. Keep the container’s motion short enough that the text is not repeatedly moving away as users try to read. The typewriter onComplete concerns the first full phrase; it does not mean the outer NibMotion finished. Do not tie a form submit, navigation, or authorization decision to either decorative completion callback.',
        ],
        code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    NibTextReveal(
      direction: NibTextRevealDirection.left,
      child: NibGradientText(
        'Reveal the color',
        gradient: const LinearGradient(
          colors: [Color(0xFF02569B), Color(0xFF54C5F8)],
        ),
        repeat: false,
      ),
    ),
    NibMotion(
      initial: const NibAnim(opacity: 0, y: 8),
      animate: NibAnim.identity,
      child: const NibTypewriter('Then type the detail.'),
    ),
  ],
)
''',
      ),
      DocSection(
        id: 'ownership-and-exit',
        heading: 'Know which state and callbacks you own',
        paragraphs: [
          'NibText owns its per-unit NibMotion widgets. If you pass a NibMotionController to NibText, it is forwarded to every animated unit; one start command targets all attached units, and your State owns and disposes that external controller. NibTextConfig.exit is passed into each unit and creates nested presence handling, but removing a whole NibText or replacing its text is not the same as removing one keyed unit from a stable parent. Test the exact exit interaction before promising a staggered text departure.',
          'NibText.rich first calls span.toPlainText(), then applies the one flat style supplied to NibText. Inline span styles and recognizers are not preserved per unit. Use ordinary RichText or another deliberate composition for linked or differently styled phrases. A plain NibTextConfig.copyWith uses ?? for each field: passing null keeps the old nullable initial, animate, exit, or transition; it cannot clear one of them. Construct a new config when you need to remove a value.',
          'NibTextReveal has no working public replay handle at present. NibTypewriter owns and cancels its delay, typing, and blink timers on disposal. NibGradientText owns its ticker and MotionValue and disposes both. Keep State-level keys and controllers only when your screen really needs replay or cross-widget coordination.',
        ],
      ),
      DocSection(
        id: 'accessibility',
        heading: 'Keep the words available',
        paragraphs: [
          'Unit motion can produce several Text descendants where a reader expects one phrase. Inspect the semantics tree with TalkBack or VoiceOver rather than assuming the sentence is announced once in the desired order. For a decorative title, a parent Semantics label with inner semantics excluded can expose the complete phrase while its visual units animate. For interactive rich text, this shortcut is insufficient because it would hide link semantics; keep the interactive text as real accessible controls instead.',
          'Reduced motion changes the effects differently. NibText’s internal NibMotion units should settle at the target; NibTypewriter shows all text and reports completion; NibGradientText keeps a static gradient frame; NibTextReveal shows its whole child. Verify the actual screen at both motion settings, especially while changing the setting mid-animation. Do not rely on color or moving letters alone to convey status, and avoid a long stagger before a user can read an instruction.',
        ],
        code: '''
Semantics(
  label: 'Move with intention',
  child: ExcludeSemantics(
    child: NibText(
      'Move with intention',
      config: const NibTextConfig(
        unit: NibTextUnit.word,
        initial: NibAnim(opacity: 0),
        animate: NibAnim.identity,
      ),
    ),
  ),
)
''',
      ),
      DocSection(
        id: 'nib-text-api',
        heading: 'NibText and NibTextConfig parameters',
        paragraphs: [
          'Both NibText(text, ...) and NibText.rich(span, ...) accept the same named parameters. The first takes a String; the second takes an InlineSpan that is flattened to plain text. NibTextConfig is immutable. Its defaults alone do not create an entrance because animate is null. The table records the current constructor values; it also applies to a new config built after a host state change.',
          'copyWith accepts unit, initial, animate, exit, staggerDelay, staggerFrom, and transition, with nullable arguments. It returns a new config and uses ?? for each field. Therefore copyWith(animate: null) retains the old animate value rather than clearing it. Use a new NibTextConfig to deliberately clear a nullable field.',
        ],
        api: [
          DocApiEntry(
            name: 'NibText.text',
            type: 'String',
            defaultValue: 'required positional in NibText',
            description: 'Source string split into animated units.',
          ),
          DocApiEntry(
            name: 'NibText.rich.span',
            type: 'InlineSpan',
            defaultValue: 'required positional in NibText.rich',
            description: 'Flattened with toPlainText before splitting; inline styles are not preserved.',
          ),
          DocApiEntry(
            name: 'NibText.key',
            type: 'Key?',
            defaultValue: 'null',
            description:
                'Flutter identity; change deliberately to remount and replay.',
          ),
          DocApiEntry(
            name: 'NibText.config',
            type: 'NibTextConfig',
            defaultValue: 'const NibTextConfig()',
            description: 'Unit splitting, states, stagger, and transition.',
          ),
          DocApiEntry(
            name: 'NibText.style',
            type: 'TextStyle?',
            defaultValue: 'null',
            description: 'Flat base style applied to each unit.',
          ),
          DocApiEntry(
            name: 'NibText.textAlign',
            type: 'TextAlign?',
            defaultValue: 'null',
            description: 'Mapped to Wrap or Column alignment.',
          ),
          DocApiEntry(
            name: 'NibText.overflow',
            type: 'TextOverflow?',
            defaultValue: 'null',
            description:
                'Passed to each unit’s Text, not a paragraph-level ellipsis.',
          ),
          DocApiEntry(
            name: 'NibText.controller',
            type: 'NibMotionController?',
            defaultValue: 'null',
            description:
                'External handle forwarded to all animated unit widgets.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.unit',
            type: 'NibTextUnit',
            defaultValue: 'character',
            description: 'Character approximation, whitespace-delimited word, or explicit newline.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.initial',
            type: 'NibAnim?',
            defaultValue: 'null → identity',
            description: 'Starting state for each animated unit.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.animate',
            type: 'NibAnim?',
            defaultValue: 'null',
            description: 'Resting target; null means no entrance animation.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.exit',
            type: 'NibAnim?',
            defaultValue: 'null',
            description: 'Exit target passed to each unit; verify the surrounding removal lifecycle.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.staggerDelay',
            type: 'Duration',
            defaultValue: '30 ms',
            description: 'Increment between animated unit starts.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.staggerFrom',
            type: 'NibTextStaggerFrom',
            defaultValue: 'start',
            description: 'start, end, center, or repeatable random delays.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.transition',
            type: 'NibTransition?',
            defaultValue: 'null → 400 ms tween',
            description: 'Timing for each unit; its delay is replaced by the unit stagger.',
          ),
          DocApiEntry(
            name: 'NibTextConfig.copyWith(...)',
            type: 'NibTextConfig',
            defaultValue: 'existing fields retained',
            description: 'Uses ?? for every argument; null cannot clear an existing nullable value.',
          ),
          DocApiEntry(
            name: 'copyWith.unit',
            type: 'NibTextUnit?',
            defaultValue: 'null → keep old',
            description: 'Replace the split mode when non-null.',
          ),
          DocApiEntry(
            name: 'copyWith.initial',
            type: 'NibAnim?',
            defaultValue: 'null → keep old',
            description: 'Replace the unit start state when non-null.',
          ),
          DocApiEntry(
            name: 'copyWith.animate',
            type: 'NibAnim?',
            defaultValue: 'null → keep old',
            description: 'Replace the target when non-null; cannot clear it.',
          ),
          DocApiEntry(
            name: 'copyWith.exit',
            type: 'NibAnim?',
            defaultValue: 'null → keep old',
            description:
                'Replace the exit target when non-null; cannot clear it.',
          ),
          DocApiEntry(
            name: 'copyWith.staggerDelay',
            type: 'Duration?',
            defaultValue: 'null → keep old',
            description: 'Replace the time between animated units.',
          ),
          DocApiEntry(
            name: 'copyWith.staggerFrom',
            type: 'NibTextStaggerFrom?',
            defaultValue: 'null → keep old',
            description: 'Replace the stagger origin.',
          ),
          DocApiEntry(
            name: 'copyWith.transition',
            type: 'NibTransition?',
            defaultValue: 'null → keep old',
            description:
                'Replace the transition when non-null; cannot clear it.',
          ),
        ],
      ),
      DocSection(
        id: 'typewriter-api',
        heading: 'NibTypewriter parameters',
        paragraphs: [
          'NibTypewriter changes visible content through timers. It is the text primitive that rebuilds on each discrete reveal or deletion tick. Keep it short and dispose the surrounding route normally; its State cancels its timers. Avoid zero or negative timer intervals in host settings.',
        ],
        api: [
          DocApiEntry(
            name: 'NibTypewriter.text',
            type: 'String',
            defaultValue: 'required positional',
            description: 'Full phrase to reveal; changing it in place does not reset the count.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.key',
            type: 'Key?',
            defaultValue: 'null',
            description:
                'Flutter identity; a new key creates a fresh typing lifecycle.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.speed',
            type: 'Duration',
            defaultValue: '50 ms',
            description: 'Interval between visible grapheme increments.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.cursor',
            type: 'String?',
            defaultValue: "'|'",
            description: 'Cursor text; null removes it.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.cursorBlinkInterval',
            type: 'Duration',
            defaultValue: '530 ms',
            description: 'Visibility toggle interval when a cursor exists.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.style',
            type: 'TextStyle?',
            defaultValue: 'null',
            description: 'Applied to revealed text and cursor.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.onComplete',
            type: 'VoidCallback?',
            defaultValue: 'null',
            description: 'Called once after first full reveal, including reduced motion.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.repeat',
            type: 'bool',
            defaultValue: 'false',
            description: 'Delete and retype indefinitely when true.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.deleteSpeed',
            type: 'Duration?',
            defaultValue: 'null → speed',
            description: 'Interval between deletion steps during repeat.',
          ),
          DocApiEntry(
            name: 'NibTypewriter.delay',
            type: 'Duration',
            defaultValue: 'Duration.zero',
            description: 'Wait before typing starts.',
          ),
        ],
      ),
      DocSection(
        id: 'effects-api',
        heading: 'Gradient and reveal parameters',
        paragraphs: [
          'NibGradientText paints the whole text with a moving gradient. NibTextReveal clips a whole child. Their parameter names overlap only at key; duration measures one gradient sweep in the first widget and one reveal traversal in the second. The reveal controller field is currently inert even though it appears in the constructor.',
        ],
        api: [
          DocApiEntry(
            name: 'NibGradientText.text',
            type: 'String',
            defaultValue: 'required positional',
            description: 'Complete laid-out text.',
          ),
          DocApiEntry(
            name: 'NibGradientText.key',
            type: 'Key?',
            defaultValue: 'null',
            description: 'Flutter widget identity.',
          ),
          DocApiEntry(
            name: 'NibGradientText.gradient',
            type: 'Gradient',
            defaultValue: 'required',
            description: 'Colors masked onto painted glyphs.',
          ),
          DocApiEntry(
            name: 'NibGradientText.style',
            type: 'TextStyle?',
            defaultValue: 'null',
            description: 'Font metrics and styling; color is ignored.',
          ),
          DocApiEntry(
            name: 'NibGradientText.duration',
            type: 'Duration',
            defaultValue: '2000 ms',
            description: 'Time for one sweep.',
          ),
          DocApiEntry(
            name: 'NibGradientText.repeat',
            type: 'bool',
            defaultValue: 'true',
            description: 'Whether the sweep loops.',
          ),
          DocApiEntry(
            name: 'NibGradientText.direction',
            type: 'TextDirection',
            defaultValue: 'ltr',
            description:
                'Sweep travel direction, not paragraph layout direction.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.child',
            type: 'Widget',
            defaultValue: 'required',
            description: 'Entire block exposed by the clip.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.key',
            type: 'Key?',
            defaultValue: 'null',
            description: 'Flutter identity; remounting can replay entrance.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.direction',
            type: 'NibTextRevealDirection',
            defaultValue: 'left',
            description:
                'Clip edge: left, right, up from bottom, or down from top.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.duration',
            type: 'Duration',
            defaultValue: '500 ms',
            description: 'Time for the clip to reach full size.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.delay',
            type: 'Duration',
            defaultValue: 'Duration.zero',
            description: 'Wait before starting the reveal.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.curve',
            type: 'Curve',
            defaultValue: 'easeInOut',
            description: 'Easing curve of the clip factor.',
          ),
          DocApiEntry(
            name: 'NibTextReveal.controller',
            type: 'NibMotionController?',
            defaultValue: 'null',
            description: 'Declared but unconnected in current implementation; cannot replay the reveal.',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'path-motion',
    title: 'Path motion',
    summary: 'Draw a Path or move a child along its local geometry.',
    evidence: 'MotionNib/motion/lib/src/path/nib_draw_path.dart; MotionNib/motion/lib/src/path/nib_path_motion.dart',
    sections: [
      DocSection(
        id: 'path-shape',
        heading: 'Place the path in a bounded box',
        paragraphs: [
          'A Flutter Path contains coordinates, but it does not choose the surrounding widget’s size. Build it for the box that will display it, such as a 240 by 120 logical-pixel SizedBox, and check that every control point lies where you expect. NibDrawPath reveals the stroke from the beginning of the measured path; it does not move a child. NibPathMotion samples the path tangent at a zero-to-one progress fraction and paints its child there. rotate: true follows the tangent, so an icon’s original orientation matters.',
          'For a static status mark, give NibDrawPath a short path and let autoPlay start it on mount. For a moving icon that must follow scroll, supply an external MotionValue<double> progress. That disables the internal duration, curve, repeat, and autoPlay behavior. Clamp and dispose that value in the caller; the path widget reads it but does not take ownership. The controller play, pause, and restart commands affect only internally driven traversal.',
        ],
      ),
      DocSection(
        id: 'draw',
        heading: 'Reveal a stroke',
        paragraphs: [
          'NibDrawPath takes a Flutter Path and paints its stroke progressively. strokeWidth defaults to 2 logical pixels, duration to 1000 ms, curve to easeOut, and autoPlay to true. Use NibDrawPathController for play, pause, and restart; NibMotionController does not control this widget.',
        ],
        code: "// In build(); signaturePath uses this box’s local coordinates.\nNibDrawPath(\n  path: signaturePath,\n  color: Theme.of(context).colorScheme.primary,\n  strokeWidth: 3,\n  duration: const Duration(milliseconds: 1200),\n)",
        api: [
          DocApiEntry(
            name: 'path',
            type: 'Path',
            defaultValue: 'required',
            description: 'Geometry of the stroke to reveal.',
          ),
          DocApiEntry(
            name: 'strokeWidth',
            type: 'double',
            defaultValue: '2.0',
            description: 'Stroke width in logical pixels.',
          ),
          DocApiEntry(
            name: 'duration',
            type: 'Duration',
            defaultValue: '1000 ms',
            description: 'Time for one draw traversal.',
          ),
        ],
      ),
      DocSection(
        id: 'follow',
        heading: 'Move a child along the path',
        paragraphs: [
          'NibPathMotion measures the Path in the widget’s local coordinate space and positions its child at progress zero through one. rotate aligns the child to the path tangent when true. Its internal traversal defaults to 1000 ms, easeInOut, autoPlay true, and no repeat.',
          'Supply an external MotionValue<double> as progress to drive traversal yourself, such as from scroll. In that mode duration, curve, repeat, and autoPlay are ignored. The caller owns and disposes the external value; a NibPathMotionController can play, pause, or restart the internal traversal instead.',
        ],
        api: [
          DocApiEntry(
            name: 'progress',
            type: 'MotionValue<double>?',
            defaultValue: 'null',
            description: 'External zero-to-one driver when supplied.',
          ),
          DocApiEntry(
            name: 'rotate',
            type: 'bool',
            defaultValue: 'false',
            description: 'Align the child to the path tangent.',
          ),
          DocApiEntry(
            name: 'autoPlay',
            type: 'bool',
            defaultValue: 'true',
            description: 'Start internal traversal on mount.',
          ),
        ],
      ),
      DocSection(
        id: 'hands-on',
        heading: 'Check replay and a changed parent',
        paragraphs: [
          'Start with the stroke example above, add a NibDrawPathController owned by State, set autoPlay: false, and call restart from a button. Pause halfway, inspect the visible segment, then play again. In the current implementation, play starts a fresh ticker time origin after pause, so the next tick can jump back toward the beginning; test this before promising exact resume. Repeat with NibPathMotion and its separate NibPathMotionController. These controllers do not implement the NibMotionController target API because progress along a path is a different quantity from a NibAnim property target.',
          'Next change the parent box width while traversal is paused. The same Path coordinates may now occupy a different fraction of the available space; decide whether to rebuild the Path from the new constraints. Test the endpoint, child hit area, and tangent rotation. With reduced motion, the internally driven path shows its completed state. Keep the completed mark or destination understandable even when the travel is skipped.',
          'If nothing is visible, first draw the same Path with a static CustomPaint to confirm its bounds before debugging the animation clock. NibPathMotion follows the first measurable contour, so use a continuous contour for one trip or separate multiple trips into distinct widgets. Dispose any external progress value and any controller created by your State. Replacing a path while a controller is paused should be tested at both the old and new endpoints.',
        ],
      ),
      DocSection(
        id: 'geometry',
        heading: 'Test the path in its real constraints',
        paragraphs: [
          'A Path is a local geometry object. Verify its bounds and hit behavior inside the final parent layout, especially when a rotated child or transformed ancestor is involved. Keep a static endpoint meaningful when reduced motion skips traversal.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'navigation',
    title: 'Navigation motion',
    summary:
        'Animate route content or use the package’s bottom navigation shell.',
    evidence: 'MotionNib/motion/lib/src/routes/nib_routes.dart; MotionNib/motion/lib/src/nav/nib_scaffold.dart; MotionNib/motion/lib/src/nav/nib_screen_stack.dart',
    sections: [
      DocSection(
        id: 'routes',
        heading: 'Animate a page or modal route',
        paragraphs: [
          'NibPageRoute and NibModalRoute wrap route content in NibMotion. Their defaults fade and shift a page or scale a modal toward identity. The route duration controls route lifetime and barrier timing; the content transition can be spring-driven. Reverse route lifetime is extended to let the exit transition settle.',
          'NibPageRoute.backSwipe is off by default. When enabled, a start-edge drag can pop after crossing 40 percent of the page width or a fast release. Keep a non-gesture back action and test RTL and nested navigation in the host app.',
        ],
        code: "// Inside a button callback with a mounted context.\nNavigator.of(context).push(\n  NibPageRoute<void>(builder: (_) => const DetailsPage()),\n);",
        api: [
          DocApiEntry(
            name: 'builder',
            type: 'WidgetBuilder',
            defaultValue: 'required',
            description: 'Route content.',
          ),
          DocApiEntry(
            name: 'backSwipe',
            type: 'bool',
            defaultValue: 'false',
            description: 'Enable start-edge interactive pop on a page route.',
          ),
          DocApiEntry(
            name: 'duration',
            type: 'Duration',
            defaultValue: '350 ms',
            description: 'Route entrance lifetime, distinct from content spring settling.',
          ),
        ],
      ),
      DocSection(
        id: 'route-lifecycle',
        heading: 'Understand the route and content clocks',
        paragraphs: [
          'NibPageRoute builds content through builder and wraps it in motion between initial, animate, and exit. Its default page state starts transparent and 32 logical pixels lower, then settles at identity. NibModalRoute starts transparent and slightly smaller. Both default exit to their initial state. The route duration is 350 ms by default, while the content transition is spring-driven by default; reverse route lifetime is extended when needed so the exit spring can finish before removal.',
          'Keep navigation intent in the Navigator. The animation is a visual transition around that route, not a replacement for route state or back behavior. A page may remain mounted while another covers it when maintainState is true. Back-swipe is opt-in; it begins from a 24 logical-pixel start-edge strip, commits after 40 percent width or a 700 logical-pixel-per-second release toward back, and mirrors in RTL. Test a normal back button as well as the gesture.',
        ],
      ),
      DocSection(
        id: 'shell',
        heading: 'Use an animated tab shell',
        paragraphs: [
          'NibScaffold accepts equal-length screens and navItems lists and owns the selected tab index. NibScreenStack keeps screens mounted according to each NibNavScreen.keepAlive value and animates outgoing and incoming content. NibNavScreenTransition chooses fade, horizontal or vertical slide, scale, shared-axis, or none.',
          'A nav badge with null count is a dot, zero hides it, and counts above 99 display 99+. Test labels, focus order, and route state retention after repeated tab changes.',
        ],
      ),
      DocSection(
        id: 'tab-shell-exercise',
        heading: 'Choose route motion or tab motion',
        paragraphs: [
          'Use a page route when a screen is pushed onto a navigation stack and should be popped later. Use NibScaffold when the user switches between peer destinations. Give NibScaffold equal-length screens and navItems lists. NibNavScreen.keepAlive defaults to true, so decide whether a tab should retain forms, scroll position, and controllers while another is selected. A non-retained tab can rebuild from its initial state after return.',
          'Try the route snippet by pushing a details page, popping it, then repeating with backSwipe enabled. Next build two tab screens and switch while the first has a half-filled form. Observe whether the form persists with keepAlive true, then set it false. Exercise keyboard focus and screen-reader labels during these changes. When placing a floating navigation bar over content, account for the body inset or extendBodyBehindNavBar intentionally so controls are not obscured.',
        ],
      ),
      DocSection(
        id: 'shared',
        heading: 'Use shared-source handoffs carefully',
        paragraphs: [
          'The route sharedFrom key can animate content out of an existing source widget. The source must remain mounted below the route when measured; otherwise the route falls back to its normal initial and exit states. Treat that as a conditional visual enhancement, not a required navigation path.',
        ],
      ),
      DocSection(
        id: 'shared-exercise',
        heading: 'Make the shared source optional',
        paragraphs: [
          'Wrap a source thumbnail in NibSharedSource with a GlobalKey, then pass that key as sharedFrom to the pushed route. Keep the source mounted below the new route during both entry and return; the route measures it when transitioning. If the source disappears because a filter changes or a list item is disposed, the route uses its ordinary initial and exit states. Verify both paths. Do not make completion of a business action depend on the shared measurement succeeding.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'shaders',
    title: 'Shaders',
    summary:
        'Use bundled effects with asset and renderer fallbacks understood.',
    evidence: 'MotionNib/motion/pubspec.yaml; MotionNib/motion/lib/src/shaders/shader_loader.dart; MotionNib/motion/lib/src/shaders/nib_shimmer.dart; MotionNib/motion/lib/src/shaders/nib_dissolve.dart; MotionNib/motion/lib/src/shaders/nib_glass.dart',
    sections: [
      DocSection(
        id: 'custom-fragments',
        heading: 'Bring a custom fragment shader',
        paragraphs: [
          'Declare the .frag asset under flutter: shaders: in the consumer pubspec. Give NibShaderEffect exactly one asset key or compiled FragmentProgram. For an overlay, uniform floats are elapsed time when includeTime is true, then width and height when includeSize is true, followed by the supplied MotionValues in list order. Dispose values that you create.',
          'sampleChild transforms the child texture through ImageFilter.shader and requires a supported Impeller renderer. Its first uniform must be a vec2 size, includeSize must stay true, and OpenGL ES sampling needs the documented y-axis treatment. Unsupported or failed shader loading paints the child unchanged; use onLoadError for diagnostics. Reduced motion freezes automatic time at zero; externally driven uniforms remain your responsibility.',
        ],
        blocks: [
          DocLink(
            'Flutter fragment shader authoring',
            'https://docs.flutter.dev/ui/design/graphics/fragment-shaders',
          ),
        ],
      ),

      DocSection(
        id: 'related-effects',
        heading: 'Choose the right sampling boundary',
        paragraphs: [
          'Glass samples a backdrop where shader filters are supported. Water samples its designated Flutter background. Custom fragment effects use an explicit asset and uniforms; these are different rendering contracts.',
        ],
        blocks: [
          DocLink('Water surfaces and sampling policies', '/docs/motion/water'),
        ],
      ),

      DocSection(
        id: 'bundle',
        heading: 'Check shader assets in the consumer',
        paragraphs: [
          'The published 0.3.5 package declares six fragment shaders: shimmer, dissolve, gradient sweep, liquid glass, the nav indicator, and the water material. Water is part of the stable public API. NibShaderLoader loads package asset keys and caches compiled FragmentPrograms. NibMotionConfig.init can preload them; preloadAll swallows failures so startup can continue.',
          'Inspect a built consumer’s asset manifest and rendered result. A successful compile alone does not prove that a particular shader path ran.',
        ],
      ),
      DocSection(
        id: 'choose-effect',
        heading: 'Choose an effect for a real state',
        paragraphs: [
          'Use NibShimmer on a loading placeholder whose eventual content has roughly the same shape. Its child paints after the shimmer; an opaque child can hide the effect. Use a transparent SizedBox to see the sweep. Its speed is sweeps per second, angle is radians, and enabled false stops its ticker and shows the child without the overlay. A missing shader also leaves the child visible. Replace the placeholder with real content when loading ends; do not let the sweep masquerade as progress with a known percentage.',
          'NibDissolve is a one-shot reveal or removal around a child. direction decides whether it enters or leaves, duration is 500 ms by default, and onComplete runs when the effect finishes. If the shader is unavailable, the child still fades. NibGlass paints child content over a sampled backdrop with subtle tint and a rim. Its blurSigma is a backdrop blur amount, while thickness, refractiveIndex, chromaticAberration, and saturation tune the shader path. Those shader-only settings do not have identical visual meaning in the frosted fallback.',
        ],
      ),
      DocSection(
        id: 'widgets',
        heading: 'Choose the visual effect',
        paragraphs: [
          'NibShimmer makes a diagonal loading sweep, with speed 1.5 and enabled true by default. NibDissolve takes 500 ms by default and can run inward or outward; if its program is unavailable it falls back to a plain opacity fade. NibGlass uses a refractive path where shader filters are supported, otherwise a frosted blur, tint, and rim.',
        ],
        code: "// In build() while the content is loading.\nNibShimmer(\n  child: const SizedBox(width: 160, height: 20),\n)",
        api: [
          DocApiEntry(
            name: 'NibShimmer.speed',
            type: 'double',
            defaultValue: '1.5',
            description: 'Rate of the diagonal sweep.',
          ),
          DocApiEntry(
            name: 'NibDissolve.duration',
            type: 'Duration',
            defaultValue: '500 ms',
            description: 'Time for inward or outward dissolve.',
          ),
          DocApiEntry(
            name: 'NibGlass.blurSigma',
            type: 'double',
            defaultValue: '1.0',
            description: 'Backdrop blur strength in its surface effect.',
          ),
        ],
      ),
      DocSection(
        id: 'asset-check',
        heading: 'Inspect the built consumer',
        paragraphs: [
          'The published 0.3.5 package declares six fragment shader assets, including the water material alongside shimmer, dissolve, gradient sweep, liquid glass, and the navigation indicator. A package example can find an asset that a mispackaged consumer cannot, so inspect the final consumer asset manifest and load the effect there. A successful Dart or web compile is insufficient: serve the release build, observe the interaction, and record whether the shader path or fallback painted.',
          'For a hands-on check, render the shimmer snippet in an isolated app, toggle enabled at runtime, and compare it with reduced motion enabled. Then try NibDissolve with both directions. Capture the device, SDK, browser backend or renderer, and a screenshot or short recording. If raster frames spike, compare with the effect removed in the same profile workload before adjusting a visual parameter. A static fallback that leaves the content readable is preferable to a hidden control.',
          'Do not make a business state depend on the shader being available. A dissolve completion may be useful for coordinating a decorative transition, but the content must remain correct when the fallback fades instead. Keep contrast legible under NibGlass’s tint and blur, especially over changing backgrounds. If the browser and a physical device render different effects, document the two results separately; they may have different shader-filter support and raster cost. Check fallback appearance before adjusting shader-only parameters.',
        ],
      ),
      DocSection(
        id: 'limits',
        heading: 'Profile the renderer and reduced motion',
        paragraphs: [
          'Shaders can add raster cost even when the widget tree stays stable. Record browser backend or device renderer, GPU support, and fallback behavior in a profile run. The true NibGlass refraction path depends on shader filter support; reduced motion still needs a useful final state.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'physics',
    title: 'Physics drivers',
    summary: 'Understand the spring and inertia engines below the widgets.',
    evidence: 'MotionNib/motion/lib/src/physics/spring_description.dart; MotionNib/motion/lib/src/physics/spring_solver.dart; MotionNib/motion/lib/src/physics/inertia_solver.dart',
    sections: [
      DocSection(
        id: 'choose-spring',
        heading: 'Tune a spring without guessing duration',
        paragraphs: [
          'A spring travels according to position, velocity, and its mass, stiffness, and damping. Greater stiffness pulls harder; greater mass resists acceleration; damping removes energy and reduces overshoot. NibSpringDescription requires positive finite mass and stiffness and non-negative finite damping. Start with gentle, snappy, wobbly, or stiff before choosing raw numbers. fromDuration accepts a perceptual duration and bounce between -1 and 1; it converts them into a spring rather than imposing a hard animation deadline.',
          'For an ordinary widget, pass the description through NibTransition(spring: ...). The spring determines settling, so a duration and curve on that transition do not control its path. Open spring-retarget and move the target again before the first run settles. Observe that the value continues from its current position and velocity instead of jumping back to the original start. Compare that with spring-tween, where a tween’s duration and curve define a fixed time path.',
        ],
        code: "// In build(); moved is a bool held by State.\nNibMotion(\n  animate: moved\n      ? const NibAnim(x: 120)\n      : const NibAnim(x: 0),\n  transition: const NibTransition(\n    spring: NibSpringDescription.gentle,\n  ),\n  child: const Icon(Icons.circle),\n)",
      ),
      DocSection(
        id: 'spring',
        heading: 'Describe a spring',
        paragraphs: [
          'NibSpringDescription stores mass, stiffness, and damping and converts them to Flutter’s SpringDescription. Its defaults are 1, 100, and 10. Use the named gentle, snappy, wobbly, or stiff descriptions, or fromDuration for a perceptual duration and bounce.',
          'Most applications only need NibTransition(spring: ...). SpringSolver is the lower-level driver when you already own a MotionValue<double> and a TickerProvider.',
        ],
        api: [
          DocApiEntry(
            name: 'mass',
            type: 'double',
            defaultValue: '1.0',
            description: 'Positive finite inertia.',
          ),
          DocApiEntry(
            name: 'stiffness',
            type: 'double',
            defaultValue: '100.0',
            description: 'Positive finite pull toward the target.',
          ),
          DocApiEntry(
            name: 'damping',
            type: 'double',
            defaultValue: '10.0',
            description: 'Non-negative finite resistance.',
          ),
        ],
      ),
      DocSection(
        id: 'driver-contract',
        heading: 'Use direct drivers only when you own the value',
        paragraphs: [
          'SpringSolver accepts a TickerProvider, MotionValue<double>, and spring description. animateTo takes a target in the same units as that value; an optional from resets the start position, while initialVelocity is in those units per second. With no override it can inherit MotionValue.velocity across retargets. Its Future completes on settlement, supersession, stop, or dispose. The completion callback is for natural settlement, so do not use it as the only cleanup path after cancellation.',
          'InertiaSolver starts from the current value with a velocity, not a destination. Its optional min and max bounds can make it coast past an edge and spring back. drag defaults to 0.135; higher values closer to one coast farther. Keep local positions and local velocities in the same coordinate system before feeding either driver. For a drag receiver, 0.3.5 reports release velocity in receiver-local logical pixels per second. A global pointer velocity sent into a local simulation can produce a visibly wrong trajectory.',
        ],
      ),
      DocSection(
        id: 'drivers',
        heading: 'Drive a value directly',
        paragraphs: [
          'SpringSolver.animateTo moves a MotionValue toward a target and can carry velocity across a retarget. InertiaSolver uses a FrictionSimulation; its drag parameter defaults to 0.135 and animateTo starts with a supplied velocity. Both drivers expose stop and dispose.',
          'Keep velocity and position in matching units. The 0.3.5 drag path reports receiver-local logical pixels per second; do not feed a global pointer velocity into a local offset simulation without converting it.',
        ],
      ),
      DocSection(
        id: 'driver-exercise',
        heading: 'Test interruption and disposal',
        paragraphs: [
          'Create a MotionValue<double> in State and drive it with a SpringSolver using that State’s TickerProvider. Animate to one target, retarget midway, then call stop and inspect value and velocity. Dispose both solver and value when the owner leaves. Repeat with InertiaSolver and a bounded range, including a release just beyond the bound. Compare the final value with the edge; it should settle there after overshoot.',
          'This direct-driver exercise is useful when you need a value that is not naturally a NibMotion property. For a normal button, card, or route, the widget API already owns the ticker and property values. Prefer that higher-level path unless a measured use case requires independent simulation control.',
        ],
      ),
      DocSection(
        id: 'lifecycle',
        heading: 'Own the low-level lifecycle',
        paragraphs: [
          'A direct driver needs a TickerProvider, an owned MotionValue, and explicit disposal. Do not keep a ticker alive after its route leaves. Test cancellation and rapid retargeting as well as the single uninterrupted path.',
        ],
      ),
    ],
  ),
];
