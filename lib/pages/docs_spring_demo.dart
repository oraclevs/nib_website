import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

/// The documentation preview and its copyable example use this same widget.
/// Pausing freezes position. Resuming starts a spring from that position.
class DocumentationSpring extends StatefulWidget {
  const DocumentationSpring({
    super.key,
    required this.target,
    this.stiffness = 180,
    this.damping = 18,
    this.paused = false,
    this.reduceMotion = false,
    this.size = 78,
  });

  final double target;
  final double stiffness;
  final double damping;
  final bool paused;
  final bool reduceMotion;
  final double size;

  @override
  State<DocumentationSpring> createState() => _DocumentationSpringState();
}

class _DocumentationSpringState extends State<DocumentationSpring> {
  final _controller = NibMotionController();
  late final double _initialTarget = widget.target;

  @override
  void didUpdateWidget(covariant DocumentationSpring oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target ||
        oldWidget.stiffness != widget.stiffness ||
        oldWidget.damping != widget.damping ||
        oldWidget.paused != widget.paused ||
        oldWidget.reduceMotion != widget.reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _update();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _update();
    });
  }

  void _update() {
    final target = NibAnim(x: widget.target);
    if (widget.reduceMotion || MediaQuery.disableAnimationsOf(context)) {
      _controller.set(target);
    } else if (widget.paused) {
      _controller.stop();
    } else {
      _controller.start(
        target: target,
        transition: NibTransition(
          spring: NibSpringDescription(
            stiffness: widget.stiffness,
            damping: widget.damping,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NibMotion(
    controller: _controller,
    initial: NibAnim(x: _initialTarget),
    child: Transform.rotate(
      angle: -0.10472,
      child: Semantics(
        label: 'Spring position marker',
        child: Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB51B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const CustomPaint(
            size: Size(30, 30),
            painter: DocumentationWave(),
          ),
        ),
      ),
    ),
  );
}

class DocumentationWave extends CustomPainter {
  const DocumentationWave({this.color = const Color(0xFF241A05)});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(2, 16)
        ..cubicTo(7, -2, 12, 31, 22, 6)
        ..moveTo(2, 10)
        ..cubicTo(7, -8, 12, 25, 22, 0),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(DocumentationWave oldDelegate) =>
      color != oldDelegate.color;
}
