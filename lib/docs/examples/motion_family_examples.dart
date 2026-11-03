import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// A compact sampler of the six public preset widgets.
class MotionPresetExample extends StatefulWidget {
  const MotionPresetExample({super.key});

  @override
  State<MotionPresetExample> createState() => _MotionPresetExampleState();
}

class _MotionPresetExampleState extends State<MotionPresetExample> {
  static const _names = <String>[
    'Bounce',
    'Float',
    'Pulse',
    'Shake',
    'Flip',
    'Rubber band',
  ];
  final NibShakeController _shake = NibShakeController();
  String _selected = 'Bounce';
  int _replay = 0;
  bool _flipped = false;

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _select(String name) {
    setState(() {
      _selected = name;
      _replay++;
      _flipped = false;
    });
    if (name == 'Shake') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selected == 'Shake') _shake.shake();
      });
    }
  }

  Widget _card(String label, ColorScheme colors) => Container(
    width: 108,
    height: 65,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(label, style: TextStyle(color: colors.onPrimaryContainer)),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final card = _card(_selected, colors);
    final Widget display = switch (_selected) {
      'Float' => NibFloat(key: ValueKey(_replay), child: card),
      'Pulse' => NibPulse(key: ValueKey(_replay), child: card),
      'Shake' => NibShake(controller: _shake, child: card),
      'Flip' => NibFlip(
        isFlipped: _flipped,
        front: _card('Front', colors),
        back: _card('Back', colors),
      ),
      'Rubber band' => NibRubberBand(key: ValueKey(_replay), child: card),
      _ => NibBounce(key: ValueKey(_replay), child: card),
    };
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 0,
            children: [
              for (final name in _names)
                ChoiceChip(
                  label: Text(name, style: const TextStyle(fontSize: 11)),
                  selected: name == _selected,
                  onSelected: (_) => _select(name),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          Expanded(child: Center(child: display)),
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: () {
                if (_selected == 'Shake') {
                  _shake.shake();
                } else if (_selected == 'Flip') {
                  setState(() => _flipped = !_flipped);
                } else {
                  _select(_selected);
                }
              },
              child: Text(
                _selected == 'Flip'
                    ? 'Flip card'
                    : _selected == 'Shake'
                    ? 'Shake again'
                    : 'Replay',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Replays a real [NibMotionList] while changing its delay and order.
class MotionListExample extends StatefulWidget {
  const MotionListExample({super.key});

  @override
  State<MotionListExample> createState() => _MotionListExampleState();
}

class _MotionListExampleState extends State<MotionListExample> {
  bool _reverse = false;
  bool _slow = false;
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _listControl(
                icon: Icons.swap_vert,
                tooltip: 'Change stagger direction',
                label: _reverse ? 'Last first' : 'First first',
                onPressed: () => setState(() {
                  _reverse = !_reverse;
                  _run++;
                }),
              ),
              _listControl(
                icon: Icons.timer_outlined,
                tooltip: 'Change stagger delay',
                label: _slow ? '160 ms' : '60 ms',
                onPressed: () => setState(() {
                  _slow = !_slow;
                  _run++;
                }),
              ),
              _listControl(
                icon: Icons.replay,
                tooltip: 'Replay list entrance',
                label: 'Replay',
                onPressed: () => setState(() => _run++),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: NibMotionList(
                key: ValueKey(_run),
                initial: const NibAnim(opacity: 0, y: 14),
                animate: NibAnim.identity,
                transition: const NibTransition(
                  duration: Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                ),
                staggerDelay: Duration(milliseconds: _slow ? 160 : 60),
                staggerDirection: _reverse
                    ? NibStaggerDirection.reverse
                    : NibStaggerDirection.forward,
                children: [
                  for (var index = 0; index < 3; index++)
                    Padding(
                      key: ValueKey('$_run-$index'),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Container(
                        width: 160,
                        height: 34,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Item ${index + 1}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _listControl({
    required IconData icon,
    required String tooltip,
    required String label,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: 72,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 19),
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}

/// Pinch and swipe controls with an accessible removal path.
class MotionGestureToolsExample extends StatefulWidget {
  const MotionGestureToolsExample({super.key});

  @override
  State<MotionGestureToolsExample> createState() =>
      _MotionGestureToolsExampleState();
}

class _MotionGestureToolsExampleState extends State<MotionGestureToolsExample> {
  bool _pinch = true;
  bool _dismissed = false;
  int _reset = 0;
  double _scale = 1;

  void _restore() => setState(() {
    _dismissed = false;
    _scale = 1;
    _reset++;
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final card = Container(
      key: const ValueKey('gesture-card'),
      width: 145,
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        _pinch ? 'Pinch with two fingers' : 'Swipe sideways',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.onTertiaryContainer),
      ),
    );
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final (label, isPinch) in [
                ('Pinch', true),
                ('Dismiss', false),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _pinch == isPinch,
                  onSelected: (_) => setState(() {
                    _pinch = isPinch;
                    _dismissed = false;
                    _scale = 1;
                    _reset++;
                  }),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: _dismissed
                  ? const Text('Card removed')
                  : _pinch
                  ? NibPinch(
                      key: ValueKey('pinch-$_reset'),
                      minScale: 0.7,
                      maxScale: 1.8,
                      snapBackOnRelease: true,
                      onScaleChanged: (scale) {
                        if (mounted) setState(() => _scale = scale);
                      },
                      child: card,
                    )
                  : NibSwipeDismiss(
                      key: ValueKey('swipe-$_reset'),
                      dismissThreshold: 0.4,
                      onDismissed: () {
                        if (mounted) setState(() => _dismissed = true);
                      },
                      background: const Center(child: Text('Removed')),
                      child: card,
                    ),
            ),
          ),
          Text(
            _pinch
                ? 'Scale: ${_scale.toStringAsFixed(2)}×'
                : 'Drag past 40% of the card to dismiss',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(onPressed: _restore, child: const Text('Reset card')),
              if (!_pinch && !_dismissed)
                TextButton(
                  onPressed: () => setState(() => _dismissed = true),
                  child: const Text('Remove card'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A small nested Navigator whose detail page is a real [NibPageRoute].
class MotionRoutesExample extends StatefulWidget {
  const MotionRoutesExample({super.key});

  @override
  State<MotionRoutesExample> createState() => _MotionRoutesExampleState();
}

class _MotionRoutesExampleState extends State<MotionRoutesExample> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();
  bool _detail = false;

  Future<void> _open() async {
    if (_detail) return;
    setState(() => _detail = true);
    await _navigator.currentState!.push<void>(
      NibPageRoute<void>(
        builder: (context) => _routeCard(context, 'Detail page', Icons.layers),
        initial: const NibAnim(opacity: 0, x: 30),
        exit: const NibAnim(opacity: 0, x: -30),
        transition: const NibTransition(
          duration: Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        ),
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 280),
      ),
    );
    if (mounted) setState(() => _detail = false);
  }

  void _back() {
    if (_navigator.currentState?.canPop() ?? false) {
      _navigator.currentState!.pop();
    }
  }

  Widget _routeCard(BuildContext context, String label, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerLow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 27, color: colors.primary),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 5),
            Text(
              _detail ? 'Pop to return' : 'Push to see the route transition',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 240,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _routeControl(
              icon: Icons.open_in_new,
              label: 'Open',
              tooltip: 'Open page',
              onPressed: _detail ? null : _open,
            ),
            _routeControl(
              icon: Icons.arrow_back,
              label: 'Back',
              tooltip: 'Back',
              onPressed: _detail ? _back : null,
            ),
            _routeControl(
              icon: Icons.replay,
              label: 'Reset',
              tooltip: 'Reset route demo',
              onPressed: _back,
            ),
          ],
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Navigator(
              key: _navigator,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) =>
                    _routeCard(context, 'Home page', Icons.home_outlined),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Nested Navigator with NibPageRoute',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );

  Widget _routeControl({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback? onPressed,
  }) => SizedBox(
    width: 66,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 19),
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}
