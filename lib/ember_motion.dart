import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

class EmberMotionPolicy extends InheritedWidget {
  const EmberMotionPolicy({
    super.key,
    required this.paused,
    required this.reduced,
    required this.ambient,
    required super.child,
  });

  final bool paused, reduced, ambient;

  static EmberMotionPolicy? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EmberMotionPolicy>();

  @override
  bool updateShouldNotify(EmberMotionPolicy oldWidget) =>
      paused != oldWidget.paused ||
      reduced != oldWidget.reduced ||
      ambient != oldWidget.ambient;
}

enum EmberEntrance { up, left, right, scale, tilt }

class EmberReveal extends StatelessWidget {
  const EmberReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.amount = .12,
    this.entrance = EmberEntrance.up,
  });

  final Widget child;
  final Duration delay;
  final double amount;
  final EmberEntrance entrance;

  @override
  Widget build(BuildContext context) => NibScrollReveal(
    initial: switch (entrance) {
      EmberEntrance.up => const NibAnim(opacity: 0, y: 32),
      EmberEntrance.left => const NibAnim(opacity: 0, x: -42, y: 12),
      EmberEntrance.right => const NibAnim(opacity: 0, x: 42, y: 12),
      EmberEntrance.scale => const NibAnim(opacity: 0, scale: .91, y: 18),
      EmberEntrance.tilt => const NibAnim(
        opacity: 0,
        rotate: -.012,
        scale: .96,
        y: 30,
      ),
    },
    transition: NibTransition(
      duration: const Duration(milliseconds: 900),
      delay: delay,
      curve: Curves.easeInOutCubic,
    ),
    amount: amount,
    child: child,
  );
}

class EmberHover extends StatelessWidget {
  const EmberHover({super.key, required this.child, this.scale = 1.025});
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) => NibMotionConfig(
    reducedMotion:
        (EmberMotionPolicy.maybeOf(context)?.paused ?? false) ||
        (EmberMotionPolicy.maybeOf(context)?.reduced ?? false) ||
        NibMotionConfig.shouldReduceMotion(context),
    child: NibMotion(
      whileHover: NibAnim(scale: scale, y: -4),
      whileTap: const NibAnim(scale: .96),
      transition: const NibTransition(
        spring: NibSpringDescription(stiffness: 190, damping: 23),
      ),
      child: child,
    ),
  );
}

/// A small ambient drift driven by the public NibMotion controller.
/// Visibility is measured by NibViewportProgress. Leaving the viewport,
/// pausing, focusing, or backgrounding stops the current motion in place.
class EmberFloat extends StatefulWidget {
  const EmberFloat({
    super.key,
    required this.child,
    this.y = 5,
    this.x = 0,
    this.turn = 0,
    this.scale = 1,
    this.reverse = false,
    this.duration = const Duration(milliseconds: 3200),
  });

  final Widget child;
  final double y, x, turn, scale;
  final bool reverse;
  final Duration duration;

  @override
  State<EmberFloat> createState() => _EmberFloatState();
}

class _EmberFloatState extends State<EmberFloat> with WidgetsBindingObserver {
  final motion = NibMotionController();
  final viewport = NibViewportProgressController();
  EmberMotionPolicy? policy;
  bool ready = false;
  bool running = false;
  bool foreground = true;
  bool hovered = false;
  bool focused = false;
  bool reduced = false;
  bool forward = true;
  bool restScheduled = false;
  bool returningToRest = false;
  int generation = 0;

  @override
  void initState() {
    super.initState();
    forward = !widget.reverse;
    WidgetsBinding.instance.addObserver(this);
    viewport.visibleFraction.addListener(sync);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ready = true;
      sync();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    policy = EmberMotionPolicy.maybeOf(context);
    reduced =
        (policy?.reduced ?? false) || MediaQuery.of(context).disableAnimations;
    if (ready) sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    sync();
  }

  void sync() {
    if (!ready || !mounted) return;
    if (returningToRest &&
        (reduced ||
            (policy?.paused ?? false) ||
            !foreground ||
            viewport.visibleFraction.value <= .01)) {
      generation++;
      returningToRest = false;
      motion.stop();
      if (reduced) rest();
      return;
    }
    final active =
        foreground &&
        !reduced &&
        !(policy?.paused ?? false) &&
        (policy?.ambient ?? true) &&
        !hovered &&
        !focused &&
        viewport.visibleFraction.value > .01;
    if (active == running) {
      if (!active && reduced) {
        rest();
      } else if (!active && !(policy?.ambient ?? true)) {
        settle();
      }
      return;
    }
    running = active;
    final token = ++generation;
    returningToRest = false;
    motion.stop();
    if (active) {
      drift(token);
    } else if (reduced) {
      rest();
    } else if (!(policy?.ambient ?? true)) {
      settle();
    }
  }

  void settle() {
    if (returningToRest) return;
    if (policy?.paused ?? false) {
      rest();
      return;
    }
    returningToRest = true;
    final token = generation;
    motion
        .start(
          target: NibAnim.identity,
          transition: const NibTransition(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          ),
        )
        .whenComplete(() {
          if (mounted && token == generation) returningToRest = false;
        });
  }

  void rest() {
    motion.set(NibAnim.identity);
    // The descendant also observes reduced motion and finishes its last target
    // during this build. Apply the decorative resting pose after that update.
    if (restScheduled) return;
    restScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restScheduled = false;
      if (mounted &&
          !running &&
          !returningToRest &&
          (reduced || !(policy?.ambient ?? true))) {
        motion.set(NibAnim.identity);
      }
    });
  }

  Future<void> drift(int token) async {
    while (mounted && running && token == generation) {
      final sign = forward ? 1.0 : -1.0;
      await motion.start(
        target: NibAnim(
          y: -widget.y * sign,
          x: widget.x * sign,
          rotate: widget.turn * sign,
          scale: forward ? widget.scale : 1,
        ),
        transition: NibTransition(
          duration: widget.duration,
          curve: Curves.easeInOutSine,
        ),
      );
      if (!mounted || token != generation) return;
      forward = !forward;
    }
  }

  @override
  void dispose() {
    generation++;
    viewport.visibleFraction.removeListener(sync);
    viewport.dispose();
    motion.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NibViewportProgress(
    controller: viewport,
    child: MouseRegion(
      onEnter: (_) {
        hovered = true;
        sync();
      },
      onExit: (_) {
        hovered = false;
        sync();
      },
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (value) {
          focused = value;
          sync();
        },
        child: NibMotionConfig(
          reducedMotion: reduced,
          child: NibMotion(
            controller: motion,
            initial: NibAnim.identity,
            child: NibMotionConfig(
              reducedMotion: NibMotionConfig.shouldReduceMotion(context),
              child: RepaintBoundary(child: widget.child),
            ),
          ),
        ),
      ),
    ),
  );
}
