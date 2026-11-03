import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import 'ember_theme.dart';

class HomeHero extends StatefulWidget {
  const HomeHero({
    super.key,
    required this.mobile,
    required this.ambient,
    required this.playground,
    required this.docs,
    required this.copyInstall,
  });
  final bool mobile, ambient;
  final VoidCallback playground, docs, copyInstall;

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  bool _headlineComplete = false;
  bool get mobile => widget.mobile;
  bool get ambient => widget.ambient;

  Widget _typeLine(
    String text,
    TextStyle style, {
    required Duration delay,
    bool centered = false,
  }) => Stack(
    alignment: centered ? Alignment.center : Alignment.centerLeft,
    children: [
      Opacity(opacity: 0, child: Text(text, style: style)),
      Positioned.fill(
        child: Align(
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          child: NibTypewriter(
            text,
            speed: const Duration(milliseconds: 45),
            cursor: null,
            delay: delay,
            style: style,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final style = TextStyle(
      fontFamily: 'Ember Sans',
      color: Ember.text,
      fontSize: mobile ? 46 : math.min(84, width * .06),
      fontWeight: FontWeight.w700,
      height: 1.04,
      letterSpacing: mobile ? -2.2 : -3.8,
    );
    final count = Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: 0, child: Text('count.', style: style)),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _headlineComplete
                ? NibMotionConfig(
                    reducedMotion:
                        !ambient || NibMotionConfig.shouldReduceMotion(context),
                    child: NibGradientText(
                      'count.',
                      gradient: const LinearGradient(
                        colors: [
                          Ember.accent,
                          Color(0xFFFFE7A5),
                          Color(0xFFFF9342),
                          Ember.accent,
                        ],
                        tileMode: TileMode.mirror,
                      ),
                      duration: const Duration(milliseconds: 4200),
                      style: style,
                    ),
                  )
                : NibTypewriter(
                    'count.',
                    speed: const Duration(milliseconds: 65),
                    delay: const Duration(milliseconds: 1300),
                    cursor: null,
                    style: style.copyWith(color: Ember.accent),
                    onComplete: () {
                      if (mounted) setState(() => _headlineComplete = true);
                    },
                  ),
          ),
        ),
        Positioned(
          bottom: -14,
          left: -5,
          right: -5,
          height: 25,
          child: IgnorePointer(
            child: EmberFloat(
              y: 1.5,
              scale: 1.07,
              duration: const Duration(milliseconds: 2400),
              child: CustomPaint(painter: _CountGlowPainter()),
            ),
          ),
        ),
      ],
    );
    return EmberWrap(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (ambient)
            Positioned(
              top: mobile ? 42 : 16,
              left: 0,
              right: 0,
              height: mobile ? 260 : 224,
              child: IgnorePointer(
                child: EmberFloat(
                  y: 6,
                  turn: .004,
                  duration: const Duration(milliseconds: 5100),
                  child: CustomPaint(painter: _HeroOrbitPainter()),
                ),
              ),
            ),
          if (width >= 1200) ...[
            const Positioned(
              top: 35,
              left: 8,
              child: _HeroNote('BUILT TO RESPOND'),
            ),
            const Positioned(
              top: 35,
              right: 0,
              child: _HeroNote('EVERY STATE HAS A STORY', reverse: true),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              mobile ? 35 : 64,
              0,
              mobile ? 45 : 38,
            ),
            child: Column(
              children: [
                const EmberReveal(
                  entrance: EmberEntrance.scale,
                  child: EmberEyebrow(
                    'THE NIB ECOSYSTEM FOR FLUTTER',
                    center: true,
                  ),
                ),
                const SizedBox(height: 22),
                EmberReveal(
                  delay: const Duration(milliseconds: 90),
                  child: Semantics(
                    header: true,
                    label: 'Make every interaction count.',
                    excludeSemantics: true,
                    child: mobile
                        ? Column(
                            children: [
                              _typeLine(
                                'Make every',
                                style,
                                delay: const Duration(milliseconds: 180),
                                centered: true,
                              ),
                              _typeLine(
                                'interaction',
                                style,
                                delay: const Duration(milliseconds: 700),
                                centered: true,
                              ),
                              count,
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _typeLine(
                                'Make every interaction ',
                                style,
                                delay: const Duration(milliseconds: 180),
                              ),
                              count,
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                const EmberReveal(
                  entrance: EmberEntrance.left,
                  delay: Duration(milliseconds: 170),
                  child: Text(
                    'Motion, components and generative UI.\nExplore the interaction. Understand the details. Make it your own.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Ember.muted,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                EmberReveal(
                  entrance: EmberEntrance.right,
                  delay: const Duration(milliseconds: 250),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      EmberButton(
                        label: 'Explore the playground',
                        icon: Icons.arrow_forward,
                        onPressed: widget.playground,
                        attention: true,
                      ),
                      EmberButton(
                        label: 'Read the docs',
                        icon: Icons.menu_book_outlined,
                        secondary: true,
                        onPressed: widget.docs,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                EmberReveal(
                  entrance: EmberEntrance.scale,
                  delay: const Duration(milliseconds: 320),
                  child: EmberHover(
                    child: TextButton.icon(
                      onPressed: widget.copyInstall,
                      icon: const Text(
                        r'$ ',
                        style: TextStyle(
                          fontFamily: Ember.mono,
                          color: Ember.muted,
                          fontSize: 11,
                        ),
                      ),
                      label: const Text(
                        'flutter pub add nib_motion',
                        style: TextStyle(
                          fontFamily: Ember.mono,
                          color: Ember.text,
                          fontSize: 11,
                        ),
                      ),
                      style: TextButton.styleFrom(foregroundColor: Ember.muted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroNote extends StatelessWidget {
  const _HeroNote(this.label, {this.reverse = false});
  final String label;
  final bool reverse;
  @override
  Widget build(BuildContext context) => EmberFloat(
    y: 5,
    reverse: reverse,
    duration: const Duration(milliseconds: 3500),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          color: Ember.accent.withValues(alpha: .65),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: Ember.mono,
            fontSize: 9,
            color: Ember.muted,
            letterSpacing: .5,
          ),
        ),
      ],
    ),
  );
}

class _CountGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ring = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: 5,
    );
    canvas.drawOval(
      ring.inflate(2),
      Paint()
        ..color = Ember.accent.withValues(alpha: .4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    final gradient = const LinearGradient(
      colors: [
        Color(0x00FFB51B),
        Ember.accent,
        Color(0xFFFFD989),
        Ember.accent,
        Color(0x00FFB51B),
      ],
    );
    canvas.drawOval(
      ring,
      Paint()
        ..shader = gradient.createShader(ring)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ring = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * .9,
      height: size.height,
    );
    canvas.drawOval(
      ring,
      Paint()
        ..color = Ember.accent.withValues(alpha: .09)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final point = Offset(size.width * .15, size.height * .18);
    canvas.drawCircle(
      point,
      6,
      Paint()
        ..color = Ember.accent.withValues(alpha: .24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      point,
      2,
      Paint()..color = Ember.accent.withValues(alpha: .65),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
