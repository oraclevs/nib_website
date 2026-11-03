import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ember_theme.dart';
import '../recipes/recipe_catalog.dart';

/// Authored static illustrations. These communicate the interaction; they are
/// not recordings or plots sampled from the package runtime.
enum RecipeIllustration {
  retarget,
  keyframes,
  responses,
  counter,
  progress,
  followers,
  flip,
  bounds,
  swipe,
  feedback,
  snap,
  pivot,
  reorder,
  presence,
  expansion,
  filtering,
  selection,
  focus,
  stagger,
  variants,
  onboarding,
  result,
  commands,
  viewport,
  parallax,
  reading,
  navigation,
  validation,
  tabs,
  accordion,
}

/// Identity is explicit so filtering, order, and copy changes cannot select a
/// different recipe's artwork. New recipes must supply a reviewed illustration.
const recipeIllustrations = <String, RecipeIllustration>{
  'spring-retarget': RecipeIllustration.retarget,
  'keyframe-hop': RecipeIllustration.keyframes,
  'spring-tween': RecipeIllustration.responses,
  'animated-counter': RecipeIllustration.counter,
  'progress-choreography': RecipeIllustration.progress,
  'linked-objects': RecipeIllustration.followers,
  'card-flip': RecipeIllustration.flip,
  'bounded-drag': RecipeIllustration.bounds,
  'swipe-restore': RecipeIllustration.swipe,
  'hover-press': RecipeIllustration.feedback,
  'drag-snap': RecipeIllustration.snap,
  'pivot-turn': RecipeIllustration.pivot,
  'keyed-reorder': RecipeIllustration.reorder,
  'presence-reflow': RecipeIllustration.presence,
  'expanding-card': RecipeIllustration.expansion,
  'filtered-list': RecipeIllustration.filtering,
  'selection-indicator': RecipeIllustration.selection,
  'focus-overlay': RecipeIllustration.focus,
  'stagger-list': RecipeIllustration.stagger,
  'variant-orchestration': RecipeIllustration.variants,
  'onboarding-sequence': RecipeIllustration.onboarding,
  'loading-result': RecipeIllustration.result,
  'command-palette': RecipeIllustration.commands,
  'viewport-reveal': RecipeIllustration.viewport,
  'local-parallax': RecipeIllustration.parallax,
  'scroll-progress': RecipeIllustration.reading,
  'page-transition': RecipeIllustration.navigation,
  'form-validation': RecipeIllustration.validation,
  'tab-content': RecipeIllustration.tabs,
  'accordion': RecipeIllustration.accordion,
};

extension RecipeIllustrationDescription on RecipeIllustration {
  String get description => switch (this) {
    RecipeIllustration.retarget => 'A moving object redirects left toward a new target before reaching its old target on the right.',
    RecipeIllustration.keyframes => 'Three numbered poses show the low starting position, raised overshoot, and settled keyframe in time order.',
    RecipeIllustration.responses => 'Two labeled paths compare a spring response and a timed response to the same target change.',
    RecipeIllustration.counter => 'A counter changes from 10 to 20 with a scaled entrance for the new value.',
    RecipeIllustration.progress => 'A 50 percent task state connects its progress marker to a track and status.',
    RecipeIllustration.followers => 'A leader and a softer follower move toward the same target with different responses.',
    RecipeIllustration.flip =>
      'A front card turns around its vertical axis to reveal its back.',
    RecipeIllustration.bounds => 'A draggable object stays inside its outlined movement bounds and can return to the center.',
    RecipeIllustration.swipe =>
      'A row moves out to the right; a restore action brings the row back.',
    RecipeIllustration.feedback =>
      'The same button grows on hover or focus and compresses when pressed.',
    RecipeIllustration.snap => 'A dragged object releases near a stop and snaps onto the nearest target.',
    RecipeIllustration.pivot =>
      'An offset card rotates around a marked point outside its center.',
    RecipeIllustration.reorder =>
      'Rows A, B, and C change order while retaining their identity.',
    RecipeIllustration.presence => 'A middle row exits to the right and fades while the surrounding rows remain.',
    RecipeIllustration.expansion =>
      'A compact card opens to show attached detail below its title.',
    RecipeIllustration.filtering => 'A filter removes the Components row while Motion and GenUI remain visible.',
    RecipeIllustration.selection =>
      'An active indicator moves from the first option to the third option.',
    RecipeIllustration.focus => 'Keyboard focus moves into an open panel and returns to its trigger on close.',
    RecipeIllustration.stagger =>
      'Three rows enter in order, separated by a stagger delay.',
    RecipeIllustration.variants =>
      'One parent state controls the positions and opacity of three children.',
    RecipeIllustration.onboarding =>
      'Three onboarding steps advance in a fixed order.',
    RecipeIllustration.result =>
      'A local busy state fades out as a completion result enters.',
    RecipeIllustration.commands =>
      'A command panel enters and exits above its trigger.',
    RecipeIllustration.viewport =>
      'A card becomes visible as it enters the local scroll viewport.',
    RecipeIllustration.parallax => 'Foreground and background move at different rates inside a local scroll area.',
    RecipeIllustration.reading =>
      'A reading progress marker advances as the local article scrolls.',
    RecipeIllustration.navigation =>
      'A first view leaves while a second view enters from the same direction.',
    RecipeIllustration.validation =>
      'A short name receives inline validation feedback beside its input.',
    RecipeIllustration.tabs =>
      'Selecting a second tab changes the displayed content panel.',
    RecipeIllustration.accordion =>
      'A question expands to reveal its answer in place.',
  };
}

class ExampleCardArt extends StatelessWidget {
  const ExampleCardArt({super.key, required this.recipe});
  final RecipeDefinition recipe;

  @override
  Widget build(BuildContext context) {
    final illustration = recipeIllustrations[recipe.id];
    if (illustration == null) {
      // A missing mapping must remain visible, never borrow an unrelated image.
      return const Center(
        child: Text(
          'Illustration unavailable',
          style: TextStyle(color: Ember.muted, fontSize: 11),
        ),
      );
    }
    return Semantics(
      label: 'Illustration: ${illustration.description}',
      image: true,
      child: ExcludeSemantics(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              key: ValueKey('recipe-art-${recipe.id}'),
              width: 245,
              height: 160,
              child: CustomPaint(painter: _RecipePainter(illustration)),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipePainter extends CustomPainter {
  const _RecipePainter(this.illustration);
  final RecipeIllustration illustration;
  static const accent = Ember.accent;
  static const ink = Ember.text;
  static const muted = Ember.muted;
  static const green = Ember.positive;
  static const border = Ember.border;

  void text(
    Canvas c,
    String value,
    double x,
    double y, {
    double size = 10,
    Color color = muted,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'Ember Sans',
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(c, Offset(x, y));
  }

  void box(
    Canvas c,
    Rect r, {
    Color fill = Ember.panel,
    Color stroke = border,
    double radius = 5,
  }) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(radius));
    c.drawRRect(rr, Paint()..color = fill);
    c.drawRRect(
      rr,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void line(
    Canvas c,
    Offset a,
    Offset b, {
    Color color = border,
    double width = 1,
  }) => c.drawLine(
    a,
    b,
    Paint()
      ..color = color
      ..strokeWidth = width,
  );
  void arrow(Canvas c, Offset a, Offset b, {Color color = accent}) {
    line(c, a, b, color: color, width: 1.5);
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    for (final turn in [-.55, .55]) {
      line(
        c,
        b,
        b - Offset(math.cos(angle + turn), math.sin(angle + turn)) * 6,
        color: color,
        width: 1.5,
      );
    }
  }

  void dashed(Canvas c, Offset a, Offset b, {Color color = Ember.strong}) {
    final distance = (b - a).distance;
    for (var start = 0.0; start < distance; start += 7) {
      line(
        c,
        Offset.lerp(a, b, start / distance)!,
        Offset.lerp(a, b, math.min(start + 3, distance) / distance)!,
        color: color,
      );
    }
  }

  void tile(
    Canvas c,
    double x,
    double y, {
    String label = 'N',
    double size = 33,
    Color color = accent,
    bool ghost = false,
  }) {
    box(
      c,
      Rect.fromLTWH(x, y, size, size),
      fill: ghost ? Ember.soft : color,
      stroke: ghost ? Ember.strong : color,
      radius: 7,
    );
    if (label.isNotEmpty) {
      text(
        c,
        label,
        x + size * .3,
        y + size * .23,
        size: size * .4,
        color: ghost ? muted : Ember.onAccent,
        bold: true,
      );
    }
  }

  void row(
    Canvas c,
    String label,
    double x,
    double y, {
    double width = 170,
    bool selected = false,
    bool dim = false,
  }) {
    box(
      c,
      Rect.fromLTWH(x, y, width, 27),
      fill: selected ? Ember.soft : Ember.panel,
      stroke: selected ? const Color(0xFF88621B) : border,
    );
    c.drawCircle(
      Offset(x + 12, y + 13.5),
      2.5,
      Paint()..color = dim ? Ember.strong : accent,
    );
    text(c, label, x + 23, y + 7, color: dim ? Ember.strong : ink, size: 9);
  }

  void check(Canvas c, Offset at) {
    line(c, at, at + const Offset(4, 4), color: green, width: 2);
    line(
      c,
      at + const Offset(4, 4),
      at + const Offset(12, -5),
      color: green,
      width: 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (illustration) {
      case RecipeIllustration.retarget:
        text(canvas, 'NEW TARGET', 7, 24, size: 8, color: accent);
        text(canvas, 'OLD TARGET', 163, 24, size: 8);
        box(
          canvas,
          const Rect.fromLTWH(18, 65, 32, 32),
          fill: Ember.soft,
          stroke: accent,
          radius: 7,
        );
        box(
          canvas,
          const Rect.fromLTWH(193, 65, 32, 32),
          fill: Ember.code,
          stroke: Ember.strong,
          radius: 7,
        );
        dashed(canvas, const Offset(50, 81), const Offset(193, 81));
        tile(canvas, 106, 65);
        arrow(canvas, const Offset(115, 48), const Offset(54, 48));
        line(
          canvas,
          const Offset(203, 75),
          const Offset(215, 87),
          color: muted,
        );
        line(
          canvas,
          const Offset(215, 75),
          const Offset(203, 87),
          color: muted,
        );
        text(
          canvas,
          'Change target before settling',
          37,
          122,
          size: 10,
          color: ink,
        );
      case RecipeIllustration.keyframes:
        final positions = <Offset>[
          const Offset(18, 88),
          const Offset(103, 33),
          const Offset(192, 66),
        ];
        dashed(
          canvas,
          const Offset(10, 98),
          const Offset(236, 98),
          color: border,
        );
        arrow(
          canvas,
          positions[0] + const Offset(35, 8),
          positions[1] + const Offset(-8, 25),
        );
        arrow(
          canvas,
          positions[1] + const Offset(35, 25),
          positions[2] + const Offset(-7, 9),
        );
        for (var i = 0; i < 3; i++) {
          tile(
            canvas,
            positions[i].dx,
            positions[i].dy,
            label: '${i + 1}',
            ghost: i == 0,
          );
          text(
            canvas,
            ['0% · LOW', '55% · APEX', '100% · REST'][i],
            i * 82 + 3,
            134,
            size: 8,
            color: i == 1 ? accent : muted,
          );
        }
      case RecipeIllustration.responses:
        text(canvas, 'ONE TARGET CHANGE', 69, 15, size: 8, color: ink);
        for (var i = 0; i < 2; i++) {
          final y = 54.0 + i * 55;
          text(
            canvas,
            i == 0 ? 'SPRING' : 'TIMED',
            5,
            y - 3,
            size: 9,
            color: i == 0 ? accent : green,
          );
          dashed(canvas, Offset(70, y), Offset(228, y));
          line(canvas, Offset(213, y - 17), Offset(213, y + 17), color: muted);
          final path = Path()..moveTo(72, y + 12);
          if (i == 0) {
            path.cubicTo(110, y + 12, 145, y - 21, 178, y - 5);
            path.cubicTo(197, y + 8, 205, y - 4, 213, y);
          } else {
            path.cubicTo(100, y + 12, 157, y, 213, y);
          }
          canvas.drawPath(
            path,
            Paint()
              ..color = i == 0 ? accent : green
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          canvas.drawCircle(
            Offset(213, y),
            4,
            Paint()..color = i == 0 ? accent : green,
          );
        }
        text(canvas, 'Illustrated response paths', 67, 143, size: 8);
      case RecipeIllustration.counter:
        text(canvas, '10', 25, 50, size: 35, color: Ember.strong, bold: true);
        arrow(canvas, const Offset(92, 78), const Offset(127, 78));
        text(canvas, '20', 143, 39, size: 52, color: accent, bold: true);
        text(canvas, '+10 · entrance replay', 57, 120);
      case RecipeIllustration.progress:
        text(canvas, 'LOCAL TASK', 20, 27, size: 8);
        text(canvas, '50%', 174, 21, size: 20, color: ink, bold: true);
        box(canvas, const Rect.fromLTWH(20, 63, 205, 12), fill: Ember.raised);
        box(
          canvas,
          const Rect.fromLTWH(20, 63, 102, 12),
          fill: Ember.soft,
          stroke: accent,
        );
        tile(canvas, 107, 83, size: 24, label: '•');
        text(canvas, 'Advance a bounded task', 43, 129, size: 10);
      case RecipeIllustration.followers:
        text(canvas, 'SAME TARGET', 126, 20, size: 8);
        arrow(canvas, const Offset(101, 34), const Offset(220, 34));
        tile(canvas, 117, 57, label: '1');
        tile(canvas, 79, 104, label: '2', color: green);
        text(canvas, 'LEADER', 10, 68, size: 8);
        text(canvas, 'SOFTER', 10, 115, size: 8);
        dashed(canvas, const Offset(215, 49), const Offset(215, 143));
      case RecipeIllustration.flip:
        box(
          canvas,
          const Rect.fromLTWH(21, 39, 76, 89),
          fill: Ember.soft,
          stroke: accent,
          radius: 7,
        );
        text(canvas, 'FRONT', 39, 71, size: 12, color: accent, bold: true);
        arrow(canvas, const Offset(104, 82), const Offset(142, 82));
        box(
          canvas,
          const Rect.fromLTWH(151, 28, 76, 100),
          fill: accent,
          stroke: accent,
          radius: 7,
        );
        text(
          canvas,
          'BACK',
          171,
          68,
          size: 12,
          color: Ember.onAccent,
          bold: true,
        );
        text(canvas, '180°', 108, 102, size: 9);
      case RecipeIllustration.bounds:
        box(
          canvas,
          const Rect.fromLTWH(12, 24, 221, 111),
          fill: Ember.code,
          stroke: Ember.strong,
          radius: 9,
        );
        dashed(canvas, const Offset(24, 80), const Offset(217, 80));
        tile(canvas, 92, 63, ghost: true);
        tile(canvas, 154, 44, color: green);
        arrow(canvas, const Offset(156, 98), const Offset(123, 98));
        text(canvas, 'Drag within bounds · return', 33, 145, size: 9);
      case RecipeIllustration.swipe:
        row(canvas, 'Keyed row', 17, 39, width: 170, dim: true);
        row(canvas, 'Swipe →', 67, 74, width: 163, selected: true);
        arrow(canvas, const Offset(136, 59), const Offset(217, 59));
        arrow(
          canvas,
          const Offset(140, 124),
          const Offset(66, 124),
          color: green,
        );
        text(canvas, 'Restore', 83, 134, size: 9, color: green);
      case RecipeIllustration.feedback:
        for (var i = 0; i < 3; i++) {
          final width = [61.0, 72.0, 56.0][i];
          box(
            canvas,
            Rect.fromCenter(
              center: Offset(40 + i * 83, 76),
              width: width,
              height: i == 1 ? 39 : 32,
            ),
            fill: i == 1 ? Ember.soft : Ember.panel,
            stroke: i == 1 ? accent : border,
          );
          text(canvas, 'Press', 24 + i * 83, 70, size: 9, color: ink);
          text(
            canvas,
            ['REST', 'HOVER', 'PRESS'][i],
            23 + i * 83,
            112,
            size: 8,
            color: i == 1 ? accent : muted,
          );
        }
      case RecipeIllustration.snap:
        line(canvas, const Offset(27, 88), const Offset(218, 88));
        for (final x in [30.0, 121.0, 215.0]) {
          canvas.drawCircle(
            Offset(x, 88),
            14,
            Paint()
              ..color = Ember.strong
              ..style = PaintingStyle.stroke,
          );
        }
        tile(canvas, 161, 49, size: 31, color: green);
        arrow(canvas, const Offset(188, 66), const Offset(214, 84));
        text(canvas, 'RELEASE', 137, 25, size: 8);
        text(canvas, 'Nearest snap target', 61, 125, size: 10, color: ink);
      case RecipeIllustration.pivot:
        canvas.drawCircle(const Offset(65, 93), 4, Paint()..color = accent);
        dashed(canvas, const Offset(65, 93), const Offset(196, 93));
        canvas.save();
        canvas.translate(65, 93);
        canvas.rotate(-.35);
        box(
          canvas,
          const Rect.fromLTWH(29, -22, 130, 44),
          fill: Ember.soft,
          stroke: accent,
        );
        text(canvas, 'Offset card', 51, -6, color: ink);
        canvas.restore();
        text(canvas, 'PIVOT', 46, 113, size: 8, color: accent);
      case RecipeIllustration.reorder:
        for (var i = 0; i < 3; i++) {
          row(
            canvas,
            ['A', 'B', 'C'][i],
            10,
            25 + i * 38,
            width: 76,
            selected: i == 0,
          );
          row(
            canvas,
            ['B', 'C', 'A'][i],
            156,
            25 + i * 38,
            width: 76,
            selected: i == 2,
          );
        }
        arrow(canvas, const Offset(95, 39), const Offset(147, 114));
        arrow(
          canvas,
          const Offset(95, 80),
          const Offset(147, 40),
          color: green,
        );
      case RecipeIllustration.presence:
        row(canvas, 'First row', 25, 23);
        row(canvas, 'Exit', 66, 64, width: 149, dim: true);
        arrow(canvas, const Offset(190, 77), const Offset(233, 77));
        row(canvas, 'Last row', 25, 105);
      case RecipeIllustration.expansion:
        box(canvas, const Rect.fromLTWH(30, 21, 185, 119), fill: Ember.panel);
        text(canvas, 'Compact first', 48, 35, color: ink, bold: true);
        line(canvas, const Offset(44, 59), const Offset(201, 59));
        text(canvas, 'Details stay attached', 48, 76, size: 10);
        text(canvas, 'to their card.', 48, 94, size: 10);
        arrow(canvas, const Offset(194, 78), const Offset(194, 117));
      case RecipeIllustration.filtering:
        text(canvas, 'ALL', 21, 16, size: 8);
        text(canvas, 'MOTION + GENUI', 74, 16, size: 8, color: accent);
        row(canvas, 'Motion', 30, 37, selected: true);
        row(canvas, 'Components', 54, 75, dim: true);
        line(
          canvas,
          const Offset(74, 88),
          const Offset(199, 88),
          color: Ember.strong,
        );
        row(canvas, 'GenUI', 30, 113, selected: true);
      case RecipeIllustration.selection:
        for (var i = 0; i < 3; i++) {
          text(
            canvas,
            ['Build', 'Tune', 'Copy'][i],
            22 + i * 80,
            69,
            color: i == 2 ? ink : muted,
          );
        }
        box(
          canvas,
          const Rect.fromLTWH(7, 98, 61, 5),
          fill: Ember.soft,
          stroke: Ember.strong,
          radius: 2,
        );
        box(
          canvas,
          const Rect.fromLTWH(167, 98, 61, 5),
          fill: accent,
          stroke: accent,
          radius: 2,
        );
        arrow(canvas, const Offset(39, 122), const Offset(197, 122));
      case RecipeIllustration.focus:
        box(
          canvas,
          const Rect.fromLTWH(51, 15, 166, 80),
          fill: Ember.panel,
          stroke: Ember.strong,
        );
        text(canvas, 'Open panel', 64, 27, color: ink, bold: true);
        box(
          canvas,
          const Rect.fromLTWH(65, 53, 136, 25),
          fill: Ember.code,
          stroke: accent,
        );
        text(canvas, 'Close panel', 77, 60, size: 9, color: accent);
        row(canvas, 'Trigger', 16, 118, width: 105, selected: true);
        arrow(
          canvas,
          const Offset(174, 104),
          const Offset(129, 129),
          color: green,
        );
      case RecipeIllustration.stagger:
        for (var i = 0; i < 3; i++) {
          row(
            canvas,
            'Row ${i + 1}',
            15 + i * 17,
            23 + i * 39,
            width: 150,
            selected: i == 0,
            dim: i == 2,
          );
          text(
            canvas,
            '+${i * 60}ms',
            192,
            31 + i * 39,
            size: 8,
            color: i == 0 ? accent : muted,
          );
        }
      case RecipeIllustration.variants:
        box(
          canvas,
          const Rect.fromLTWH(70, 13, 107, 28),
          fill: Ember.soft,
          stroke: accent,
        );
        text(canvas, 'PARENT: OPEN', 81, 22, size: 8, color: accent);
        for (var i = 0; i < 3; i++) {
          arrow(
            canvas,
            const Offset(123, 48),
            Offset(42 + i * 80, 89),
            color: Ember.strong,
          );
          tile(canvas, 26 + i * 80, 100, label: '${i + 1}', ghost: i == 2);
        }
      case RecipeIllustration.onboarding:
        line(canvas, const Offset(39, 61), const Offset(208, 61));
        for (var i = 0; i < 3; i++) {
          tile(canvas, 21 + i * 83, 44, label: '${i + 1}', ghost: i == 2);
          text(
            canvas,
            ['Start', 'Configure', 'Ready'][i],
            22 + i * 78,
            98,
            size: 10,
            color: i == 2 ? muted : ink,
          );
        }
        text(canvas, 'One step follows the last', 48, 130, size: 9);
      case RecipeIllustration.result:
        box(canvas, const Rect.fromLTWH(17, 46, 81, 63));
        canvas.drawArc(
          const Rect.fromLTWH(43, 58, 27, 27),
          -.5,
          4.8,
          false,
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        text(canvas, 'BUSY', 41, 91, size: 8);
        arrow(canvas, const Offset(106, 78), const Offset(135, 78));
        box(
          canvas,
          const Rect.fromLTWH(148, 46, 81, 63),
          fill: Ember.soft,
          stroke: accent,
        );
        check(canvas, const Offset(181, 72));
        text(canvas, 'DONE', 174, 91, size: 8, color: ink);
        text(canvas, 'Local simulated task', 66, 133, size: 9);
      case RecipeIllustration.commands:
        box(
          canvas,
          const Rect.fromLTWH(24, 21, 197, 113),
          stroke: Ember.strong,
        );
        text(canvas, '> Find a command', 38, 34, color: ink);
        line(canvas, const Offset(37, 58), const Offset(208, 58));
        row(canvas, 'Open docs', 36, 67, width: 173, selected: true);
        text(canvas, 'Toggle to close', 43, 109, size: 9);
      case RecipeIllustration.viewport:
        box(
          canvas,
          const Rect.fromLTWH(35, 23, 177, 114),
          fill: Ember.code,
          stroke: Ember.strong,
        );
        row(canvas, 'Now visible', 50, 41, width: 146, selected: true);
        row(canvas, 'Entering view', 50, 96, width: 146, dim: true);
        dashed(canvas, const Offset(21, 122), const Offset(226, 122));
        arrow(canvas, const Offset(18, 111), const Offset(18, 72));
        text(canvas, 'LOCAL VIEWPORT', 62, 145, size: 8);
      case RecipeIllustration.parallax:
        box(canvas, const Rect.fromLTWH(34, 27, 175, 108), fill: Ember.panel);
        for (var i = 0; i < 3; i++) {
          line(
            canvas,
            Offset(49, 49 + i * 27),
            Offset(193, 49 + i * 27),
            color: Ember.strong,
          );
        }
        tile(canvas, 104, 65, color: green);
        arrow(canvas, const Offset(18, 124), const Offset(18, 45));
        arrow(
          canvas,
          const Offset(225, 105),
          const Offset(225, 76),
          color: green,
        );
        text(canvas, 'SCROLL', 9, 16, size: 8);
        text(canvas, 'MARK', 210, 118, size: 8, color: green);
      case RecipeIllustration.reading:
        box(canvas, const Rect.fromLTWH(40, 21, 165, 119), fill: Ember.panel);
        line(canvas, const Offset(51, 35), const Offset(193, 35), width: 4);
        line(
          canvas,
          const Offset(51, 35),
          const Offset(138, 35),
          width: 4,
          color: accent,
        );
        for (var i = 0; i < 5; i++) {
          line(
            canvas,
            Offset(56, 60 + i * 14),
            Offset(i == 4 ? 142 : 186, 60 + i * 14),
            color: Ember.strong,
          );
        }
        arrow(canvas, const Offset(225, 61), const Offset(225, 111));
      case RecipeIllustration.navigation:
        box(
          canvas,
          const Rect.fromLTWH(17, 39, 84, 86),
          fill: Ember.panel,
          stroke: Ember.strong,
        );
        text(canvas, 'VIEW 1', 38, 75, size: 10);
        box(
          canvas,
          const Rect.fromLTWH(145, 39, 84, 86),
          fill: Ember.soft,
          stroke: accent,
        );
        text(canvas, 'VIEW 2', 166, 75, size: 10, color: accent);
        arrow(canvas, const Offset(105, 81), const Offset(137, 81));
        text(canvas, 'Next view', 94, 141, size: 9);
      case RecipeIllustration.validation:
        text(canvas, 'Project name', 25, 27, size: 10, color: ink);
        box(
          canvas,
          const Rect.fromLTWH(25, 49, 195, 34),
          fill: Ember.code,
          stroke: accent,
        );
        text(canvas, 'Jo', 38, 59, color: ink);
        text(
          canvas,
          '!  Use at least 4 characters',
          25,
          95,
          size: 10,
          color: accent,
        );
        arrow(canvas, const Offset(111, 124), const Offset(98, 124));
        arrow(canvas, const Offset(132, 124), const Offset(145, 124));
      case RecipeIllustration.tabs:
        for (var i = 0; i < 2; i++) {
          box(
            canvas,
            Rect.fromLTWH(22 + i * 104, 29, 98, 27),
            fill: i == 1 ? Ember.soft : Ember.panel,
            stroke: i == 1 ? accent : border,
          );
          text(
            canvas,
            ['Preview', 'Code'][i],
            50 + i * 102,
            38,
            size: 8,
            color: i == 1 ? accent : muted,
          );
        }
        box(canvas, const Rect.fromLTWH(22, 66, 202, 65), fill: Ember.panel);
        text(canvas, 'Copyable Dart', 39, 80, color: ink, bold: true);
        line(
          canvas,
          const Offset(39, 108),
          const Offset(184, 108),
          color: Ember.strong,
        );
      case RecipeIllustration.accordion:
        row(canvas, 'What is Nib?       −', 23, 24, width: 200, selected: true);
        box(canvas, const Rect.fromLTWH(23, 51, 200, 50), fill: Ember.panel);
        text(canvas, 'Animation and native', 37, 63, size: 10, color: ink);
        text(canvas, 'Flutter components.', 37, 79, size: 10, color: ink);
        row(canvas, 'Where do I start?  +', 23, 111, width: 200);
    }
  }

  @override
  bool shouldRepaint(covariant _RecipePainter oldDelegate) =>
      illustration != oldDelegate.illustration;
}
