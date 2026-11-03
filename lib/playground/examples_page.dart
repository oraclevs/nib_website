import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nib_motion/nib_motion.dart';

import '../ember_theme.dart';
import '../recipes/recipe_catalog.dart';
import 'example_card_art.dart';
import 'discovery_card.dart';

/// An illustrated index of verified recipes. Recipe previews run on their
/// detail pages, keeping gallery scrolling inexpensive.
class ExamplesPage extends StatefulWidget {
  const ExamplesPage({
    super.key,
    required this.onOpenRecipe,
    this.favorites,
    this.onToggleFavorite,
  });

  final ValueChanged<String> onOpenRecipe;
  final ValueListenable<Set<String>>? favorites;
  final ValueChanged<String>? onToggleFavorite;

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  final _search = TextEditingController();
  final _localFavorites = ValueNotifier<Set<String>>({});
  String _filter = 'All';
  bool _paused = false, _reduced = false, _ambient = true;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
  }

  void _refresh() => setState(() {});
  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    _localFavorites.dispose();
    super.dispose();
  }

  void _toggleFavorite(String id) {
    final external = widget.onToggleFavorite;
    if (external != null) {
      external(id);
      return;
    }
    final next = {..._localFavorites.value};
    next.contains(id) ? next.remove(id) : next.add(id);
    _localFavorites.value = next;
  }

  String _family(RecipeDefinition recipe) {
    final category = recipe.category.toLowerCase();
    if (category.contains('genui')) return 'GenUI';
    if (category.contains('component')) return 'Components';
    return 'Motion';
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).width;
    final mobile = screen < 640;
    final systemReduced =
        MediaQuery.of(context).disableAnimations ||
        NibMotionConfig.shouldReduceMotion(context);
    final reduced = _paused || _reduced || systemReduced;
    return EmberMotionPolicy(
      paused: _paused,
      reduced: reduced,
      ambient: _ambient,
      child: NibMotionConfig(
        reducedMotion: reduced,
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: widget.favorites ?? _localFavorites,
          builder: (context, saved, _) {
            final query = _search.text.trim().toLowerCase();
            final matches = verifiedRecipes.where((recipe) {
              if (_filter == 'Saved' && !saved.contains(recipe.id)) {
                return false;
              }
              if (_filter != 'All' &&
                  _filter != 'Saved' &&
                  _family(recipe) != _filter) {
                return false;
              }
              return query.isEmpty ||
                  '${recipe.title} ${recipe.summary} ${recipe.category} ${recipe.id}'
                      .toLowerCase()
                      .contains(query);
            }).toList();
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                EmberWrap(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _intro(mobile),
                      _motionDock(systemReduced),
                      _filterBar(mobile, matches.length),
                      if (matches.isEmpty)
                        _emptyState(saved.isEmpty)
                      else
                        _gallery(matches, saved, screen),
                      _note(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _intro(bool mobile) => Padding(
    padding: EdgeInsets.only(top: mobile ? 30 : 44, bottom: mobile ? 18 : 31),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NIBMOTION / RECIPES / COMPOSITIONS',
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
              TextSpan(text: 'Less imagining.\n'),
              TextSpan(
                text: 'More interacting.',
                style: TextStyle(color: Ember.accent),
              ),
            ],
          ),
          style: TextStyle(
            color: Ember.text,
            fontSize: mobile ? 39 : 48,
            fontWeight: FontWeight.w600,
            letterSpacing: mobile ? -1.8 : -2,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Explore the building blocks and the combinations. Open an example to adjust the design and inspect its settings.',
            style: TextStyle(
              color: Ember.muted,
              fontSize: mobile ? 13 : 14,
              height: 1.8,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _motionDock(bool systemReduced) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 16),
    child: Wrap(
      spacing: 9,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _dockButton(
          _paused ? Icons.play_arrow : Icons.pause,
          _paused ? 'Resume motion' : 'Pause motion',
          _paused,
          () => setState(() => _paused = !_paused),
        ),
        _dockButton(
          Icons.visibility_outlined,
          systemReduced || _reduced ? 'Reduced motion on' : 'Reduce motion',
          systemReduced || _reduced,
          systemReduced ? null : () => setState(() => _reduced = !_reduced),
        ),
        _dockButton(
          Icons.blur_on,
          _ambient ? 'Ambient on' : 'Ambient off',
          _ambient,
          () => setState(() => _ambient = !_ambient),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            systemReduced
                ? 'SYSTEM REDUCED MOTION · RESPECTED'
                : 'FLUTTER GALLERY / ILLUSTRATED CARDS',
            style: const TextStyle(
              color: Ember.muted,
              fontFamily: Ember.mono,
              fontSize: 9,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _dockButton(
    IconData icon,
    String label,
    bool pressed,
    VoidCallback? onTap,
  ) => Semantics(
    button: true,
    selected: pressed,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Ember.panel,
          border: Border.all(
            color: pressed ? const Color(0xFF88621B) : Ember.border,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: pressed ? Ember.accent : Ember.muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: pressed ? Ember.accent : Ember.text,
                fontFamily: Ember.mono,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _filterBar(bool mobile, int count) {
    final filters = Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final name in const [
          'Saved',
          'All',
          'Motion',
          'Components',
          'GenUI',
        ])
          _filterButton(name),
      ],
    );
    final search = SizedBox(
      width: mobile ? double.infinity : 210,
      height: 36,
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Ember.text, fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Search examples',
          hintStyle: const TextStyle(color: Ember.muted, fontSize: 11),
          prefixIcon: const Icon(Icons.search, size: 16, color: Ember.muted),
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: _search.clear,
                  icon: const Icon(Icons.close, size: 16),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: Ember.panel,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Ember.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Ember.accent),
          ),
        ),
      ),
    );
    final counter = Text(
      '${count.toString().padLeft(2, '0')} ${_filter == 'Saved' ? 'SAVED' : 'RUNNABLE'} EXAMPLES',
      style: TextStyle(
        color: Ember.muted,
        fontFamily: Ember.mono,
        fontSize: mobile ? 9 : 10,
      ),
    );
    return Padding(
      padding: EdgeInsets.only(top: mobile ? 8 : 15, bottom: 25),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                filters,
                const SizedBox(height: 13),
                search,
                const SizedBox(height: 13),
                counter,
              ],
            )
          : Row(
              children: [
                Expanded(child: filters),
                const SizedBox(width: 16),
                search,
                const SizedBox(width: 18),
                counter,
              ],
            ),
    );
  }

  Widget _filterButton(String name) {
    final selected = name == _filter;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => setState(() => _filter = name),
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Ember.soft : Colors.transparent,
            border: Border.all(
              color: selected ? const Color(0xFF88621B) : Ember.border,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            name == 'Saved' ? '☆ Saved' : name,
            style: TextStyle(
              color: selected ? Ember.accent : Ember.muted,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _gallery(
    List<RecipeDefinition> recipes,
    Set<String> saved,
    double screen,
  ) {
    final mobile = screen < 640;
    final gap = mobile
        ? 18.0
        : screen <= 1199
        ? 14.0
        : 22.0;
    final artHeight = mobile
        ? 177.0
        : screen <= 850
        ? 157.0
        : screen <= 1199
        ? 177.0
        : 196.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = mobile ? 1 : 3;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 24,
          children: [
            for (final (index, recipe) in recipes.indexed)
              SizedBox(
                width: width,
                child: EmberReveal(
                  delay: Duration(milliseconds: (index % 3) * 65),
                  entrance: switch (index % 3) {
                    1 => EmberEntrance.scale,
                    2 => EmberEntrance.right,
                    _ => EmberEntrance.up,
                  },
                  child: DiscoveryCard(
                    key: ValueKey('recipe-card-${recipe.id}'),
                    title: recipe.title,
                    summary: recipe.summary,
                    preview: ExampleCardArt(recipe: recipe),
                    artHeight: artHeight,
                    mobile: mobile,
                    compact: screen <= 850 && !mobile,
                    saved: saved.contains(recipe.id),
                    ambient: _ambient && index == 0,
                    onTap: () => widget.onOpenRecipe(recipe.id),
                    onToggleFavorite: () => _toggleFavorite(recipe.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _emptyState(bool noFavorites) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      border: Border.all(color: Ember.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _filter == 'Saved' && noFavorites
          ? 'Save examples with the star button. They stay in this browser when local storage is available.'
          : 'No verified recipes match that search. Try a different word or filter.',
      style: const TextStyle(color: Ember.muted, fontSize: 14),
    ),
  );

  Widget _note() => const Padding(
    padding: EdgeInsets.only(top: 26, bottom: 54),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Ember.border, height: 1),
        SizedBox(height: 15),
        Text(
          'Cards are static illustrations of each interaction. Open a recipe to run its Flutter demo, adjust its controls, and copy its source.',
          style: TextStyle(color: Ember.muted, fontSize: 11),
        ),
      ],
    ),
  );
}
