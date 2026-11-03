// Authoring input for generate_motion_minimal_templates_test.dart.
// Exported code is formatted by the Dart SDK before becoming a runtime template.
String motionTemplateSource(
  String family, {
  String arguments = '',
  double distance = 80,
  double durationMs = 550,
  double stiffness = 180,
  double damping = 18,
  double mass = 1,
}) {
  const tile = 'const FlutterLogo(size: 64)';
  final spring =
      'NibTransition(spring: NibSpringDescription(stiffness: $stiffness, damping: $damping, mass: $mass))';
  final tween =
      'NibTransition(duration: Duration(milliseconds: ${durationMs.round()}))';
  var fields = 'bool active = false;';
  var dispose = '';
  var mixin = '';
  var action = 'setState(() => active = !active)';
  var body = switch (family) {
    'entrance' => 'Column(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < 3; i++) NibMotion(key: ValueKey("\$active-\$i"), initial: const NibAnim(opacity: 0, y: 18), animate: const NibAnim(opacity: 1, y: 0), transition: NibTransition(duration: const Duration(milliseconds: 480), delay: Duration(milliseconds: i * 90), curve: Curves.easeOutCubic), child: Padding(padding: const EdgeInsets.all(12), child: Text(["A little motion.", "Sketch the idea", "Let it arrive"][i])))])',
    'bookmark' => 'NibMotion(animate: NibAnim(y: active ? -10 : 0, scale: active ? 1.15 : 1, rotate: active ? -.035 : 0), transition: NibTransition.springGentle, child: Icon(active ? Icons.bookmark : Icons.bookmark_border, size: 60, color: Theme.of(context).colorScheme.primary))',
    'tuner' => 'const SizedBox(width: 300, child: NibSpringTuner())',
    'shared-layout' => 'NibLayoutScope(child: SizedBox(width: 240, height: 180, child: Align(alignment: active ? Alignment.bottomRight : Alignment.topLeft, child: NibMotion(key: ValueKey(active), layoutId: "card", layout: NibLayout.both, child: SizedBox(width: active ? 120 : 60, height: active ? 120 : 60, child: const FlutterLogo())))))',
    'water' => 'SizedBox(width: 240, height: 180, child: NibWaterSurface(controller: water, surface: true, sampling: NibWaterSampling.live, background: const Center(child: FlutterLogo(size: 120))))',
    'spring' =>
      'NibMotion(animate: NibAnim(x: active ? $distance : 0), transition: $spring, child: $tile)',
    'compare' =>
      'Row(mainAxisSize: MainAxisSize.min, children: [NibMotion(animate: NibAnim(y: active ? -60 : 0), transition: $spring, child: const Text("Spring")), const SizedBox(width: 32), NibMotion(animate: NibAnim(y: active ? -60 : 0), transition: $tween, child: const Text("Tween"))])',
    'draw-follow' => 'SizedBox(width: 220, height: 120, child: Stack(children: [NibDrawPath(key: ValueKey("draw-\$active"), path: Path()..moveTo(0, 80)..quadraticBezierTo(100, -40, 180, 80), color: Theme.of(context).colorScheme.primary), NibPathMotion(key: ValueKey(active), path: Path()..moveTo(0, 80)..quadraticBezierTo(100, -40, 180, 80), child: const Icon(Icons.navigation))]))',
    'counter' =>
      'NibMotion(key: ValueKey(active), initial: const NibAnim(scale: .7, opacity: 0), animate: NibAnim.identity, transition: $tween, child: Text(active ? "${distance.round()}" : "0", style: const TextStyle(fontSize: 64)))',
    'progress' =>
      'ClipRect(child: SizedBox(width: 200, height: 12, child: NibMotion(animate: NibAnim(x: active ? 0 : -160), transition: $spring, child: ColoredBox(color: Theme.of(context).colorScheme.primary))))',
    'linked' =>
      'Row(mainAxisSize: MainAxisSize.min, children: [NibMotion(animate: NibAnim(x: active ? $distance : 0), transition: $spring, child: $tile), NibMotion(animate: NibAnim(x: active ? $distance : 0), transition: NibTransition.springGentle, child: $tile)])',
    'pivot' =>
      'NibMotion(animate: NibAnim(rotate: active ? ${distance / 360} : 0), transition: $spring, child: SizedBox(width: 160, child: Align(alignment: Alignment.centerRight, child: $tile)))',
    'selection' =>
      'SizedBox(width: 240, child: Column(children: [const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Build"), Text("Tune"), Text("Copy")]), Align(alignment: Alignment.centerLeft, child: NibMotion(animate: NibAnim(x: active ? 160 : 0), transition: $spring, child: Container(width: 80, height: 3, color: Theme.of(context).colorScheme.primary)))]))',
    'expand' => 'AnimatedSize(duration: const Duration(milliseconds: 350), child: Card(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Details"), if (active) NibMotion(initial: const NibAnim(opacity: 0, y: 12), animate: NibAnim.identity, child: const Padding(padding: EdgeInsets.all(24), child: Text("More information")))])))',
    'accordion' => 'SizedBox(width: 280, child: NibAccordion(animated: true, items: const [NibAccordionItem(title: Text("What is Nib?"), content: Text("Animation and native Flutter components."))]))',
    'tab' =>
      'NibMotion(key: ValueKey(active), initial: const NibAnim(opacity: 0, x: 24), animate: NibAnim.identity, transition: $tween, child: Text(active ? "Copyable Dart" : "Live preview"))',
    'snap' =>
      'NibMotion(drag: const NibDragConfig(axis: Axis.horizontal, constraints: Rect.fromLTRB(-80, 0, 80, 0), snapPoints: [Offset(-80, 0), Offset.zero, Offset(80, 0)]), child: $tile)',
    'tween' =>
      'NibMotion(animate: NibAnim(x: active ? $distance : 0), transition: $tween, child: $tile)',
    'transform' =>
      'NibMotion(animate: NibAnim(x: active ? 60 : 0, rotate: active ? .4 : 0, scale: active ? 1.2 : 1, opacity: active ? .5 : 1), child: $tile)',
    'hover' =>
      'NibMotion(whileHover: const NibAnim(scale: 1.15), whileTap: const NibAnim(scale: .9), transition: $spring, child: $tile)',
    'drag' =>
      'NibMotion(drag: const NibDragConfig(axis: Axis.horizontal, constraints: Rect.fromLTRB(-80, 0, 80, 0)), child: $tile)',
    'pinch' =>
      'NibPinch(minScale: .5, maxScale: 2, snapBackOnRelease: true, child: $tile)',
    'swipe' =>
      'active ? const Text("Dismissed. Tap below to restore.") : NibSwipeDismiss(onDismissed: () => setState(() => active = true), child: $tile)',
    'flip' =>
      'NibFlip(isFlipped: active, front: $tile, back: const Icon(Icons.check, size: 64))',
    'preset' => 'NibBounce(key: ValueKey(active), child: $tile)',
    'loop' =>
      'NibMotion(key: ValueKey(active), initial: const NibAnim(y: -20), animate: const NibAnim(y: 20), repeatAnimationInLoop: true, transition: $tween, child: $tile)',
    'keyframes' =>
      'NibMotion(key: ValueKey(active), keyframes: const [NibKeyframe(at: 0, value: NibAnim(y: 0)), NibKeyframe(at: .5, value: NibAnim(y: -50)), NibKeyframe(at: 1, value: NibAnim(y: 0))], transition: $tween, child: $tile)',
    'presence' =>
      'NibPresence(children: [if (!active) NibMotion(key: const ValueKey("tile"), initial: const NibAnim(opacity: 0), animate: const NibAnim(opacity: 1), exit: const NibAnim(opacity: 0, y: -24), child: $tile)])',
    'layout' => 'Row(mainAxisSize: MainAxisSize.min, children: [for (final id in (active ? [2, 1, 0] : [0, 1, 2])) NibMotion(key: ValueKey(id), layout: NibLayout.position, child: Padding(padding: const EdgeInsets.all(12), child: Text("\$id")))])',
    'stagger' => 'NibMotionList(key: ValueKey(active), initial: const NibAnim(opacity: 0, y: 16), animate: NibAnim.identity, staggerDelay: const Duration(milliseconds: 100), children: const [Text("One"), Text("Two"), Text("Three")])',
    'variants' =>
      'NibMotion(animate: active ? "open" : "closed", variants: {"open": const NibAnim(x: 60, opacity: 1), "closed": const NibAnim(x: 0, opacity: .4)}, child: $tile)',
    'viewport' =>
      'SizedBox(height: 240, child: ListView(children: [const SizedBox(height: 300, child: Center(child: Text("Scroll down"))), NibScrollReveal(key: ValueKey(active), once: false, child: $tile)]))',
    'accessibility' =>
      'NibMotionConfig(reducedMotion: active, child: NibMotion(key: ValueKey(active), initial: const NibAnim(x: -60), animate: const NibAnim(x: 60), child: $tile))',
    'path' =>
      'SizedBox(width: 220, height: 120, child: NibPathMotion(key: ValueKey(active), path: Path()..moveTo(0, 80)..quadraticBezierTo(100, -40, 180, 80), child: $tile))',
    'draw' => 'SizedBox(width: 220, height: 120, child: NibDrawPath(key: ValueKey(active), path: Path()..moveTo(0, 80)..quadraticBezierTo(100, -40, 180, 80), color: Theme.of(context).colorScheme.primary))',
    'navigation' => 'SizedBox(height: 180, child: NibScreenStack(currentIndex: active ? 1 : 0, screens: const [NibNavScreen(child: Center(child: Text("Inbox"))), NibNavScreen(child: Center(child: Text("Saved")))]))',
    'glass' => 'Stack(alignment: Alignment.center, children: [const Icon(Icons.circle, size: 120, color: Colors.amber), NibGlass(blurSigma: active ? 12 : 4, child: const SizedBox(width: 180, height: 100, child: Center(child: Text("Glass"))))])',
    _ => tile,
  };
  if (family == 'validation') {
    fields += '\n  final name = TextEditingController();\n  final shake = NibShakeController();';
    dispose = 'name.dispose(); shake.dispose();';
    action =
        'setState(() => active = name.text.trim().length < ${distance.round()}); if (active) shake.shake()';
    body =
        'SizedBox(width: 280, child: Column(children: [TextField(controller: name, decoration: InputDecoration(labelText: "Project name", errorText: active ? "Use at least ${distance.round()} characters" : null)), NibShake(controller: shake, child: Text(active ? "Try a longer name" : "Ready to check"))]))';
  }
  if (family == 'controller' || family == 'timeline') {
    fields += '\n  final controller = NibMotionController();';
    dispose = 'controller.dispose();';
    body =
        'NibMotion(controller: controller, initial: const NibAnim(x: 0), child: $tile)';
    action = 'controller.start(target: const NibAnim(x: 80))';
    if (family == 'timeline') {
      fields += '\n  late final timeline = NibTimeline([NibTimelineEntry(controller: controller, target: const NibAnim(x: 80), at: Duration.zero), NibTimelineEntry(controller: controller, target: const NibAnim(x: 0), at: const Duration(milliseconds: 800))]);';
      dispose = 'timeline.dispose(); controller.dispose();';
      action = 'timeline.play()';
    }
  }
  if (family == 'water') {
    fields += '\n  final water = NibWaterController(drops: const []);';
    dispose = 'water.dispose();';
    action = 'water.disturb(const Offset(120, 90))';
  }
  if (family == 'values' || family == 'physics') {
    fields += '\n  final position = MotionValue<double>(0);';
    dispose = 'position.dispose();';
    body =
        'NibMotion(motionValues: NibMotionValues(translateX: position), child: $tile)';
    action = 'position.value = position.value == 0 ? 80 : 0';
    if (family == 'values') {
      fields += '\n  late final opacity = position.mapRange([0, 80], [.3, 1]);';
      dispose = 'opacity.dispose(); position.dispose();';
      body =
          'NibMotion(motionValues: NibMotionValues(translateX: position, opacity: opacity), child: $tile)';
    }
    if (family == 'physics') {
      mixin = ' with SingleTickerProviderStateMixin';
      fields += '\n  late final solver = SpringSolver(vsync: this, value: position, spring: NibSpringDescription.gentle);';
      dispose = 'solver.dispose(); position.dispose();';
      action = 'solver.animateTo(target: position.value < 40 ? 80 : 0)';
    }
  }
  if (family == 'scroll' || family == 'parallax') {
    fields += '\n  final scroll = ScrollController();\n  late final bridge = ScrollMotionBridge(controller: scroll);\n  late final travel = bridge.scrollY.mapRange([0, 400], [0, 100]);';
    dispose = 'travel.dispose(); bridge.dispose(); scroll.dispose();';
    body =
        'SizedBox(height: 240, child: Column(children: [NibMotion(motionValues: NibMotionValues(translateX: travel), child: $tile), Expanded(child: ListView(controller: scroll, children: const [SizedBox(height: 600, child: Text("Scroll to move the logo"))]))]))';
    if (family == 'scroll') {
      fields +=
          '\n  late final angle = bridge.scrollY.mapRange([0, 400], [0, .5]);';
      dispose = 'angle.dispose(); $dispose';
      body = body.replaceFirst(
        'translateX: travel)',
        'translateX: travel, rotate: angle)',
      );
    }
    if (family == 'parallax') {
      body =
          'SizedBox(height: 240, child: ListView(controller: scroll, children: [NibParallax(scrollController: scroll, factor: .5, child: $tile), const SizedBox(height: 600)]))';
    }
  }
  if (family == 'route') {
    action = 'Navigator.of(context).push(NibPageRoute<void>(builder: (_) => Scaffold(appBar: AppBar(title: const Text("Detail")), body: const Center(child: Text("Go back with the app bar")))))';
  }
  if (family == 'text') {
    final unit = arguments.contains('NibTextUnit.line')
        ? 'line'
        : arguments.contains('NibTextUnit.character')
        ? 'character'
        : 'word';
    final origin = arguments.contains('NibTextStaggerFrom.center')
        ? 'center'
        : 'start';
    final text = unit == 'line'
        ? r'Make things\nmove together'
        : 'Make things move';
    body =
        'NibText("$text", key: ValueKey(active), config: NibTextConfig(unit: NibTextUnit.$unit, staggerFrom: NibTextStaggerFrom.$origin, initial: const ${arguments.contains('composed: true') ? 'NibAnim(opacity: 0, x: -10, y: 18, scale: .75, rotate: -.15, blur: 4)' : 'NibAnim(opacity: 0, y: 16)'}, animate: NibAnim.identity, transition: ${arguments.contains('spring: true') ? 'NibTransition.springGentle' : tween}))';
    if (arguments.contains('typewriter') ||
        arguments.contains('typingEntrance')) {
      body = 'NibTypewriter("Make things move", key: ValueKey(active))';
    }
    if (arguments.contains('gradient') ||
        arguments.contains('revealGradient')) {
      body = 'NibGradientText("Make things move", gradient: const LinearGradient(colors: [Colors.amber, Colors.teal]))';
    }
    if (arguments.contains('TextMotionKind.reveal,') ||
        arguments.endsWith('TextMotionKind.reveal')) {
      body = 'const Text("Make things move")';
    }
    if (arguments.contains('reveal')) {
      body = 'NibTextReveal(key: ValueKey(active), child: $body)';
    }
    if (arguments.contains('typingEntrance')) {
      body =
          'NibMotion(key: ValueKey(active), initial: const NibAnim(y: 24), animate: NibAnim.identity, transition: NibTransition.springGentle, child: $body)';
    }
  }
  return '''// Add ${family == 'accordion' ? 'nib_components' : 'nib_motion'} to your Flutter app, then paste into lib/main.dart.
// Minimal primitive example; Full example includes the preview controls.
import 'package:flutter/material.dart';
${family == 'accordion' ? '' : "import 'package:nib_motion/nib_motion.dart';"}
${family == 'accordion' ? "import 'package:nib_components/nib_components.dart';" : ''}

void main() => runApp(const MaterialApp(
  home: Scaffold(body: Center(child: NibExample())),
));

class NibExample extends StatefulWidget {
  const NibExample({super.key});
  @override
  State<NibExample> createState() => _NibExampleState();
}

class _NibExampleState extends State<NibExample>$mixin {
  $fields
  ${dispose.isEmpty ? '' : '@override\n  void dispose() { $dispose super.dispose(); }'}
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      $body,
      const SizedBox(height: 24),
      TextButton(onPressed: () { $action; }, child: const Text('Try / replay')),
    ],
  );
}
''';
}
