import 'motion_minimal_templates.dart';
import '../components/component_doc_minimal_examples.dart';
import 'genui_minimal_example.dart';
import 'doc_example_catalog.dart';

/// Small, standalone examples of each documented primitive. Full interactive
/// exercises remain available separately, including their controls and styling.
String? minimalDocExample(DocExample example) {
  if (example.widgetClass == 'GenUiFixtureExample') return minimalGenUiExample;
  final family = switch (example.widgetClass) {
    'MotionWaterExample' => 'water',
    'MotionTunerExample' => 'tuner',
    'MotionSharedLayoutExample' => 'shared-layout',
    'MotionEntranceExample' => 'entrance',
    'MotionIntroExample' => 'bookmark',
    'MotionSpringExample' => 'spring',
    'MotionTransitionsExample' => 'compare',
    'MotionKeyframesExample' => 'keyframes',
    'MotionValuesExample' => 'values',
    'MotionPresenceExample' || 'MotionPresenceModesExample' => 'presence',
    'MotionLayoutExample' => 'layout',
    'MotionGesturesExample' => 'hover',
    'MotionDragAxesExample' => 'drag',
    'MotionGestureToolsExample' => 'pinch',
    'MotionScrollExample' || 'MotionViewportReplayExample' => 'viewport',
    'MotionScrollProgressExample' => 'scroll',
    'MotionAccessibilityExample' => 'accessibility',
    'MotionVariantsExample' => 'variants',
    'MotionControllerExample' => 'controller',
    'MotionTimelineExample' => 'timeline',
    'MotionPathExample' => 'path',
    'MotionDrawPathExample' => 'draw-follow',
    'MotionNavigationExample' => 'navigation',
    'MotionRoutesExample' => 'route',
    'MotionShaderExample' => 'glass',
    'MotionPhysicsExample' => 'physics',
    'MotionPresetExample' => 'preset',
    'MotionListExample' || 'MotionStaggerOrderExample' => 'stagger',
    'MotionLoopExample' => 'loop',
    'MotionTransformExample' => 'transform',
    'MotionTextExample' => 'text',
    _ => null,
  };
  return family == null
      ? minimalComponentDocExample(example)
      : minimalMotionExample(family, arguments: example.constructorArguments);
}

String minimalMotionExample(
  String family, {
  String arguments = '',
  double distance = 80,
  double durationMs = 550,
  double stiffness = 180,
  double damping = 18,
  double mass = 1,
}) {
  final template = motionMinimalTemplates['$family|$arguments'];
  if (template == null) {
    throw ArgumentError('No minimal example template for $family / $arguments');
  }
  // Only numeric setting placeholders are substituted. All code layout and
  // quoted strings are preserved from the SDK-formatted development template.
  return template
      .replaceAll('@@distance@@', distance.toString())
      .replaceAll('@@distanceRound@@', distance.round().toString())
      .replaceAll('@@distanceTurn@@', (distance / 360).toString())
      .replaceAll('@@duration@@', durationMs.round().toString())
      .replaceAll('@@stiffness@@', stiffness.toString())
      .replaceAll('@@damping@@', damping.toString())
      .replaceAll('@@mass@@', mass.toString());
}
