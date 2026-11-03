import '../components/component_toggle.dart';
import 'api_reference_panel.dart';
import '../components/component_catalog.dart';
import '../components/component_model.dart';
import '../components/component_pages.dart';
import '../components/component_support_guides.dart';
import 'doc_blocks.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ember_theme.dart';
import '../content/site_content.dart';
import 'docs_spring_demo.dart';
import '../widgets/dart_code_view.dart';
import '../docs/doc_example_catalog.dart';
import 'doc_example_gallery.dart';
import '../content/motion_api_topics.dart';
import '../content/motion_guides.dart';
import '../external_link.dart';

import 'package:nib_motion/nib_motion.dart';

/// The Springs article follows the approved HTML documentation composition.
/// Its example uses the real local NibMotion package.
class DocsSpringReference extends StatefulWidget {
  const DocsSpringReference({
    super.key,
    required this.onNavigate,
    this.packageId = 'motion',
    this.sectionId = 'springs',
    this.anchor = '',
  });

  final String packageId;
  final String sectionId;
  final String anchor;

  final ValueChanged<String> onNavigate;

  @override
  State<DocsSpringReference> createState() => _DocsSpringReferenceState();
}

class _DocsSpringReferenceState extends State<DocsSpringReference> {
  final ScrollController _fallbackScroll = ScrollController();
  final ScrollController _topicsScroll = ScrollController();
  final ScrollController _tocScroll = ScrollController();
  ScrollController? _scroll;
  String _activeSection = 'live-example';
  bool _copied = false;
  String? _demoSource;
  DocArticle? get _articleData =>
      SiteContent.articleById(widget.packageId, widget.sectionId);
  String get _packageName =>
      SiteContent.packageById(widget.packageId)?.name ?? 'NibMotion';
  bool get _isApi => widget.sectionId == 'api';
  ComponentGuide? get _componentGuide =>
      widget.packageId == 'components' ? componentById(widget.sectionId) : null;
  List<String> get _topicApis => _isApi
      ? const []
      : widget.packageId == 'components'
      ? _componentGuide?.symbols ??
            componentSupportSymbols[widget.sectionId] ??
            const []
      : widget.packageId == 'motion'
      ? motionApiTopics[widget.sectionId] ?? const []
      : const [];
  bool get _isSpring =>
      widget.packageId == 'motion' && widget.sectionId == 'springs';
  String get _title => widget.packageId == 'motion'
      ? SiteContent.motionReferenceNav.entries
                .where((e) => e.value == widget.sectionId)
                .firstOrNull
                ?.key ??
            _articleData?.title ??
            'Guide not found'
      : _articleData?.title ?? 'Guide not found';
  bool get _reduced => _reduce || MediaQuery.disableAnimationsOf(context);
  bool get _narrow => MediaQuery.sizeOf(context).width <= 850;
  final Map<String, GlobalKey> _sectionKeys = {};
  double _progress = 0;
  bool _reduce = false;
  bool _pause = false;
  bool _showCode = false;
  bool _right = false;
  String _preset = 'Balanced';

  double get _stiffness => switch (_preset) {
    'Gentle' => 120,
    'Snappy' => 300,
    _ => 180,
  };
  double get _damping => switch (_preset) {
    'Gentle' => 14,
    'Snappy' => 20,
    _ => 18,
  };

  String get _code =>
      '''DocumentationSpring(
  target: targetRight ? 0 : -60,
  stiffness: ${_stiffness.toStringAsFixed(0)},
  damping: ${_damping.toStringAsFixed(0)},
  reduceMotion: $_reduce,
  paused: $_pause,
)''';

  String get _completeCode => '${_demoSource ?? ""}\n${_launcher()}';

  String _launcher() =>
      '''
void main() => runApp(const MaterialApp(home: SpringExample()));

class SpringExample extends StatefulWidget {
  const SpringExample({super.key});
  @override
  State<SpringExample> createState() => _SpringExampleState();
}
class _SpringExampleState extends State<SpringExample> {
  bool targetRight = $_right;
  bool paused = $_pause;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF111210),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      DocumentationSpring(
        target: targetRight ? 0 : -60,
        stiffness: ${_stiffness.toStringAsFixed(0)},
        damping: ${_damping.toStringAsFixed(0)},
        reduceMotion: $_reduce,
        paused: paused,
      ),
      const SizedBox(height: 40),
      FilledButton(
        onPressed: () => setState(() => targetRight = !targetRight),
        child: const Text('Replay'),
      ),
      TextButton(
        onPressed: () => setState(() => paused = !paused),
        child: Text(paused ? 'Resume' : 'Pause'),
      ),
    ])),
  );
}
''';

  @override
  void initState() {
    super.initState();
    _prepareSections();
    _scrollToAnchor();
  }

  AssetBundle? _sourceBundle;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    if (_sourceBundle != bundle) {
      _sourceBundle = bundle;
      bundle.loadString('lib/pages/docs_spring_demo.dart').then((source) {
        if (mounted) setState(() => _demoSource = source);
      });
    }
  }

  bool get _hasLiveExample =>
      !_isApi &&
      (_isSpring ||
          _componentGuide != null ||
          docExamplesFor(widget.packageId, widget.sectionId).isNotEmpty);

  void _prepareSections() {
    _sectionKeys.clear();
    for (final id in [
      if (_isApi) 'api-reference' else if (_hasLiveExample) 'live-example',
      ...?_articleData?.sections.map((s) => s.id),
      if (_topicApis.isNotEmpty) 'topic-api',
    ]) {
      _sectionKeys[id] = GlobalKey();
    }
    _activeSection = _sectionKeys.keys.firstOrNull ?? '';
  }

  @override
  void didUpdateWidget(covariant DocsSpringReference oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId ||
        oldWidget.packageId != widget.packageId) {
      _prepareSections();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll?.hasClients == true) _scroll!.jumpTo(0);
        if (mounted &&
            oldWidget.packageId != widget.packageId &&
            _topicsScroll.hasClients) {
          _topicsScroll.jumpTo(0);
        }
      });
    }
    if (oldWidget.anchor != widget.anchor ||
        oldWidget.sectionId != widget.sectionId) {
      _scrollToAnchor();
    }
  }

  void _scrollToAnchor() {
    if (widget.anchor.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _jump(widget.anchor, updateLocation: false);
    });
  }

  void _bindScroll(ScrollController controller) {
    if (_scroll == controller) return;
    _scroll?.removeListener(_readProgress);
    _scroll = controller..addListener(_readProgress);
  }

  void _readProgress() {
    if (_scroll?.hasClients != true) return;
    final max = _scroll!.position.maxScrollExtent;
    final next = max <= 0 ? 0.0 : (_scroll!.offset / max).clamp(0.0, 1.0);
    var active = _sectionKeys.keys.firstOrNull ?? '';
    for (final entry in _sectionKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject();
      if (box is RenderBox && box.localToGlobal(Offset.zero).dy < 160) {
        active = entry.key;
      }
    }
    if (mounted) {
      setState(() {
        _progress = next;
        _activeSection = active;
      });
    }
  }

  void _jump(String id, {bool updateLocation = true}) {
    final target = _sectionKeys[id]?.currentContext;
    if (target == null) return;
    if (updateLocation) {
      widget.onNavigate('/docs/${widget.packageId}/${widget.sectionId}#$id');
    }
    Scrollable.ensureVisible(
      target,
      duration: _reduced ? Duration.zero : const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      alignment: .04,
    );
  }

  @override
  void dispose() {
    _scroll?.removeListener(_readProgress);
    _fallbackScroll.dispose();
    _topicsScroll.dispose();
    _tocScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 640;
      final medium = constraints.maxWidth < 1200;
      final sideWidth = _narrow
          ? 190.0
          : medium
          ? 222.0
          : 250.0;
      _bindScroll(PrimaryScrollController.maybeOf(context) ?? _fallbackScroll);
      return SizedBox(
        height: constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height,
        child: Column(
          children: [
            if (compact) _mobileBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!compact)
                        SizedBox(
                          width: sideWidth,
                          child: Scrollbar(
                            controller: _topicsScroll,
                            child: SingleChildScrollView(
                              key: const ValueKey('docs-topics-scroll'),
                              controller: _topicsScroll,
                              primary: false,
                              child: _sidebar(medium),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Scrollbar(
                          controller: _scroll,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            key: const ValueKey('docs-article-scroll'),
                            controller: _scroll,
                            primary: false,
                            child: Column(
                              children: [
                                _article(compact: compact, medium: medium),
                                _footer(compact),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!medium)
                        SizedBox(
                          width: 220,
                          child: SingleChildScrollView(
                            controller: _tocScroll,
                            primary: false,
                            child: _toc(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _mobileBar() => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(
      color: Ember.panel,
      border: Border(bottom: BorderSide(color: Ember.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          message: 'Choose documentation article',
          child: InkWell(
            onTap: () async {
              final destination = await _showLearningPath();
              if (mounted && destination != null) {
                widget.onNavigate(destination);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu, size: 15, color: Ember.muted),
                const SizedBox(width: 8),
                Text(
                  _packageName,
                  style: const TextStyle(color: Ember.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: Text(
            _title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Ember.muted, fontSize: 11),
          ),
        ),
      ],
    ),
  );

  Future<String?> _showLearningPath() => showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Ember.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      side: BorderSide(color: Ember.border),
    ),
    builder: (sheet) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_packageName learning path',
                      style: const TextStyle(
                        color: Ember.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close contents',
                    onPressed: () => Navigator.pop(sheet),
                    icon: const Icon(Icons.close, color: Ember.muted, size: 18),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Ember.border),
            Expanded(
              child: ListView(
                primary: false,
                children: [
                  for (final group
                      in SiteContent
                          .learningPaths[widget.packageId]!
                          .entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                      child: Text(
                        group.key.toUpperCase(),
                        style: const TextStyle(
                          color: Ember.muted,
                          fontFamily: Ember.mono,
                          fontSize: 10,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    for (final id in group.value)
                      ListTile(
                        dense: true,
                        selected: id == widget.sectionId,
                        selectedColor: Ember.accent,
                        selectedTileColor: Ember.soft,
                        textColor: Ember.text,
                        title: Text(
                          _navigationItems.entries
                              .firstWhere((e) => e.value == id)
                              .key,
                        ),
                        onTap: () => Navigator.pop(
                          sheet,
                          '/docs/${widget.packageId}/$id',
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sidebar(bool medium) => Container(
    decoration: const BoxDecoration(
      border: Border(right: BorderSide(color: Ember.border)),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        _narrow ? 14 : 22,
        _narrow ? 26 : 30,
        _narrow ? 14 : 22,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Ember.panel,
              border: Border.all(color: Ember.strong),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.packageId,
                isExpanded: true,
                dropdownColor: Ember.panel,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 17,
                  color: Ember.text,
                ),
                style: const TextStyle(color: Ember.text, fontSize: 12),
                items: const [
                  DropdownMenuItem(value: 'motion', child: Text('NibMotion')),
                  DropdownMenuItem(
                    value: 'components',
                    child: Text('NibComponents'),
                  ),
                  DropdownMenuItem(value: 'genui', child: Text('NibGenUI')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    widget.onNavigate('/docs/$value/getting-started');
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 26),
          for (final group
              in SiteContent.learningPaths[widget.packageId]!.entries)
            _sideGroup(group.key.toUpperCase(), [
              for (final id in group.value)
                _navigationItems.entries.firstWhere((e) => e.value == id).key,
            ]),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Ember.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'ONE ECOSYSTEM\nSwitch packages without changing the visual language.',
              style: TextStyle(color: Ember.muted, fontSize: 10, height: 1.8),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sideGroup(String heading, List<String> labels) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 0, 9),
        child: Text(
          heading,
          style: const TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 9,
            letterSpacing: 1.4,
          ),
        ),
      ),
      for (final label in labels) ...[
        Material(
          color: _selectedLabel(label) ? Ember.soft : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            onTap: () => _openArticle(label),
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _selectedLabel(label) ? Ember.accent : Ember.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );

  Map<String, String> get _navigationItems => {
    for (final article in SiteContent.articlesFor(widget.packageId))
      (widget.packageId == 'motion'
              ? SiteContent.motionReferenceNav.entries
                        .where((e) => e.value == article.id)
                        .firstOrNull
                        ?.key ??
                    article.title
              : article.title):
          article.id,
  };
  String _idForLabel(String label) => _navigationItems[label]!;

  bool _selectedLabel(String label) => _idForLabel(label) == widget.sectionId;
  void _openArticle(String label) =>
      widget.onNavigate('/docs/${widget.packageId}/${_idForLabel(label)}');

  Widget _article({required bool compact, required bool medium}) {
    final horizontal = compact
        ? 20.0
        : (_narrow
              ? 26.0
              : medium
              ? 36.0
              : 52.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        compact
            ? 25
            : _narrow
            ? 30
            : medium
            ? 34
            : 37,
        horizontal,
        compact ? 36 : 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _crumb(
                'Docs',
                () => widget.onNavigate('/docs/motion/introduction'),
              ),
              const _Chevron(),
              Text(
                _packageName,
                style: const TextStyle(color: Ember.muted, fontSize: 10),
              ),
              const _Chevron(),
              Flexible(
                child: Text(
                  _title,
                  style: const TextStyle(color: Ember.muted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 22 : 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  _title,
                  style: TextStyle(
                    color: Ember.text,
                    fontSize: compact
                        ? 40
                        : _narrow
                        ? 42
                        : 49,
                    fontWeight: FontWeight.w600,
                    letterSpacing: compact ? -1.8 : -2.4,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              _TinyTag(
                SiteContent.levelFor(
                  widget.packageId,
                  widget.sectionId,
                ).toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            _isSpring
                ? 'Tune the feel, not just the duration. Explore stiffness, damping and mass through an example you can adjust.'
                : _articleData?.summary ??
                      'Choose a guide from the documentation navigation.',
            style: TextStyle(
              color: Ember.muted,
              fontSize: compact
                  ? 13
                  : _narrow
                  ? 14
                  : 15,
              height: 1.8,
            ),
          ),
          SizedBox(height: compact ? 17 : 20),
          Wrap(
            spacing: compact ? 5 : 7,
            runSpacing: 6,
            children: [
              _TinyTag(_packageName, motionIcon: true),
              _TinyTag(
                _isApi
                    ? 'Public API'
                    : _hasLiveExample
                    ? 'Interactive example'
                    : 'Guide',
              ),
              if (_hasLiveExample) const _TinyTag('Reduced-motion aware'),
            ],
          ),
          if (widget.packageId == 'motion' &&
              motionDocsSources.containsKey(widget.sectionId)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'nib_motion $motionDocsVersion · $motionDocsChannel · ${motionDocsCommit.substring(0, 7)}',
                  style: const TextStyle(color: Ember.muted, fontSize: 12),
                ),
                TextButton.icon(
                  onPressed: () => openExternalLink(
                    'https://github.com/oraclevs/nib_motion/edit/$motionDocsEditRef/${motionDocsSources[widget.sectionId]}',
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit this page on GitHub'),
                ),
              ],
            ),
          ],
          if (medium) ...[
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('On this page'),
              tilePadding: EdgeInsets.zero,
              children: _contents(),
            ),
          ],
          if (_hasLiveExample) ...[
            SizedBox(height: compact ? 40 : 38),
            _motionBar(compact),
            SizedBox(height: compact ? 40 : 44),
          ] else
            const SizedBox(height: 28),
          if (_isApi) ...[
            ApiReferencePanel(
              key: _sectionKeys['api-reference'],
              packageId: widget.packageId,
            ),
          ] else if (_isSpring) ...[
            _demo(compact),
            const SizedBox(height: 22),
            _sourcePanel(),
          ] else if (_componentGuide != null) ...[
            TickerMode(
              enabled: !_pause,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: _reduced),
                child: ComponentGuidePage(
                  key: _sectionKeys['live-example'],
                  guide: _componentGuide!,
                  onNavigate: widget.onNavigate,
                  embedded: true,
                ),
              ),
            ),
          ] else if (docExampleFor(widget.packageId, widget.sectionId) !=
              null) ...[
            NibMotionConfig(
              reducedMotion: _reduced,
              child: TickerMode(
                enabled: !_pause,
                child: DocExampleGallery(
                  key: _sectionKeys['live-example'],
                  examples: docExamplesFor(widget.packageId, widget.sectionId),
                  onNavigate: widget.onNavigate,
                ),
              ),
            ),
          ],
          if (_hasLiveExample || _isApi) const SizedBox(height: 34),
          for (final section in _articleData?.sections ?? <DocSection>[]) ...[
            _section(
              section.id,
              section.heading,
              section.paragraphs.join('\n\n'),
            ),
            if (section.blocks.isNotEmpty) ...[
              const SizedBox(height: 14),
              DocBlocks(blocks: section.blocks, onNavigate: widget.onNavigate),
            ],
            if (section.api.isNotEmpty) ...[
              const SizedBox(height: 18),
              _apiTable(section.api),
            ],
            if (section.code != null) ...[
              const SizedBox(height: 18),
              _codePanel(section.code!, 'Flutter / Dart'),
            ],
            if (section.note != null) ...[
              const SizedBox(height: 18),
              _note('Keep in mind', section.note!),
            ],
            if (docSectionExamples(
              widget.packageId,
              widget.sectionId,
              section.id,
            ).isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final example in docSectionExamples(
                    widget.packageId,
                    widget.sectionId,
                    section.id,
                  ))
                    DocExampleButton(
                      example: example,
                      onNavigate: widget.onNavigate,
                      reducedMotion: _reduced,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 34),
          ],
          if (_topicApis.isNotEmpty) ...[
            if (docExamplesFor(widget.packageId, widget.sectionId).length > 1 &&
                widget.sectionId != 'text-motion') ...[
              const Text(
                'Practice the combinations',
                style: TextStyle(
                  fontSize: 23,
                  color: Ember.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              for (final example in docExamplesFor(
                widget.packageId,
                widget.sectionId,
              ).skip(1)) ...[
                Text(
                  example.description,
                  style: const TextStyle(color: Ember.muted, height: 1.8),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DocExampleButton(
                    example: example,
                    onNavigate: widget.onNavigate,
                    reducedMotion: _reduced,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
            ApiReferencePanel(
              key: _sectionKeys['topic-api'],
              packageId: _componentGuide?.apiPackageId ?? widget.packageId,
              symbolNames: _topicApis,
              title: 'API for $_title',
            ),
          ],
          const SizedBox(height: 28),
          _articleNavigation(),
        ],
      ),
    );
  }

  Widget _note(String title, String text, {Key? sectionKey}) => Container(
    key: sectionKey,
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    decoration: BoxDecoration(
      color: Ember.soft,
      border: Border.all(color: const Color(0xFF5B4921)),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Ember.accent, size: 17),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: const TextStyle(
                    color: Ember.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
            style: const TextStyle(
              color: Ember.muted,
              fontSize: 12,
              height: 1.8,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _articleNavigation() {
    final articles = SiteContent.articlesFor(widget.packageId);
    final index = articles.indexWhere((a) => a.id == widget.sectionId);
    final previous = index > 0 ? articles[index - 1] : null;
    final next = index >= 0 && index < articles.length - 1
        ? articles[index + 1]
        : null;
    return Container(
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Ember.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: previous == null
                ? const SizedBox()
                : _articleLink(previous, false),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: next == null ? const SizedBox() : _articleLink(next, true),
          ),
        ],
      ),
    );
  }

  Widget _articleLink(DocArticle article, bool next) => InkWell(
    onTap: () => widget.onNavigate(article.route),
    child: Column(
      crossAxisAlignment: next
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          next ? 'NEXT →' : '← PREVIOUS',
          style: const TextStyle(color: Ember.muted, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Text(
          article.title,
          style: const TextStyle(
            color: Ember.text,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _crumb(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Text(
      label,
      style: const TextStyle(color: Ember.muted, fontSize: 10),
    ),
  );

  Widget _motionBar(bool compact) => LayoutBuilder(
    builder: (context, bounds) {
      final buttons = Wrap(
        spacing: compact ? 7 : 9,
        runSpacing: 9,
        children: [
          if (_isSpring)
            _policyButton(
              _pause ? 'Resume motion' : 'Pause motion',
              _pause,
              () => setState(() => _pause = !_pause),
              icon: _pause ? Icons.play_arrow_outlined : Icons.pause,
            ),
          _policyButton(
            _reduced ? 'Reduced motion on' : 'Reduce motion',
            _reduced,
            MediaQuery.disableAnimationsOf(context)
                ? null
                : () => setState(() => _reduce = !_reduce),
            icon: Icons.visibility_outlined,
          ),
        ],
      );
      final note = Text(
        MediaQuery.disableAnimationsOf(context)
            ? 'SYSTEM REDUCED MOTION · RESPECTED'
            : 'LIVE FLUTTER / ${_packageName.toUpperCase()}',
        style: TextStyle(
          color: Ember.muted,
          fontFamily: Ember.mono,
          fontSize: compact ? 8 : 9,
        ),
      );
      if (bounds.maxWidth < 675) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buttons, const SizedBox(height: 9), note],
        );
      }
      return Row(
        children: [
          buttons,
          const SizedBox(width: 16),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: note),
          ),
        ],
      );
    },
  );

  Widget _policyButton(
    String label,
    bool active,
    VoidCallback? action, {
    IconData? icon,
  }) => TextButton(
    onPressed: action,
    style: TextButton.styleFrom(
      foregroundColor: active ? Ember.accent : Ember.muted,
      disabledForegroundColor: Ember.muted,
      backgroundColor: Ember.panel,
      side: BorderSide(color: active ? const Color(0xFF88621B) : Ember.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      minimumSize: const Size(0, 36),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 640 ? 9 : 12,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: TextStyle(
        fontFamily: Ember.mono,
        fontSize: MediaQuery.sizeOf(context).width < 640 ? 9 : 10,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 12), const SizedBox(width: 8)],
        Text(label),
      ],
    ),
  );

  Widget _demo(bool compact) => Container(
    key: _sectionKeys['live-example'],
    decoration: BoxDecoration(
      color: Ember.panel,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(7),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        SizedBox(
          height: compact ? 47 : 52,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 17),
            child: Row(
              children: [
                _tab(
                  'Preview',
                  !_showCode,
                  () => setState(() => _showCode = false),
                ),
                _tab(
                  'Settings',
                  _showCode,
                  () => setState(() => _showCode = true),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _openPlaygroundLink(compact),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(color: Ember.border, height: 1),
        if (_showCode)
          SizedBox(
            height: compact
                ? 180
                : _narrow
                ? 182
                : 200,
            child: SingleChildScrollView(
              primary: false,
              padding: const EdgeInsets.all(20),
              child: DartCodeView(code: _code, fontSize: 10),
            ),
          )
        else
          SizedBox(
            height: compact
                ? 180
                : _narrow
                ? 182
                : 200,
            width: double.infinity,
            child: CustomPaint(
              painter: const _DotField(enabled: true),
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final gap = compact
                      ? 19.0
                      : _narrow
                      ? 12.0
                      : 30.0;
                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: compact ? 52 : 66,
                          height: compact ? 52 : 66,
                          child: const CustomPaint(painter: _DashedTarget()),
                        ),
                        SizedBox(width: gap),
                        SizedBox(
                          width: compact
                              ? 66
                              : _narrow
                              ? 75
                              : 140,
                          height: 60,
                          child: const CustomPaint(painter: _SpringCurve()),
                        ),
                        SizedBox(width: gap),
                        DocumentationSpring(
                          target: _right ? 0 : -60,
                          stiffness: _stiffness,
                          damping: _damping,
                          paused: _pause,
                          reduceMotion: _reduced,
                          size: compact ? 64 : 78,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        const Divider(color: Ember.border, height: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: 11,
          ),
          child: Row(
            children: [
              Flexible(
                child: Wrap(
                  spacing: 7,
                  children: [
                    for (final name in ['Gentle', 'Balanced', 'Snappy'])
                      _presetButton(name),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _right = !_right),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  foregroundColor: Ember.accent,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: TextStyle(fontSize: compact ? 10 : 11),
                ),
                icon: const Icon(Icons.refresh, size: 13),
                label: const Text('Replay'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _openPlaygroundLink(bool compact) => TextButton(
    onPressed: () => widget.onNavigate('/playground/spring-retarget'),
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'Open playground',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Ember.accent, fontSize: compact ? 9 : 11),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.north_east, size: 12, color: Ember.accent),
      ],
    ),
  );

  Widget _tab(String label, bool selected, VoidCallback action) => TextButton(
    onPressed: action,
    style: TextButton.styleFrom(
      foregroundColor: selected ? Ember.text : Ember.muted,
      backgroundColor: selected ? Ember.raised : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      minimumSize: const Size(0, 34),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: const TextStyle(fontSize: 11),
    ),
    child: Text(label),
  );

  Widget _presetButton(String name) => OutlinedButton(
    onPressed: () => setState(() => _preset = name),
    style: OutlinedButton.styleFrom(
      foregroundColor: _preset == name ? Ember.accent : Ember.muted,
      backgroundColor: _preset == name ? Ember.soft : Colors.transparent,
      side: BorderSide(
        color: _preset == name ? const Color(0xFF876421) : Ember.border,
      ),
      minimumSize: const Size(0, 32),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: TextStyle(
        fontSize: MediaQuery.sizeOf(context).width < 640 ? 9 : 10,
      ),
    ),
    child: Text(name),
  );

  Widget _sourcePanel() => _codePanel(
    _code,
    'spring_retarget.dart',
    copyText: _demoSource == null ? null : _completeCode,
    note: 'The preview and copied example use the same widget. Copy includes imports and a runnable Flutter app.',
    loading: _demoSource == null,
  );

  Widget _codePanel(
    String code,
    String filename, {
    String? copyText,
    String? note,
    bool loading = false,
  }) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Ember.code,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(7),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Ember.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  filename,
                  style: const TextStyle(
                    color: Ember.muted,
                    fontFamily: Ember.mono,
                    fontSize: 10,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: loading
                    ? null
                    : () async {
                        try {
                          await Clipboard.setData(
                            ClipboardData(text: copyText ?? code),
                          );
                          if (!mounted) return;
                          setState(() => _copied = true);
                          Future<void>.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _copied = false);
                          });
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Copy unavailable. Select the source instead.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(3),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Ember.text,
                  textStyle: const TextStyle(
                    fontFamily: Ember.mono,
                    fontSize: 10,
                  ),
                ),
                icon: Icon(
                  _copied ? Icons.check : Icons.copy_outlined,
                  size: 12,
                ),
                label: Text(_copied ? 'Copied' : 'Copy code'),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(22),
          child: DartCodeView(code: code),
        ),
        if (note != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Ember.border)),
            ),
            child: Text(
              note,
              style: const TextStyle(
                color: Ember.muted,
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _section(String id, String title, String body) => Column(
    key: _sectionKeys[id],
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          title,
          style: TextStyle(
            color: Ember.text,
            fontSize: MediaQuery.sizeOf(context).width < 640 ? 21 : 22,
            height: 1.55,
            fontWeight: FontWeight.w500,
            letterSpacing: -.7,
          ),
        ),
      ),
      const SizedBox(height: 13),
      Text(
        body,
        style: TextStyle(
          color: Ember.muted,
          fontSize: MediaQuery.sizeOf(context).width < 640 ? 13 : 14,
          height: 1.9,
        ),
      ),
    ],
  );

  Widget _apiTable(List<DocApiEntry> entries) => Container(
    decoration: BoxDecoration(
      color: Ember.code,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: Ember.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final entry = entries[i];
                final signature = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      entry.name,
                      style: const TextStyle(
                        color: Ember.accent,
                        fontFamily: Ember.mono,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      entry.type,
                      style: const TextStyle(
                        color: Color(0xFF92D5D0),
                        fontFamily: Ember.mono,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Default: ${entry.defaultValue}',
                      style: const TextStyle(
                        color: Ember.muted,
                        fontSize: 11,
                        height: 1.6,
                      ),
                    ),
                  ],
                );
                final description = Text(
                  entry.description,
                  style: const TextStyle(
                    color: Ember.text,
                    fontSize: 13,
                    height: 1.8,
                  ),
                );
                if (constraints.maxWidth < 480) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      signature,
                      const SizedBox(height: 12),
                      description,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: signature),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: description),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    ),
  );

  Widget _footer(bool compact) => Container(
    padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 56, vertical: 24),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Ember.border)),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 32,
      runSpacing: 20,
      children: [
        const Text(
          'NIB / ONE ECOSYSTEM. BUILT AROUND FLUTTER.',
          style: TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 10,
          ),
        ),
        Wrap(
          spacing: 25,
          runSpacing: 16,
          children: [
            _footerLink(
              'Documentation',
              () => widget.onNavigate('/docs/motion/introduction'),
            ),
            _footerLink('Examples', () => widget.onNavigate('/examples')),
            _footerLink(
              'Motion preferences',
              () => showDialog<void>(
                context: context,
                builder: (dialog) => AlertDialog(
                  backgroundColor: Ember.panel,
                  title: const Text('Motion preferences'),
                  content: Text(
                    _reduced
                        ? 'Reduced motion is active. All examples reach their final state immediately.'
                        : 'Use each example’s controls to replay or stop it. Reduce motion preserves the final state. System reduced motion always takes priority.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() => _reduce = !_reduce);
                        Navigator.pop(dialog);
                      },
                      child: Text(_reduce ? 'Allow motion' : 'Reduce motion'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialog),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _footerLink(String label, VoidCallback action) => InkWell(
    onTap: action,
    child: Text(
      label,
      style: TextStyle(
        color: label == 'Motion preferences' ? Ember.accent : Ember.muted,
        fontFamily: Ember.mono,
        fontSize: 10,
      ),
    ),
  );

  List<Widget> _contents() => [
    if (_isApi || _hasLiveExample)
      _tocLink(
        _isApi ? 'API reference' : 'Live example',
        _isApi ? 'api-reference' : 'live-example',
      ),
    for (final section in _articleData?.sections ?? <DocSection>[])
      _tocLink(section.heading, section.id),
    if (_topicApis.isNotEmpty) _tocLink('API reference', 'topic-api'),
  ];

  Widget _toc() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 43, 22, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ON THIS PAGE',
          style: TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ..._contents(),
        const SizedBox(height: 24),
        Text(
          'READING PROGRESS / ${(_progress * 100).round()}%',
          style: const TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 25),
        const Divider(color: Ember.border),
        const SizedBox(height: 16),
        if (_hasLiveExample) ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Reduce motion',
                  style: TextStyle(color: Ember.muted, fontSize: 11),
                ),
              ),
              ComponentToggle(
                label: 'Reduce motion',
                value: _reduced,
                onChanged: MediaQuery.disableAnimationsOf(context)
                    ? null
                    : (value) => setState(() => _reduce = value),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'System preference takes priority.\nColor theme stays dark.',
            style: TextStyle(color: Ember.muted, fontSize: 10, height: 1.7),
          ),
        ],
        const SizedBox(height: 22),
        const Divider(color: Ember.border),
        const SizedBox(height: 22),
        if (!_isApi &&
            docExampleFor(
                  widget.packageId,
                  widget.sectionId,
                )?.playgroundRoute !=
                null)
          _tocAction(
            'Related playground ↗',
            () => widget.onNavigate(
              docExampleFor(
                widget.packageId,
                widget.sectionId,
              )!.playgroundRoute,
            ),
          ),
        if (_componentGuide != null)
          _tocAction(
            'Open in playground ↗',
            () => widget.onNavigate(_componentGuide!.playgroundRoute),
          ),
        _tocAction(
          'Browse more examples ↗',
          () => widget.onNavigate('/examples'),
        ),
      ],
    ),
  );

  Widget _tocLink(String label, String id) => InkWell(
    key: ValueKey('toc-$id'),
    onTap: () => _jump(id),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          color: _activeSection == id ? Ember.accent : Ember.muted,
          fontSize: 11,
        ),
      ),
    ),
  );

  Widget _tocAction(String label, VoidCallback action) => InkWell(
    onTap: action,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: const TextStyle(color: Ember.muted, fontSize: 11),
      ),
    ),
  );
}

class _Chevron extends StatelessWidget {
  const _Chevron();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 9),
    child: Icon(Icons.chevron_right, size: 11, color: Ember.muted),
  );
}

class _TinyTag extends StatelessWidget {
  const _TinyTag(this.label, {this.motionIcon = false});
  final String label;
  final bool motionIcon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (motionIcon) ...[
          const CustomPaint(
            size: Size(11, 11),
            painter: DocumentationWave(color: Ember.muted),
          ),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: MediaQuery.sizeOf(context).width < 640 ? 8 : 9,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _DotField extends CustomPainter {
  const _DotField({required this.enabled});
  final bool enabled;
  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;
    final paint = Paint()..color = const Color(0xFF424737);
    for (var x = 11.0; x < size.width; x += 22) {
      for (var y = 11.0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), .7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotField oldDelegate) =>
      enabled != oldDelegate.enabled;
}

class _DashedTarget extends CustomPainter {
  const _DashedTarget();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Ember.strong
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final metric in path.computeMetrics()) {
      for (var offset = 0.0; offset < metric.length; offset += 5) {
        canvas.drawPath(
          metric.extractPath(offset, math.min(offset + 2, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpringCurve extends CustomPainter {
  const _SpringCurve();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 280, size.height / 78);
    final guide = Paint()
      ..color = Ember.accent.withValues(alpha: .13)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 52), const Offset(280, 52), guide);
    canvas.drawLine(const Offset(0, 26), const Offset(280, 26), guide);
    final path = Path()
      ..moveTo(0, 69)
      ..cubicTo(17, 69, 20, 3, 46, 8)
      ..cubicTo(67, 13, 67, 75, 89, 52)
      ..cubicTo(109, 28, 109, 28, 130, 47)
      ..cubicTo(151, 58, 151, 58, 171, 50)
      ..cubicTo(202, 52, 202, 52, 223, 51)
      ..lineTo(280, 51);
    canvas.drawPath(
      path,
      Paint()
        ..color = Ember.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
