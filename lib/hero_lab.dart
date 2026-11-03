import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import 'ember_theme.dart';
import 'recipe_art.dart';

/// The three demonstrations occupying the reference's main interaction lab.
/// NibMotion drives the card flip; Flutter turns the back-face content toward
/// the viewer. Drag and keyed reordering use Nib package widgets directly.
class HeroLab extends StatefulWidget {
  const HeroLab({
    super.key,
    required this.paused,
    required this.reduced,
    required this.ambient,
  });
  final bool paused;
  final bool reduced;
  final bool ambient;

  @override
  State<HeroLab> createState() => _HeroLabState();
}

class _HeroLabState extends State<HeroLab> {
  final flip = NibMotionController();
  MotionValue<double>? flipAngle;
  bool flipped = false;
  bool showBack = false;
  final order = <String>['Motion', 'Components', 'Generative UI'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => attachFlipAngle());
  }

  void attachFlipAngle() {
    if (!mounted) return;
    final value = flip.motionValueOf(NibProperty.rotateY);
    if (identical(value, flipAngle)) return;
    flipAngle?.removeListener(updateFace);
    flipAngle = value;
    flipAngle?.addListener(updateFace);
    updateFace();
  }

  void updateFace() {
    final next = (flipAngle?.value ?? 0).abs() >= .25;
    if (next != showBack && mounted) setState(() => showBack = next);
  }

  @override
  void didUpdateWidget(covariant HeroLab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused && !oldWidget.paused) flip.stop();
  }

  @override
  void dispose() {
    flipAngle?.removeListener(updateFace);
    flip.dispose();
    super.dispose();
  }

  void toggleFlip() {
    attachFlipAngle();
    flipped = !flipped;
    final target = NibAnim(rotateY: flipped ? .5 : 0);
    if (widget.paused || widget.reduced) {
      flip.set(target);
    } else {
      flip.start(
        target: target,
        transition: const NibTransition(
          duration: Duration(milliseconds: 560),
          curve: Curves.easeInOutCubic,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 1100;
    return Container(
      decoration: BoxDecoration(
        color: Ember.panel,
        border: Border.all(color: Ember.border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 46,
            color: const Color(0xFF191C16),
            padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 22),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'INTERACTION LAB / FEEL THE DIFFERENCE',
                    style: TextStyle(
                      fontFamily: Ember.mono,
                      fontSize: mobile ? 8 : 10,
                      letterSpacing: mobile ? .5 : 1.2,
                      color: Ember.muted,
                    ),
                  ),
                ),
                const CircleAvatar(radius: 3, backgroundColor: Ember.accent),
                const SizedBox(width: 8),
                Text(
                  'THREE WAYS TO PLAY',
                  style: TextStyle(
                    fontFamily: Ember.mono,
                    fontSize: mobile ? 8 : 9,
                    color: Ember.accent,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Ember.border),
          TickerMode(
            enabled: !widget.paused,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations:
                    widget.reduced || MediaQuery.of(context).disableAnimations,
              ),
              child: CustomPaint(
                painter: widget.ambient ? _DotFieldPainter() : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 18 : 44,
                    vertical: mobile ? 27 : 25,
                  ),
                  child: mobile
                      ? Column(
                          children: [
                            _flipCard(),
                            const SizedBox(height: 30),
                            _springField(),
                            const SizedBox(height: 28),
                            _identity(),
                          ],
                        )
                      : SizedBox(
                          height: 310,
                          child: Row(
                            children: [
                              Expanded(child: _flipCard()),
                              const SizedBox(width: 28),
                              Expanded(child: _springField()),
                              const SizedBox(width: 32),
                              Expanded(child: _identity()),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Ember.border),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 18 : 22,
              vertical: 14,
            ),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              children: const [
                _LabTag(Icons.flip, 'CHANGE PERSPECTIVE'),
                _LabTag(Icons.drag_indicator, 'DIRECT MANIPULATION'),
                _LabTag(Icons.layers_outlined, 'CONTINUOUS IDENTITY'),
                _LabTag(Icons.code, 'EXPLORE → ADAPT'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flipCard() => SizedBox(
    height: 270,
    child: Center(
      child: SizedBox(
        width: 320,
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(child: OrbitRings()),
            EmberFloat(
              y: 5,
              x: -2,
              turn: -.007,
              reverse: true,
              child: Transform.rotate(
                angle: -13 * math.pi / 180,
                child: Container(
                  width: 182,
                  height: 226,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303326),
                    border: Border.all(color: const Color(0xFF64694A)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            EmberFloat(
              y: 8,
              x: 2,
              turn: .008,
              child: NibMotion(
                controller: flip,
                initial: const NibAnim(scale: 1, rotate: -5 / 360, rotateY: 0),
                animate: const NibAnim(scale: 1, rotate: -5 / 360, rotateY: 0),
                whileTap: const NibAnim(scale: .97, rotate: 0),
                transition: NibTransition.springSnappy,
                child: Semantics(
                  button: true,
                  label: showBack
                      ? 'Flip card. Back: A different point of view.'
                      : 'Flip card. Front: Make it move you.',
                  onTap: toggleFlip,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(showBack ? math.pi : 0),
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: toggleFlip,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 190,
                          height: 232,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: showBack ? Ember.positive : Ember.accent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55000000),
                                blurRadius: 30,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'NIB / MOTION',
                                    style: TextStyle(
                                      fontFamily: Ember.mono,
                                      fontSize: 9,
                                      color: Ember.onAccent,
                                    ),
                                  ),
                                  WaveMark(size: 17),
                                ],
                              ),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    showBack
                                        ? 'A different\npoint of view.'
                                        : 'Make it\nmove you.',
                                    style: const TextStyle(
                                      color: Ember.onAccent,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1.4,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tap to flip',
                                    style: TextStyle(
                                      color: Ember.onAccent,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 17,
                                    color: Ember.onAccent,
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
              ),
            ),
            const Positioned(
              top: 5,
              left: 0,
              child: _FloatingLabel('PERSPECTIVE / 3D'),
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: _FloatingLabel('TAP TO TURN IT AROUND', reverse: true),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _springField() => EmberFloat(
    y: 5,
    reverse: true,
    duration: const Duration(milliseconds: 4100),
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Ember.bg,
        border: Border.all(color: Ember.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPRING FIELD',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: Ember.muted,
                ),
              ),
              CircleAvatar(radius: 3, backgroundColor: Ember.positive),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 78,
            width: double.infinity,
            child: CustomPaint(painter: _SpringCurvePainter()),
          ),
          const SizedBox(height: 9),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'k / 180',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 9,
                  color: Ember.muted,
                ),
              ),
              Text(
                'c / 18',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 9,
                  color: Ember.muted,
                ),
              ),
              Text(
                'm / 1',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 9,
                  color: Ember.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 78,
            decoration: BoxDecoration(
              border: Border.all(color: Ember.strong, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Semantics(
                label: 'Drag the spring puck; it returns on release',
                child: NibDraggable(
                  bounds: const Rect.fromLTWH(-75, -14, 150, 28),
                  snapBack: true,
                  spring: NibSpringDescription.gentle,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Ember.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Drag. Release. Return.',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 9,
                  color: Ember.muted,
                ),
              ),
              Text(
                '0 px',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 9,
                  color: Ember.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _identity() => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 290),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'IDENTITY IN MOTION',
              style: TextStyle(
                fontFamily: Ember.mono,
                fontSize: 9,
                letterSpacing: 1.1,
                color: Ember.muted,
              ),
            ),
            Text(
              '03 NODES',
              style: TextStyle(
                fontFamily: Ember.mono,
                fontSize: 9,
                color: Ember.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        NibLayoutGroup(
          transition: NibTransition.springGentle,
          children: [
            for (var i = 0; i < order.length; i++)
              EmberFloat(
                key: ValueKey(order[i]),
                y: 2.5,
                x: 2,
                reverse: i.isOdd,
                duration: Duration(milliseconds: 2800 + i * 500),
                child: Container(
                  height: 45,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Ember.bg,
                    border: Border.all(color: Ember.border),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '0${i + 1}',
                        style: const TextStyle(
                          fontFamily: Ember.mono,
                          fontSize: 9,
                          color: Ember.muted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const WaveMark(size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          order[i],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Ember.text,
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 3,
                        backgroundColor: Ember.positive,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Same elements. New places.',
                style: TextStyle(color: Ember.muted, fontSize: 11),
              ),
            ),
            EmberHover(
              child: TextButton.icon(
                onPressed: () => setState(() => order.add(order.removeAt(0))),
                icon: const Icon(Icons.shuffle, size: 14),
                label: const Text('Shuffle'),
                style: TextButton.styleFrom(foregroundColor: Ember.text),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _LabTag extends StatelessWidget {
  const _LabTag(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Ember.accent, size: 14),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          fontFamily: Ember.mono,
          fontSize: 9,
          color: Ember.muted,
        ),
      ),
    ],
  );
}

class _DotFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF454B39).withValues(alpha: .62);
    for (var x = 0.0; x < size.width; x += 22) {
      for (var y = 0.0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), .7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpringCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Ember.border
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * .38),
      Offset(size.width, size.height * .38),
      grid,
    );
    canvas.drawLine(
      Offset(0, size.height * .81),
      Offset(size.width, size.height * .81),
      grid,
    );
    final line = Paint()
      ..color = Ember.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * .82)
      ..cubicTo(
        size.width * .09,
        size.height * .80,
        size.width * .08,
        size.height * .32,
        size.width * .20,
        size.height * .34,
      )
      ..cubicTo(
        size.width * .32,
        size.height * .37,
        size.width * .37,
        size.height * .36,
        size.width * .46,
        size.height * .38,
      )
      ..lineTo(size.width, size.height * .38);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingLabel extends StatelessWidget {
  const _FloatingLabel(this.label, {this.reverse = false});
  final String label;
  final bool reverse;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: EmberFloat(
      y: 6,
      reverse: reverse,
      duration: const Duration(milliseconds: 3600),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: Ember.bg,
          border: Border.all(color: Ember.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: Ember.mono,
            fontSize: 8,
            letterSpacing: .3,
            color: reverse ? Ember.accent : Ember.muted,
          ),
        ),
      ),
    ),
  );
}
