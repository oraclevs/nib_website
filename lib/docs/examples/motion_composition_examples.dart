import '../../components/component_toggle.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

// Each public widget can be placed directly in a MaterialApp's body.
// The private helpers belong in the same file when copying an example.

/// Three host-controlled passes, or an unlimited native NibMotion loop.
class MotionLoopExample extends StatefulWidget {
  const MotionLoopExample({super.key});

  @override
  State<MotionLoopExample> createState() => _MotionLoopExampleState();
}

class _MotionLoopExampleState extends State<MotionLoopExample> {
  static const _start = NibAnim(x: -56);
  static const _end = NibAnim(x: 56);
  static const _timing = NibTransition(
    duration: Duration(milliseconds: 700),
    curve: Curves.linear,
  );
  final _controller = NibMotionController();
  bool _unlimited = false;
  bool _reverse = true;
  bool _reduced = false;
  int _generation = 0;
  String _status = 'One entrance; replay to compare loops.';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = NibMotionConfig.watchReducedMotion(context);
    if (reduced && !_reduced) {
      _generation++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.repeat(false);
        _controller.stop();
        _controller.set(_end);
      });
    }
    _reduced = reduced;
  }

  void _stop() {
    _generation++;
    _controller.repeat(false);
    _controller.stop();
    setState(() => _status = 'Stopped at the current position.');
  }

  Future<void> _replay() async {
    final generation = ++_generation;
    _controller.repeat(false);
    _controller.stop();
    if (_reduced) {
      _controller.set(_end);
      setState(() => _status = 'Reduced motion: final position.');
      return;
    }
    _controller.set(_start);
    if (_unlimited) {
      setState(() => _status = 'Repeating until Stop.');
      _controller.repeat();
      return;
    }
    for (var pass = 0; pass < 3; pass++) {
      if (!mounted || generation != _generation) return;
      if (!_reverse && pass > 0) _controller.set(_start);
      setState(() => _status = 'Pass ${pass + 1} of 3');
      await _controller.start(
        target: _reverse && pass.isOdd ? _start : _end,
        transition: _timing,
      );
    }
    if (mounted && generation == _generation) {
      setState(() => _status = 'Three passes complete.');
    }
  }

  @override
  void dispose() {
    _generation++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lesson(
    explanation:
        'Reverse alternates direction. Restart returns to the left '
        'between passes. Three passes use an awaited controller sequence; '
        'Unlimited uses the native loop.',
    children: [
      _Stage(
        height: 100,
        child: NibMotion(
          key: const ValueKey('loop-motion'),
          controller: _controller,
          initial: _reduced ? _end : _start,
          animate: _end,
          transition: _timing,
          loopMode: _reverse ? NibLoopMode.pingPong : NibLoopMode.restart,
          child: const _Tile(label: 'LOOP'),
        ),
      ),
      Wrap(
        spacing: 6,
        children: [
          ChoiceChip(
            label: const Text('3 passes'),
            selected: !_unlimited,
            onSelected: (_) {
              _stop();
              setState(() => _unlimited = false);
            },
          ),
          ChoiceChip(
            label: const Text('Unlimited'),
            selected: _unlimited,
            onSelected: (_) {
              _stop();
              setState(() => _unlimited = true);
            },
          ),
        ],
      ),
      _Toggle(
        label: 'Reverse each pass',
        value: _reverse,
        onChanged: (value) {
          _stop();
          setState(() => _reverse = value);
        },
      ),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(onPressed: _replay, child: const Text('Replay')),
          OutlinedButton(onPressed: _stop, child: const Text('Stop')),
        ],
      ),
      Text(_reduced ? 'Reduced motion: final position.' : _status),
    ],
  );
}

/// A stroke being revealed and a separate child following the same path.
class MotionDrawPathExample extends StatefulWidget {
  const MotionDrawPathExample({super.key});

  @override
  State<MotionDrawPathExample> createState() => _MotionDrawPathExampleState();
}

class _MotionDrawPathExampleState extends State<MotionDrawPathExample> {
  final _draw = NibDrawPathController();
  final _follow = NibPathMotionController();
  final _path = Path()
    ..moveTo(12, 80)
    ..cubicTo(30, 5, 125, 5, 174, 76);
  bool _showStroke = true;
  bool _showMarker = true;
  bool _rotate = true;
  bool _paused = false;

  @override
  void dispose() {
    _draw.dispose();
    _follow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = NibMotionConfig.watchReducedMotion(context);
    final color = Theme.of(context).colorScheme.primary;
    return _Lesson(
      explanation:
          'The stroke reveals path length. The arrow is a child '
          'translated along that path. Rotation follows the tangent. '
          'Pause freezes both; Restart begins at zero.',
      children: [
        _Stage(
          height: 120,
          child: SizedBox(
            width: 190,
            height: 100,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _PathGuide(_path, color)),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: _showStroke ? 1 : 0,
                    child: NibDrawPath(
                      key: ValueKey('draw-$reduced'),
                      path: _path,
                      color: color,
                      strokeWidth: 3,
                      duration: const Duration(seconds: 3),
                      curve: Curves.linear,
                      controller: _draw,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Opacity(
                    opacity: _showMarker ? 1 : 0,
                    child: NibPathMotion(
                      key: ValueKey('follow-$reduced'),
                      path: _path,
                      duration: const Duration(seconds: 3),
                      curve: Curves.linear,
                      rotate: _rotate,
                      controller: _follow,
                      child: Transform.translate(
                        offset: const Offset(-10, -10),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _Toggle(
          label: 'Draw stroke',
          value: _showStroke,
          onChanged: (v) => setState(() => _showStroke = v),
        ),
        _Toggle(
          label: 'Follow path',
          value: _showMarker,
          onChanged: (v) => setState(() => _showMarker = v),
        ),
        _Toggle(
          label: 'Rotate arrow',
          value: _rotate,
          onChanged: (v) => setState(() => _rotate = v),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: () {
                _draw.restart();
                _follow.restart();
                setState(() => _paused = false);
              },
              child: const Text('Restart'),
            ),
            OutlinedButton(
              onPressed: reduced
                  ? null
                  : () {
                      _draw.pause();
                      _follow.pause();
                      setState(() => _paused = true);
                    },
              child: const Text('Pause'),
            ),
          ],
        ),
        Text(
          reduced
              ? 'Reduced motion: complete path and endpoint.'
              : _paused
              ? 'Paused. Restart plays from the beginning.'
              : 'Both use a 3-second linear clock.',
        ),
      ],
    );
  }
}

/// Scroll offset drives both a painted progress track and a child transform.
class MotionScrollProgressExample extends StatefulWidget {
  const MotionScrollProgressExample({super.key});

  @override
  State<MotionScrollProgressExample> createState() =>
      _MotionScrollProgressExampleState();
}

class _MotionScrollProgressExampleState
    extends State<MotionScrollProgressExample> {
  final _scroll = ScrollController();
  late final _bridge = ScrollMotionBridge(controller: _scroll);
  late final _progress = _bridge.scrollY.mapRange([0, 420], [0, 1]);
  late final _x = _bridge.scrollY.mapRange([0, 420], [-56, 56]);
  late final _angle = _bridge.scrollY.mapRange([0, 420], [-0.4, 0.4]);

  @override
  void initState() {
    super.initState();
    // Create each derived value once; they own listeners on the bridge.
    _progress;
    _x;
    _angle;
  }

  void _jump(double fraction) {
    if (_scroll.hasClients) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent * fraction);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _x.dispose();
    _angle.dispose();
    _bridge.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = NibMotionConfig.watchReducedMotion(context);
    final color = Theme.of(context).colorScheme.primary;
    return _Lesson(
      explanation:
          'Scroll the reading pane. One bridge maps 0–420 pixels '
          'to progress, horizontal position and rotation. The bar repaints '
          'from its MotionValue without rebuilding the reading pane.',
      children: [
        _Stage(
          height: 90,
          child: NibMotion(
            key: ValueKey('scroll-tile-$reduced'),
            animate: reduced ? const NibAnim(x: 56) : null,
            motionValues: reduced
                ? null
                : NibMotionValues(translateX: _x, rotate: _angle),
            child: const _Tile(label: 'READ'),
          ),
        ),
        SizedBox(
          height: 8,
          width: double.infinity,
          child: CustomPaint(painter: _ProgressPaint(_progress, color)),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _progress,
          builder: (_, value, _) => Text('${(value * 100).round()}% read'),
        ),
        SizedBox(
          height: 160,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              key: const ValueKey('progress-scroll'),
              controller: _scroll,
              primary: false,
              child: SizedBox(
                height: 580,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('01 / Begin\nScroll this pane to move the tile.'),
                      Text(
                        '02 / Middle\nProgress is continuous, including when you drag the scrollbar.',
                      ),
                      Text(
                        '03 / Finish\nThe bar and tile share the same scroll source.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 4,
          children: [
            TextButton(onPressed: () => _jump(0), child: const Text('Start')),
            TextButton(
              onPressed: () => _jump(.5),
              child: const Text('Halfway'),
            ),
            TextButton(onPressed: () => _jump(1), child: const Text('End')),
          ],
        ),
        if (reduced)
          const Text(
            'Reduced motion: the tile stays still; reading progress remains live.',
          ),
      ],
    );
  }
}

/// Axis locking, elastic boundaries, and optional inertial release.
class MotionDragAxesExample extends StatefulWidget {
  const MotionDragAxesExample({super.key}) : _isolated = false;
  const MotionDragAxesExample._canvas() : _isolated = true;
  final bool _isolated;

  @override
  State<MotionDragAxesExample> createState() => _MotionDragAxesExampleState();
}

class _MotionDragAxesExampleState extends State<MotionDragAxesExample> {
  final _controller = NibMotionController();
  MotionValue<double>? _x;
  MotionValue<double>? _y;
  Axis? _axis = Axis.horizontal;
  bool _elastic = false;
  bool _momentum = false;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _x = _controller.motionValueOf(NibProperty.x);
      _y = _controller.motionValueOf(NibProperty.y);
      _x?.addListener(_positionChanged);
      _y?.addListener(_positionChanged);
    });
  }

  void _positionChanged() {
    // Keep constraints relative to the next gesture's resting position.
    // During a gesture, preserve the bounds captured when it began.
    if (mounted && !_dragging) setState(() {});
  }

  void _center() {
    _controller.stop();
    _controller.set(NibAnim.identity);
    setState(() {});
  }

  @override
  void dispose() {
    _x?.removeListener(_positionChanged);
    _y?.removeListener(_positionChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCanvas() => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 420,
        height: math.min(480, MediaQuery.sizeOf(context).height - 64),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      namesRoute: true,
                      child: const Text('Drag canvas'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close drag canvas',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Expanded(child: MotionDragAxesExample._canvas()),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final reduced = NibMotionConfig.watchReducedMotion(context);
    final x = _x?.value ?? 0;
    final y = _y?.value ?? 0;
    final parts = <Widget>[
      _Stage(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160,
              height: 116,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            NibMotion(
              key: const ValueKey('drag-motion'),
              controller: _controller,
              drag: NibDragConfig(
                axis: _axis,
                constraints: Rect.fromLTRB(-56 - x, -34 - y, 56 - x, 34 - y),
                elastic: _elastic,
                releaseMode: _momentum && !reduced
                    ? NibDragReleaseMode.inertia
                    : NibDragReleaseMode.stay,
                onDragStart: () => _dragging = true,
                onDragEnd: (_) {
                  _dragging = false;
                  setState(() {});
                },
              ),
              child: const _Tile(label: 'DRAG'),
            ),
          ],
        ),
      ),
      if (widget._isolated)
        Wrap(
          spacing: 6,
          children: [
            for (final entry in <(String, Axis?)>[
              ('X', Axis.horizontal),
              ('Y', Axis.vertical),
              ('Both', null),
            ])
              ChoiceChip(
                label: Text(entry.$1),
                selected: _axis == entry.$2,
                onSelected: (_) {
                  _center();
                  setState(() => _axis = entry.$2);
                },
              ),
          ],
        ),
      _Toggle(
        label: 'Elastic boundary',
        value: _elastic,
        onChanged: (v) {
          _center();
          setState(() => _elastic = v);
        },
      ),
      _Toggle(
        label: 'Momentum on release',
        value: _momentum,
        onChanged: (v) {
          _center();
          setState(() => _momentum = v);
        },
      ),
      OutlinedButton(onPressed: _center, child: const Text('Center')),
      Text(
        'Resting offset: x ${x.toStringAsFixed(0)}, y ${y.toStringAsFixed(0)}',
      ),
      if (reduced)
        const Text(
          'Reduced motion: dragging remains direct; momentum is disabled.',
        ),
    ];
    if (widget._isolated) {
      // The stage is a sibling of the scrolling controls, so no page scroll
      // recognizer competes with its native NibMotion pan recognizer.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          parts.first,
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final control in parts.skip(1))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: control,
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return _Lesson(
      explanation:
          'Drag horizontally here. Elastic adds resistance at the boundary; '
          'Momentum coasts after release. Otherwise the tile stays where you leave it.',
      children: [
        ...parts,
        const Text(
          'A scrolling page can claim vertical and diagonal pans before the '
          'tile. Open the drag canvas to compare X, Y, and Both without that competition.',
        ),
        OutlinedButton.icon(
          onPressed: _openCanvas,
          icon: const Icon(Icons.open_in_full, size: 16),
          label: const Text('Open drag canvas'),
        ),
      ],
    );
  }
}

/// Entrance order is controlled by NibPresence's stagger ranks.
class MotionStaggerOrderExample extends StatefulWidget {
  const MotionStaggerOrderExample({super.key});

  @override
  State<MotionStaggerOrderExample> createState() =>
      _MotionStaggerOrderExampleState();
}

class _MotionStaggerOrderExampleState extends State<MotionStaggerOrderExample> {
  NibStaggerFrom _from = NibStaggerFrom.first;
  int _generation = 0;

  @override
  Widget build(BuildContext context) {
    final reduced = NibMotionConfig.watchReducedMotion(context);
    return _Lesson(
      explanation:
          'All five tiles share one transition. Stagger changes '
          'when each starts: 160 ms per rank. Center gives equal delays '
          'to tiles the same distance from tile 3.',
      children: [
        _Stage(
          height: 110,
          child: NibPresence.layout(
            key: ValueKey('stagger-$_generation-$reduced'),
            axis: NibPresenceAxis.row,
            stagger: reduced
                ? Duration.zero
                : const Duration(milliseconds: 160),
            staggerFrom: _from,
            children: [
              for (var i = 0; i < 5; i++)
                NibMotion(
                  key: ValueKey('stagger-$i'),
                  initial: reduced
                      ? NibAnim.identity
                      : const NibAnim(opacity: 0, y: 20),
                  animate: NibAnim.identity,
                  transition: const NibTransition(
                    duration: Duration(milliseconds: 320),
                    curve: Curves.linear,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _Tile(label: '${i + 1}', size: 32),
                  ),
                ),
            ],
          ),
        ),
        Wrap(
          spacing: 6,
          children: [
            for (final entry in [
              ('Start', NibStaggerFrom.first),
              ('End', NibStaggerFrom.last),
              ('Center', NibStaggerFrom.center),
            ])
              ChoiceChip(
                label: Text(entry.$1),
                selected: _from == entry.$2,
                onSelected: (_) => setState(() {
                  _from = entry.$2;
                  _generation++;
                }),
              ),
          ],
        ),
        FilledButton(
          onPressed: () => setState(() => _generation++),
          child: const Text('Replay order'),
        ),
        Text(
          reduced
              ? 'Reduced motion: all five appear together.'
              : switch (_from) {
                  NibStaggerFrom.first => 'Order: 1 → 2 → 3 → 4 → 5',
                  NibStaggerFrom.last => 'Order: 5 → 4 → 3 → 2 → 1',
                  NibStaggerFrom.center => 'Order: 3 → 2 + 4 → 1 + 5',
                },
        ),
      ],
    );
  }
}

/// Compare the two native presence exit layout policies.
class MotionPresenceModesExample extends StatefulWidget {
  const MotionPresenceModesExample({super.key});

  @override
  State<MotionPresenceModesExample> createState() =>
      _MotionPresenceModesExampleState();
}

class _MotionPresenceModesExampleState
    extends State<MotionPresenceModesExample> {
  NibExitLayout _mode = NibExitLayout.sync;
  bool _middle = true;

  @override
  Widget build(BuildContext context) => _Lesson(
    explanation:
        'Remove B and watch C. Sync reserves B’s space until its '
        'exit finishes. Pop removes B from layout immediately, so C can '
        'move while B fades. Restore keeps the same stable key.',
    children: [
      _Stage(
        height: 100,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: NibPresence.layout(
              key: ValueKey(_mode),
              axis: NibPresenceAxis.row,
              exitLayout: _mode,
              exit: const NibAnim(opacity: 0, scale: .5, y: 18),
              exitTransition: const NibTransition(
                duration: Duration(milliseconds: 900),
                curve: Curves.linear,
              ),
              children: [
                for (final label in ['A', if (_middle) 'B', 'C'])
                  NibMotion(
                    key: ValueKey('presence-$label'),
                    initial: const NibAnim(opacity: 0, scale: .8),
                    animate: NibAnim.identity,
                    transition: const NibTransition(
                      duration: Duration(milliseconds: 500),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _Tile(label: label, size: 48),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      Wrap(
        spacing: 6,
        children: [
          for (final mode in NibExitLayout.values)
            ChoiceChip(
              label: Text(mode == NibExitLayout.sync ? 'Sync' : 'Pop'),
              selected: _mode == mode,
              onSelected: (_) => setState(() {
                _mode = mode;
                _middle = true;
              }),
            ),
        ],
      ),
      FilledButton(
        onPressed: () => setState(() => _middle = !_middle),
        child: Text(_middle ? 'Remove B' : 'Restore B'),
      ),
      Text(
        _middle
            ? 'Three stable keys: A, B and C.'
            : 'B leaves; A and C keep their identity.',
      ),
      if (NibMotionConfig.watchReducedMotion(context))
        const Text('Reduced motion: exit and reflow complete immediately.'),
    ],
  );
}

/// Compose five transform channels and interrupt an in-flight transition.
class MotionTransformExample extends StatefulWidget {
  const MotionTransformExample({super.key});

  @override
  State<MotionTransformExample> createState() => _MotionTransformExampleState();
}

class _MotionTransformExampleState extends State<MotionTransformExample> {
  final _controller = NibMotionController();
  double _x = 0, _y = 0, _scale = 1, _rotation = 0, _opacity = 1;

  void _preset(bool composed) => setState(() {
    _x = composed ? 48 : 0;
    _y = composed ? -22 : 0;
    _scale = composed ? 1.2 : 1;
    _rotation = composed ? math.pi / 3 : 0;
    _opacity = composed ? .55 : 1;
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lesson(
    explanation:
        'Position, scale, rotation and opacity animate together. '
        'Move a slider during a transition to retarget from the current '
        'value. Rotation is supplied to NibAnim in radians.',
    children: [
      _Stage(
        height: 150,
        child: NibMotion(
          key: const ValueKey('transform-motion'),
          controller: _controller,
          animate: NibAnim(
            x: _x,
            y: _y,
            scale: _scale,
            rotate: _rotation,
            opacity: _opacity,
          ),
          transition: const NibTransition(
            duration: Duration(milliseconds: 600),
            curve: Curves.linear,
          ),
          child: const _Tile(label: 'NIB'),
        ),
      ),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () => _preset(true),
            child: const Text('Compose'),
          ),
          OutlinedButton(
            onPressed: () => _preset(false),
            child: const Text('Reset'),
          ),
        ],
      ),
      _Range(
        label: 'X',
        value: _x,
        min: -54,
        max: 54,
        onChanged: (v) => setState(() => _x = v),
      ),
      _Range(
        label: 'Y',
        value: _y,
        min: -26,
        max: 26,
        onChanged: (v) => setState(() => _y = v),
      ),
      _Range(
        label: 'Scale',
        value: _scale,
        min: .65,
        max: 1.25,
        onChanged: (v) => setState(() => _scale = v),
      ),
      _Range(
        label: 'Radians',
        value: _rotation,
        min: -math.pi / 2,
        max: math.pi / 2,
        onChanged: (v) => setState(() => _rotation = v),
      ),
      _Range(
        label: 'Opacity',
        value: _opacity,
        min: .25,
        max: 1,
        onChanged: (v) => setState(() => _opacity = v),
      ),
      if (NibMotionConfig.watchReducedMotion(context))
        const Text(
          'Reduced motion: each control applies its target immediately.',
        ),
    ],
  );
}

/// A nested viewport and a replay scope with a once-only entrance.
class MotionViewportReplayExample extends StatefulWidget {
  const MotionViewportReplayExample({super.key});

  @override
  State<MotionViewportReplayExample> createState() =>
      _MotionViewportReplayExampleState();
}

class _MotionViewportReplayExampleState
    extends State<MotionViewportReplayExample> {
  final _scroll = ScrollController();
  final _signal = NibMotionReplaySignal();
  final _target = NibMotionController();
  final _badge = NibMotionController();
  bool _once = false;
  int _replays = 0;

  void _jump(double offset) {
    if (_scroll.hasClients) {
      _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
    }
  }

  @override
  void dispose() {
    _target.dispose();
    _badge.dispose();
    _signal.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = NibMotionConfig.watchReducedMotion(context);
    return _Lesson(
      explanation:
          'Reveal puts the card inside the nested viewport. Hide '
          'moves it out. Re-enter animates every visit; Once retains its '
          'entered state. Replay scope also restarts the small badge, '
          'but preserves a card that has already entered with Once.',
      children: [
        NibMotionReplayScope(
          signal: _signal,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: NibMotion(
                  key: const ValueKey('viewport-badge'),
                  controller: _badge,
                  initial: const NibAnim(opacity: .2, scale: .6),
                  animate: NibAnim.identity,
                  transition: const NibTransition(
                    duration: Duration(milliseconds: 600),
                  ),
                  child: const Chip(label: Text('Inside replay scope')),
                ),
              ),
              SizedBox(
                height: 140,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    controller: _scroll,
                    primary: false,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 180,
                          child: Center(
                            child: Text('Scroll down to reveal the card.'),
                          ),
                        ),
                        SizedBox(
                          height: 64,
                          child: Center(
                            child: NibMotion(
                              key: ValueKey('viewport-card-$_once-$reduced'),
                              controller: _target,
                              initial: reduced
                                  ? NibAnim.identity
                                  : const NibAnim(opacity: 0, y: 18),
                              whileInView: NibAnim.identity,
                              viewport: NibInViewConfig(
                                once: _once,
                                amount: .5,
                              ),
                              transition: const NibTransition(
                                duration: Duration(milliseconds: 600),
                                curve: Curves.linear,
                              ),
                              child: const _Tile(label: 'VIEW'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Re-enter'),
              selected: !_once,
              onSelected: (_) {
                _jump(0);
                setState(() => _once = false);
              },
            ),
            ChoiceChip(
              label: const Text('Once'),
              selected: _once,
              onSelected: (_) {
                _jump(0);
                setState(() => _once = true);
              },
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          children: [
            FilledButton(
              onPressed: () => _jump(180),
              child: const Text('Reveal'),
            ),
            OutlinedButton(
              onPressed: () => _jump(0),
              child: const Text('Hide'),
            ),
            TextButton(
              onPressed: () {
                _signal.replay();
                setState(() => _replays++);
              },
              child: const Text('Replay scope'),
            ),
          ],
        ),
        Text('Scope replay requests: $_replays'),
        if (reduced)
          const Text(
            'Reduced motion: content stays fully visible when it enters view.',
          ),
      ],
    );
  }
}

class _Lesson extends StatelessWidget {
  const _Lesson({required this.explanation, required this.children});
  final String explanation;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(explanation),
      const SizedBox(height: 12),
      for (final child in children)
        Padding(padding: const EdgeInsets.only(bottom: 8), child: child),
    ],
  );
}

class _Stage extends StatelessWidget {
  const _Stage({required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.center,
    child: child,
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, this.size = 48});
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      border: Border.all(color: Theme.of(context).colorScheme.primary),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
  );
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      ComponentToggle(value: value, label: label, onChanged: onChanged),
    ],
  );
}

class _Range extends StatelessWidget {
  const _Range({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(child: Text(label)),
          Text(value.toStringAsFixed(2)),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        semanticFormatterCallback: (v) => '$label ${v.toStringAsFixed(2)}',
      ),
    ],
  );
}

class _PathGuide extends CustomPainter {
  const _PathGuide(this.path, this.color);
  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    path,
    Paint()
      ..color = color.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );

  @override
  bool shouldRepaint(_PathGuide oldDelegate) =>
      oldDelegate.path != path || oldDelegate.color != color;
}

class _ProgressPaint extends CustomPainter {
  _ProgressPaint(this.progress, this.color) : super(repaint: progress);
  final MotionValue<double> progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.drawRRect(track, Paint()..color = color.withValues(alpha: .18));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress.value, size.height),
        const Radius.circular(4),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ProgressPaint oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
