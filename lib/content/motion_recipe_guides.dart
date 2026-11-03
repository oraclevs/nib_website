import 'site_content.dart';

/// Focused guides for public Motion families that need more than a signature.
const motionRecipeGuides = <DocArticle>[
  DocArticle(
    packageId: 'motion',
    id: 'presets',
    title: 'Presets and ready-made motion',
    summary: 'Choose an entrance, a repeating effect, or an action-triggered effect.',
    evidence: 'MotionNib/motion/lib/src/presets/nib_anim_presets.dart; MotionNib/motion/lib/src/presets/nib_shake.dart; MotionNib/motion/lib/src/presets/nib_flip.dart',
    sections: [
      DocSection(
        id: 'choose-the-shape',
        heading: 'Choose a state, a sequence, or a widget',
        paragraphs: [
          'NibAnimPresets has two kinds of values. fadeUp, fadeDown, fadeLeft, fadeRight, zoomIn, and zoomOut are single NibAnim starting states. Give one to NibMotion.initial and supply a resting animate target. shake, bounceIn, pulse, rubberBand, and wiggle are lists of NibKeyframe values. Give a list to NibMotion.keyframes when its whole sequence is the effect you want.',
          'The named widgets package some of these patterns with their timing and lifecycle. Start with one NibBounce for an entrance or NibRubberBand for a one-time emphasis. Keep a stable key so an unrelated parent rebuild does not restart an entrance. Copying the keyframe list is useful when the preset timing or intermediate poses need to change.',
        ],
        code: r'''NibMotion(
  initial: NibAnimPresets.fadeUp,
  animate: NibAnim.identity,
  child: const Text('Ready'),
)

const NibBounce(child: Text('Arrived'))''',
        api: [
          DocApiEntry(
            name: 'fadeUp',
            type: 'NibAnim',
            defaultValue: 'opacity 0, y 24',
            description: 'A starting pose for an entrance.',
          ),
          DocApiEntry(
            name: 'bounceIn',
            type: 'List<NibKeyframe>',
            defaultValue: 'six stages',
            description: 'A timed drop and bounce sequence.',
          ),
          DocApiEntry(
            name: 'NibBounce.duration',
            type: 'Duration',
            defaultValue: '800 ms',
            description: 'Time for the one-time entrance.',
          ),
        ],
      ),
      DocSection(
        id: 'repeat',
        heading: 'Reserve loops for ambient motion',
        paragraphs: [
          'NibFloat moves its child vertically by distance (10 logical pixels by default) on a repeating 1600 ms ease-in-out path. NibPulse repeats a small scale heartbeat over 900 ms. Neither is a substitute for a persistent status label. Put a loop around decoration or a small cue, and confirm the same screen communicates its state when reduced motion removes the travel.',
          'A longer duration slows the cycle; it does not change the distance of NibFloat. Keep float distance small enough that the painted child does not cover adjacent controls. A loop can be cheap at the widget level and still incur paint or raster work, so measure a screen that contains several repeating elements before adding them to a scrolling list.',
        ],
        code: r'''const NibFloat(
  distance: 8,
  duration: Duration(milliseconds: 1800),
  child: Icon(Icons.cloud),
)

const NibPulse(child: Icon(Icons.favorite))''',
      ),
      DocSection(
        id: 'trigger-shake',
        heading: 'Trigger a shake when validation fails',
        paragraphs: [
          'NibShake is deliberately idle until NibShakeController.shake runs. Create a controller in the State that owns the form, pass it to NibShake, and call shake only after a failed validation result. If you pass your own controller, dispose it when that State leaves; an internally created controller is owned by NibShake. The default shake duration is 600 ms.',
          'Keep the validation message visible and connected to the field. The shake is feedback, not an error explanation. An action can fail twice quickly, so test repeated calls and make sure the field still has a usable focus and hit target while it moves.',
        ],
        code: r'''final shake = NibShakeController(); // State field

// In build:
NibShake(controller: shake, child: const Text('Check this field'))

// On failed validation:
shake.shake();

// In State.dispose:
shake.dispose();''',
      ),
      DocSection(
        id: 'flip-and-stretch',
        heading: 'Let application state choose the face',
        paragraphs: [
          'NibFlip takes front and back widgets and an isFlipped boolean. Change that boolean from State; the default 600 ms flip rotates on the horizontal axis, and flipAxis can choose the vertical axis. Both faces should make sense at the end of the transition, including when reduced motion is active. A button outside the flip is a reliable way for touch and keyboard users to request the change.',
          'NibRubberBand runs its nonuniform scale sequence once over 1000 ms by default. Use it for a bounded emphasis rather than an ongoing status. The preset values are x/y scale factors, not a layout resize: neighbors keep their own slots. For an actual layout change, use the layout guide.',
        ],
        code: r'''NibFlip(
  isFlipped: showAnswer, // bool in State
  front: const Text('Question'),
  back: const Text('Answer'),
)

const NibRubberBand(child: Text('Saved'))''',
      ),
      DocSection(
        id: 'verify-presets',
        heading: 'Check the endpoint before the effect',
        paragraphs: [
          'Run each effect with reduced motion, then restore travel and interrupt it with navigation or disposal. The endpoint, label, and focus order should still be correct. A repeated visual effect can draw attention away from the task, so use a trigger only when it explains a real event. Continue to Keyframes to edit a preset sequence, or Springs to tune physical retargeting.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'motion-lists',
    title: 'Motion lists',
    summary:
        'Stagger a short list while keeping item identity and layout explicit.',
    evidence: 'MotionNib/motion/lib/src/list/nib_motion_list.dart; MotionNib/motion/lib/src/presence/nib_presence.dart',
    sections: [
      DocSection(
        id: 'what-the-wrapper-does',
        heading: 'One motion wrapper per child',
        paragraphs: [
          'NibMotionList wraps every child in a NibMotion and offsets each transition delay by its index. staggerDelay defaults to 50 ms. NibStaggerDirection.forward starts at index zero; reverse starts at the last child. Its initial, animate, exit, variants, transition, and controller settings are forwarded to the wrapped children. Keep the source list in State and build from stable item IDs.',
          'Without presenceEnabled, the list uses a Column with minimum main-axis size. A parent Row or grid is not preserved by this wrapper. If you need a different layout, put keyed NibMotion children in that layout directly and use parent variants with delayChildren and staggerChildren, or compose NibPresence with a layoutBuilder.',
        ],
        code: r'''NibMotionList(
  initial: const NibAnim(opacity: 0, y: 12),
  animate: NibAnim.identity,
  staggerDelay: const Duration(milliseconds: 75),
  children: [
    for (final item in items)
      Text(item.label, key: ValueKey(item.id)),
  ],
)''',
        api: [
          DocApiEntry(
            name: 'staggerDelay',
            type: 'Duration',
            defaultValue: '50 ms',
            description: 'Added per child index to the base transition delay.',
          ),
          DocApiEntry(
            name: 'staggerDirection',
            type: 'NibStaggerDirection',
            defaultValue: 'forward',
            description: 'Chooses which end starts first.',
          ),
          DocApiEntry(
            name: 'presenceEnabled',
            type: 'bool',
            defaultValue: 'false',
            description: 'Uses NibPresence for keyed exits when true.',
          ),
        ],
      ),
      DocSection(
        id: 'delay-math',
        heading: 'Know when each row starts',
        paragraphs: [
          'With the 75 ms delay above, the first row starts at the base transition delay, the second 75 ms later, and the third 150 ms later. Reversing direction changes which end gets those offsets; it does not reorder the data. A transition supplied to the list keeps its own duration, curve, spring, and delay. The stagger adds to that delay rather than replacing it.',
          'Change one thing at a time: run three keyed rows forward, reverse the stagger direction, then add a base delay. Watch the start order and check that each row settles at the same animate target. For a large list, a 50 ms offset multiplied by many items can make later content wait too long; limit stagger to a small visible group.',
        ],
      ),
      DocSection(
        id: 'presence-choice',
        heading: 'Decide whether removal needs an exit',
        paragraphs: [
          'Set presenceEnabled only when removed children need their exit animation. Every direct child then needs a unique non-null key, and exit must describe the departing pose. The wrapper passes its wrapped children to NibPresence. In this mode the default presence layout is a Stack, unlike the Column used when presenceEnabled is false. If the departing row must keep a vertical slot or siblings must reflow, build that composition explicitly with NibPresence.layoutBuilder or the layout factory.',
          'Remove an item from the source list first. Presence keeps the old keyed child mounted for the visual exit and prevents pointer, focus, and semantics interaction during departure. A callback after exit is a lifecycle event, not the place to decide that the source item no longer exists.',
        ],
        code: r'''NibMotionList(
  presenceEnabled: true,
  initial: const NibAnim(opacity: 0),
  animate: NibAnim.identity,
  exit: const NibAnim(opacity: 0, x: -24),
  children: [
    for (final item in items)
      Text(item.label, key: ValueKey(item.id)),
  ],
)''',
      ),
      DocSection(
        id: 'when-to-use-variants',
        heading: 'Use named variants for a parent-controlled group',
        paragraphs: [
          'NibMotionList is concise when each row shares the same target. Parent variants are better when the group has an open or closed state and each child needs its own named pose. Both approaches can stagger, but they calculate delay in different places: the list offsets each wrapped child directly, while the parent transition schedules children that inherit a variant.',
          'Do not make a list key from its current index when rows can move. That key follows the slot and can attach an exit or entrance to the wrong item. Continue to Variants and stagger for named parent states, or Layout and presence together when reflow is part of the interaction.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'viewport-motion',
    title: 'Viewport motion and replay',
    summary: 'Trigger on entry, track progress through a viewport, or replay on purpose.',
    evidence: 'MotionNib/motion/lib/src/viewport/nib_in_view_config.dart; MotionNib/motion/lib/src/viewport/nib_viewport_progress.dart; MotionNib/motion/lib/src/core/nib_motion_replay_scope.dart',
    sections: [
      DocSection(
        id: 'entry',
        heading: 'Trigger a temporary in-view state',
        paragraphs: [
          'NibMotion.whileInView applies a NibAnim while the widget meets its viewport test. NibInViewConfig.amount defaults to 0.5, so about half the widget must be visible. once defaults to false: after the widget leaves, it can return to animate or initial and trigger again. A positive margin expands the tested viewport; a negative margin shrinks it. The value is a fraction of the widget area, not pixels.',
          'The source widget still needs a useful resting state. For a one-time entrance, set once true so leaving the viewport does not hide content again. A NibScrollReveal wrapper has different defaults, amount 0.2 and once true, and is the short form when no custom in-view state is needed.',
        ],
        code: r'''NibMotion(
  initial: const NibAnim(opacity: 0, y: 24),
  whileInView: NibAnim.identity,
  viewport: const NibInViewConfig(amount: 0.5, once: true),
  child: const Text('Visible when reached'),
)''',
        api: [
          DocApiEntry(
            name: 'amount',
            type: 'double',
            defaultValue: '0.5',
            description: 'Visible fraction needed for whileInView.',
          ),
          DocApiEntry(
            name: 'once',
            type: 'bool',
            defaultValue: 'false',
            description: 'Keep the in-view state after first entry when true.',
          ),
          DocApiEntry(
            name: 'margin',
            type: 'EdgeInsets',
            defaultValue: 'EdgeInsets.zero',
            description: 'Expand or shrink the tested viewport bounds.',
          ),
        ],
      ),
      DocSection(
        id: 'continuous',
        heading: 'Use continuous progress for a parallax-style response',
        paragraphs: [
          'NibViewportProgress reports two MotionValues through an owned NibViewportProgressController. progress is zero when the leading edge is about to enter and one after the trailing edge has left; visibleFraction measures how much area is currently inside. Wrap the measured child with NibViewportProgress, derive a paint value with mapRange, and pass that value to NibMotionValues.',
          'Create the controller and derived values once in State and dispose derived values before the controller. The widget observes all ancestor Scrollables and uses the nearest viewport for measurement. On reversed scroll axes, progress is mirrored relative to the usual forward reading. Test a nested scroll view rather than assuming the outer page alone decides visibility.',
        ],
        code: r'''// State fields:
final viewport = NibViewportProgressController();
late final opacity = viewport.progress.mapRange(
  [0, 0.3, 0.7, 1], [0, 1, 1, 0],
);

// In build:
NibViewportProgress(
  controller: viewport,
  child: NibMotion(
    motionValues: NibMotionValues(opacity: opacity),
    child: const Text('Through the window'),
  ),
)

// In State.dispose: opacity.dispose(); viewport.dispose();''',
      ),
      DocSection(
        id: 'replay',
        heading: 'Replay an entrance deliberately',
        paragraphs: [
          'A viewport trigger depends on visibility. NibMotionReplaySignal is different: its replay call asks listening descendants under NibMotionReplayScope to run their entrance again. The signal records an optional delay and notifies immediately; each listening NibMotion applies that delay before playback. NibScreenStack can use this mechanism when a tab transition asks to retrigger page animations.',
          'Create one signal in State, put the scope above the intended descendants, and call replay from a clear event such as a Replay button. Dispose the signal with the State. Avoid a replay on every build; that would keep resetting the same content and may interrupt focus or reading.',
        ],
        code: r'''final replaySignal = NibMotionReplaySignal(); // State field

// In build:
NibMotionReplayScope(
  signal: replaySignal,
  child: NibMotion(
    initial: const NibAnim(opacity: 0),
    animate: NibAnim.identity,
    child: const Text('Ready again'),
  ),
)

// On a user action: replaySignal.replay();
// In State.dispose: replaySignal.dispose();''',
      ),
      DocSection(
        id: 'viewport-checks',
        heading: 'Check the scroller that actually moves the child',
        paragraphs: [
          'Scroll an inner list while its outer page stays still, then move the outer page. Observe entry, exit, and progress separately. A child may be outside either viewport, so a screen-only check would give the wrong answer. Keep the final content available when reduced motion jumps to the endpoint. Continue to Scroll motion for ScrollController mapping and reveal behavior.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'drag-and-drop',
    title: 'Drag, pinch, and swipe',
    summary:
        'Use a standalone gesture widget when direct manipulation is the job.',
    evidence: 'MotionNib/motion/lib/src/gestures/nib_draggable.dart; MotionNib/motion/lib/src/gestures/nib_pinch.dart; MotionNib/motion/lib/src/gestures/nib_swipe_dismiss.dart',
    sections: [
      DocSection(
        id: 'choose-owner',
        heading: 'Choose one gesture owner',
        paragraphs: [
          'NibMotion.drag belongs on a NibMotion that also needs animate, whileTap, or other motion states. NibDraggable is a focused wrapper for moving a child directly. It owns two motion values for its painted x and y offsets, and dragging does not rebuild the child on every pointer update. Avoid nesting both handlers on the same pointer target; the gesture arena still has to choose a winner.',
          'NibDraggable.bounds is a Rect of offset limits from the resting position. axis locks one dimension. snapBack defaults to false, so a release stays at its offset. Set snapBack true to spring to zero or to snapTarget; spring defaults to NibSpringDescription.gentle. onDragEnd receives the final offset and velocity in receiver-local logical pixels per second.',
        ],
        code: r'''NibDraggable(
  axis: Axis.horizontal,
  bounds: const Rect.fromLTRB(-80, 0, 80, 0),
  snapBack: true,
  child: const Icon(Icons.drag_indicator),
)''',
      ),
      DocSection(
        id: 'pinch',
        heading: 'Bound a pinch before using it',
        paragraphs: [
          'NibPinch scales around the center of its child. minScale defaults to 0.5, maxScale to 4, and initialScale to 1. It clamps updates into that range. With snapBackOnRelease false, the chosen scale remains after the gesture; with true, a spring returns to initialScale. onScaleChanged reports the current scale when the gesture updates.',
          'A zoomed child can paint beyond its original slot. Leave enough space or clip deliberately, and test hit targets at the transformed edge. A pinch is hard to discover and unavailable to some users, so provide another way to reach any important zoom state.',
        ],
        code: r'''NibPinch(
  minScale: 1,
  maxScale: 2,
  snapBackOnRelease: true,
  child: const FlutterLogo(size: 80),
)''',
      ),
      DocSection(
        id: 'swipe',
        heading: 'Remove the model item after dismissal',
        paragraphs: [
          'NibSwipeDismiss compares the released offset with dismissThreshold times the widget extent. The default threshold is 0.5. A short swipe springs home; a qualifying swipe animates offscreen and then calls onDismissed. Remove the item from your source list in that callback. DismissDirection.horizontal accepts either side; startToEnd and endToStart restrict horizontal direction, while vertical allows both vertical directions.',
          'The optional background sits behind the child while swiping. It can explain the action, but the visible item also needs an accessible delete or archive control if dismissal has meaning. Test repeated input while the offscreen animation is pending so the same item cannot trigger a second destructive action.',
        ],
        code: r'''NibSwipeDismiss(
  dismissDirection: DismissDirection.endToStart,
  dismissThreshold: 0.4,
  onDismissed: () => setState(() => items.remove(item)),
  child: Text(item.label),
)''',
      ),
      DocSection(
        id: 'geometry-and-lifecycle',
        heading: 'Check geometry and interruption',
        paragraphs: [
          'Try a drag under a scrolling parent, release before the spring settles, and start another gesture. Check the painted position, pointer target, keyboard focus, and semantics during motion. The 0.3.5 source verifies selected affine transforms; perspective and near-singular transforms are outside its documented geometry contract. A test that only avoids an exception does not establish that the hit target follows the painted child.',
          'These wrappers own their internal values and solvers. Your State still owns the item list and any external controller it creates. For list reordering rather than a free dragged offset, use NibReorderable or a Flutter reorderable list with layout motion. Continue to Gestures for temporary hover, press, focus, and NibMotion.drag states.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'animation-sequences',
    title: 'Animation sequences',
    summary: 'Queue targets, waits, callbacks, and a deliberate repeat mode.',
    evidence: 'MotionNib/motion/lib/src/timeline/nib_animation_sequence.dart; MotionNib/motion/lib/src/core/nib_motion_controller.dart',
    sections: [
      DocSection(
        id: 'single-controller',
        heading: 'Keep the sequence beside its controller',
        paragraphs: [
          'NibAnimationSequence records steps for one NibMotionController. Create the controller and sequence in the State that owns the widget, attach the controller to NibMotion, then add animate targets. animate starts the controller toward a NibAnim and waits for that step to finish; wait adds a Duration pause; call runs a synchronous callback at that point. play executes the recorded steps in order.',
          'Each animate step can take its own NibTransition. If omitted, the attached NibMotion supplies its default. The sequence does not create or dispose the controller. On route disposal, stop and dispose the sequence, then dispose the controller. A controller may be attached to several widgets, but this builder is easiest to reason about when one visible object owns the story.',
        ],
        code: r'''final controller = NibMotionController(); // State field
late final sequence = NibAnimationSequence(controller)
  .animate(const NibAnim(x: -40))
  .wait(const Duration(milliseconds: 100))
  .animate(
    const NibAnim(x: 40),
    transition: NibTransition.springGentle,
  );

// In build: NibMotion(controller: controller, child: const Icon(Icons.circle))
// On Play: await sequence.play();
// In State.dispose: sequence.dispose(); controller.dispose();''',
        api: [
          DocApiEntry(
            name: 'animate',
            type: 'NibAnim + NibTransition?',
            defaultValue: 'transition null',
            description: 'Queue one controller target and wait for completion.',
          ),
          DocApiEntry(
            name: 'wait',
            type: 'Duration',
            defaultValue: 'required',
            description: 'Pause before the next step.',
          ),
          DocApiEntry(
            name: 'call',
            type: 'VoidCallback',
            defaultValue: 'required',
            description: 'Run synchronous work at this point.',
          ),
          DocApiEntry(
            name: 'loop',
            type: 'count + NibLoopMode',
            defaultValue: 'no loop',
            description: 'Repeat finite times or until stopped.',
          ),
        ],
      ),
      DocSection(
        id: 'repeat-modes',
        heading: 'Choose what repeat means',
        paragraphs: [
          'Without loop, play runs once. loop(3) runs the recorded steps three times in restart mode. NibLoopMode.pingPong alternates forward passes with reverse passes through earlier animate targets; wait and call steps run in both directions. NibLoopMode.seamless is like restart except it skips the first animate step on later passes when its target exactly equals the final animate target. That removes a dead step at the seam, not an arbitrary pause.',
          'Calling loop with no count repeats forever. The Future returned by that play never completes, even after stop, so do not await it in an action that must finish. Keep a visible Stop control or stop on disposal. Test a finite two-target sequence first, then add a loop so the endpoint behavior is clear.',
        ],
        code: r'''final sequence = NibAnimationSequence(controller)
  .animate(const NibAnim(x: -40))
  .animate(const NibAnim(x: 40))
  .loop(3, NibLoopMode.pingPong);

await sequence.play(); // Finite: completes after three passes.''',
      ),
      DocSection(
        id: 'cancel',
        heading: 'Stop between steps',
        paragraphs: [
          'stop prevents later steps from running and stops the controller. An already started wait or animation may finish its current run before the sequence exits, so do not use stop as a promise that a callback already entered will be undone. A second play call during an active run follows that same run instead of starting two concurrent copies.',
          'If a later screen replaces the owner while the sequence is waiting, guard application callbacks with mounted and dispose the sequence with the State. Use the Timeline guide for several independently scheduled controllers. Use Keyframes when one widget needs intermediate poses along one timed track.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'motion',
    id: 'routes',
    title: 'Page and modal routes',
    summary: 'Move a Navigator route while keeping dismissal and state ownership clear.',
    evidence: 'MotionNib/motion/lib/src/routes/nib_routes.dart; MotionNib/motion/lib/src/routes/nib_shared_source.dart',
    sections: [
      DocSection(
        id: 'push-page',
        heading: 'Push a page with a visible endpoint',
        paragraphs: [
          'NibPageRoute is a PageRoute. Pass a builder to Navigator.push and let the Navigator own the route lifetime. Its default content starts transparent and 32 logical pixels lower, then reaches NibAnim.identity. Popping uses the starting pose as the default exit. The default transition is a spring. duration controls the route entrance; reverseDuration is a minimum exit lifetime and grows if the spring needs longer to settle.',
          'Keep page data and decisions in the destination widget as usual. A route animation should not become the only way to understand which page is open. Press Back during entrance and check that the content heads toward its exit without briefly returning to the start pose.',
        ],
        code: r'''Navigator.of(context).push(
  NibPageRoute<void>(
    builder: (_) => const Scaffold(
      body: Center(child: Text('Details')),
    ),
  ),
);''',
        api: [
          DocApiEntry(
            name: 'backSwipe',
            type: 'bool',
            defaultValue: 'false',
            description: 'Enable the start-edge interactive pop gesture.',
          ),
          DocApiEntry(
            name: 'parallax',
            type: 'double',
            defaultValue: '0.3',
            description: 'Fractional shift of the covered route during a back swipe above it.',
          ),
          DocApiEntry(
            name: 'maintainState',
            type: 'bool',
            defaultValue: 'true',
            description: 'Keep the covered page state alive.',
          ),
        ],
      ),
      DocSection(
        id: 'back-swipe',
        heading: 'Test an interrupted back swipe',
        paragraphs: [
          'backSwipe is off by default. When enabled, a drag from the start-edge strip follows the pointer; releasing beyond 40 percent of page width or with a fast fling pops, while a shorter gesture springs back. The direction mirrors in right-to-left layouts. parallax shifts the route below only during that interactive gesture, and zero disables the effect.',
          'Test a cancelled drag, a committed drag, a fast fling, and a pop while entrance is still running. Check the edge hit target against any control placed there. A compiled route cannot establish physical touch behavior, so perform these interactions on the platform you claim to support.',
        ],
      ),
      DocSection(
        id: 'modal',
        heading: 'Use a modal route for a dialog result',
        paragraphs: [
          'NibModalRoute is a PopupRoute with a barrier, Navigator dismissal, and a result type. showNibDialog pushes one on the root Navigator by default. Its initial pose is transparent at 92 percent scale; its default duration and reverseDuration are 350 and 250 ms. The barrier is dismissible by default, so turn that off when the host action requires an explicit decision.',
          'The builder supplies the content. Put confirmation semantics, focus order, and the real action in that content; the route only animates it. A result from Navigator.pop returns through the Future. Check that a pending confirmation is invalidated when its underlying state changes, rather than treating the animation as authorization.',
        ],
        code: r'''final confirmed = await showNibDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) => Center(
    child: TextButton(
      onPressed: () => Navigator.of(dialogContext).pop(true),
      child: const Text('Confirm'),
    ),
  ),
);''',
      ),
      DocSection(
        id: 'shared-source',
        heading: 'Mark the source of a shared transition',
        paragraphs: [
          'Give a NibSharedSource a GlobalKey and pass the same key as sharedFrom to NibPageRoute, NibModalRoute, or showNibDialog. The source keeps its layout space while the route stands in for it, then reappears when the route leaves. Without the wrapper, a plain GlobalKey can still provide geometry, but its source remains visible beneath the route.',
          'Keep the source mounted long enough for the transition to measure it. A shared pose depends on rectangles across the source and destination; perspective, nearly singular transforms, and clipped overlays are outside the current verified geometry contract. Test focus and hit targets when the source is hidden and restored.',
        ],
        code: r'''final sourceKey = GlobalKey(); // Keep in State.

NibSharedSource(
  sourceKey: sourceKey,
  child: const Icon(Icons.photo),
)

// In a button callback:
Navigator.of(context).push(
  NibPageRoute<void>(
    sharedFrom: sourceKey,
    builder: (_) => const Scaffold(body: Icon(Icons.photo)),
  ),
);''',
      ),
      DocSection(
        id: 'route-next',
        heading: 'Choose route motion for a navigation job',
        paragraphs: [
          'Use NibScreenStack and NibNavBar for persistent tab screens; use NibPageRoute for a pushed page and NibModalRoute for an overlay with a result. These solve different ownership problems. Continue to Navigation for tab state retention and to Accessibility for reduced motion and focus checks.',
        ],
      ),
    ],
  ),
];
