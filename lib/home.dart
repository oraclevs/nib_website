import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nib_motion/nib_motion.dart';

import 'ember_theme.dart';
import 'hero_lab.dart';
import 'home_hero.dart';
import 'widgets/dart_code_view.dart';
import 'fixture_demo.dart';
import 'recipe_art.dart';
import 'site_navigation.dart';

class EmberHome extends StatefulWidget {
  const EmberHome({super.key, this.onNavigatePath});

  /// When hosted by the site router, page links use durable browser paths.
  /// Standalone previews keep their local section navigation.
  final ValueChanged<String>? onNavigatePath;

  @override
  State<EmberHome> createState() => _EmberHomeState();
}

class _EmberHomeState extends State<EmberHome> {
  bool paused = false;
  bool reduced = false;
  bool ambient = true;
  final scroll = ScrollController();
  final labKey = GlobalKey();
  final packagesKey = GlobalKey();
  final studiesKey = GlobalKey();
  final examplesKey = GlobalKey();
  final workflowKey = GlobalKey();

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void goTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: paused || reduced || MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void navigate(String label) {
    if (widget.onNavigatePath != null) {
      widget.onNavigatePath!(switch (label) {
        'Ecosystem' => '/packages',
        'Docs' => '/docs/motion/getting-started',
        'Examples' => '/examples',
        'Playground' => '/playground/spring-retarget',
        _ => '/',
      });
      return;
    }
    switch (label) {
      case 'Ecosystem':
        scroll.animateTo(
          0,
          duration:
              paused || reduced || MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      case 'Docs':
        goTo(workflowKey);
      case 'Examples':
        goTo(examplesKey);
      case 'Playground':
        goTo(labKey);
    }
  }

  Future<void> copyInstall() async {
    try {
      await Clipboard.setData(
        const ClipboardData(text: 'flutter pub add nib_motion'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Install command copied.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Clipboard unavailable. Select the command to copy it.',
            ),
          ),
        );
      }
    }
  }

  void showSupport() => showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Support the Nib ecosystem'),
      content: const Text(
        'Thanks for wanting to support NibMotion, NibComponents, and NibGenUI. Payments are coming soon while we choose a payment provider. No payment can be made here yet.',
      ),
      actions: [
        EmberButton(label: 'Got it', onPressed: () => Navigator.pop(dialog)),
      ],
    ),
  );

  void showSearch() => showDialog<void>(
    context: context,
    builder: (dialog) {
      final controller = TextEditingController();
      final items = <(String, GlobalKey)>[
        ('Ecosystem', packagesKey),
        ('Motion playground', labKey),
        ('Interactive studies', studiesKey),
        ('Examples', examplesKey),
        ('Flutter implementation', workflowKey),
      ];
      return StatefulBuilder(
        builder: (dialog, update) => Dialog(
          backgroundColor: Ember.panel,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 490),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) => update(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search the Nib site',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final item in items)
                          if (item.$1.toLowerCase().contains(
                            controller.text.toLowerCase(),
                          ))
                            ListTile(
                              title: Text(item.$1),
                              trailing: const Icon(
                                Icons.arrow_forward,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.pop(dialog);
                                goTo(item.$2);
                              },
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  void searchOrNavigate() {
    if (widget.onNavigatePath case final navigate?) {
      navigate('/search');
    } else {
      showSearch();
    }
  }

  void exploreOrScroll(GlobalKey key, String path) {
    if (widget.onNavigatePath case final navigate?) {
      navigate(path);
    } else {
      goTo(key);
    }
  }

  void openPackage(String packageId) {
    if (widget.onNavigatePath case final navigate?) {
      navigate('/packages/$packageId');
    } else {
      goTo(workflowKey);
    }
  }

  void navigateHeaderPath(String route) {
    if (widget.onNavigatePath case final navigate?) {
      navigate(route);
      return;
    }
    switch (route) {
      case '/':
        scroll.animateTo(
          0,
          duration:
              paused || reduced || MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      case '/packages':
        navigate('Ecosystem');
      case '/docs/motion/springs':
        navigate('Docs');
      case '/examples':
        navigate('Examples');
      case '/playground/spring-retarget':
        navigate('Playground');
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmberMotionPolicy(
      paused: paused,
      reduced: reduced || MediaQuery.of(context).disableAnimations,
      ambient: ambient,
      child: Scaffold(
        backgroundColor: Ember.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                SiteNavigation(
                  path: '/',
                  onNavigate: navigateHeaderPath,
                  onSearch: searchOrNavigate,
                  onSupport: showSupport,
                ),
                Expanded(
                  child: NibMotionConfig(
                    reducedMotion:
                        paused ||
                        reduced ||
                        MediaQuery.of(context).disableAnimations,
                    child: SingleChildScrollView(
                      controller: scroll,
                      child: Column(
                        children: [
                          HomeHero(
                            mobile: MediaQuery.sizeOf(context).width < 900,
                            ambient: ambient,
                            playground: () => exploreOrScroll(
                              labKey,
                              '/playground/spring-retarget',
                            ),
                            docs: () => exploreOrScroll(
                              workflowKey,
                              '/docs/motion/getting-started',
                            ),
                            copyInstall: copyInstall,
                          ),
                          EmberWrap(
                            child: Column(
                              key: labKey,
                              children: [
                                _MotionPreferences(
                                  paused: paused,
                                  reduced:
                                      reduced ||
                                      MediaQuery.of(context).disableAnimations,
                                  ambient: ambient,
                                  systemReduced: MediaQuery.of(context)
                                      .disableAnimations,
                                  onPause: () =>
                                      setState(() => paused = !paused),
                                  onReduce: () =>
                                      setState(() => reduced = !reduced),
                                  onAmbient: () =>
                                      setState(() => ambient = !ambient),
                                ),
                                EmberReveal(
                                  entrance: EmberEntrance.up,
                                  child: HeroLab(
                                    paused: paused,
                                    reduced: reduced,
                                    ambient: ambient,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _PackageBand(
                            key: packagesKey,
                            onExplore: openPackage,
                          ),
                          _Studies(
                            key: studiesKey,
                            paused: paused,
                            reduced: reduced,
                          ),
                          _FeaturedExamples(
                            key: examplesKey,
                            onExplore: () =>
                                exploreOrScroll(labKey, '/examples'),
                          ),
                          _Workflow(
                            key: workflowKey,
                            onExplore: () => exploreOrScroll(
                              labKey,
                              '/docs/motion/getting-started',
                            ),
                          ),
                          _Principles(
                            onExplore: () =>
                                exploreOrScroll(labKey, '/examples'),
                          ),
                          EmberReveal(
                            entrance: EmberEntrance.tilt,
                            child: _Closing(
                              onExplore: () => exploreOrScroll(
                                labKey,
                                '/playground/spring-retarget',
                              ),
                              support: showSupport,
                            ),
                          ),
                          _Footer(onNavigate: navigate, support: showSupport),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MotionPreferences extends StatelessWidget {
  const _MotionPreferences({
    required this.paused,
    required this.reduced,
    required this.ambient,
    required this.systemReduced,
    required this.onPause,
    required this.onReduce,
    required this.onAmbient,
  });
  final bool paused, reduced, ambient, systemReduced;
  final VoidCallback onPause, onReduce, onAmbient;
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PreferenceButton(
                  paused ? 'Resume motion' : 'Pause motion',
                  paused ? Icons.play_arrow : Icons.pause,
                  paused,
                  onPause,
                ),
                _PreferenceButton(
                  reduced ? 'Reduced motion on' : 'Reduce motion',
                  Icons.visibility_outlined,
                  reduced,
                  systemReduced ? null : onReduce,
                ),
                if (!mobile)
                  _PreferenceButton(
                    ambient ? 'Ambient on' : 'Ambient off',
                    Icons.auto_awesome_outlined,
                    ambient,
                    onAmbient,
                  ),
              ],
            ),
          ),
          if (!mobile) ...[
            const Spacer(),
            Text(
              systemReduced
                  ? 'SYSTEM REDUCED MOTION · RESPECTED'
                  : 'LIVE FLUTTER / NIB PACKAGE INTERACTIONS',
              style: const TextStyle(
                fontFamily: Ember.mono,
                color: Ember.muted,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreferenceButton extends StatelessWidget {
  const _PreferenceButton(this.label, this.icon, this.active, this.onPressed);
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 14),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: active ? Ember.accent : Ember.muted,
      backgroundColor: active ? Ember.soft : Ember.panel,
      side: BorderSide(color: active ? const Color(0xFF70541D) : Ember.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 11),
      textStyle: const TextStyle(fontFamily: Ember.mono, fontSize: 10),
    ),
  );
}

class _PackageBand extends StatelessWidget {
  const _PackageBand({super.key, required this.onExplore});
  final ValueChanged<String> onExplore;
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    final packages = [
      (
        'motion',
        'NibMotion',
        'Give state changes a deliberate feel with motion, gestures and layout.',
        'Explore motion',
        Icons.waves_rounded,
      ),
      (
        'components',
        'NibComponents',
        'Build a consistent interface with reusable, expressive controls.',
        'Browse components',
        Icons.grid_view,
      ),
      (
        'genui',
        'NibGenUI',
        'Explore native interfaces composed from a trusted component vocabulary.',
        'Discover generative UI',
        Icons.chat_bubble_outline,
      ),
    ];
    return EmberWrap(
      child: Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmberReveal(
              entrance: EmberEntrance.up,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'One ecosystem. Three starting points.',
                    style: TextStyle(
                      fontSize: mobile ? 26 : 31,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.3,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Start with the layer you need. Keep the experience connected.',
                    style: TextStyle(fontSize: 13, color: Ember.muted),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Flex(
              direction: mobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in packages)
                  if (mobile)
                    _PackageTile(p.$2, p.$3, p.$4, p.$5, () => onExplore(p.$1))
                  else
                    Expanded(
                      child: _PackageTile(
                        p.$2,
                        p.$3,
                        p.$4,
                        p.$5,
                        () => onExplore(p.$1),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile(
    this.title,
    this.description,
    this.action,
    this.icon,
    this.onTap,
  );
  final String title, description, action;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    return EmberReveal(
      entrance: title == 'NibComponents'
          ? EmberEntrance.scale
          : title == 'NibMotion'
          ? EmberEntrance.left
          : EmberEntrance.right,
      delay: Duration(
        milliseconds: title == 'NibComponents'
            ? 90
            : title == 'NibGenUI'
            ? 180
            : 0,
      ),
      child: EmberFloat(
        y: 3,
        reverse: title == 'NibComponents',
        child: Container(
          width: double.infinity,
          constraints: mobile ? null : const BoxConstraints(minHeight: 218),
          padding: EdgeInsets.fromLTRB(mobile ? 0 : 25, 26, 24, 28),
          decoration: BoxDecoration(
            border: Border(
              top: const BorderSide(color: Ember.border),
              bottom: mobile
                  ? const BorderSide(color: Ember.border)
                  : BorderSide.none,
              left: mobile
                  ? BorderSide.none
                  : const BorderSide(color: Ember.border),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Ember.soft,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, color: Ember.accent, size: 21),
                  ),
                  const SizedBox(width: 13),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Ember.muted,
                  height: 1.75,
                ),
              ),
              const SizedBox(height: 17),
              EmberHover(
                child: TextButton.icon(
                  onPressed: onTap,
                  label: Text(action),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    foregroundColor: Ember.accent,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The lower homepage sections are defined below to preserve the reference's
// editorial order. Their interactive details are added after hero parity.

class _Studies extends StatefulWidget {
  const _Studies({super.key, required this.paused, required this.reduced});
  final bool paused, reduced;
  @override
  State<_Studies> createState() => _StudiesState();
}

class _StudiesState extends State<_Studies> {
  bool targetRight = false;
  final layers = <int>[1, 2];
  int nextLayer = 3;
  int selected = 0;
  int fixtureStep = 0;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    final cards = <Widget>[
      _StudyCard(
        number: '01',
        title: 'From abrupt to intentional.',
        summary: 'One change of state. Two different ways of arriving.',
        footer: 'RETARGET WHILE IT MOVES',
        buttonLabel: 'Change target',
        onPressed: () => setState(() => targetRight = !targetRight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ResponseLane(label: 'Instant', right: targetRight, spring: false),
            const SizedBox(height: 12),
            _ResponseLane(label: 'Spring', right: targetRight, spring: true),
          ],
        ),
      ),
      _StudyCard(
        number: '02',
        title: 'Make room for what’s next.',
        summary: 'Add something. Remove it. Let the layout follow.',
        footer: 'ENTER / EXIT / REFLOW',
        buttonLabel: layers.length >= 6 ? 'At capacity' : 'Add element',
        onPressed: layers.length >= 6
            ? null
            : () => setState(() => layers.add(nextLayer++)),
        child: NibPresence.layout(
          axis: NibPresenceAxis.wrap,
          children: [
            for (final id in layers)
              NibMotion(
                key: ValueKey(id),
                initial: const NibAnim(opacity: 0, scale: .8),
                animate: const NibAnim(opacity: 1, scale: 1),
                exit: const NibAnim(opacity: 0, x: -25),
                transition: NibTransition.springGentle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => setState(() => layers.remove(id)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Ember.accent,
                      backgroundColor: Ember.soft,
                      side: const BorderSide(color: Color(0xFF70541D)),
                      minimumSize: const Size(95, 52),
                    ),
                    child: Text('Layer ${id.toString().padLeft(2, '0')}  ×'),
                  ),
                ),
              ),
          ],
        ),
      ),
      _StudyCard(
        number: '03',
        title: 'One connected experience.',
        summary: 'The active highlight travels. The context stays yours.',
        footer: 'SHARED HIGHLIGHT / IDENTITY',
        buttonLabel: 'Explore',
        onPressed: () => setState(() => selected = (selected + 1) % 3),
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            alignment: Alignment.centerLeft,
            children: [
              NibMotion(
                initial: const NibAnim(x: 0),
                animate: NibAnim(x: selected * box.maxWidth / 3),
                transition: NibTransition.springGentle,
                child: Container(
                  width: box.maxWidth / 3 - 6,
                  height: 42,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Ember.accent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: TextButton(
                          onPressed: () => setState(() => selected = i),
                          style: TextButton.styleFrom(
                            foregroundColor: i == selected
                                ? Ember.onAccent
                                : Ember.muted,
                            backgroundColor: Colors.transparent,
                            minimumSize: const Size(0, 42),
                          ),
                          child: Text(
                            ['Motion', 'Components', 'GenUI'][i],
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      _StudyCard(
        number: '04',
        title: 'Watch an interface arrive.',
        summary: 'Structure appears progressively, without losing the thread.',
        footer: 'SCRIPTED FIXTURE · NOT LIVE AI',
        buttonLabel: 'Replay stream',
        onPressed: () => setState(() => fixtureStep++),
        child: EmberFixtureDemo(replay: fixtureStep),
      ),
    ];
    return EmberWrap(
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmberReveal(
              entrance: EmberEntrance.up,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EmberEyebrow('SMALL INTERACTIONS. A DIFFERENT FEEL.'),
                  const SizedBox(height: 12),
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(text: 'The hard things.\n'),
                        TextSpan(
                          text: 'Made hands-on.',
                          style: TextStyle(color: Ember.accent),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: mobile ? 27 : 38,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Don’t just watch a loop. Change something and feel the response.',
                    style: TextStyle(color: Ember.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
            if (mobile)
              Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EmberReveal(
                        entrance: cards.indexOf(card).isEven
                            ? EmberEntrance.left
                            : EmberEntrance.right,
                        child: EmberFloat(
                          y: 3,
                          reverse: cards.indexOf(card).isOdd,
                          child: card,
                        ),
                      ),
                    ),
                ],
              )
            else
              LayoutBuilder(
                builder: (context, box) => Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    for (final card in cards)
                      SizedBox(
                        width: (box.maxWidth - 18) / 2,
                        child: EmberReveal(
                          entrance: cards.indexOf(card).isEven
                              ? EmberEntrance.left
                              : EmberEntrance.right,
                          delay: Duration(
                            milliseconds: cards.indexOf(card).isOdd ? 120 : 0,
                          ),
                          child: EmberFloat(
                            y: 3,
                            reverse: cards.indexOf(card).isOdd,
                            child: card,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResponseLane extends StatelessWidget {
  const _ResponseLane({
    required this.label,
    required this.right,
    required this.spring,
  });
  final String label;
  final bool right, spring;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 55,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: Ember.mono,
            fontSize: 10,
            color: Ember.muted,
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 38,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Ember.panel,
            border: Border.all(color: Ember.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: LayoutBuilder(
              builder: (context, constraints) => spring
                  ? NibMotion(
                      initial: const NibAnim(x: 0),
                      animate: NibAnim(
                        x: right ? constraints.maxWidth - 25 : 0,
                      ),
                      transition: NibTransition.springGentle,
                      child: const _ResponsePuck(color: Ember.accent),
                    )
                  : Container(
                      margin: EdgeInsets.only(
                        left: right ? constraints.maxWidth - 25 : 0,
                      ),
                      child: const _ResponsePuck(color: Ember.strong),
                    ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _ResponsePuck extends StatelessWidget {
  const _ResponsePuck({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 25,
    height: 25,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.number,
    required this.title,
    required this.summary,
    required this.footer,
    required this.buttonLabel,
    required this.onPressed,
    required this.child,
  });
  final String number, title, summary, footer, buttonLabel;
  final VoidCallback? onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.sizeOf(context).width < 480
        ? 480
        : MediaQuery.sizeOf(context).width < 900
        ? 420
        : 370,
    decoration: BoxDecoration(
      color: Ember.panel,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(8),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.16,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Ember.muted,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                number,
                style: const TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 10,
                  color: Ember.accent,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Ember.border),
        Expanded(
          child: Container(
            color: const Color(0xFF161813),
            padding: const EdgeInsets.all(20),
            child: Center(child: child),
          ),
        ),
        const Divider(height: 1, color: Ember.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  footer,
                  style: const TextStyle(
                    fontFamily: Ember.mono,
                    fontSize: 9,
                    color: Ember.muted,
                  ),
                ),
              ),
              EmberHover(
                child: TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(foregroundColor: Ember.accent),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FeaturedExamples extends StatelessWidget {
  const _FeaturedExamples({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => EmberWrap(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmberReveal(
            entrance: EmberEntrance.up,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Try the interaction.\nKeep the idea.',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.13,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A few starting points for your next expressive interface.',
                  style: TextStyle(color: Ember.muted, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onExplore,
                  label: const Text('Browse the examples'),
                  icon: const Icon(Icons.arrow_forward, size: 17),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    foregroundColor: Ember.accent,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final mobile = box.maxWidth < 900;
              final cards = [
                ('The flip card', 'Perspective · tap · transform', Icons.flip),
                (
                  'Interrupt the ordinary',
                  'Springs · retargeting · response',
                  Icons.waves_rounded,
                ),
                (
                  'Make room for change',
                  'Layout · identity · reorder',
                  Icons.layers_outlined,
                ),
              ];
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width: mobile ? box.maxWidth : (box.maxWidth - 36) / 3,
                      child: EmberReveal(
                        entrance: EmberEntrance.scale,
                        delay: Duration(
                          milliseconds: mobile ? 0 : cards.indexOf(card) * 100,
                        ),
                        child: EmberHover(
                          scale: 1.018,
                          child: InkWell(
                            onTap: onExplore,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Ember.panel,
                                border: Border.all(color: Ember.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Container(
                                    height: 170,
                                    color: Ember.code,
                                    child: Center(
                                      child: RecipeArt(
                                        index: cards.indexOf(card),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1, color: Ember.border),
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                card.$1,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                card.$2,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Ember.muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_outward,
                                          color: Ember.accent,
                                          size: 17,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _Workflow extends StatelessWidget {
  const _Workflow({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => EmberWrap(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 54),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Ember.border)),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final mobile = box.maxWidth < 800;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmberEyebrow('FROM EXPLORATION TO IMPLEMENTATION'),
              const SizedBox(height: 17),
              const Text(
                'One preview.\nCode that belongs to it.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1.13,
                  letterSpacing: -1.3,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Choose an example, adjust its feel, then take the matching implementation into your application.',
                style: TextStyle(fontSize: 14, color: Ember.muted, height: 1.8),
              ),
              const SizedBox(height: 22),
              const Text(
                '01  Explore      02  Adjust      03  Copy',
                style: TextStyle(
                  fontFamily: Ember.mono,
                  fontSize: 10,
                  color: Ember.muted,
                ),
              ),
              const SizedBox(height: 22),
              EmberButton(
                label: 'Explore the workspace',
                onPressed: onExplore,
                icon: Icons.arrow_forward,
                attention: true,
              ),
            ],
          );
          final panel = Container(
            decoration: BoxDecoration(
              color: Ember.code,
              border: Border.all(color: Ember.border),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'spring_recipe.dart',
                    style: TextStyle(
                      fontFamily: Ember.mono,
                      fontSize: 10,
                      color: Ember.muted,
                    ),
                  ),
                ),
                Divider(height: 1, color: Ember.border),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: DartCodeView(
                    code: "import 'package:nib_motion/nib_motion.dart';\n\nNibMotion(\n  animate: const NibAnim(x: 80),\n  transition: NibTransition.springGentle,\n  child: const FlutterLogo(),\n);",
                    lineHeight: 1.75,
                  ),
                ),
              ],
            ),
          );
          return mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EmberReveal(entrance: EmberEntrance.left, child: copy),
                    const SizedBox(height: 30),
                    EmberReveal(
                      entrance: EmberEntrance.right,
                      child: EmberFloat(y: 4, turn: .0015, child: panel),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: EmberReveal(
                        entrance: EmberEntrance.left,
                        child: copy,
                      ),
                    ),
                    const SizedBox(width: 56),
                    Expanded(
                      child: EmberReveal(
                        entrance: EmberEntrance.right,
                        child: EmberFloat(y: 4, turn: .0015, child: panel),
                      ),
                    ),
                  ],
                );
        },
      ),
    ),
  );
}

class _Principles extends StatelessWidget {
  const _Principles({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => EmberWrap(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmberReveal(
            entrance: EmberEntrance.up,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EmberEyebrow('THE LAYERS WORK TOGETHER'),
                const SizedBox(height: 14),
                const Text(
                  'Start anywhere. Keep building.',
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose a layer to see its place in the experience.',
                  style: TextStyle(color: Ember.muted),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) => Wrap(
              spacing: 0,
              runSpacing: 0,
              children: [
                for (final p in [
                  (
                    '01 / DISCOVER',
                    'Choose',
                    'Find an interaction worth keeping.',
                  ),
                  (
                    '02 / NIBMOTION',
                    'Animate',
                    'Give state changes continuity.',
                  ),
                  (
                    '03 / COMPONENTS',
                    'Compose',
                    'Build with a shared visual language.',
                  ),
                  (
                    '04 / GENUI',
                    'Generate',
                    'Explore context-shaped interfaces.',
                  ),
                ])
                  SizedBox(
                    width: box.maxWidth < 720
                        ? box.maxWidth / 2
                        : box.maxWidth / 4,
                    child: EmberReveal(
                      entrance: p.$2 == 'Animate'
                          ? EmberEntrance.up
                          : EmberEntrance.scale,
                      child: EmberFloat(
                        y: 3,
                        reverse: p.$2 == 'Compose',
                        child: Container(
                          height: box.maxWidth < 500
                              ? 220
                              : box.maxWidth < 720
                              ? 195
                              : 155,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Ember.panel,
                            border: Border.all(color: Ember.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.$1,
                                style: const TextStyle(
                                  fontFamily: Ember.mono,
                                  fontSize: 9,
                                  color: Ember.accent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                p.$2,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.$3,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Ember.muted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          for (final p in [
            (
              'Interaction, not interruption.',
              'Keep keyboard input, readable content and reduced motion at the center of the design.',
            ),
            (
              'The preview belongs to the code.',
              'The Flutter implementation must display the same verified source that runs its examples.',
            ),
            (
              'One identity. Independent layers.',
              'A connected visual language without requiring every application to install every package.',
            ),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.$1,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.$2,
                    style: const TextStyle(
                      color: Ember.muted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Ember.border),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _Closing extends StatelessWidget {
  const _Closing({required this.onExplore, required this.support});
  final VoidCallback onExplore, support;
  @override
  Widget build(BuildContext context) => EmberWrap(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your next interaction starts here.',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Read a guide, open a recipe, or explore how the packages connect.',
            style: TextStyle(color: Ember.muted, fontSize: 14),
          ),
          const SizedBox(height: 25),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              EmberButton(
                label: 'Get started',
                onPressed: onExplore,
                icon: Icons.arrow_forward,
                attention: true,
              ),
              EmberButton(
                label: 'Support Nib',
                onPressed: support,
                secondary: true,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onNavigate, required this.support});
  final ValueChanged<String> onNavigate;
  final VoidCallback support;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 22),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Ember.border)),
    ),
    child: EmberWrap(
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'NIB / ONE ECOSYSTEM. BUILT AROUND FLUTTER.',
            style: TextStyle(
              fontFamily: Ember.mono,
              fontSize: 10,
              color: Ember.muted,
            ),
          ),
          TextButton(
            onPressed: () => onNavigate('Docs'),
            child: const Text('Documentation'),
          ),
          TextButton(
            onPressed: () => onNavigate('Examples'),
            child: const Text('Examples'),
          ),
          TextButton(onPressed: support, child: const Text('Support Nib')),
        ],
      ),
    ),
  );
}
