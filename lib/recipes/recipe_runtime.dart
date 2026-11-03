import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';

import 'recipe_tuning.dart';

/// Drives the same interaction as the recipe's on-screen controls.
/// Calls after the recipe is unmounted have no effect.
class RecipeRuntimeController {
  Object? _owner;
  VoidCallback? _play;
  VoidCallback? _reset;

  void play() => _play?.call();
  void reset() => _reset?.call();

  void _attach(Object owner, VoidCallback play, VoidCallback reset) {
    _owner = owner;
    _play = play;
    _reset = reset;
  }

  void _detach(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    _play = null;
    _reset = null;
  }

  void dispose() {
    _owner = null;
    _play = null;
    _reset = null;
  }
}

/// The compiled implementation used by the playground. This file is bundled
/// as a source asset and copied verbatim with a generated launcher. It has no
/// website-only imports, so the same file works in a small Flutter consumer.
class RecipeRuntime extends StatefulWidget {
  const RecipeRuntime({
    super.key,
    required this.recipeId,
    required this.value,
    this.settings = const RecipeTuning(),
    this.controller,
  });

  final String recipeId;
  final double value;
  final RecipeTuning settings;
  final RecipeRuntimeController? controller;

  @override
  State<RecipeRuntime> createState() => _RecipeRuntimeState();
}

class _RecipeRuntimeState extends State<RecipeRuntime> {
  static const ink = Color(0xFFF4E8C8);
  static const muted = Color(0xFFB8B5A4);
  static const accent = Color(0xFFFFB51B);
  static const dark = Color(0xFF1B1D19);

  bool active = false;
  int step = 0;
  int count = 0;
  List<int> order = [0, 1, 2];
  late final Ticker _taskTicker;
  Duration _taskElapsed = Duration.zero;
  Duration _taskStartedFrom = Duration.zero;
  int _taskStepMs = 1;
  bool _taskPending = false;
  bool _taskIsSequence = false;
  bool _taskVisible = true;
  final _name = TextEditingController();
  final _scroll = ScrollController();
  late ScrollMotionBridge _scrollBridge;
  late DerivedMotionValue<double, double> _scrollMarker;
  final _shake = NibShakeController();
  final _focus = FocusNode();
  final _triggerFocus = FocusNode();
  bool _invalid = false;

  NibSpringDescription get _springDescription => NibSpringDescription(
    mass: widget.settings.mass,
    stiffness: widget.settings.stiffness,
    damping: widget.settings.damping,
  );

  NibTransition get _springTransition =>
      NibTransition(spring: _springDescription);

  NibTransition get _timedTransition => NibTransition(
    duration: Duration(milliseconds: widget.settings.durationMs.round()),
    curve: widget.settings.curve,
  );

  double get _secondary => widget.settings.secondary ?? 24;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this, _act, _reset);
    _taskTicker = Ticker(_advanceTask);
    _scrollBridge = ScrollMotionBridge(controller: _scroll);
    _scrollMarker = _scrollBridge.scrollY.mapRange(
      [0, widget.settings.secondary ?? 400],
      [0, widget.value],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskVisible = TickerMode.valuesOf(context).enabled;
    if (!_taskVisible) {
      _taskTicker.stop();
    } else if (_taskPending && !_taskTicker.isActive) {
      _taskStartedFrom = _taskElapsed;
      _taskTicker.start();
    }
  }

  void _advanceTask(Duration elapsed) {
    _taskElapsed = _taskStartedFrom + elapsed;
    final next = _taskIsSequence
        ? (_taskElapsed.inMilliseconds ~/ _taskStepMs).clamp(0, 3)
        : (_taskElapsed.inMilliseconds >= _taskStepMs ? 2 : 1);
    if (next != count) setState(() => count = next);
    if ((_taskIsSequence && next == 3) || (!_taskIsSequence && next == 2)) {
      _taskPending = false;
      _taskTicker.stop();
    }
  }

  void _startTask({required bool sequence}) {
    _taskTicker.stop();
    _taskElapsed = Duration.zero;
    _taskStartedFrom = Duration.zero;
    _taskStepMs = math.max(1, widget.value.round());
    _taskIsSequence = sequence;
    _taskPending = true;
    setState(() {
      count = sequence ? 0 : 1;
      step++;
    });
    if (_taskVisible) _taskTicker.start();
  }

  void _cancelTask() {
    _taskPending = false;
    _taskTicker.stop();
    _taskElapsed = Duration.zero;
  }

  @override
  void didUpdateWidget(covariant RecipeRuntime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this, _act, _reset);
    }
    if (oldWidget.value != widget.value ||
        oldWidget.settings.secondary != widget.settings.secondary) {
      _scrollMarker.dispose();
      _scrollMarker = _scrollBridge.scrollY.mapRange(
        [0, widget.settings.secondary ?? 400],
        [0, widget.value],
      );
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _taskTicker.dispose();
    _name.dispose();
    _scrollMarker.dispose();
    _scrollBridge.dispose();
    _scroll.dispose();
    _shake.dispose();
    _focus.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  void _act() {
    switch (widget.recipeId) {
      case 'card-flip':
        setState(() => active = !active);
      case 'animated-counter':
        setState(() {
          count += widget.value.round();
          step++;
        });
      case 'progress-choreography':
        setState(() => count = (count + widget.value.round()).clamp(0, 100));
      case 'keyed-reorder':
        setState(() => order = [order[1], order[2], order[0]]);
      case 'stagger-list':
      case 'keyframe-hop':
        setState(() => step++);
      case 'onboarding-sequence':
        _startTask(sequence: true);
      case 'loading-result':
        _startTask(sequence: false);
      case 'form-validation':
        final invalid = _name.text.trim().length < widget.value.round();
        setState(() => _invalid = invalid);
        if (invalid) unawaited(_shake.shake());
      case 'focus-overlay':
        setState(() => active = !active);
        if (active) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _focus.requestFocus();
          });
        } else {
          _focus.unfocus();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _triggerFocus.requestFocus();
          });
        }
      case 'swipe-restore':
        setState(() {
          active = !active;
          step++;
        });
      default:
        setState(() {
          active = !active;
          step++;
        });
    }
  }

  void _reset() {
    _cancelTask();
    setState(() {
      active = false;
      step = 0;
      count = 0;
      order = [0, 1, 2];
      _invalid = false;
      _name.clear();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.recipeId;
    if (id == 'card-flip') return Center(child: _cardFlip());
    final direct = const {
      'hover-press',
      'viewport-reveal',
      'local-parallax',
      'scroll-progress',
      'accordion',
    }.contains(id);
    return LayoutBuilder(
      builder: (context, bounds) => Center(
        child: SizedBox(
          width: math.min(bounds.maxWidth, 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: SizedBox(
                  height: 235,
                  child: Center(child: _scene(context, id)),
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!direct)
                    FilledButton.icon(
                      focusNode: id == 'focus-overlay' ? _triggerFocus : null,
                      onPressed: id == 'progress-choreography' && count >= 100
                          ? null
                          : _act,
                      icon: const Icon(Icons.play_arrow, size: 17),
                      label: Text(_actionLabel(id)),
                    ),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt, size: 17),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(String id) => switch (id) {
    'keyframe-hop' || 'stagger-list' => 'Replay',
    'animated-counter' => 'Add ${widget.value.round()}',
    'progress-choreography' => count >= 100 ? 'Complete' : 'Advance step',
    'keyed-reorder' => 'Shuffle',
    'form-validation' => 'Check name',
    'bounded-drag' => active ? 'Center the puck' : 'Nudge right',
    'drag-snap' => active ? 'Center the puck' : 'Snap right',
    'swipe-restore' => active ? 'Restore row' : 'Dismiss row',
    'loading-result' => 'Run local task',
    'focus-overlay' => active ? 'Close panel' : 'Open panel',
    'card-flip' => active ? 'Show front' : 'Show back',
    _ => active ? 'Reverse' : 'Try it',
  };

  Widget _scene(BuildContext context, String id) => switch (id) {
    'keyframe-hop' => _keyframeHop(),
    'spring-tween' => _springTween(),
    'animated-counter' => _animatedCounter(),
    'progress-choreography' => _progress(),
    'linked-objects' => _linkedObjects(),
    'card-flip' => _cardFlip(),
    'bounded-drag' => _boundedDrag(),
    'swipe-restore' => _swipeRestore(),
    'hover-press' => _hoverPress(),
    'drag-snap' => _dragSnap(),
    'pivot-turn' => _pivotTurn(),
    'keyed-reorder' => _keyedReorder(),
    'presence-reflow' => _presenceReflow(),
    'expanding-card' => _expandingCard(),
    'filtered-list' => _filteredList(),
    'selection-indicator' => _selectionIndicator(),
    'focus-overlay' => _focusOverlay(),
    'stagger-list' => _staggerList(),
    'variant-orchestration' => _variants(),
    'onboarding-sequence' => _onboarding(),
    'loading-result' => _loadingResult(),
    'command-palette' => _commandPalette(),
    'viewport-reveal' => _viewportReveal(),
    'local-parallax' => _localParallax(),
    'scroll-progress' => _scrollProgress(),
    'page-transition' => _pageTransition(),
    'form-validation' => _formValidation(),
    'tab-content' => _tabContent(),
    'accordion' => _accordion(),
    _ => const Text('Recipe unavailable.'),
  };

  Widget _tile(String label, {Color color = dark, IconData? icon}) => Container(
    width: 190,
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: const Color(0xFF74796B)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(label, style: const TextStyle(color: ink)),
        ),
      ],
    ),
  );

  Widget _puck({String text = 'N', double size = 58}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF241A05),
        fontSize: 23,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _keyframeHop() => NibMotion(
    key: ValueKey(step),
    keyframes: [
      NibKeyframe(at: 0, value: NibAnim(y: widget.value, opacity: 0)),
      NibKeyframe(
        at: .55,
        value: NibAnim(
          y: -widget.value * (widget.settings.secondary ?? .25),
          opacity: 1,
        ),
      ),
      const NibKeyframe(at: 1, value: NibAnim(y: 0, opacity: 1)),
    ],
    transition: _timedTransition,
    child: _puck(),
  );

  Widget _springTween() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final spring in [true, false])
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  spring ? 'SPRING' : 'TIMED',
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ),
              NibMotion(
                animate: NibAnim(x: active ? widget.value : 0),
                transition: spring ? _springTransition : _timedTransition,
                child: _puck(text: spring ? 'S' : 'T', size: 40),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _animatedCounter() => NibMotion(
    key: ValueKey(step),
    initial: NibAnim(
      scale: widget.settings.secondary ?? .7,
      opacity: .25,
      y: 12,
    ),
    animate: NibAnim.identity,
    transition: _timedTransition,
    child: Semantics(
      liveRegion: true,
      child: Text(
        '$count',
        style: const TextStyle(
          color: accent,
          fontSize: 88,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  Widget _progress() {
    final progress = count.clamp(0, 100);
    final complete = progress == 100;
    const stages = ['Prepare', 'Process', 'Finish'];
    return Container(
      key: const ValueKey('progress-task-panel'),
      width: 410,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark,
        border: Border.all(color: const Color(0xFF393D33)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SIMULATED TASK',
            style: TextStyle(color: muted, fontSize: 9, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  complete ? 'Task complete' : 'Preparing a report',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  '$progress%',
                  key: const ValueKey('progress-value'),
                  style: const TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            label: 'Simulated task progress',
            value: '$progress percent',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LayoutBuilder(
                builder: (context, bounds) => SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: Color(0xFF393D33)),
                      ),
                      NibMotion(
                        key: const ValueKey('progress-fill-motion'),
                        initial: NibAnim(x: -bounds.maxWidth),
                        animate: NibAnim(
                          x: bounds.maxWidth * (progress / 100 - 1),
                        ),
                        transition: _springTransition,
                        child: SizedBox(
                          width: bounds.maxWidth,
                          height: 8,
                          child: const ColoredBox(color: accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < stages.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  NibMotion(
                    animate: NibAnim(
                      scale: progress >= (i + 1) * 100 / 3 ? 1 : .85,
                    ),
                    transition: _springTransition,
                    child: Icon(
                      progress >= (i + 1) * 100 / 3
                          ? Icons.check_circle_outline
                          : Icons.circle_outlined,
                      size: 14,
                      color: progress >= (i + 1) * 100 / 3 ? accent : muted,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      stages[i],
                      style: const TextStyle(color: ink, fontSize: 11),
                    ),
                  ),
                  Text(
                    progress >= (i + 1) * 100 / 3
                        ? 'Done'
                        : progress >= i * 100 / 3 && !complete
                        ? 'Ready'
                        : 'Waiting',
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            complete
                ? 'Reset to try a different response.'
                : 'Advance manually. No files are uploaded.',
            style: const TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _linkedObjects() => SizedBox(
    width: 300,
    child: Row(
      children: [
        NibMotion(
          animate: NibAnim(x: active ? widget.value : 0),
          transition: _springTransition,
          child: _puck(text: '1', size: 44),
        ),
        const SizedBox(width: 16),
        NibMotion(
          animate: NibAnim(x: active ? widget.value : 0),
          transition: NibTransition(
            spring: NibSpringDescription(
              mass: widget.settings.mass,
              stiffness: widget.settings.stiffness * .7,
              damping: widget.settings.damping * .75,
            ),
          ),
          child: _puck(text: '2', size: 44),
        ),
      ],
    ),
  );

  Widget _cardFlip() => LayoutBuilder(
    builder: (context, bounds) {
      final compact = MediaQuery.sizeOf(context).width < 640;
      final width = compact ? 180.0 : 207.0;
      final height = compact ? 226.0 : 252.0;
      return Center(
        child: SizedBox(
          width: math.min(bounds.maxWidth, 310),
          height: 292,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Transform.rotate(
                  angle: -20 * math.pi / 180,
                  child: SizedBox(
                    width: 285,
                    height: 245,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0x19FFB51B),
                              ),
                              borderRadius: BorderRadius.circular(150),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 46,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x66FFB51B),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              NibMotion(
                animate: NibAnim(rotate: (active ? 4 : -5) / 360),
                whileHover: const NibAnim(rotate: 0, y: -3),
                whileFocus: const NibAnim(rotate: 0, y: -3),
                transition: const NibTransition(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: NibFlip(
                    isFlipped: active,
                    flipAxis: widget.settings.option
                        ? Axis.vertical
                        : Axis.horizontal,
                    duration: Duration(milliseconds: widget.value.round()),
                    front: _flipFace(back: false),
                    back: _flipFace(back: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _flipFace({required bool back}) {
    final foreground = back ? const Color(0xFF243017) : const Color(0xFF241A05);
    return Semantics(
      label: back
          ? 'Return to front of demonstration card'
          : 'Flip the demonstration card',
      button: true,
      toggled: back,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              offset: Offset(0, 18),
              blurRadius: 45,
            ),
          ],
        ),
        child: Material(
          color: back ? const Color(0xFFCFDEA0) : accent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            focusNode: back ? _triggerFocus : _focus,
            onTap: _act,
            borderRadius: BorderRadius.circular(12),
            focusColor: foreground.withValues(alpha: .08),
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(21),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: foreground,
                  fontFamily: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.fontFamily,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              back ? 'A NEW PERSPECTIVE' : 'NIB / MOTION',
                              style: const TextStyle(
                                fontFamily: 'Ember Mono',
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          back ? Icons.layers_outlined : Icons.waves_rounded,
                          size: 18,
                          color: foreground,
                        ),
                      ],
                    ),
                    Text(
                      back ? 'Keep the\nfeeling.' : 'Make it\nmove you.',
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.05,
                        letterSpacing: -1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              back ? 'Tap to return' : 'Tap to flip',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          back ? Icons.restart_alt : Icons.arrow_forward,
                          size: 16,
                          color: foreground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _boundedDrag() => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: widget.value * 2 + 62,
        height: 175,
        decoration: BoxDecoration(
          border: Border.all(color: muted),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      NibMotion(
        animate: NibAnim(x: active ? widget.value * .6 : 0),
        transition: _springTransition,
        child: NibDraggable(
          bounds: Rect.fromCenter(
            center: Offset.zero,
            width: widget.value * 2,
            height: widget.value * 1.3,
          ),
          snapBack: widget.settings.option,
          spring: _springDescription,
          child: _puck(),
        ),
      ),
    ],
  );

  Widget _swipeRestore() => SizedBox(
    width: 285,
    child: active
        ? const Text('Row dismissed. Use Restore row to bring it back.')
        : NibSwipeDismiss(
            key: ValueKey(step),
            dismissThreshold: widget.value,
            spring: _springDescription,
            onDismissed: () => setState(() => active = true),
            background: Container(color: const Color(0xFF59322A)),
            child: _tile('Swipe to dismiss', icon: Icons.swipe),
          ),
  );

  Widget _hoverPress() => NibMotion(
    whileHover: NibAnim(scale: widget.value),
    whileFocus: NibAnim(scale: widget.value),
    whileTap: NibAnim(scale: widget.settings.secondary ?? .92),
    transition: _springTransition,
    child: ElevatedButton(
      onPressed: () => setState(() => count++),
      child: Text('Press me · $count'),
    ),
  );

  Widget _dragSnap() => Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  border: Border.all(color: muted),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
      NibMotion(
        animate: NibAnim(x: active ? widget.value : 0),
        transition: _springTransition,
        drag: NibDragConfig(
          axis: Axis.horizontal,
          elastic: widget.settings.elasticity > 0,
          elasticFactor: widget.settings.elasticity,
          releaseMode: switch (widget.settings.release) {
            RecipeDragRelease.springBack => NibDragReleaseMode.springBack,
            RecipeDragRelease.inertia => NibDragReleaseMode.inertia,
            RecipeDragRelease.stay => NibDragReleaseMode.stay,
          },
          constraints: Rect.fromLTWH(-widget.value, 0, widget.value * 2, 0),
          snapPoints: widget.settings.release == RecipeDragRelease.springBack
              ? [Offset(-widget.value, 0), Offset.zero, Offset(widget.value, 0)]
              : null,
        ),
        child: _puck(size: 46),
      ),
    ],
  );

  Widget _pivotTurn() => NibMotion(
    animate: NibAnim(rotate: active ? widget.value / 360 : 0),
    transition: _springTransition,
    child: SizedBox(
      width: 260,
      height: 90,
      child: Align(
        alignment: Alignment.centerRight,
        child: _tile('Off-centre turn', icon: Icons.rotate_right),
      ),
    ),
  );

  Widget _keyedReorder() => SizedBox(
    width: 250,
    child: NibLayoutGroup(
      transition: _springTransition,
      children: [
        for (final index in order)
          Padding(
            key: ValueKey(index),
            padding: EdgeInsets.only(bottom: widget.value),
            child: _tile(
              '0${index + 1}  ${['Motion', 'Components', 'GenUI'][index]}',
            ),
          ),
      ],
    ),
  );

  Widget _presenceReflow() => SizedBox(
    width: 235,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tile('First row'),
        const SizedBox(height: 8),
        NibPresence(
          children: [
            if (!active)
              NibMotion(
                key: const ValueKey('middle'),
                exit: NibAnim(x: widget.value, opacity: 0),
                transition: _timedTransition,
                child: _tile('Remove me'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _tile('Last row'),
      ],
    ),
  );

  Widget _expandingCard() => SizedBox(
    width: 250,
    child: AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: widget.settings.durationMs.round()),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: dark,
          border: Border.all(color: muted),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Compact first', style: TextStyle(color: ink)),
            if (active)
              SizedBox(
                height: widget.value,
                child: NibMotion(
                  initial: const NibAnim(opacity: 0, y: 12),
                  animate: NibAnim.identity,
                  transition: _timedTransition,
                  child: const Center(
                    child: Text(
                      'Details stay attached to their card.',
                      style: TextStyle(color: muted),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _filteredList() => SizedBox(
    width: 235,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NibPresence(
          children: [
            for (final index in (active ? [0, 2] : [0, 1, 2]))
              NibMotion(
                key: ValueKey(index),
                exit: NibAnim(x: widget.value, opacity: 0),
                transition: _timedTransition,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _tile(['Motion', 'Components', 'GenUI'][index]),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _selectionIndicator() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in ['Build', 'Tune', 'Copy'])
            SizedBox(
              width: widget.value,
              child: Text(item, textAlign: TextAlign.center),
            ),
        ],
      ),
      const SizedBox(height: 7),
      SizedBox(
        width: widget.value * 3,
        child: Align(
          alignment: Alignment.centerLeft,
          child: NibMotion(
            animate: NibAnim(x: active ? widget.value * 2 : 0),
            transition: _springTransition,
            child: Container(width: widget.value, height: 3, color: accent),
          ),
        ),
      ),
    ],
  );

  Widget _focusOverlay() => SizedBox(
    width: 270,
    height: 175,
    child: Stack(
      alignment: Alignment.center,
      children: [
        _tile('Behind the panel'),
        NibPresence(
          children: [
            if (active)
              NibMotion(
                key: const ValueKey('panel'),
                initial: NibAnim(opacity: 0, y: widget.value),
                animate: NibAnim.identity,
                exit: NibAnim(opacity: 0, y: widget.value),
                transition: _timedTransition,
                child: Material(
                  color: const Color(0xFF332A15),
                  child: SizedBox(
                    width: 225,
                    height: 125,
                    child: Center(
                      child: TextButton(
                        focusNode: _focus,
                        onPressed: _act,
                        child: const Text('Close panel'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _staggerList() => NibMotionList(
    key: ValueKey(step),
    initial: NibAnim(opacity: 0, y: _secondary),
    animate: NibAnim.identity,
    transition: _timedTransition,
    staggerDelay: Duration(milliseconds: widget.value.round()),
    children: [
      for (var index = 0; index < 3; index++)
        Padding(
          key: ValueKey(index),
          padding: const EdgeInsets.only(bottom: 8),
          child: _tile(['Make', 'Tune', 'Ship'][index]),
        ),
    ],
  );

  Widget _variants() => NibMotion(
    animate: active ? 'open' : 'closed',
    variants: {
      'open': NibAnim(opacity: 1),
      'closed': NibAnim(opacity: widget.settings.opacity),
    },
    transition: NibTransition(
      duration: Duration(milliseconds: widget.settings.durationMs.round()),
      curve: widget.settings.curve,
      staggerChildren: Duration(milliseconds: widget.value.round()),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 3; index++)
          Padding(
            padding: const EdgeInsets.all(5),
            child: NibMotion(
              variants: {
                'open': NibAnim(y: -_secondary * index, scale: 1),
                'closed': const NibAnim(y: 0, scale: .75),
              },
              child: _puck(text: '${index + 1}', size: 42),
            ),
          ),
      ],
    ),
  );

  Widget _onboarding() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < 3; index++)
        Padding(
          padding: const EdgeInsets.all(6),
          child: NibMotion(
            animate: NibAnim(
              opacity: count > index ? 1 : .25,
              scale: count > index ? 1 : .78,
            ),
            transition: _timedTransition,
            child: _puck(text: '${index + 1}', size: 48),
          ),
        ),
    ],
  );

  Widget _loadingResult() => NibPresence(
    children: [
      if (count == 0)
        NibMotion(
          key: const ValueKey('ready'),
          exit: const NibAnim(opacity: 0, scale: .8),
          transition: _timedTransition,
          child: _tile('Ready when you are'),
        ),
      if (count == 1)
        NibMotion(
          key: ValueKey('loading-$step'),
          initial: const NibAnim(opacity: 0, y: 15),
          animate: NibAnim.identity,
          exit: const NibAnim(opacity: 0, y: -15),
          transition: _timedTransition,
          child: _tile('Working locally…', icon: Icons.hourglass_bottom),
        ),
      if (count == 2)
        NibMotion(
          key: ValueKey('result-$step'),
          initial: NibAnim(opacity: 0, scale: widget.settings.scale),
          animate: NibAnim.identity,
          transition: _timedTransition,
          child: _tile('Done', icon: Icons.check_circle),
        ),
    ],
  );

  Widget _commandPalette() => NibPresence(
    children: [
      if (active)
        NibMotion(
          key: const ValueKey('palette'),
          initial: NibAnim(opacity: 0, y: -widget.value),
          animate: NibAnim.identity,
          exit: NibAnim(opacity: 0, y: -widget.value),
          transition: _timedTransition,
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tile('Search commands', icon: Icons.search),
                const SizedBox(height: 4),
                _tile('Open docs', icon: Icons.menu_book),
              ],
            ),
          ),
        )
      else
        NibMotion(
          key: const ValueKey('hint'),
          exit: const NibAnim(opacity: 0),
          child: _tile('Press Try it to open'),
        ),
    ],
  );

  Widget _viewportReveal() => SizedBox(
    width: 260,
    height: 205,
    child: ListView(
      children: [
        for (var index = 0; index < 6; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NibScrollReveal(
              initial: NibAnim(opacity: 0, y: widget.value),
              once: widget.settings.option,
              amount: widget.settings.secondary ?? .2,
              child: _tile('Section ${index + 1}'),
            ),
          ),
      ],
    ),
  );

  Widget _localParallax() => SizedBox(
    width: 270,
    height: 210,
    child: Stack(
      children: [
        Positioned.fill(
          child: ListView(
            controller: _scroll,
            children: [
              for (var index = 0; index < 7; index++)
                Padding(
                  padding: const EdgeInsets.all(7),
                  child: _tile('Layer ${index + 1}'),
                ),
            ],
          ),
        ),
        IgnorePointer(
          child: NibParallax(
            scrollController: _scroll,
            factor: MediaQuery.disableAnimationsOf(context) ? 1 : widget.value,
            child: Align(
              alignment: Alignment.topRight,
              child: _puck(text: 'N', size: 42),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _scrollProgress() => SizedBox(
    width: 285,
    height: 205,
    child: Column(
      children: [
        SizedBox(
          width: widget.value + 28,
          height: 17,
          child: Align(
            alignment: Alignment.centerLeft,
            child: NibMotion(
              motionValues: NibMotionValues(translateX: _scrollMarker),
              child: Container(
                key: const ValueKey('scroll-progress-marker'),
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            children: [
              for (var index = 0; index < 8; index++)
                Padding(
                  padding: const EdgeInsets.all(7),
                  child: _tile('Paragraph ${index + 1}'),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _pageTransition() => NibPresence(
    children: [
      NibMotion(
        key: ValueKey(active),
        initial: NibAnim(x: widget.value, opacity: 0),
        animate: NibAnim.identity,
        exit: NibAnim(x: -widget.value, opacity: 0),
        transition: _timedTransition,
        child: _tile(
          active ? 'Second view' : 'First view',
          icon: active ? Icons.bolt : Icons.layers,
        ),
      ),
    ],
  );

  Widget _formValidation() => SizedBox(
    width: 280,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: 'A name for your project',
            errorText: _invalid
                ? 'Use at least ${widget.value.round()} characters'
                : null,
          ),
        ),
        const SizedBox(height: 12),
        NibShake(
          controller: _shake,
          duration: Duration(milliseconds: widget.settings.durationMs.round()),
          child: _tile(
            _invalid ? 'Try a longer name' : 'Ready to check',
            icon: _invalid ? Icons.info_outline : Icons.check,
          ),
        ),
      ],
    ),
  );

  Widget _tabContent() => SizedBox(
    width: 260,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final value in [false, true])
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => active = value),
                  child: Text(value ? 'Code' : 'Preview'),
                ),
              ),
          ],
        ),
        NibMotion(
          key: ValueKey(active),
          initial: NibAnim(opacity: 0, x: widget.value),
          animate: NibAnim.identity,
          transition: _timedTransition,
          child: _tile(active ? 'Copyable Dart' : 'Live interaction'),
        ),
      ],
    ),
  );

  Widget _accordion() => SizedBox(
    width: 290,
    child: NibAccordion(
      animated: true,
      allowMultipleOpen: widget.settings.option,
      transition: _timedTransition,
      items: [
        NibAccordionItem(
          title: const Text('What is Nib?'),
          content: SizedBox(
            height: widget.value,
            child: const Text('Animation and native Flutter components.'),
          ),
        ),
        const NibAccordionItem(
          title: Text('Can I use the source?'),
          content: Text('Open Code, then copy the checked Dart files.'),
        ),
      ],
    ),
  );
}
