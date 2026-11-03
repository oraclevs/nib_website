import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import 'ember_motion.dart';
export 'ember_motion.dart';

/// Values transcribed from Nib_Ember_Living_Prototype.html's :root tokens.
abstract final class Ember {
  static const bg = Color(0xFF111210);
  static const panel = Color(0xFF1B1D19);
  static const raised = Color(0xFF262922);
  static const border = Color(0xFF393D33);
  static const strong = Color(0xFF74796B);
  static const text = Color(0xFFF4E8C8);
  static const muted = Color(0xFFB8B5A4);
  static const accent = Color(0xFFFFB51B);
  static const onAccent = Color(0xFF241A05);
  static const soft = Color(0xFF332A15);
  static const code = Color(0xFF151711);
  static const positive = Color(0xFFCFDEA0);
  static const negative = Color(0xFFFFAEA3);
  static const mono = 'Ember Mono';
}

class EmberWrap extends StatelessWidget {
  const EmberWrap({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1424),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 720 ? 19 : 56,
          ),
          child: child,
        ),
      ),
    ),
  );
}

class EmberEyebrow extends StatelessWidget {
  const EmberEyebrow(this.text, {super.key, this.center = false});
  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: center
        ? MainAxisAlignment.center
        : MainAxisAlignment.start,
    children: [
      const CircleAvatar(radius: 3, backgroundColor: Ember.accent),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.visible,
          style: const TextStyle(
            color: Ember.accent,
            fontFamily: Ember.mono,
            fontSize: 10,
            letterSpacing: 1.7,
          ),
        ),
      ),
    ],
  );
}

class EmberButton extends StatefulWidget {
  const EmberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.icon,
    this.attention = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool secondary;
  final IconData? icon;
  final bool attention;

  @override
  State<EmberButton> createState() => _EmberButtonState();
}

class _EmberButtonState extends State<EmberButton> {
  final NibShakeController _shake = NibShakeController();
  Timer? _attentionTimer;
  bool _engaged = false;
  bool _nudged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleAttention(const Duration(milliseconds: 2800));
    });
  }

  @override
  void didUpdateWidget(covariant EmberButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.attention && !oldWidget.attention) {
      _scheduleAttention(const Duration(milliseconds: 2800));
    } else if (!widget.attention) {
      _attentionTimer?.cancel();
    }
  }

  void _scheduleAttention(Duration delay) {
    _attentionTimer?.cancel();
    if (!widget.attention || _engaged || _nudged) return;
    _attentionTimer = Timer(delay, _tryNudge);
  }

  void _tryNudge() {
    if (!mounted || _engaged || _nudged || !widget.attention) return;
    final renderObject = context.findRenderObject();
    final size = MediaQuery.sizeOf(context);
    final visible =
        renderObject is RenderBox &&
        renderObject.attached &&
        renderObject.hasSize &&
        () {
          final position = renderObject.localToGlobal(Offset.zero);
          return position.dy < size.height - renderObject.size.height / 2 &&
              position.dy + renderObject.size.height / 2 > 0 &&
              position.dx < size.width &&
              position.dx + renderObject.size.width > 0;
        }();
    if (!visible ||
        !TickerMode.valuesOf(context).enabled ||
        NibMotionConfig.shouldReduceMotion(context)) {
      _scheduleAttention(const Duration(milliseconds: 900));
      return;
    }
    _nudged = true;
    unawaited(_shake.shake());
  }

  void _markEngaged() {
    _engaged = true;
    _attentionTimer?.cancel();
  }

  @override
  void dispose() {
    _attentionTimer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EmberFloat(
    y: widget.secondary ? 1.5 : 3,
    reverse: widget.secondary,
    duration: Duration(milliseconds: widget.secondary ? 3700 : 2900),
    child: NibShake(
      controller: _shake,
      child: EmberHover(
        scale: 1.04,
        child: OutlinedButton(
          onPressed: () {
            _markEngaged();
            widget.onPressed();
          },
          onHover: (hovering) {
            if (hovering) _markEngaged();
          },
          onFocusChange: (focused) {
            if (focused) _markEngaged();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.secondary ? Ember.text : Ember.onAccent,
            backgroundColor: widget.secondary
                ? Colors.transparent
                : Ember.accent,
            side: BorderSide(
              color: widget.secondary ? Ember.border : Ember.accent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(widget.label, textAlign: TextAlign.center)),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, size: 17),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class WaveMark extends StatelessWidget {
  const WaveMark({super.key, this.size = 30});
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _WavePainter());
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paint = Paint()
      ..color = Ember.accent
      ..strokeWidth = w / 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = w * (0.23 + i * 0.25);
      final path = Path()
        ..moveTo(w * .06, y + w * .06)
        ..cubicTo(
          w * .26,
          y - w * .16,
          w * .40,
          y - w * .07,
          w * .55,
          y + w * .03,
        )
        ..cubicTo(
          w * .69,
          y + w * .13,
          w * .84,
          y - w * .13,
          w * .95,
          y - w * .15,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
