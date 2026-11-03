import 'examples/motion_entrance_example.dart';
import 'examples/motion_workflow_examples.dart';
import 'examples/motion_physics_example.dart';
import 'examples/motion_family_examples.dart';
import 'examples/motion_composition_examples.dart';
import 'examples/motion_shader_example.dart';
import 'examples/motion_navigation_example.dart';
import 'examples/motion_path_example.dart';
import 'examples/motion_text_example.dart';
import 'examples/motion_timeline_example.dart';
import 'examples/motion_controller_example.dart';
import 'examples/motion_variants_example.dart';
import 'examples/motion_transitions_example.dart';

import 'package:flutter/widgets.dart';
import 'package:nib_motion/nib_motion.dart';

import 'examples/components_button_example.dart';
import 'examples/components_form_example.dart';
import 'examples/components_theme_example.dart';
import 'examples/genui_fixture_example.dart';
import 'examples/motion_accessibility_example.dart';
import 'examples/motion_gestures_example.dart';
import 'examples/motion_intro_example.dart';
import 'examples/motion_keyframes_example.dart';
import 'examples/motion_layout_example.dart';
import 'examples/motion_presence_example.dart';
import 'examples/motion_scroll_example.dart';
import 'examples/motion_spring_example.dart';
import 'examples/motion_values_example.dart';

/// The preview is built from the same Dart file served as [sourceAsset].
/// Source can be loaded with `rootBundle.loadString(example.sourceAsset)`.
class DocExample {
  const DocExample({
    required this.title,
    required this.description,
    required this.sourceAsset,
    required this.widgetClass,
    required String? playgroundRoute,
    required this.previewBuilder,
    this.constructorArguments = '',
  }) : relatedPlaygroundRoute = playgroundRoute;

  final String title;
  final String description;
  final String sourceAsset;

  /// Public zero-argument widget constructor for a generated runnable launcher.
  final String widgetClass;
  final String? relatedPlaygroundRoute;
  String get playgroundId {
    final name = widgetClass
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '-${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^-'), '');
    final configuration = constructorArguments
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')
        .replaceFirst(RegExp(r'-$'), '')
        .toLowerCase();
    return 'guide-$name${configuration.isEmpty ? '' : '-$configuration'}';
  }

  String get playgroundRoute => '/playground/$playgroundId';
  final Widget Function() previewBuilder;
  final String constructorArguments;
  String get identity => '$sourceAsset|$widgetClass|$constructorArguments';

  Widget buildPreview() => previewBuilder();
}

final _intro = DocExample(
  title: 'An idea worth saving',
  description: 'Save an idea, then undo before the spring settles. Position, scale and rotation respond to the same application state.',
  sourceAsset: 'lib/docs/examples/motion_intro_example.dart',
  widgetClass: 'MotionIntroExample',
  playgroundRoute: '/playground/spring-retarget',
  previewBuilder: MotionIntroExample.new,
);

final _entrance = DocExample(
  title: 'Give an idea its entrance',
  description: 'A headline arrives first, followed by two supporting details. Replay to see opacity, travel and timing work together.',
  sourceAsset: 'lib/docs/examples/motion_entrance_example.dart',
  widgetClass: 'MotionEntranceExample',
  playgroundRoute: null,
  previewBuilder: MotionEntranceExample.new,
);

final _spring = DocExample(
  title: 'Retarget a spring',
  description: 'Move the target before the spring settles. The response comes from NibMotion, with an explicit stiffness and damping.',
  sourceAsset: 'lib/docs/examples/motion_spring_example.dart',
  widgetClass: 'MotionSpringExample',
  playgroundRoute: '/playground/spring-retarget',
  previewBuilder: MotionSpringExample.new,
);

final _keyframes = DocExample(
  playgroundRoute: null,
  title: 'Three objects, one choreography',
  description: 'Follow three tiles from scattered positions through a crossing to an aligned row. Change duration or inspect each keyframe stage.',
  sourceAsset: 'lib/docs/examples/motion_keyframes_example.dart',
  widgetClass: 'MotionKeyframesExample',
  previewBuilder: MotionKeyframesExample.new,
);

final _values = DocExample(
  title: 'One value, two outputs',
  description: 'Drag the slider to drive position and opacity through derived MotionValues. This shows data flow, not a benchmark.',
  sourceAsset: 'lib/docs/examples/motion_values_example.dart',
  widgetClass: 'MotionValuesExample',
  playgroundRoute: '/playground/linked-objects',
  previewBuilder: MotionValuesExample.new,
);

final _presence = DocExample(
  title: 'Let an exit finish',
  description: 'Add and remove keyed children. NibPresence keeps a departing tile until its NibMotion exit completes.',
  sourceAsset: 'lib/docs/examples/motion_presence_example.dart',
  widgetClass: 'MotionPresenceExample',
  playgroundRoute: '/playground/presence-reflow',
  previewBuilder: MotionPresenceExample.new,
);

final _layout = DocExample(
  title: 'Reorder with layout motion',
  description: 'Move the first tile to the end; keyed NibMotion children animate their changed layout positions.',
  sourceAsset: 'lib/docs/examples/motion_layout_example.dart',
  widgetClass: 'MotionLayoutExample',
  playgroundRoute: '/playground/keyed-reorder',
  previewBuilder: MotionLayoutExample.new,
);

final _gestures = DocExample(
  title: 'Touch, hover and drag',
  description: 'Drag horizontally or use the button. NibMotion supplies the hover, press and drag response.',
  sourceAsset: 'lib/docs/examples/motion_gestures_example.dart',
  widgetClass: 'MotionGesturesExample',
  playgroundRoute: '/playground/bounded-drag',
  previewBuilder: MotionGesturesExample.new,
);

final _scroll = DocExample(
  title: 'Reveal in a viewport',
  description: 'Scroll the inner window; NibScrollReveal runs when the final card enters view.',
  sourceAsset: 'lib/docs/examples/motion_scroll_example.dart',
  widgetClass: 'MotionScrollExample',
  playgroundRoute: '/playground/viewport-reveal',
  previewBuilder: MotionScrollExample.new,
);

final _access = DocExample(
  title: 'Keep the result, reduce the travel',
  description: 'Toggle reduced motion and complete the task. NibMotion applies the target immediately when reduction is active.',
  sourceAsset: 'lib/docs/examples/motion_accessibility_example.dart',
  widgetClass: 'MotionAccessibilityExample',
  playgroundRoute: null,
  previewBuilder: MotionAccessibilityExample.new,
);

final _button = DocExample(
  title: 'A control with real state',
  description: 'NibButton updates a local counter. The outline reset becomes disabled at zero.',
  sourceAsset: 'lib/docs/examples/components_button_example.dart',
  widgetClass: 'ComponentsButtonExample',
  playgroundRoute: '/playground/hover-press',
  previewBuilder: ComponentsButtonExample.new,
);

final _form = DocExample(
  title: 'Validate inside a Flutter Form',
  description: 'NibInput checks a name, NibSwitch changes a choice, and the host handles the result.',
  sourceAsset: 'lib/docs/examples/components_form_example.dart',
  widgetClass: 'ComponentsFormExample',
  playgroundRoute: '/playground/form-validation',
  previewBuilder: ComponentsFormExample.new,
);

final _theme = DocExample(
  title: 'Change a NibTheme token',
  description: 'Switch between two dark accent colors. The actual NibButton reads the host ThemeExtension.',
  sourceAsset: 'lib/docs/examples/components_theme_example.dart',
  widgetClass: 'ComponentsThemeExample',
  playgroundRoute: null,
  previewBuilder: ComponentsThemeExample.new,
);

final _genui = DocExample(
  title: 'Replay a bounded local fixture',
  description: 'Step through three checked A2UI v0.9.1 subset frames. A native form and a guarded synthetic action run entirely locally. No AI or backend request is made.',
  sourceAsset: 'lib/docs/examples/genui_fixture_example.dart',
  widgetClass: 'GenUiFixtureExample',
  playgroundRoute: null,
  previewBuilder: GenUiFixtureExample.new,
);

final _transitions = DocExample(
  title: 'Compare spring and tween',
  description: 'Change the target mid-flight. The left tile uses a spring; the right tile follows a fixed-duration transition.',
  sourceAsset: 'lib/docs/examples/motion_transitions_example.dart',
  widgetClass: 'MotionTransitionsExample',
  playgroundRoute: '/playground/spring-tween',
  previewBuilder: MotionTransitionsExample.new,
);

final _variants = DocExample(
  title: 'One state, staggered children',
  description: 'Toggle the parent variant. Each child inherits the named state and starts after its own stagger offset.',
  sourceAsset: 'lib/docs/examples/motion_variants_example.dart',
  widgetClass: 'MotionVariantsExample',
  playgroundRoute: '/playground/variant-orchestration',
  previewBuilder: MotionVariantsExample.new,
);

final _controller = DocExample(
  title: 'Start, stop, set',
  description: 'Use the same controller to retarget, freeze or place the tile immediately.',
  sourceAsset: 'lib/docs/examples/motion_controller_example.dart',
  widgetClass: 'MotionControllerExample',
  playgroundRoute: null,
  previewBuilder: MotionControllerExample.new,
);

final _timeline = DocExample(
  title: 'Direct a two-part entrance',
  description: 'Play the timed sequence, cancel it, or scrub through its explicit starting and target states.',
  sourceAsset: 'lib/docs/examples/motion_timeline_example.dart',
  widgetClass: 'MotionTimelineExample',
  playgroundRoute: null,
  previewBuilder: MotionTimelineExample.new,
);

final _text = DocExample(
  title: 'Words, characters and lines',
  description: 'Choose a unit, stagger origin and effect. Change the timing, edit the sentence and replay the result.',
  sourceAsset: 'lib/docs/examples/motion_text_example.dart',
  widgetClass: 'MotionTextExample',
  playgroundRoute: null,
  previewBuilder: MotionTextExample.new,
);

final _path = DocExample(
  title: 'Follow a curve',
  description: 'Move the progress slider. Toggle tangent rotation to see position and orientation respond independently.',
  sourceAsset: 'lib/docs/examples/motion_path_example.dart',
  widgetClass: 'MotionPathExample',
  playgroundRoute: null,
  previewBuilder: MotionPathExample.new,
);

final _navigation = DocExample(
  title: 'Keep screen state',
  description: 'Use the native Nib navigation bar and verify that each screen retains its counter.',
  sourceAsset: 'lib/docs/examples/motion_navigation_example.dart',
  widgetClass: 'MotionNavigationExample',
  playgroundRoute: null,
  previewBuilder: MotionNavigationExample.new,
);

final _shader = DocExample(
  title: 'Inspect the glass surface',
  description: 'Adjust blur and read the renderer capability. A supported shader filter and a frosted fallback are different paths.',
  sourceAsset: 'lib/docs/examples/motion_shader_example.dart',
  widgetClass: 'MotionShaderExample',
  playgroundRoute: null,
  previewBuilder: MotionShaderExample.new,
);

final _physics = DocExample(
  title: 'Drive a MotionValue with a solver',
  description: 'Retarget before the tile arrives. Change the spring and observe how its response changes.',
  sourceAsset: 'lib/docs/examples/motion_physics_example.dart',
  widgetClass: 'MotionPhysicsExample',
  playgroundRoute: null,
  previewBuilder: MotionPhysicsExample.new,
);

final _presets = DocExample(
  title: 'Choose a ready-made effect',
  description: 'Compare bounce, float, pulse, shake, flip and rubber band. Trigger each effect with its real API.',
  sourceAsset: 'lib/docs/examples/motion_family_examples.dart',
  widgetClass: 'MotionPresetExample',
  playgroundRoute: null,
  previewBuilder: MotionPresetExample.new,
);
final _motionList = DocExample(
  title: 'Stagger a motion list',
  description: 'Change direction and delay, then replay the same keyed list.',
  sourceAsset: 'lib/docs/examples/motion_family_examples.dart',
  widgetClass: 'MotionListExample',
  playgroundRoute: null,
  previewBuilder: MotionListExample.new,
);
final _gestureTools = DocExample(
  title: 'Pinch and swipe',
  description: 'Try native gesture wrappers and their alternate actions. Touch checks on physical devices remain separate.',
  sourceAsset: 'lib/docs/examples/motion_family_examples.dart',
  widgetClass: 'MotionGestureToolsExample',
  playgroundRoute: null,
  previewBuilder: MotionGestureToolsExample.new,
);
final _routes = DocExample(
  title: 'Push and pop a route',
  description: 'Use a real nested Navigator with NibPageRoute. Change transitions and return to the original screen.',
  sourceAsset: 'lib/docs/examples/motion_family_examples.dart',
  widgetClass: 'MotionRoutesExample',
  playgroundRoute: null,
  previewBuilder: MotionRoutesExample.new,
);

final _loop = DocExample(
  title: 'Loop modes and cancellation',
  description: 'Compare three host-controlled passes with native unlimited looping. Reverse direction or stop midway.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionLoopExample',
  playgroundRoute: null,
  previewBuilder: MotionLoopExample.new,
);
final _drawPath = DocExample(
  title: 'Draw and follow the same path',
  description: 'Compare stroke drawing with a child following the path. Pause or restart both clocks.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionDrawPathExample',
  playgroundRoute: null,
  previewBuilder: MotionDrawPathExample.new,
);
final _scrollProgress = DocExample(
  title: 'Continuous scroll-driven motion',
  description: 'One scroll offset drives progress, translation and rotation. Use buttons or the reading pane.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionScrollProgressExample',
  playgroundRoute: null,
  previewBuilder: MotionScrollProgressExample.new,
);
final _dragAxes = DocExample(
  title: 'Drag axes and release behavior',
  description: 'Compare x, y and both axes. Change elastic resistance, constraints and release settings.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionDragAxesExample',
  playgroundRoute: null,
  previewBuilder: MotionDragAxesExample.new,
);
final _staggerOrder = DocExample(
  title: 'Change the stagger order',
  description:
      'Compare start, end and center timing with the same children and delay.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionStaggerOrderExample',
  playgroundRoute: null,
  previewBuilder: MotionStaggerOrderExample.new,
);
final _presenceModes = DocExample(
  title: 'Keep or pop the exit layout',
  description: 'Switch native presence layout modes and remove keyed items during motion.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionPresenceModesExample',
  playgroundRoute: null,
  previewBuilder: MotionPresenceModesExample.new,
);
final _transform = DocExample(
  title: 'Combine transform channels',
  description: 'Drive translation, scale, rotation and opacity together, then inspect each channel.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionTransformExample',
  playgroundRoute: null,
  previewBuilder: MotionTransformExample.new,
);
final _viewportReplay = DocExample(
  title: 'Viewport entry and deliberate replay',
  description: 'Compare once-only entry, re-entry and a replay signal in a bounded scrolling panel.',
  sourceAsset: 'lib/docs/examples/motion_composition_examples.dart',
  widgetClass: 'MotionViewportReplayExample',
  playgroundRoute: null,
  previewBuilder: MotionViewportReplayExample.new,
);

final _water = DocExample(
  title: 'Water sampling and fallback',
  description: 'Disturb a real Flutter background; pause, reset and inspect the selected rendering path.',
  sourceAsset: 'lib/docs/examples/motion_workflow_examples.dart',
  widgetClass: 'MotionWaterExample',
  playgroundRoute: null,
  previewBuilder: MotionWaterExample.new,
);
final _tuner = DocExample(
  title: 'Tune a spring',
  description: 'Change physical or duration/bounce parameters, replay and copy the spring configuration.',
  sourceAsset: 'lib/docs/examples/motion_workflow_examples.dart',
  widgetClass: 'MotionTunerExample',
  playgroundRoute: null,
  previewBuilder: MotionTunerExample.new,
);
final _sharedLayout = DocExample(
  title: 'Shared layout handoff',
  description: 'Detach one keyed placement and mount another with the same layoutId in a common scope.',
  sourceAsset: 'lib/docs/examples/motion_workflow_examples.dart',
  widgetClass: 'MotionSharedLayoutExample',
  playgroundRoute: null,
  previewBuilder: MotionSharedLayoutExample.new,
);

/// Conceptual and installation guides intentionally have no live example.
/// The Springs article may keep its larger dedicated reference composition.
DocExample? docExampleFor(String packageId, String articleId) =>
    switch ('$packageId/$articleId') {
      'motion/water' => _water,
      'motion/debugging' => _tuner,
      'motion/introduction' || 'motion/installation' => null,
      'motion/migration' => _controller,
      'motion/getting-started' => _entrance,
      'motion/first-animation' || 'motion/api' => _intro,
      'motion/springs' => _spring,
      'motion/transitions' => _transitions,
      'motion/presets' => _presets,
      'motion/motion-lists' => _motionList,
      'motion/drag-and-drop' => _gestureTools,
      'motion/routes' => _routes,
      'motion/viewport-motion' => _viewportReplay,
      'motion/animation-sequences' => _loop,
      'motion/variants-stagger' => _variants,
      'motion/controllers' => _controller,
      'motion/timeline' => _timeline,
      'motion/text-motion' => _text,
      'motion/path-motion' => _path,
      'motion/navigation' => _navigation,
      'motion/shaders' => _shader,
      'motion/physics' => _physics,
      'motion/keyframes' => _keyframes,
      'motion/motion-values' || 'motion/performance' => _values,
      'motion/presence' || 'motion/troubleshooting' => _presence,
      'motion/layout-animations' ||
      'motion/layout-presence' ||
      'motion/platform-limits' => _layout,
      'motion/gestures' => _gestures,
      'motion/scroll-motion' => _scroll,
      'motion/accessibility' => _access,
      'components/getting-started' ||
      'components/catalog' ||
      'components/api' ||
      'components/platform-limits' => _button,
      'components/forms' ||
      'components/accessibility' ||
      'components/troubleshooting' => _form,
      'components/theming' => _theme,
      'genui/getting-started' ||
      'genui/protocol-scope' ||
      'genui/runtime' ||
      'genui/api' ||
      'genui/bindings-and-forms' ||
      'genui/actions-and-policy' ||
      'genui/accessibility' ||
      'genui/platform-limits' ||
      'genui/troubleshooting' => _genui,
      _ => null,
    };

DocExample _textRecipe(
  String title,
  String description,
  String arguments,
  Widget Function() builder,
) => DocExample(
  title: title,
  description: description,
  sourceAsset: 'lib/docs/examples/motion_text_example.dart',
  widgetClass: 'MotionTextExample',
  constructorArguments: arguments,
  playgroundRoute: null,
  previewBuilder: builder,
);

final textMotionExamples = <String, DocExample>{
  'character-units': _textRecipe(
    'Character entrance',
    'Animate each character. Compare fade, slide, scale, rotation, blur and their composition.',
    'unit: NibTextUnit.character',
    () => const MotionTextExample(unit: NibTextUnit.character),
  ),
  'word-units': _text,
  'line-units': _textRecipe(
    'Line entrance',
    'Use explicit line breaks, then compare stagger timing across whole lines.',
    'unit: NibTextUnit.line',
    () => const MotionTextExample(unit: NibTextUnit.line),
  ),
  'stagger-origins': _textRecipe(
    'Stagger in four directions',
    'Compare start, end, center and deterministic random ordering with the same text.',
    'unit: NibTextUnit.character, origin: NibTextStaggerFrom.center',
    () => const MotionTextExample(
      unit: NibTextUnit.character,
      origin: NibTextStaggerFrom.center,
    ),
  ),
  'composed-motion': _textRecipe(
    'Compose text transforms',
    'Position, opacity, rotation, scale and blur share one target. Compare the composite with each isolated effect.',
    'composed: true',
    () => const MotionTextExample(composed: true),
  ),
  'spring-vs-tween': _textRecipe(
    'Spring or timed text',
    'Toggle the spring. Duration and curve controls apply to the tween; spring timing comes from its physics.',
    'spring: true',
    () => const MotionTextExample(spring: true),
  ),
  'typewriter': _textRecipe(
    'Type, pause, delete, repeat',
    'Set typing speed, initial delay, cursor and deletion speed. Completion is counted once per mounted run.',
    'kind: TextMotionKind.typewriter',
    () => const MotionTextExample(kind: TextMotionKind.typewriter),
  ),
  'gradient': _textRecipe(
    'Gradient text',
    'Choose linear, radial or sweep colors. Control travel direction, duration and repetition.',
    'kind: TextMotionKind.gradient',
    () => const MotionTextExample(kind: TextMotionKind.gradient),
  ),
  'reveal': _textRecipe(
    'Reveal from any edge',
    'Compare left, right, up and down clipping. Replay remounts the reveal with the selected timing.',
    'kind: TextMotionKind.reveal',
    () => const MotionTextExample(kind: TextMotionKind.reveal),
  ),
  'layered-combinations': _textRecipe(
    'Reveal with gradient',
    'A clip reveals the whole gradient-painted child. The two effects retain their separate responsibilities.',
    'kind: TextMotionKind.revealGradient',
    () => const MotionTextExample(kind: TextMotionKind.revealGradient),
  ),
  'typing-entrance': _textRecipe(
    'Typewriter with spring entrance',
    'A parent NibMotion moves the block while NibTypewriter adds characters. Adjust the typing delay to separate the two beats.',
    'kind: TextMotionKind.typingEntrance',
    () => const MotionTextExample(kind: TextMotionKind.typingEntrance),
  ),
};

List<DocExample> docExamplesFor(String packageId, String articleId) {
  if (packageId == 'motion') {
    final examples = switch (articleId) {
      'text-motion' => textMotionExamples.values.toList(),
      'introduction' || 'installation' => <DocExample>[],
      'getting-started' => [_entrance],
      'first-animation' => [_intro],
      'springs' => [_spring, _transitions, _physics],
      'transitions' => [_transitions, _transform, _loop],
      'keyframes' => [_keyframes, _presets, _loop],
      'presets' => [_presets, _keyframes, _transform],
      'gestures' => [_gestures, _dragAxes, _gestureTools],
      'drag-and-drop' => [_gestureTools, _dragAxes, _gestures],
      'variants-stagger' => [_variants, _staggerOrder, _motionList],
      'motion-lists' => [_motionList, _staggerOrder, _presenceModes],
      'motion-values' => [_values, _scrollProgress, _physics],
      'presence' => [_presence, _presenceModes, _layout],
      'layout-animations' ||
      'layout-presence' => [_layout, _sharedLayout, _presenceModes],
      'scroll-motion' => [_scroll, _scrollProgress, _viewportReplay],
      'viewport-motion' => [_viewportReplay, _scrollProgress, _scroll],
      'controllers' => [_controller, _loop, _timeline],
      'animation-sequences' => [_loop, _timeline, _staggerOrder],
      'timeline' => [_timeline, _loop],
      'path-motion' => [_path, _drawPath],
      'navigation' => [_navigation, _routes],
      'routes' => [_routes, _navigation],
      'physics' => [_physics, _transitions, _dragAxes],
      _ => null,
    };
    if (examples != null) return examples;
  }
  final first = docExampleFor(packageId, articleId);
  return first == null ? [] : [first];
}

List<DocExample> docSectionExamples(
  String packageId,
  String articleId,
  String sectionId,
) {
  if (packageId != 'motion' || articleId != 'text-motion') return const [];
  final example = textMotionExamples[sectionId];
  return [
    ?example,
    if (sectionId == 'layered-combinations')
      textMotionExamples['typing-entrance']!,
  ];
}
