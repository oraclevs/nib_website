import '../recipes/recipe_catalog.dart';
import '../recipes/recipe_export.dart';
import '../recipes/recipe_tuning.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../docs/doc_example_catalog.dart';
import '../docs/motion_minimal_examples.dart';
import '../ember_theme.dart';
import '../widgets/dart_code_view.dart';

Future<String> loadDocExampleSource(
  DocExample example, {
  AssetBundle? bundle,
}) async {
  final assets = bundle ?? rootBundle;
  return recipeRunnableExample(
    recipeById(example.playgroundId)!,
    0,
    const RecipeTuning(),
    await assets.loadString(example.sourceAsset),
    await assets.loadString('lib/ember_material_theme.dart'),
    null,
    await assets.loadString('lib/components/component_theme.dart'),
    await assets.loadString('lib/components/component_toggle.dart'),
  );
}

/// The source shown here is the Dart asset imported by the preview catalog.
class DocExamplePanel extends StatefulWidget {
  const DocExamplePanel({
    super.key,
    required this.example,
    required this.onNavigate,
  });
  final DocExample example;
  final ValueChanged<String> onNavigate;
  @override
  State<DocExamplePanel> createState() => _DocExamplePanelState();
}

class _DocExamplePanelState extends State<DocExamplePanel> {
  Future<String>? _source;
  AssetBundle? _bundle;
  bool _showSource = false;
  bool _minimal = true;
  bool _copied = false;
  int _generation = 0;

  Future<String> _loadSource() =>
      loadDocExampleSource(widget.example, bundle: _bundle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    if (_bundle != bundle) {
      _bundle = bundle;
      _source = _loadSource();
    }
  }

  @override
  void didUpdateWidget(covariant DocExamplePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.example.identity != widget.example.identity) {
      _source = _loadSource();
      _showSource = false;
      _minimal = true;
      _copied = false;
      _generation++;
    }
  }

  Future<void> _copy(String source) async {
    try {
      await Clipboard.setData(ClipboardData(text: source));
      if (mounted) setState(() => _copied = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copy unavailable. Select the source instead.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _source,
    builder: (context, snapshot) => Container(
      decoration: BoxDecoration(
        color: Ember.panel,
        border: Border.all(color: Ember.border),
        borderRadius: BorderRadius.circular(7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tab(
                      'Preview',
                      !_showSource,
                      () => setState(() => _showSource = false),
                    ),
                    _tab(
                      'Source',
                      _showSource,
                      () => setState(() => _showSource = true),
                    ),
                  ],
                ),
                if (widget.example.playgroundRoute case final route)
                  TextButton.icon(
                    onPressed: () => widget.onNavigate(route),
                    icon: const Icon(Icons.north_east, size: 12),
                    label: const Text('Open playground'),
                    style: TextButton.styleFrom(
                      foregroundColor: Ember.accent,
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Ember.border),
          if (_showSource) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  if (minimalDocExample(widget.example) != null)
                    _tab(
                      'Minimal example',
                      _minimal,
                      () => setState(() {
                        _minimal = true;
                        _copied = false;
                      }),
                    ),
                  _tab(
                    'Full example',
                    !_minimal || minimalDocExample(widget.example) == null,
                    () => setState(() {
                      _minimal = false;
                      _copied = false;
                    }),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Paste into lib/main.dart. Full example includes the preview controls.',
                style: TextStyle(color: Ember.muted, fontSize: 11),
              ),
            ),
            SizedBox(
              height: 360,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  child: snapshot.hasData
                      ? DartCodeView(
                          code: _selectedSource(snapshot.data!),
                          fontSize: 11,
                        )
                      : Text(
                          snapshot.hasError
                              ? 'Source could not load. Reopen this guide to retry.'
                              : 'Loading source…',
                        ),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryScrollController.none(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.example.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Ember.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.example.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Ember.muted,
                        fontSize: 12,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    KeyedSubtree(
                      key: ValueKey('${widget.example.identity}-$_generation'),
                      child: Material(
                        color: Colors.transparent,
                        child: widget.example.buildPreview(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1, color: Ember.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _generation++),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Reset example'),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
                TextButton.icon(
                  onPressed: snapshot.hasData
                      ? () => _copy(_selectedSource(snapshot.data!))
                      : null,
                  icon: Icon(
                    _copied ? Icons.check : Icons.copy_outlined,
                    size: 13,
                  ),
                  label: Text(
                    _copied
                        ? 'Copied example'
                        : _minimal && minimalDocExample(widget.example) != null
                        ? 'Copy minimal example'
                        : 'Copy full example',
                  ),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String _selectedSource(String full) =>
      _minimal ? minimalDocExample(widget.example) ?? full : full;

  Widget _tab(String label, bool selected, VoidCallback onTap) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: selected ? Ember.text : Ember.muted,
      backgroundColor: selected ? Ember.raised : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: const TextStyle(fontSize: 11),
    ),
    child: Text(label),
  );
}
