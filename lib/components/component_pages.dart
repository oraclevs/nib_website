import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ember_theme.dart';
import '../playground/playground_chrome.dart';
import '../playground/discovery_card.dart';
import '../content/site_content.dart';
import '../pages/api_reference_panel.dart';
import '../pages/doc_blocks.dart';
import '../widgets/dart_code_view.dart';
import 'component_catalog.dart';
import 'component_export.dart';
import 'component_model.dart';
import 'component_preview.dart';
import 'component_settings.dart';
import 'component_toggle.dart';

class ComponentExplorerPage extends StatefulWidget {
  const ComponentExplorerPage({super.key, required this.onNavigate});
  final ValueChanged<String> onNavigate;
  @override
  State<ComponentExplorerPage> createState() => _ComponentExplorerPageState();
}

class _ComponentExplorerPageState extends State<ComponentExplorerPage> {
  final _search = TextEditingController();
  String _category = 'All';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase().trim();
    final matches = componentGuides
        .where(
          (g) =>
              (_category == 'All' || g.category == _category) &&
              '${g.title} ${g.summary} ${g.symbols.join(' ')} ${g.sections.expand((s) => s.paragraphs).join(' ')}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 640;
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
    return Theme(
      data: playgroundTheme(context),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: EmberWrap(
              child: Padding(
                padding: EdgeInsets.only(top: mobile ? 30 : 44, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: double.infinity),
                    const Text(
                      'NIBCOMPONENTS / THE CATALOG',
                      style: TextStyle(
                        color: Ember.accent,
                        fontFamily: Ember.mono,
                        fontSize: 10,
                        letterSpacing: 1.7,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(text: 'Real components.\n'),
                          TextSpan(
                            text: 'Ready to make yours.',
                            style: TextStyle(color: Ember.accent),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Ember.text,
                        fontSize: mobile ? 39 : 48,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.8,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(
                      width: 620,
                      child: Text(
                        'Browse the real Flutter widgets. Open a component in the playground to try its states, change its settings, and take the working source.',
                        style: TextStyle(
                          color: Ember.muted,
                          fontSize: 14,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final category in [
                          'All',
                          ...componentGuides.map((g) => g.category).toSet(),
                        ])
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: category == _category
                                  ? Ember.soft
                                  : Colors.transparent,
                              foregroundColor: category == _category
                                  ? Ember.accent
                                  : Ember.muted,
                              side: BorderSide(
                                color: category == _category
                                    ? const Color(0xFF88621B)
                                    : Ember.border,
                              ),
                            ),
                            onPressed: () =>
                                setState(() => _category = category),
                            child: Text(category),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 18,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: mobile ? double.infinity : 280,
                          child: TextField(
                            controller: _search,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Find a component or public API',
                              prefixIcon: Icon(Icons.search, size: 16),
                            ),
                          ),
                        ),
                        Text(
                          '${matches.where((g) => !g.composition).length} COMPONENT GUIDES · ${matches.where((g) => g.composition).length} COMPOSITIONS',
                          style: const TextStyle(
                            color: Ember.muted,
                            fontFamily: Ember.mono,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              // Same card proportions and max-width wrapper as the Examples page.
              final usable = constraints.crossAxisExtent;
              final inset =
                  (usable - 1424).clamp(0.0, double.infinity) / 2 +
                  (usable < 720 ? 19.0 : 56.0);
              final columns = mobile || largeText
                  ? 1
                  : width <= 850
                  ? 2
                  : 3;
              final artHeight = mobile
                  ? 230.0
                  : width <= 850
                  ? 220.0
                  : 250.0;
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(inset, 0, inset, 48),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: artHeight + (largeText ? 190 : 150),
                    crossAxisSpacing: width > 1199 ? 22 : 14,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (_, index) {
                    final guide = matches[index];
                    return DiscoveryCard(
                      key: ValueKey('component-card-${guide.id}'),
                      title: guide.title,
                      summary: guide.summary,
                      actionLabel: 'Open in playground',
                      artHeight: artHeight,
                      mobile: mobile,
                      compact: width <= 850 && !mobile,
                      ambient: false,
                      onTap: () => widget.onNavigate(guide.playgroundRoute),
                      preview: ExcludeSemantics(
                        child: ExcludeFocus(
                          child: IgnorePointer(
                            child: ClipRect(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 420,
                                  height: guide.composition
                                      ? guide.previewHeight
                                      : 300,
                                  child: ComponentPreview(
                                    settings: guide.initial,
                                    height: guide.previewHeight,
                                    paused: true,
                                    child: buildComponentDemo(
                                      guide,
                                      guide.initial,
                                      (_) {},
                                      (_) {},
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          if (matches.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No matching components. Try an API name such as NibInput.',
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: EmberWrap(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  'View-only previews. Each playground uses the same component and exports its configured source. Local candidate: nib_components 0.2.2; published releases may differ.',
                  style: TextStyle(
                    color: Ember.muted,
                    fontSize: 11,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ComponentCodeView { short, full, source }

class ComponentGuidePage extends StatefulWidget {
  const ComponentGuidePage({
    super.key,
    required this.guide,
    required this.onNavigate,
    this.anchor = '',
    this.playground = false,
    this.embedded = false,
  });
  final ComponentGuide guide;
  final ValueChanged<String> onNavigate;
  final String anchor;
  final bool playground;
  final bool embedded;
  @override
  State<ComponentGuidePage> createState() => _ComponentGuidePageState();
}

class _ComponentGuidePageState extends State<ComponentGuidePage> {
  late ComponentSettings _settings = widget.guide.initial;
  late Future<String> _source = componentRunnableSource(
    widget.guide,
    _settings,
  );
  late Future<String> _demoSource = componentDemoSource(widget.guide);
  late final _textInspector = TextEditingController(text: _settings.text);
  final _topics = ScrollController();
  final _article = ScrollController();
  final _sections = <String, GlobalKey>{};
  final _events = <String>[];
  int _generation = 0;
  int _waterMobileTab = 0;
  bool _paused = false;
  bool _reduced = false;
  String _componentQuery = '';
  _ComponentCodeView _codeView = _ComponentCodeView.short;
  String? _copyStatus;
  @override
  void initState() {
    super.initState();
    _scheduleAnchor();
  }

  @override
  void didUpdateWidget(covariant ComponentGuidePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guide.id != widget.guide.id) {
      _settings = widget.guide.initial;
      _textInspector.text = _settings.text;
      _source = componentRunnableSource(widget.guide, _settings);
      _demoSource = componentDemoSource(widget.guide);
      _codeView = _ComponentCodeView.short;
      _events.clear();
      _generation++;
      _sections.clear();
      _copyStatus = null;
      if (_article.hasClients) _article.jumpTo(0);
    }
    if (oldWidget.anchor != widget.anchor ||
        oldWidget.guide.id != widget.guide.id) {
      _scheduleAnchor();
    }
  }

  void _scheduleAnchor() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && widget.anchor.isNotEmpty) _jump(widget.anchor);
  });
  void _jump(String id) {
    final target = _sections[id]?.currentContext;
    if (target != null) {
      unawaited(Scrollable.ensureVisible(target, duration: Duration.zero));
    }
  }

  @override
  void dispose() {
    _textInspector.dispose();
    _topics.dispose();
    _article.dispose();
    super.dispose();
  }

  void _change(ComponentSettings next) => setState(() {
    if (_textInspector.text != next.text) {
      final selection = _textInspector.selection;
      _textInspector.value = TextEditingValue(
        text: next.text,
        selection: selection.isValid
            ? TextSelection(
                baseOffset: selection.baseOffset.clamp(0, next.text.length),
                extentOffset: selection.extentOffset.clamp(0, next.text.length),
              )
            : TextSelection.collapsed(offset: next.text.length),
      );
    }
    _settings = next;
    _source = componentRunnableSource(widget.guide, _settings);
    _copyStatus = null;
  });
  void _event(String event) => setState(() {
    _events.insert(0, event);
    if (_events.length > 4) _events.removeLast();
  });
  Future<void> _copy() async {
    try {
      final code = switch (_codeView) {
        _ComponentCodeView.short => componentShortSource(widget.guide),
        _ComponentCodeView.full => await _source,
        _ComponentCodeView.source => await _demoSource,
      };
      await Clipboard.setData(ClipboardData(text: code));
      if (mounted) {
        setState(
          () => _copyStatus = switch (_codeView) {
            _ComponentCodeView.short => 'Short example copied.',
            _ComponentCodeView.full => 'Full example copied.',
            _ComponentCodeView.source => 'Demo source copied.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _copyStatus = 'Clipboard unavailable. Select the code below and copy it manually.',
        );
      }
    }
  }

  Widget _codePanel() {
    final label = switch (_codeView) {
      _ComponentCodeView.short => 'Short example',
      _ComponentCodeView.full => 'Full example',
      _ComponentCodeView.source => 'Demo source',
    };
    final description = switch (_codeView) {
      _ComponentCodeView.short => 'A small main.dart you can run with nib_components and nib_motion installed. State and callbacks are included.',
      _ComponentCodeView.full => 'The configured playground as a complete main.dart, with theme and support code included.',
      _ComponentCodeView.source =>
        'The website demo file at ${widget.guide.demoFile}. It uses website helpers; choose Full example for a standalone app.',
    };
    final code = switch (_codeView) {
      _ComponentCodeView.short => null,
      _ComponentCodeView.full => _source,
      _ComponentCodeView.source => _demoSource,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Code',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in _ComponentCodeView.values)
              OutlinedButton(
                key: ValueKey('component-code-${choice.name}'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _codeView == choice
                      ? Ember.soft
                      : Colors.transparent,
                  foregroundColor: _codeView == choice
                      ? Ember.accent
                      : Ember.muted,
                  side: BorderSide(
                    color: _codeView == choice ? Ember.accent : Ember.border,
                  ),
                ),
                onPressed: () => setState(() {
                  _codeView = choice;
                  _copyStatus = null;
                }),
                child: Text(switch (choice) {
                  _ComponentCodeView.short => 'Short',
                  _ComponentCodeView.full => 'Full example',
                  _ComponentCodeView.source => 'Demo source',
                }),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(color: Ember.muted, fontSize: 12, height: 1.6),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('component-copy-code'),
            onPressed: _copy,
            icon: const Icon(Icons.copy, size: 16),
            label: Text('Copy $label'),
          ),
        ),
        if (_copyStatus != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(liveRegion: true, child: Text(_copyStatus!)),
          ),
        const SizedBox(height: 12),
        if (code == null)
          _code(componentShortSource(widget.guide))
        else
          FutureBuilder<String>(
            future: code,
            builder: (_, snapshot) => snapshot.hasData
                ? _code(snapshot.data!)
                : Text(
                    snapshot.hasError
                        ? 'Code could not load. Reload to retry.'
                        : 'Loading code…',
                  ),
          ),
      ],
    );
  }

  Widget _heading(String id, String title) => Padding(
    key: _sections.putIfAbsent(id, GlobalKey.new),
    padding: const EdgeInsets.only(top: 32, bottom: 14),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        letterSpacing: -.5,
      ),
    ),
  );
  Widget _code(String code) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Ember.code,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DartCodeView(code: code),
    ),
  );
  Widget _control(ComponentControl control) {
    final value = _settings.values[control.key]!;
    final label = Text(
      control.label,
      style: const TextStyle(color: Ember.text, fontSize: 12, height: 1.5),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (control.kind == ComponentControlKind.toggle)
            Row(
              children: [
                Expanded(child: label),
                const SizedBox(width: 12),
                ComponentToggle(
                  key: ValueKey('component-control-${control.key}'),
                  value: value as bool,
                  label: control.label,
                  onChanged: (next) =>
                      _change(_settings.change(control.key, next)),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(child: label),
                if (control.kind == ComponentControlKind.number)
                  Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Ember.bg,
                      border: Border.all(color: Ember.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      value is double
                          ? value.toStringAsFixed(value.abs() < 2 ? 2 : 0)
                          : '$value',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Ember.text,
                        fontFamily: Ember.mono,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            switch (control.kind) {
              ComponentControlKind.number => Slider(
                key: ValueKey('component-control-${control.key}'),
                value: (value as num).toDouble().clamp(
                  control.minimum,
                  control.maximum,
                ),
                min: control.minimum,
                max: control.maximum,
                semanticFormatterCallback: (v) =>
                    '${control.label}: ${v.toStringAsFixed(2)}',
                onChanged: (next) =>
                    _change(_settings.change(control.key, next)),
              ),
              ComponentControlKind.choice => DropdownButtonFormField<String>(
                key: ValueKey('${widget.guide.id}-${control.key}-$value'),
                initialValue: value as String,
                isExpanded: true,
                dropdownColor: Ember.panel,
                borderRadius: BorderRadius.circular(5),
                style: const TextStyle(
                  color: Ember.text,
                  fontSize: 12,
                  fontFamily: 'Ember Sans',
                ),
                icon: const Icon(
                  Icons.expand_more,
                  color: Ember.muted,
                  size: 17,
                ),
                decoration: InputDecoration(semanticCounterText: control.label),
                items: [
                  for (final choice in control.choices)
                    DropdownMenuItem(value: choice, child: Text(choice)),
                ],
                onChanged: (next) {
                  if (next != null) {
                    _change(_settings.change(control.key, next));
                  }
                },
              ),
              ComponentControlKind.text => TextFormField(
                key: ValueKey('${widget.guide.id}-${control.key}-$_generation'),
                controller: _textInspector,
                style: const TextStyle(color: Ember.text, fontSize: 12),
                maxLength: 280,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: control.label,
                ),
                onChanged: (next) =>
                    _change(_settings.change(control.key, next)),
              ),
              ComponentControlKind.toggle => const SizedBox.shrink(),
            },
          ],
          if (control.help != null)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                control.help!,
                style: const TextStyle(
                  color: Ember.muted,
                  fontSize: 11,
                  height: 1.7,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inspector() => Container(
    padding: const EdgeInsets.all(20),

    child: Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Make it yours',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
          ),
          const SizedBox(height: 12),
          const Text(
            'Animation starts on. Adjust the preview. Full example includes your choices; Short shows the basic usage.',
            style: TextStyle(color: Ember.muted, fontSize: 11, height: 1.8),
          ),
          const SizedBox(height: 24),
          for (final control in widget.guide.controls.where(
            (c) => !c.advanced && c.isVisible(_settings),
          ))
            _control(control),
          if (widget.guide.controls.any(
            (c) => c.advanced && c.isVisible(_settings),
          ))
            ExpansionTile(
              title: const Text(
                'Advanced settings',
                style: TextStyle(color: Ember.text, fontSize: 12),
              ),
              iconColor: Ember.accent,
              collapsedIconColor: Ember.muted,
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: EdgeInsets.zero,
              children: [
                for (final control in widget.guide.controls.where(
                  (c) => c.advanced && c.isVisible(_settings),
                ))
                  _control(control),
              ],
            ),
          const Divider(color: Ember.border),
          const Text('Preview theme', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final accent in {
                'Amber': 0xFFFFB51B,
                'Sage': 0xFFCFDEA0,
              }.entries)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _settings.accent == accent.value
                        ? Ember.accent
                        : Ember.muted,
                    backgroundColor: _settings.accent == accent.value
                        ? Ember.soft
                        : Colors.transparent,
                    side: BorderSide(
                      color: _settings.accent == accent.value
                          ? const Color(0xFF88621B)
                          : Ember.border,
                    ),
                  ),
                  onPressed: () =>
                      _change(_settings.change('accent', accent.value)),
                  child: Text(accent.key),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!widget.guide.controls.any((control) => control.key == 'radius'))
            _control(
              const ComponentControl(
                'radius',
                'Theme radius',
                ComponentControlKind.number,
                minimum: 0,
                maximum: 24,
                help: 'A component’s explicit radius or custom clipper takes precedence.',
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _settings = widget.guide.initial;
              _textInspector.text = _settings.text;
              _generation++;
              _events.clear();
              _source = componentRunnableSource(widget.guide, _settings);
              _copyStatus = null;
            }),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset example'),
          ),
        ],
      ),
    ),
  );
  Widget _preview() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PlaygroundPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.guide.title.toUpperCase()} / ${widget.guide.composition ? 'COMPOSITION' : 'COMPONENTS'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Ember.text,
                        fontFamily: Ember.mono,
                        fontSize: 9,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Ember.soft,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'REAL FLUTTER',
                      style: TextStyle(
                        color: Ember.accent,
                        fontFamily: Ember.mono,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Ember.border),
            CustomPaint(
              painter: const PlaygroundDots(),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations:
                      _reduced || MediaQuery.disableAnimationsOf(context),
                ),
                child: ComponentPreview(
                  key: ValueKey('${widget.guide.id}-$_generation'),
                  settings: _settings,
                  height: widget.guide.previewHeight,
                  paused: _paused,
                  child: buildComponentDemo(
                    widget.guide,
                    _settings,
                    _change,
                    _event,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Ember.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _generation++),
                    icon: const Icon(Icons.restart_alt, size: 14),
                    label: const Text('Restart'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _paused = !_paused),
                    icon: Icon(
                      _paused ? Icons.play_arrow : Icons.pause,
                      size: 14,
                    ),
                    label: Text(_paused ? 'Resume' : 'Pause'),
                  ),
                  if (widget.playground)
                    TextButton.icon(
                      onPressed: () => widget.onNavigate(widget.guide.route),
                      icon: const Icon(Icons.menu_book_outlined, size: 14),
                      label: const Text('Read the guide'),
                    )
                  else
                    TextButton.icon(
                      onPressed: () =>
                          widget.onNavigate(widget.guide.playgroundRoute),
                      icon: const Icon(Icons.tune, size: 14),
                      label: const Text('Open in playground'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Semantics(
        liveRegion: true,
        child: Text(
          _events.isEmpty
              ? 'Interact with the component to see its callbacks here.'
              : _events.join('\n'),
          style: const TextStyle(
            color: Ember.positive,
            fontSize: 12,
            height: 1.7,
          ),
        ),
      ),
    ],
  );

  Widget _body() => LayoutBuilder(
    builder: (context, bounds) => SingleChildScrollView(
      controller: _article,
      padding: EdgeInsets.symmetric(
        horizontal: bounds.maxWidth < 640 ? 20 : 32,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => widget.onNavigate('/components'),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('All components'),
            ),
          ),
          const SizedBox(height: 10),
          EmberEyebrow(widget.guide.category.toUpperCase()),
          _heading('overview', widget.guide.title),
          Text(
            widget.guide.summary,
            style: const TextStyle(
              color: Ember.muted,
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.guide.composition
                ? 'Composition using local nib_motion 0.3.4 and nib_components 0.2.2 candidates.'
                : 'Source: local nib_components 0.2.2 candidate. The published release may differ.',
            style: TextStyle(color: Ember.muted, fontSize: 12),
          ),
          _heading('try-it', 'Try it'),
          _preview(),
          const SizedBox(height: 20),
          _heading('code', 'Copy a working example'),
          _codePanel(),
          for (final section in widget.guide.sections) ...[
            _heading(section.id, section.heading),
            for (final paragraph in section.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SelectableText(
                  paragraph,
                  style: const TextStyle(
                    color: Ember.muted,
                    height: 1.85,
                    fontSize: 14,
                  ),
                ),
              ),
            if (section.code != null) _code(section.code!),
            if (section.note != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  section.note!,
                  style: const TextStyle(color: Ember.positive, height: 1.7),
                ),
              ),
            if (section.api.isNotEmpty)
              DocBlocks(
                blocks: [
                  DocTable(
                    headers: const ['Property', 'Type', 'Default', 'Behavior'],
                    rows: [
                      for (final entry in section.api)
                        [
                          entry.name,
                          entry.type,
                          entry.defaultValue,
                          entry.description,
                        ],
                    ],
                  ),
                ],
                onNavigate: widget.onNavigate,
              ),
            DocBlocks(blocks: section.blocks, onNavigate: widget.onNavigate),
          ],
          if (widget.guide.limitations.isNotEmpty) ...[
            _heading('limitations', 'Limits and platform evidence'),
            for (final limit in widget.guide.limitations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '• $limit',
                  style: const TextStyle(color: Ember.muted, height: 1.7),
                ),
              ),
          ],
          _heading('api', 'API reference'),
          ApiReferencePanel(
            packageId: widget.guide.apiPackageId,
            symbolNames: widget.guide.symbols,
            title: 'Constructors, properties and supporting APIs',
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
  void _reset() => setState(() {
    _settings = widget.guide.initial;
    _textInspector.text = _settings.text;
    _generation++;
    _events.clear();
    _paused = false;
    _source = componentRunnableSource(widget.guide, _settings);
    _copyStatus = null;
  });

  Widget _playgroundBrowser() => ListView(
    padding: const EdgeInsets.fromLTRB(12, 18, 12, 20),
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 13),
        child: Text(
          'COMPONENTS',
          style: TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 9,
            letterSpacing: 1.4,
          ),
        ),
      ),
      TextField(
        onChanged: (v) => setState(() => _componentQuery = v.toLowerCase()),
        style: const TextStyle(fontSize: 11),
        decoration: const InputDecoration(
          hintText: 'Find a component',
          prefixIcon: Icon(Icons.search, size: 16),
        ),
      ),
      for (final category
          in componentGuides.map((g) => g.category).toSet()) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 13),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: Ember.muted,
              fontFamily: Ember.mono,
              fontSize: 9,
              letterSpacing: 1.4,
            ),
          ),
        ),
        for (final guide in componentGuides.where(
          (g) =>
              g.category == category &&
              '${g.title} ${g.symbols.join(' ')}'.toLowerCase().contains(
                _componentQuery,
              ),
        ))
          InkWell(
            onTap: () => widget.onNavigate(guide.playgroundRoute),
            borderRadius: BorderRadius.circular(5),
            child: Container(
              constraints: const BoxConstraints(minHeight: 39),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: guide.id == widget.guide.id
                    ? Ember.soft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.widgets_outlined,
                    size: 15,
                    color: guide.id == widget.guide.id
                        ? Ember.accent
                        : Ember.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      guide.title,
                      style: TextStyle(
                        fontSize: 11,
                        color: guide.id == widget.guide.id
                            ? Ember.accent
                            : Ember.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
      const SizedBox(height: 20),
      const Divider(color: Ember.border),
      TextButton(
        onPressed: () => widget.onNavigate('/components'),
        child: const Text('Browse all components'),
      ),
      TextButton(
        onPressed: () => widget.onNavigate('/playground/card-flip'),
        child: const Text('Motion recipes'),
      ),
    ],
  );

  Widget _playground() => LayoutBuilder(
    builder: (context, bounds) {
      final mobile =
          bounds.maxWidth < 640 ||
          MediaQuery.textScalerOf(context).scale(14) > 19;
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The playground',
            style: TextStyle(
              color: Ember.text,
              fontSize: 32,
              height: 1.55,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.3,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Choose a component. Try its states. Make it yours.',
            style: TextStyle(color: Ember.muted, fontSize: 12, height: 1.55),
          ),
        ],
      );
      final actions = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt, size: 16),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
          ),
          FilledButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy code'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
          ),
        ],
      );
      final titlebar = Padding(
        padding: EdgeInsets.fromLTRB(
          mobile
              ? 20
              : bounds.maxWidth < 1200
              ? 28
              : 40,
          30,
          mobile
              ? 20
              : bounds.maxWidth < 1200
              ? 28
              : 40,
          25,
        ),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [heading, const SizedBox(height: 16), actions],
              )
            : Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  actions,
                ],
              ),
      );
      final dock = Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Wrap(
          spacing: 9,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _paused = !_paused),
              icon: Icon(_paused ? Icons.play_arrow : Icons.pause, size: 12),
              label: Text(_paused ? 'Resume motion' : 'Pause motion'),
            ),
            OutlinedButton.icon(
              onPressed: MediaQuery.disableAnimationsOf(context)
                  ? null
                  : () => setState(() => _reduced = !_reduced),
              icon: const Icon(Icons.visibility_outlined, size: 12),
              label: Text(
                _reduced || MediaQuery.disableAnimationsOf(context)
                    ? 'Reduced motion on'
                    : 'Reduce motion',
              ),
            ),
            const Text(
              'NATIVE FLUTTER / NIBCOMPONENTS',
              style: TextStyle(
                color: Ember.muted,
                fontFamily: Ember.mono,
                fontSize: 9,
              ),
            ),
          ],
        ),
      );
      final preview = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _preview(),
          const SizedBox(height: 20),
          Text(
            widget.guide.summary,
            style: const TextStyle(
              color: Ember.muted,
              fontSize: 12,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          _codePanel(),
        ],
      );
      final inspector = SingleChildScrollView(child: _inspector());
      if (mobile) {
        return ListView(
          children: [
            titlebar,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  dock,
                  DropdownButtonFormField<String>(
                    initialValue: widget.guide.id,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Component'),
                    items: [
                      for (final guide in componentGuides)
                        DropdownMenuItem(
                          value: guide.id,
                          child: Text(guide.title),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        widget.onNavigate(componentById(id)!.playgroundRoute);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  if (widget.guide.id == 'liquid-glass') ...[
                    Row(
                      children: [
                        for (var index = 0; index < 3; index++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: OutlinedButton(
                                key: ValueKey('water-mobile-tab-$index'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: _waterMobileTab == index
                                      ? Ember.soft
                                      : Colors.transparent,
                                  foregroundColor: _waterMobileTab == index
                                      ? Ember.accent
                                      : Ember.muted,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                ),
                                onPressed: () =>
                                    setState(() => _waterMobileTab = index),
                                child: Text(
                                  const ['Preview', 'Tune', 'Code'][index],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Offstage(
                      offstage: _waterMobileTab != 0,
                      child: TickerMode(
                        enabled: _waterMobileTab == 0,
                        child: preview,
                      ),
                    ),
                    Offstage(
                      offstage: _waterMobileTab != 1,
                      child: PlaygroundPanel(child: _inspector()),
                    ),
                    Offstage(
                      offstage: _waterMobileTab != 2,
                      child: _codePanel(),
                    ),
                  ] else ...[
                    preview,
                    const SizedBox(height: 18),
                    PlaygroundPanel(child: _inspector()),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        );
      }
      return PlaygroundWorkspace(
        width: bounds.maxWidth,
        titlebar: titlebar,
        dock: dock,
        browser: _playgroundBrowser(),
        preview: preview,
        inspector: inspector,
      );
    },
  );

  @override
  Widget build(BuildContext context) => Theme(
    data: playgroundTheme(context),
    child: widget.embedded
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _preview(),
              const SizedBox(height: 16),
              Text(
                widget.guide.composition
                    ? 'Local Motion 0.3.4 / Components 0.2.2 composition.'
                    : 'Local nib_components 0.2.2 candidate; published releases may differ.',
                style: const TextStyle(color: Ember.muted, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        widget.onNavigate(widget.guide.playgroundRoute),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Open in playground'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _copy,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy code'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _codePanel(),
            ],
          )
        : widget.playground
        ? _playground()
        : LayoutBuilder(
            builder: (context, bounds) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (bounds.maxWidth >= 900)
                  Container(
                    width: 210,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Ember.border)),
                    ),
                    child: ListView(
                      controller: _topics,
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            'NIBCOMPONENTS',
                            style: TextStyle(
                              fontFamily: Ember.mono,
                              fontSize: 11,
                              color: Ember.muted,
                            ),
                          ),
                        ),
                        for (final category
                            in componentGuides
                                .map((g) => g.category)
                                .toSet()) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(
                                color: Ember.muted,
                                fontFamily: Ember.mono,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          for (final guide in componentGuides.where(
                            (g) => g.category == category,
                          ))
                            TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                foregroundColor: guide.id == widget.guide.id
                                    ? Ember.accent
                                    : Ember.muted,
                              ),
                              onPressed: () => widget.onNavigate(guide.route),
                              child: Text(guide.title),
                            ),
                        ],
                        const Divider(color: Ember.border),
                        TextButton(
                          onPressed: () =>
                              widget.onNavigate('/docs/components/theming'),
                          child: const Text('Theming guide'),
                        ),
                        TextButton(
                          onPressed: () =>
                              widget.onNavigate('/docs/components/api'),
                          child: const Text('Entire public API'),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _body()),
                if (bounds.maxWidth >= 1440)
                  SizedBox(
                    width: 180,
                    child: ListView(
                      primary: false,
                      padding: const EdgeInsets.fromLTRB(4, 44, 18, 16),
                      children: [
                        const Text(
                          'ON THIS PAGE',
                          style: TextStyle(
                            fontFamily: Ember.mono,
                            color: Ember.muted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final section in {
                          'overview': 'Overview',
                          'try-it': 'Try it',
                          'minimal': 'Minimal usage',
                          for (final s in widget.guide.sections)
                            s.id: s.heading,
                          if (widget.guide.limitations.isNotEmpty)
                            'limitations': 'Limits',
                          'api': 'API reference',
                        }.entries)
                          TextButton(
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              foregroundColor: Ember.muted,
                            ),
                            onPressed: () {
                              _jump(section.key);
                              widget.onNavigate(
                                '${widget.guide.route}#${section.key}',
                              );
                            },
                            child: Text(
                              section.value,
                              style: const TextStyle(fontSize: 12, height: 1.6),
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
