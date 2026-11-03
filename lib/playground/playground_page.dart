import '../components/component_toggle.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nib_motion/nib_motion.dart';

import '../ember_theme.dart';
import 'playground_chrome.dart';
import '../recipes/recipe_catalog.dart';
import '../recipes/recipe_export.dart';
import '../recipes/recipe_favorites.dart';
import '../recipes/recipe_runtime.dart';
import '../recipes/recipe_tuning.dart';
import '../recipes/spring_retarget_recipe.dart';
import '../widgets/dart_code_view.dart';

enum _Pane { preview, tune, code }

enum _SourcePane { minimal, configuration, behavior, handoff }

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({
    super.key,
    required this.recipeId,
    required this.onOpenRecipe,
    this.onNavigate,
  });

  final String recipeId;
  final ValueChanged<String> onOpenRecipe;
  final ValueChanged<String>? onNavigate;

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final _favorites = RecipeFavorites.shared;
  final _codeKey = GlobalKey();

  final _search = TextEditingController();
  String _category = 'All';
  _Pane _pane = _Pane.preview;
  _SourcePane _sourcePane = _SourcePane.minimal;
  late RecipeDefinition? _recipe;
  late double _value;
  late RecipeTuning _tuning;
  int _generation = 0;
  String? _notice;
  Future<String>? _source;
  Future<String>? _tuningSource;
  Future<List<String>>? _sources;
  bool _codeVisited = false;
  bool _reducePreview = false;
  bool _previewPaused = false;
  bool _motionPaused = false;
  bool _ambient = true;
  bool _showRecipeFilters = false;
  final _runtimeController = RecipeRuntimeController();
  String? _loadedUri;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
    _loadRecipe();
    unawaited(_favorites.load());
  }

  @override
  void didUpdateWidget(covariant PlaygroundPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeId != widget.recipeId ||
        _loadedUri != Uri.base.toString()) {
      _loadRecipe();
      if (oldWidget.recipeId != widget.recipeId) {
        _pane = _Pane.preview;
        _codeVisited = false;
        _generation++;
        _previewPaused = false;
      }
    }
  }

  void _loadRecipe() {
    _loadedUri = Uri.base.toString();
    _recipe = recipeById(widget.recipeId);
    final recipe = _recipe;
    if (recipe == null) {
      _value = 0;
      _tuning = const RecipeTuning();
      _source = null;
      _sources = null;
      return;
    }
    final config = recipeConfigurationFromUri(recipe, Uri.base);
    _value = config.value;
    _tuning = config.tuning;
    _source = rootBundle.loadString(recipe.sourceAsset);
    _tuningSource = rootBundle.loadString('lib/recipes/recipe_tuning.dart');
    _sources = Future.wait([
      _source!,
      rootBundle.loadString('lib/ember_material_theme.dart'),
      rootBundle.loadString('lib/components/component_theme.dart'),
      rootBundle.loadString('lib/components/component_toggle.dart'),
      if (recipe.id != 'spring-retarget' && recipe.documentationExample == null)
        _tuningSource!,
    ]);
    _notice = null;
    _sourcePane = recipeMinimalExample(recipe, _value, _tuning) == null
        ? _SourcePane.behavior
        : _SourcePane.minimal;
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    _runtimeController.dispose();
    super.dispose();
  }

  Uri get _shareUri => recipeShareUri(_recipe!, _value, _tuning, Uri.base);

  Future<void> _copy(String text, String success) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      setState(() => _notice = success);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _notice = 'Clipboard unavailable. Select the code below to copy it.';
        _pane = _Pane.code;
        _codeVisited = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_notice!)));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final codeContext = _codeKey.currentContext;
        if (mounted && codeContext != null) {
          Scrollable.ensureVisible(codeContext);
        }
      });
    }
  }

  Future<void> _copyExample(
    RecipeDefinition recipe, {
    bool full = false,
  }) async {
    try {
      final minimal = recipeMinimalExample(recipe, _value, _tuning);
      if (!full && _sourcePane == _SourcePane.minimal && minimal != null) {
        await _copy(minimal, 'Minimal main.dart copied.');
        return;
      }
      final files = await _sources!;
      if (!mounted || _recipe?.id != recipe.id) return;
      await _copy(
        recipeRunnableExample(
          recipe,
          _value,
          _tuning,
          files.first,
          files[1],
          files.length > 4 ? files[4] : null,
          files[2],
          files[3],
        ),
        'Complete main.dart copied.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () =>
            _notice = 'Example source could not be loaded. Try the Code panel.',
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_notice!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    if (recipe == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This recipe is not in the catalog.'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => widget.onOpenRecipe(verifiedRecipes.first.id),
              child: const Text('Open the first recipe'),
            ),
          ],
        ),
      );
    }
    return EmberMotionPolicy(
      paused: _motionPaused,
      reduced: _reducePreview || MediaQuery.disableAnimationsOf(context),
      ambient: _ambient,
      child: Theme(
        data: playgroundTheme(context),
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 640
              ? _desktop(recipe, constraints.maxWidth)
              : _mobile(recipe),
        ),
      ),
    );
  }

  Widget _desktop(RecipeDefinition recipe, double width) => PlaygroundWorkspace(
    width: width,
    titlebar: _titlebar(recipe, horizontal: width < 1200 ? 28 : 40),
    dock: _motionDock(),
    browser: _browser(),
    preview: _previewAndCode(recipe),
    inspector: _inspector(recipe),
    footer: _status(),
  );

  Widget _framed(Widget child) => PlaygroundPanel(child: child);

  Widget _titlebar(
    RecipeDefinition recipe, {
    required double horizontal,
  }) => Padding(
    padding: EdgeInsets.fromLTRB(horizontal, 30, horizontal, 25),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The playground',
                style: TextStyle(
                  color: Ember.text,
                  fontSize: 32,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.3,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Choose a recipe. Adjust the feel. Find your starting point.',
                style: TextStyle(
                  color: Ember.muted,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => _reset(recipe),
          icon: const Icon(Icons.restart_alt, size: 16),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _copyExample(recipe),
          icon: const Icon(Icons.copy, size: 16),
          label: Text(
            _sourcePane == _SourcePane.minimal &&
                    recipeMinimalExample(recipe, _value, _tuning) != null
                ? 'Copy minimal example'
                : 'Copy full example',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  void _reset(RecipeDefinition recipe) => setState(() {
    _value = recipe.initial;
    _tuning = defaultRecipeTuning(recipe);
    _previewPaused = false;
    _generation++;
  });

  Widget _status() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Ember.border)),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'EMBER / LOCAL FLUTTER PREVIEW',
          style: TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 9,
          ),
        ),
        Text(
          'Settings and source stay together.',
          style: TextStyle(
            color: Ember.muted,
            fontFamily: Ember.mono,
            fontSize: 9,
          ),
        ),
      ],
    ),
  );

  Widget _mobile(RecipeDefinition recipe) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The playground',
              style: TextStyle(
                color: Ember.text,
                fontSize: 31,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a recipe. Adjust the feel. Find your starting point.',
              style: TextStyle(color: Ember.muted, fontSize: 11),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _reset(recipe),
                  icon: const Icon(Icons.restart_alt, size: 15),
                  label: const Text('Reset'),
                ),
                FilledButton.icon(
                  onPressed: () => _copyExample(recipe),
                  icon: const Icon(Icons.copy, size: 15),
                  label: Text(
                    _sourcePane == _SourcePane.minimal &&
                            recipeMinimalExample(recipe, _value, _tuning) !=
                                null
                        ? 'Copy minimal example'
                        : 'Copy full example',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: _motionDock(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
        child: Row(
          children: [
            const Text(
              'RECIPE',
              style: TextStyle(
                color: Ember.muted,
                fontFamily: Ember.mono,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: recipe.id,
                underline: const SizedBox.shrink(),
                items: [
                  for (final item in allRecipes)
                    DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) widget.onOpenRecipe(id);
                },
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(
          children: [
            for (final pane in _Pane.values)
              Padding(
                padding: const EdgeInsets.only(right: 22),
                child: InkWell(
                  onTap: () => setState(() {
                    _pane = pane;
                    if (_pane == _Pane.code) _codeVisited = true;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _pane == pane
                              ? Ember.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      switch (pane) {
                        _Pane.preview => 'Preview',
                        _Pane.tune => 'Tune',
                        _Pane.code => 'Code',
                      },
                      style: TextStyle(
                        color: _pane == pane ? Ember.accent : Ember.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      Expanded(
        child: IndexedStack(
          index: _pane.index,
          children: [
            TickerMode(
              enabled: _pane == _Pane.preview,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  _preview(recipe),
                  const SizedBox(height: 12),
                  _heading(recipe),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _framed(_inspector(recipe)),
            ),
            _codeVisited ? _code(recipe) : const SizedBox.shrink(),
          ],
        ),
      ),
    ],
  );

  Widget _motionDock() {
    final systemReduced = MediaQuery.disableAnimationsOf(context);
    final mobile = MediaQuery.sizeOf(context).width < 640;
    Widget preference(
      String label,
      IconData icon,
      VoidCallback? action,
      bool selected,
    ) => OutlinedButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 12),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 9 : 12,
          vertical: mobile ? 8 : 9,
        ),
        textStyle: TextStyle(fontSize: mobile ? 9 : 10, fontFamily: Ember.mono),
        foregroundColor: selected ? Ember.accent : Ember.muted,
        backgroundColor: Ember.panel,
        side: BorderSide(
          color: selected ? const Color(0xFF88621B) : Ember.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
    final controls = [
      preference(
        _motionPaused ? 'Resume motion' : 'Pause motion',
        _motionPaused ? Icons.play_arrow : Icons.pause,
        () => setState(() => _motionPaused = !_motionPaused),
        _motionPaused,
      ),
      preference(
        systemReduced || _reducePreview ? 'Reduced motion on' : 'Reduce motion',
        Icons.visibility_outlined,
        systemReduced
            ? null
            : () => setState(() => _reducePreview = !_reducePreview),
        systemReduced || _reducePreview,
      ),
      if (!mobile)
        preference(
          _ambient ? 'Ambient on' : 'Ambient off',
          Icons.blur_on,
          () => setState(() => _ambient = !_ambient),
          _ambient,
        ),
    ];
    final note = Text(
      systemReduced
          ? 'SYSTEM REDUCED MOTION · RESPECTED'
          : 'NATIVE FLUTTER / NIBMOTION',
      style: TextStyle(
        color: Ember.muted,
        fontFamily: Ember.mono,
        fontSize: mobile ? 8 : 9,
      ),
    );
    return Padding(
      padding: EdgeInsets.only(top: mobile ? 10 : 12, bottom: 16),
      child: mobile
          ? Wrap(
              spacing: 7,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...controls,
                SizedBox(width: double.infinity, child: note),
              ],
            )
          : Row(
              children: [
                for (final control in controls) ...[
                  control,
                  const SizedBox(width: 9),
                ],
                const Spacer(),
                Flexible(child: note),
              ],
            ),
    );
  }

  String _recipeLabel(RecipeDefinition recipe) => switch (recipe.id) {
    'spring-retarget' => 'Spring retarget',
    'keyframe-hop' => 'Keyframe hop',
    'spring-tween' => 'Spring vs. timed',
    'animated-counter' => 'Animated counter',
    'progress-choreography' => 'Progress choreography',
    'linked-objects' => 'Linked objects',
    'card-flip' => 'Flip card',
    'bounded-drag' => 'Bounded drag',
    'swipe-restore' => 'Swipe and restore',
    'hover-press' => 'Hover and press',
    'drag-snap' => 'Drag and snap',
    'pivot-turn' => 'Pivot turn',
    'keyed-reorder' => 'Reorder',
    'presence-reflow' => 'Presence and reflow',
    'expanding-card' => 'Expanding card',
    'selection-indicator' => 'Shared selection',
    'variant-orchestration' => 'Variants',
    'onboarding-sequence' => 'Onboarding steps',
    'loading-result' => 'Loading to result',
    'viewport-reveal' => 'Viewport reveal',
    'local-parallax' => 'Parallax',
    'scroll-progress' => 'Scroll progress',
    'page-transition' => 'Page transition',
    'form-validation' => 'Form validation',
    _ => recipe.title,
  };

  Widget _browser() {
    final query = _search.text.trim().toLowerCase();
    final categories = <String>{
      'All',
      for (final item in allRecipes) item.category,
    }.toList();
    final fixture = allRecipes
        .where(
          (recipe) =>
              recipe.documentationExample?.sourceAsset.endsWith(
                'genui_fixture_example.dart',
              ) ??
              false,
        )
        .firstOrNull;
    final coreIds = [
      'card-flip',
      'spring-retarget',
      'keyed-reorder',
      'bounded-drag',
      'presence-reflow',
      'selection-indicator',
    ];
    final ecosystemIds = [
      'form-validation',
      'accordion',
      if (fixture != null) fixture.id,
    ];
    final featured = {...coreIds, ...ecosystemIds};
    final matches = allRecipes
        .where(
          (item) =>
              (_category == 'All' || item.category == _category) &&
              (query.isEmpty ||
                  '${item.title} ${item.summary}'.toLowerCase().contains(
                    query,
                  )),
        )
        .toList();
    Widget group(String label) => Padding(
      padding: const EdgeInsets.fromLTRB(10, 22, 10, 13),
      child: Text(
        label,
        style: const TextStyle(
          color: Ember.muted,
          fontFamily: Ember.mono,
          fontSize: 9,
          letterSpacing: 1.4,
        ),
      ),
    );
    Widget link(RecipeDefinition item) => InkWell(
      onTap: () => widget.onOpenRecipe(item.id),
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: const BoxConstraints(minHeight: 39),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: item.id == widget.recipeId ? Ember.soft : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(
              item.id == 'card-flip'
                  ? Icons.flip
                  : item.documentationExample != null
                  ? Icons.code
                  : Icons.motion_photos_on_outlined,
              size: 15,
              color: item.id == widget.recipeId ? Ember.accent : Ember.muted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.id == fixture?.id ? 'GenUI fixture' : _recipeLabel(item),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: item.id == widget.recipeId ? Ember.accent : Ember.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 20),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 13),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'MOTION RECIPES',
                  style: TextStyle(
                    color: Ember.muted,
                    fontFamily: Ember.mono,
                    fontSize: 9,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Find a recipe',
                onPressed: () =>
                    setState(() => _showRecipeFilters = !_showRecipeFilters),
                icon: Icon(
                  _showRecipeFilters ? Icons.close : Icons.search,
                  size: 13,
                ),
                color: Ember.muted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
        if (_showRecipeFilters) ...[
          TextField(
            controller: _search,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Find a recipe',
              prefixIcon: Icon(Icons.search, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              labelText: 'Category',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category,
                  child: Text(category, style: const TextStyle(fontSize: 11)),
                ),
            ],
            onChanged: (category) =>
                setState(() => _category = category ?? 'All'),
          ),
          const SizedBox(height: 12),
        ],
        if (query.isNotEmpty || _category != 'All') ...[
          for (final item in matches) link(item),
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'No matching recipes.',
                style: TextStyle(color: Ember.muted, fontSize: 11),
              ),
            ),
        ] else ...[
          for (final id in coreIds) link(recipeById(id)!),
          group('ECOSYSTEM'),
          for (final id in ecosystemIds) link(recipeById(id)!),
          const SizedBox(height: 18),
          ExpansionTile(
            key: const PageStorageKey('more-playground-recipes'),
            initiallyExpanded:
                !featured.contains(widget.recipeId) &&
                _recipe?.documentationExample == null,
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            childrenPadding: EdgeInsets.zero,
            title: const Text(
              'More recipes',
              style: TextStyle(fontSize: 11, color: Ember.muted),
            ),
            children: [
              for (final item in verifiedRecipes.where(
                (item) => !featured.contains(item.id),
              ))
                link(item),
            ],
          ),
          ExpansionTile(
            key: const PageStorageKey('guided-playground-exercises'),
            initiallyExpanded:
                _recipe?.documentationExample != null &&
                widget.recipeId != fixture?.id,
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            childrenPadding: EdgeInsets.zero,
            title: const Text(
              'Guided exercises',
              style: TextStyle(fontSize: 11, color: Ember.muted),
            ),
            children: [
              for (final item in allRecipes.where(
                (item) =>
                    item.documentationExample != null &&
                    !featured.contains(item.id),
              ))
                link(item),
            ],
          ),
        ],
        const SizedBox(height: 20),
        const Divider(color: Ember.border),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Text(
            'One interface for motion, components and generated surfaces.',
            style: TextStyle(color: Ember.muted, fontSize: 10, height: 1.8),
          ),
        ),
      ],
    );
  }

  Widget _previewAndCode(RecipeDefinition recipe) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _preview(recipe, nested: true),
      const SizedBox(height: 14),
      _heading(recipe),
      const SizedBox(height: 20),
      _code(recipe, nested: true),
    ],
  );

  Widget _heading(RecipeDefinition recipe) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        recipe.purpose,
        style: const TextStyle(color: Ember.text, fontSize: 12, height: 1.7),
      ),
      const SizedBox(height: 6),
      Text(
        'Try it: ${recipe.trigger}',
        style: const TextStyle(color: Ember.muted, fontSize: 11, height: 1.7),
      ),
      Text(
        'Observe: ${recipe.outcome}',
        style: const TextStyle(color: Ember.muted, fontSize: 11, height: 1.7),
      ),
      if (widget.onNavigate != null)
        TextButton.icon(
          onPressed: () => widget.onNavigate!(recipe.docsRoute),
          icon: const Icon(Icons.north_east, size: 13),
          label: const Text('Read the guide'),
        ),
    ],
  );

  Widget _preview(RecipeDefinition recipe, {bool nested = false}) {
    final runtime = TickerMode(
      enabled: !_previewPaused && !_motionPaused,
      child: KeyedSubtree(
        key: ValueKey('${recipe.id}-$_generation'),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                MediaQuery.disableAnimationsOf(context) ||
                _reducePreview ||
                (recipe.documentationExample != null && _motionPaused) ||
                (recipe.documentationExample != null &&
                    MediaQuery.sizeOf(context).width < 640 &&
                    _pane != _Pane.preview),
          ),
          child: recipe.documentationExample != null
              ? Material(
                  type: MaterialType.transparency,
                  child: SingleChildScrollView(
                    child: recipe.documentationExample!.buildPreview(),
                  ),
                )
              : recipe.id == 'spring-retarget'
              ? SpringRetargetRecipe(
                  settings: SpringRetargetSettings(
                    distance: _value,
                    stiffness: _tuning.stiffness,
                    damping: _tuning.damping,
                    mass: _tuning.mass,
                  ),
                )
              : RecipeRuntime(
                  recipeId: recipe.id,
                  value: _value,
                  settings: _tuning,
                  controller: _runtimeController,
                ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Ember.panel,
        border: Border.all(color: Ember.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Ember.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_recipeLabel(recipe).toUpperCase()} / ${recipe.documentationExample != null
                          ? 'GUIDED EXERCISE'
                          : recipe.category == 'Components'
                          ? 'COMPONENTS'
                          : 'MOTION'}',
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
                  const SizedBox(width: 10),
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
            SizedBox(
              height:
                  recipe.id == 'spring-retarget' &&
                      MediaQuery.sizeOf(context).width < 1200
                  ? 400
                  : nested
                  ? (MediaQuery.sizeOf(context).width < 1200 ? 345 : 390)
                  : 340,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Ember.panel),
                  TickerMode(
                    enabled: !_motionPaused && _ambient,
                    child: NibMotionConfig(
                      reducedMotion:
                          _reducePreview ||
                          MediaQuery.disableAnimationsOf(context),
                      child: NibMotion(
                        initial: const NibAnim(opacity: .65),
                        animate: const NibAnim(opacity: 1),
                        repeatAnimationInLoop: _ambient,
                        transition: const NibTransition(
                          duration: Duration(milliseconds: 2800),
                          curve: Curves.easeInOutSine,
                        ),
                        child: const ClipRect(
                          child: CustomPaint(painter: PlaygroundDots()),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(20), child: runtime),
                ],
              ),
            ),
            _transport(recipe),
          ],
        ),
      ),
    );
  }

  Widget _transport(RecipeDefinition recipe) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 450;
      final buttonStyle = OutlinedButton.styleFrom(
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      );
      final actions = <Widget>[
        if (recipe.id == 'card-flip')
          OutlinedButton.icon(
            style: buttonStyle,
            onPressed: () {
              setState(() => _previewPaused = false);
              _runtimeController.play();
            },
            icon: const Icon(Icons.play_arrow, size: 12),
            label: const Text('Play'),
          ),
        OutlinedButton.icon(
          style: buttonStyle,
          onPressed: () => setState(() {
            _previewPaused = false;
            _generation++;
          }),
          icon: const Icon(Icons.restart_alt, size: 12),
          label: const Text('Restart'),
        ),
        if (recipe.documentationExample == null)
          Tooltip(
            message: 'Pauses Flutter tickers in this preview',
            child: OutlinedButton.icon(
              style: buttonStyle,
              onPressed: () => setState(() => _previewPaused = !_previewPaused),
              icon: Icon(
                _previewPaused ? Icons.play_arrow : Icons.pause,
                size: 12,
              ),
              label: Text(_previewPaused ? 'Resume' : 'Pause'),
            ),
          ),
      ];
      final speed = recipe.id == 'card-flip' ? _cardSpeed(recipe) : null;
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 17,
          vertical: compact ? 12 : 15,
        ),
        decoration: const BoxDecoration(
          color: Ember.code,
          border: Border(top: BorderSide(color: Ember.border)),
        ),
        child: compact
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [...actions, ?speed],
              )
            : Row(
                children: [
                  for (final action in actions) ...[
                    action,
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  if (speed != null)
                    speed
                  else
                    Flexible(
                      child: Text(
                        recipe.action,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Ember.muted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
      );
    },
  );

  Widget _cardSpeed(RecipeDefinition recipe) {
    const speeds = [.5, 1.0, 1.5, 2.0];
    final selected = speeds.where(
      (speed) => (recipe.initial / speed - _value).abs() < .01,
    );
    return Tooltip(
      message: 'Playback speed changes the flip duration and copied example',
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Ember.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<double>(
            key: const ValueKey('card-playback-speed'),
            value: selected.firstOrNull,
            hint: const Text('Custom'),
            isDense: true,
            dropdownColor: Ember.panel,
            iconSize: 13,
            style: const TextStyle(
              color: Ember.text,
              fontFamily: Ember.mono,
              fontSize: 10,
            ),
            items: [
              for (final speed in speeds)
                DropdownMenuItem(
                  value: speed,
                  child: Text(
                    '${speed == speed.roundToDouble() ? speed.toInt() : speed}×',
                  ),
                ),
            ],
            onChanged: (speed) {
              if (speed != null) {
                setState(() => _value = recipe.initial / speed);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _inspector(RecipeDefinition recipe) =>
      recipe.documentationExample != null
      ? _guidedInspector(recipe)
      : ListView(
          padding: const EdgeInsets.all(21),
          children: [
            const Text(
              'Make it yours',
              style: TextStyle(
                color: Ember.text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'These controls update the live Flutter preview and its copyable setup.',
              style: TextStyle(color: Ember.muted, fontSize: 11, height: 1.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'PRESETS',
              style: TextStyle(
                color: Ember.muted,
                fontFamily: Ember.mono,
                fontSize: 9,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final label
                    in recipe.id == 'card-flip'
                        ? ['Gentle', 'Balanced', 'Snappy']
                        : ['Gentle', 'Default', 'Bold'])
                  Semantics(
                    selected: recipe.id == 'card-flip'
                        ? _value == _cardPresetDuration(label)
                        : null,
                    child: OutlinedButton(
                      onPressed: () => _applyPreset(recipe, label),
                      style:
                          recipe.id == 'card-flip' &&
                              _value == _cardPresetDuration(label)
                          ? OutlinedButton.styleFrom(
                              foregroundColor: Ember.accent,
                              backgroundColor: Ember.soft,
                              side: const BorderSide(color: Ember.accent),
                            )
                          : null,
                      child: Text(label),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Ember.border),
            const SizedBox(height: 9),
            for (final group in recipeControls(
              recipe,
            ).map((item) => item.group).toSet()) ...[
              Text(
                group,
                style: const TextStyle(
                  color: Ember.muted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontFamily: Ember.mono,
                ),
              ),
              const SizedBox(height: 7),
              for (final control in recipeControls(
                recipe,
              ).where((item) => item.group == group))
                _sliderControl(control),
              const SizedBox(height: 12),
            ],
            if (recipeHasOption(recipe))
              ComponentToggle(
                showLabel: true,
                contentPadding: EdgeInsets.zero,
                label: recipeOptionLabel(recipe),
                value: _tuning.option,
                onChanged: (value) =>
                    setState(() => _tuning = _tuning.copyWith(option: value)),
              ),
            if (recipeHasEase(recipe)) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<RecipeEase>(
                key: ValueKey('ease-${_tuning.ease.name}'),
                initialValue: _tuning.ease,
                decoration: const InputDecoration(labelText: 'Timing curve'),
                items: const [
                  DropdownMenuItem(
                    value: RecipeEase.easeInOut,
                    child: Text('Ease in and out'),
                  ),
                  DropdownMenuItem(
                    value: RecipeEase.easeOut,
                    child: Text('Ease out'),
                  ),
                  DropdownMenuItem(
                    value: RecipeEase.linear,
                    child: Text('Linear'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _tuning = _tuning.copyWith(ease: value)),
              ),
            ],
            if (recipeHasRelease(recipe)) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<RecipeDragRelease>(
                key: ValueKey('release-${_tuning.release.name}'),
                initialValue: _tuning.release,
                decoration: const InputDecoration(
                  labelText: 'Release behavior',
                ),
                items: const [
                  DropdownMenuItem(
                    value: RecipeDragRelease.springBack,
                    child: Text('Spring back'),
                  ),
                  DropdownMenuItem(
                    value: RecipeDragRelease.inertia,
                    child: Text('Carry momentum'),
                  ),
                  DropdownMenuItem(
                    value: RecipeDragRelease.stay,
                    child: Text('Stay where released'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _tuning = _tuning.copyWith(release: value)),
              ),
            ],
            const SizedBox(height: 14),
            ComponentToggle(
              showLabel: true,
              contentPadding: EdgeInsets.zero,
              label: 'Reduce preview motion',
              description:
                  'Preview only; your system setting is always respected.',
              value: _reducePreview || MediaQuery.disableAnimationsOf(context),
              onChanged: MediaQuery.disableAnimationsOf(context)
                  ? null
                  : (value) => setState(() => _reducePreview = value),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _reset(recipe),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset settings and preview'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  _copy(_shareUri.toString(), 'Recipe link copied.'),
              icon: const Icon(Icons.link),
              label: const Text('Copy recipe link'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<Set<String>>(
              valueListenable: _favorites,
              builder: (context, favorites, _) {
                final saved = favorites.contains(recipe.id);
                return OutlinedButton.icon(
                  onPressed: () => unawaited(_favorites.toggle(recipe.id)),
                  icon: Icon(saved ? Icons.star : Icons.star_border),
                  label: Text(
                    saved
                        ? (_favorites.persistentAvailable
                              ? 'Saved locally'
                              : 'Saved this session')
                        : 'Save recipe',
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            const Text(
              'Settings and source stay together. A shared link restores every setting. The link does not capture a drag in progress.',
              style: TextStyle(color: Ember.muted, fontSize: 12, height: 1.5),
            ),
            if (_notice != null) ...[
              const SizedBox(height: 18),
              Semantics(
                liveRegion: true,
                child: Text(
                  _notice!,
                  style: const TextStyle(color: Ember.positive),
                ),
              ),
            ],
          ],
        );

  Widget _guidedInspector(RecipeDefinition recipe) => ListView(
    padding: const EdgeInsets.all(21),
    children: [
      const Text(
        'Make it yours',
        style: TextStyle(
          color: Ember.text,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'This guided exercise keeps its controls beside the animation. Scroll the preview to change them.',
        style: TextStyle(color: Ember.muted, fontSize: 11, height: 1.8),
      ),
      const SizedBox(height: 14),
      Text(
        recipe.purpose,
        style: const TextStyle(color: Ember.text, fontSize: 12, height: 1.7),
      ),
      const SizedBox(height: 18),
      const Text(
        'Minimal example shows the animation primitive. Full example includes the complete exercise. Where the preview offers Copy current configuration, use it to export edited settings.',
        style: TextStyle(color: Ember.muted, fontSize: 11, height: 1.8),
      ),
      const SizedBox(height: 14),
      const Text(
        'Changing mobile panes keeps your controls and settles motion. Use Replay inside the exercise to run it again.',
        style: TextStyle(color: Ember.muted, fontSize: 11, height: 1.8),
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: () => _copyExample(recipe, full: true),
        icon: const Icon(Icons.copy, size: 15),
        label: const Text('Copy full example'),
      ),
      if (widget.onNavigate != null) ...[
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => widget.onNavigate!(recipe.docsRoute),
          icon: const Icon(Icons.north_east, size: 15),
          label: const Text('Read the guide'),
        ),
      ],
      if (_notice != null) ...[
        const SizedBox(height: 18),
        Semantics(
          liveRegion: true,
          child: Text(
            _notice!,
            style: const TextStyle(color: Ember.muted, fontSize: 11),
          ),
        ),
      ],
    ],
  );

  Widget _sliderControl(RecipeControlSpec control) {
    final selected = control.field == null
        ? _value
        : _tuning.getField(control.field!);
    final fixed = control.maximum <= 3 ? 2 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                control.label,
                style: const TextStyle(color: Ember.text, fontSize: 11),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Ember.bg,
                border: Border.all(color: Ember.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selected.toStringAsFixed(fixed),
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
        Slider(
          key: ValueKey('recipe-control-${control.field?.name ?? 'value'}'),
          value: selected.clamp(control.minimum, control.maximum),
          min: control.minimum,
          max: control.maximum,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
          divisions: 100,
          label: selected.toStringAsFixed(fixed),
          semanticFormatterCallback: (value) =>
              '${control.label}: ${value.toStringAsFixed(fixed)}',
          onChanged: (value) => setState(() {
            if (control.field == null) {
              _value = value;
            } else {
              _tuning = _tuning.withField(control.field!, value);
            }
          }),
        ),
      ],
    );
  }

  double _cardPresetDuration(String label) => switch (label) {
    'Gentle' => 900,
    'Snappy' => 300,
    _ => 600,
  };

  void _applyPreset(RecipeDefinition recipe, String label) {
    setState(() {
      if (recipe.id == 'card-flip') {
        _value = _cardPresetDuration(label);
      } else if (label == 'Default') {
        _value = recipe.initial;
        _tuning = defaultRecipeTuning(recipe);
      } else {
        final fraction = label == 'Gentle' ? .28 : .78;
        for (final control in recipeControls(recipe)) {
          final selected =
              control.minimum +
              (control.maximum - control.minimum) *
                  (control.field == RecipeField.damping
                      ? 1 - fraction
                      : fraction);
          if (control.field == null) {
            _value = selected;
          } else {
            _tuning = _tuning.withField(control.field!, selected);
          }
        }
      }
      _generation++;
      _previewPaused = false;
    });
  }

  Widget _code(RecipeDefinition recipe, {bool nested = false}) {
    final fileName = recipe.sourceAsset.split('/').last;
    final content = FutureBuilder<List<String>>(
      future: _sources,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Source asset unavailable.',
            style: TextStyle(color: Ember.negative),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final source = snapshot.data!.first.replaceAll(
          RegExp(r'(\.\./)+components/component_toggle.dart'),
          'component_toggle.dart',
        );
        final tuningSource = snapshot.data!.length > 4
            ? snapshot.data![4]
            : null;
        final launcher = recipeLauncher(recipe, _value, _tuning);
        final runnable = recipeRunnableExample(
          recipe,
          _value,
          _tuning,
          source,
          snapshot.data![1],
          tuningSource,
          snapshot.data![2],
          snapshot.data![3],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipeMinimalExample(recipe, _value, _tuning) == null
                  ? 'Full example includes the complete exercise and its required setup. Paste into lib/main.dart.'
                  : 'Minimal example is a standalone version of the animation primitive. Full example includes the preview controls and current inspector settings. Paste either into lib/main.dart.',
              style: TextStyle(color: Ember.muted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.documentationExample != null
                  ? (source.contains('package:nib_genui')
                        ? 'Requires the local unpublished nib_genui packages. This exercise runs a local fixture.'
                        : source.contains('package:nib_components')
                        ? 'Requires nib_components and its nib_motion dependency.'
                        : 'Requires nib_motion. This exercise uses the documented local candidate API.')
                  : recipe.id == 'spring-retarget'
                  ? 'Requires nib_motion. The current site tests a local candidate package.'
                  : 'Requires nib_motion and nib_components. The current site tests local candidate packages.',
              style: const TextStyle(color: Ember.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              children: [
                for (final pane in _SourcePane.values.where(
                  (pane) =>
                      pane != _SourcePane.minimal ||
                      recipeMinimalExample(recipe, _value, _tuning) != null,
                ))
                  TextButton(
                    onPressed: () => setState(() => _sourcePane = pane),
                    style: TextButton.styleFrom(
                      foregroundColor: _sourcePane == pane
                          ? Ember.accent
                          : Ember.muted,
                      backgroundColor: _sourcePane == pane
                          ? Ember.soft
                          : Colors.transparent,
                      side: BorderSide(
                        color: _sourcePane == pane
                            ? const Color(0xFF735923)
                            : Colors.transparent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: Ember.mono,
                        fontSize: 10,
                      ),
                    ),
                    child: Text(switch (pane) {
                      _SourcePane.minimal => 'Minimal example',
                      _SourcePane.configuration => 'Launcher',
                      _SourcePane.behavior => 'Full example',
                      _SourcePane.handoff => 'Source files',
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copy(
                    _sourcePane == _SourcePane.minimal
                        ? recipeMinimalExample(recipe, _value, _tuning) ??
                              runnable
                        : runnable,
                    'Example copied.',
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(
                    _sourcePane == _SourcePane.minimal &&
                            recipeMinimalExample(recipe, _value, _tuning) !=
                                null
                        ? 'Copy minimal example'
                        : 'Copy full example',
                  ),
                ),
                if (_sourcePane == _SourcePane.handoff) ...[
                  OutlinedButton.icon(
                    onPressed: () => _copy(source, '$fileName copied.'),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text('Copy $fileName'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(
                      snapshot.data![1],
                      'ember_material_theme.dart copied.',
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy theme'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(
                      snapshot.data![2].replaceAll(
                        '../ember_material_theme.dart',
                        'ember_material_theme.dart',
                      ),
                      'component_theme.dart copied.',
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy component theme'),
                  ),
                  if (source.contains('component_toggle.dart'))
                    OutlinedButton.icon(
                      onPressed: () => _copy(
                        snapshot.data![3],
                        'component_toggle.dart copied.',
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy branded switch'),
                    ),
                  if (tuningSource != null)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _copy(tuningSource, 'recipe_tuning.dart copied.'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy recipe_tuning.dart'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(
                      launcher,
                      'Launcher copied. Include its companion source files.',
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy launcher'),
                  ),
                ],
              ],
            ),
            if (_notice != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _notice!,
                  style: const TextStyle(color: Ember.positive, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            switch (_sourcePane) {
              _SourcePane.minimal => _sourcePanel(
                'main.dart',
                recipeMinimalExample(recipe, _value, _tuning) ?? runnable,
              ),
              _SourcePane.configuration => _sourcePanel('main.dart', launcher),
              _SourcePane.behavior => _sourcePanel(
                'Complete main.dart',
                runnable,
              ),
              _SourcePane.handoff =>
                tuningSource == null
                    ? _sourcePanel('main.dart', launcher)
                    : _sourcePanel('recipe_tuning.dart', tuningSource),
            },
          ],
        );
      },
    );
    return nested
        ? Column(
            key: _codeKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmberEyebrow('TAKE THE REAL SOURCE'),
              const SizedBox(height: 15),
              content,
            ],
          )
        : ListView(
            key: _codeKey,
            padding: const EdgeInsets.all(18),
            children: [
              const EmberEyebrow('TAKE THE REAL SOURCE'),
              const SizedBox(height: 15),
              content,
            ],
          );
  }

  Widget _sourcePanel(String name, String code) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Ember.code,
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Ember.accent,
            fontFamily: Ember.mono,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: name == 'main.dart' ? 210 : 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DartCodeView(code: code, fontSize: 11, lineHeight: 1.45),
            ),
          ),
        ),
      ],
    ),
  );
}
