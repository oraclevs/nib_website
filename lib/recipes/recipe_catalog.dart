import 'package:flutter/foundation.dart';

import 'recipe_tuning.dart';
import '../docs/doc_example_catalog.dart';
import '../content/site_content.dart';

@immutable
class RecipeControlSpec {
  const RecipeControlSpec({
    required this.label,
    required this.group,
    required this.minimum,
    required this.maximum,
    required this.initial,
    this.field,
  });

  /// Null selects the recipe's existing primary setting.
  final RecipeField? field;
  final String label;
  final String group;
  final double minimum;
  final double maximum;
  final double initial;
}

const _duration = RecipeControlSpec(
  field: RecipeField.durationMs,
  label: 'Duration (ms)',
  group: 'TIMING',
  minimum: 180,
  maximum: 1200,
  initial: 550,
);
const _stiffness = RecipeControlSpec(
  field: RecipeField.stiffness,
  label: 'Stiffness',
  group: 'SPRING PHYSICS',
  minimum: 80,
  maximum: 420,
  initial: 180,
);
const _damping = RecipeControlSpec(
  field: RecipeField.damping,
  label: 'Damping',
  group: 'SPRING PHYSICS',
  minimum: 6,
  maximum: 45,
  initial: 18,
);
const _mass = RecipeControlSpec(
  field: RecipeField.mass,
  label: 'Mass',
  group: 'SPRING PHYSICS',
  minimum: .4,
  maximum: 2.5,
  initial: 1,
);

/// Only controls consumed by the selected recipe are included here. The
/// primary control stays in [RecipeDefinition] for route compatibility.
List<RecipeControlSpec> recipeControls(RecipeDefinition recipe) {
  if (recipe.documentationExample != null) return const [];
  final primary = RecipeControlSpec(
    label: recipe.setting,
    group: switch (recipe.category) {
      'Springs & values' => 'MOVEMENT',
      'Gestures & transforms' => 'INTERACTION',
      'Layout & presence' => 'LAYOUT',
      'Sequencing' => 'SEQUENCE',
      'Scroll & navigation' => 'SCROLL',
      _ => 'COMPONENT',
    },
    minimum: recipe.minimum,
    maximum: recipe.maximum,
    initial: recipe.initial,
  );
  final extra = switch (recipe.id) {
    'spring-retarget' => const [_stiffness, _damping, _mass],
    'keyframe-hop' => const [
      _duration,
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Apex overshoot',
        group: 'KEYFRAMES',
        minimum: .1,
        maximum: .55,
        initial: .25,
      ),
    ],
    'spring-tween' => const [_duration, _stiffness, _damping, _mass],
    'animated-counter' => const [
      _duration,
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Entrance scale',
        group: 'RESPONSE',
        minimum: .45,
        maximum: .95,
        initial: .7,
      ),
    ],
    'progress-choreography' ||
    'linked-objects' => const [_stiffness, _damping, _mass],
    'card-flip' => const <RecipeControlSpec>[],
    'bounded-drag' || 'swipe-restore' => const [_stiffness, _damping, _mass],
    'hover-press' => const [
      _stiffness,
      _damping,
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Press scale',
        group: 'INTERACTION',
        minimum: .78,
        maximum: .98,
        initial: .92,
      ),
    ],
    'drag-snap' => const [
      _stiffness,
      _damping,
      RecipeControlSpec(
        field: RecipeField.elasticity,
        label: 'Edge elasticity',
        group: 'INTERACTION',
        minimum: 0,
        maximum: .5,
        initial: .2,
      ),
    ],
    'pivot-turn' ||
    'keyed-reorder' ||
    'selection-indicator' => const [_stiffness, _damping, _mass],
    'presence-reflow' ||
    'filtered-list' ||
    'focus-overlay' ||
    'command-palette' ||
    'page-transition' ||
    'tab-content' => const [_duration],
    'expanding-card' || 'form-validation' || 'accordion' => const [_duration],
    'stagger-list' => const [
      _duration,
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Entry travel',
        group: 'SEQUENCE',
        minimum: 8,
        maximum: 55,
        initial: 24,
      ),
    ],
    'variant-orchestration' => const [
      _duration,
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Entry travel',
        group: 'SEQUENCE',
        minimum: 8,
        maximum: 55,
        initial: 24,
      ),
      RecipeControlSpec(
        field: RecipeField.opacity,
        label: 'Closed opacity',
        group: 'APPEARANCE',
        minimum: .1,
        maximum: .9,
        initial: .6,
      ),
    ],
    'loading-result' => const [
      _duration,
      RecipeControlSpec(
        field: RecipeField.scale,
        label: 'Result entrance scale',
        group: 'APPEARANCE',
        minimum: .35,
        maximum: .95,
        initial: .7,
      ),
    ],
    'onboarding-sequence' => const [_duration],
    'viewport-reveal' => const [
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Visible fraction',
        group: 'SCROLL',
        minimum: .1,
        maximum: .8,
        initial: .2,
      ),
    ],
    'local-parallax' => const <RecipeControlSpec>[],
    'scroll-progress' => const [
      RecipeControlSpec(
        field: RecipeField.secondary,
        label: 'Scroll range',
        group: 'SCROLL',
        minimum: 160,
        maximum: 700,
        initial: 400,
      ),
    ],
    _ => const <RecipeControlSpec>[],
  };
  return [primary, ...extra];
}

bool recipeHasOption(RecipeDefinition recipe) => const {
  'card-flip',
  'bounded-drag',
  'viewport-reveal',
  'accordion',
}.contains(recipe.id);

String recipeOptionLabel(RecipeDefinition recipe) => switch (recipe.id) {
  'card-flip' => 'Vertical flip axis',
  'bounded-drag' => 'Snap back on release',
  'viewport-reveal' => 'Reveal once',
  'accordion' => 'Allow multiple sections',
  _ => '',
};

bool recipeDefaultOption(RecipeDefinition recipe) =>
    const {'bounded-drag', 'viewport-reveal'}.contains(recipe.id);

bool recipeHasEase(RecipeDefinition recipe) => const {
  'keyframe-hop',
  'spring-tween',
  'presence-reflow',
  'filtered-list',
  'page-transition',
  'tab-content',
  'variant-orchestration',
}.contains(recipe.id);

bool recipeHasRelease(RecipeDefinition recipe) => recipe.id == 'drag-snap';

RecipeTuning defaultRecipeTuning(RecipeDefinition recipe) {
  var tuning = RecipeTuning(option: recipeDefaultOption(recipe));
  for (final control in recipeControls(recipe)) {
    if (control.field != null) {
      tuning = tuning.withField(control.field!, control.initial);
    }
  }
  return tuning;
}

/// Reviewable inventory. Only entries in [verifiedRecipes] appear in the
/// gallery; proposals are kept out of the UI until their code and tests land.
@immutable
class RecipeDefinition {
  const RecipeDefinition({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.action,
    required this.setting,
    required this.minimum,
    required this.maximum,
    required this.initial,
    this.sourceAsset = 'lib/recipes/recipe_runtime.dart',
    this.documentationExample,
    this.guideRoute,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final String action;
  final String setting;
  final double minimum;
  final double maximum;
  final double initial;
  final String sourceAsset;
  final DocExample? documentationExample;
  final String? guideRoute;

  String get route => '/playground/$id';
  String get trigger => action;
  String get outcome => summary;
  String get purpose =>
      documentationExample?.description ?? _recipeContext[id]!.$2;
  String get docsRoute => guideRoute ?? _recipeContext[id]!.$1;
}

const verifiedRecipes = <RecipeDefinition>[
  RecipeDefinition(
    id: 'spring-retarget',
    title: 'Mid-flight spring retarget',
    category: 'Springs & values',
    summary: 'Change destination before the spring settles; momentum carries across.',
    action: 'Send it across, then tap again',
    setting: 'Travel distance',
    minimum: 40,
    maximum: 180,
    initial: 144,
    sourceAsset: 'lib/recipes/spring_retarget_recipe.dart',
  ),
  RecipeDefinition(
    id: 'keyframe-hop',
    title: 'Multi-stage keyframe hop',
    category: 'Springs & values',
    summary: 'Three timed poses make one deliberate entrance.',
    action: 'Replay the hop',
    setting: 'Hop height',
    minimum: 16,
    maximum: 90,
    initial: 56,
  ),
  RecipeDefinition(
    id: 'spring-tween',
    title: 'Spring or timed response',
    category: 'Springs & values',
    summary: 'One destination, two different response models.',
    action: 'Switch the response',
    setting: 'Travel distance',
    minimum: 45,
    maximum: 170,
    initial: 130,
  ),
  RecipeDefinition(
    id: 'animated-counter',
    title: 'Counter update feedback',
    category: 'Springs & values',
    summary:
        'The count changes immediately; a keyed entrance marks each update.',
    action: 'Add ten',
    setting: 'Step size',
    minimum: 2,
    maximum: 25,
    initial: 10,
  ),
  RecipeDefinition(
    id: 'progress-choreography',
    title: 'Progress choreography',
    category: 'Springs & values',
    summary: 'A bar and status advance together with a clear final state.',
    action: 'Advance progress',
    setting: 'Progress step',
    minimum: 10,
    maximum: 50,
    initial: 25,
  ),
  RecipeDefinition(
    id: 'linked-objects',
    title: 'Linked objects',
    category: 'Springs & values',
    summary: 'A follower responds to the same target with a softer spring.',
    action: 'Move the leader',
    setting: 'Separation',
    minimum: 30,
    maximum: 110,
    initial: 70,
  ),
  RecipeDefinition(
    id: 'card-flip',
    title: 'Two-sided card flip',
    category: 'Gestures & transforms',
    summary: 'Reveal a second face with a bounded half-turn.',
    action: 'Flip the card',
    setting: 'Flip duration (ms)',
    minimum: 300,
    maximum: 1200,
    initial: 600,
  ),
  RecipeDefinition(
    id: 'bounded-drag',
    title: 'Bounded drag and snap back',
    category: 'Gestures & transforms',
    summary: 'Directly move an object inside a measured range.',
    action: 'Drag the puck',
    setting: 'Drag radius',
    minimum: 40,
    maximum: 120,
    initial: 80,
  ),
  RecipeDefinition(
    id: 'swipe-restore',
    title: 'Swipe to dismiss and restore',
    category: 'Gestures & transforms',
    summary: 'Dismiss a keyed row, then bring it back.',
    action: 'Swipe the row',
    setting: 'Dismiss threshold',
    minimum: 0.2,
    maximum: 0.8,
    initial: 0.5,
  ),
  RecipeDefinition(
    id: 'hover-press',
    title: 'Hover and press response',
    category: 'Gestures & transforms',
    summary: 'Pointer, touch, and keyboard focus get distinct feedback.',
    action: 'Hover, focus, or press',
    setting: 'Hover scale',
    minimum: 1.02,
    maximum: 1.18,
    initial: 1.08,
  ),
  RecipeDefinition(
    id: 'drag-snap',
    title: 'Drag to snap targets',
    category: 'Gestures & transforms',
    summary: 'Release near a stop and the object finds the closest target.',
    action: 'Drag toward either stop',
    setting: 'Snap distance',
    minimum: 50,
    maximum: 130,
    initial: 95,
  ),
  RecipeDefinition(
    id: 'pivot-turn',
    title: 'Off-centre pivot',
    category: 'Gestures & transforms',
    summary: 'A hinge point changes the feel of a small rotation.',
    action: 'Turn around the hinge',
    setting: 'Turn angle',
    minimum: 8,
    maximum: 35,
    initial: 23,
  ),
  RecipeDefinition(
    id: 'keyed-reorder',
    title: 'Keyed row reorder',
    category: 'Layout & presence',
    summary: 'Rows change place while their keys keep identity.',
    action: 'Shuffle the rows',
    setting: 'Row spacing',
    minimum: 4,
    maximum: 20,
    initial: 10,
  ),
  RecipeDefinition(
    id: 'presence-reflow',
    title: 'Remove with presence',
    category: 'Layout & presence',
    summary: 'An exiting item gets time to leave before the list closes.',
    action: 'Remove or restore a row',
    setting: 'Exit travel',
    minimum: 15,
    maximum: 90,
    initial: 45,
  ),
  RecipeDefinition(
    id: 'expanding-card',
    title: 'Expanding card',
    category: 'Layout & presence',
    summary: 'A compact card reveals detail without losing its place.',
    action: 'Expand the card',
    setting: 'Expanded height',
    minimum: 100,
    maximum: 200,
    initial: 150,
  ),
  RecipeDefinition(
    id: 'filtered-list',
    title: 'Animated filter change',
    category: 'Layout & presence',
    summary: 'Visible items update as a category filter changes.',
    action: 'Toggle the filter',
    setting: 'Exit travel',
    minimum: 15,
    maximum: 80,
    initial: 40,
  ),
  RecipeDefinition(
    id: 'selection-indicator',
    title: 'Moving selection',
    category: 'Layout & presence',
    summary: 'The active mark follows a new choice.',
    action: 'Pick another option',
    setting: 'Indicator width',
    minimum: 40,
    maximum: 95,
    initial: 65,
  ),
  RecipeDefinition(
    id: 'focus-overlay',
    title: 'Overlay with focus return',
    category: 'Layout & presence',
    summary: 'Open and close a lightweight panel with keyboard focus restored.',
    action: 'Open the panel',
    setting: 'Entry distance',
    minimum: 12,
    maximum: 70,
    initial: 36,
  ),
  RecipeDefinition(
    id: 'stagger-list',
    title: 'Staggered list',
    category: 'Sequencing',
    summary: 'Rows enter with a measured delay instead of all at once.',
    action: 'Replay the list',
    setting: 'Stagger delay (ms)',
    minimum: 20,
    maximum: 160,
    initial: 60,
  ),
  RecipeDefinition(
    id: 'variant-orchestration',
    title: 'Parent-child variants',
    category: 'Sequencing',
    summary: 'One named state coordinates a small group.',
    action: 'Change the group state',
    setting: 'Child stagger (ms)',
    minimum: 20,
    maximum: 160,
    initial: 70,
  ),
  RecipeDefinition(
    id: 'onboarding-sequence',
    title: 'Onboarding sequence',
    category: 'Sequencing',
    summary: 'A few steps advance in a predictable order.',
    action: 'Play the sequence',
    setting: 'Step gap (ms)',
    minimum: 80,
    maximum: 420,
    initial: 180,
  ),
  RecipeDefinition(
    id: 'loading-result',
    title: 'Loading to result',
    category: 'Sequencing',
    summary: 'A busy state exits before the completed result arrives.',
    action: 'Run the local task',
    setting: 'Local wait (ms)',
    minimum: 200,
    maximum: 900,
    initial: 500,
  ),
  RecipeDefinition(
    id: 'command-palette',
    title: 'Interruptible command palette',
    category: 'Sequencing',
    summary: 'A quick command panel responds to repeated open and close.',
    action: 'Toggle the palette',
    setting: 'Entry travel',
    minimum: 12,
    maximum: 75,
    initial: 35,
  ),
  RecipeDefinition(
    id: 'viewport-reveal',
    title: 'Viewport reveal',
    category: 'Scroll & navigation',
    summary: 'Content becomes readable as it enters the local scroll area.',
    action: 'Scroll the preview',
    setting: 'Reveal distance',
    minimum: 10,
    maximum: 80,
    initial: 35,
  ),
  RecipeDefinition(
    id: 'local-parallax',
    title: 'Local parallax stage',
    category: 'Scroll & navigation',
    summary: 'A foreground mark and a scroll view travel at different rates.',
    action: 'Scroll the stage',
    setting: 'Parallax factor',
    minimum: 0.1,
    maximum: 0.9,
    initial: 0.45,
  ),
  RecipeDefinition(
    id: 'scroll-progress',
    title: 'Scroll progress',
    category: 'Scroll & navigation',
    summary: 'A progress mark follows the reader through local content.',
    action: 'Scroll the article',
    setting: 'Track length',
    minimum: 120,
    maximum: 250,
    initial: 180,
  ),
  RecipeDefinition(
    id: 'page-transition',
    title: 'Coordinated page transition',
    category: 'Scroll & navigation',
    summary: 'Two views exchange places with a clear direction.',
    action: 'Go to the next view',
    setting: 'Slide distance',
    minimum: 25,
    maximum: 110,
    initial: 65,
  ),
  RecipeDefinition(
    id: 'form-validation',
    title: 'Animated form validation',
    category: 'Components & effects',
    summary: 'Local validation gives prompt feedback beside the field.',
    action: 'Submit a short name',
    setting: 'Minimum characters',
    minimum: 2,
    maximum: 8,
    initial: 4,
  ),
  RecipeDefinition(
    id: 'tab-content',
    title: 'Tab content transition',
    category: 'Components & effects',
    summary: 'A tab changes content with a short, reversible transition.',
    action: 'Select another tab',
    setting: 'Slide distance',
    minimum: 8,
    maximum: 65,
    initial: 24,
  ),
  RecipeDefinition(
    id: 'accordion',
    title: 'Accordion disclosure',
    category: 'Components & effects',
    summary: 'An answer opens in place with a readable end state.',
    action: 'Open a question',
    setting: 'Open height',
    minimum: 55,
    maximum: 120,
    initial: 82,
  ),
];

const _recipeContext = <String, (String, String)>{
  'spring-retarget': (
    '/docs/motion/springs',
    "Keep a moving selection or panel responsive to a new destination.",
  ),
  'keyframe-hop': (
    '/docs/motion/keyframes',
    "Give an entrance a deliberate sequence of intermediate poses.",
  ),
  'spring-tween': (
    '/docs/motion/transitions',
    "Choose between a settling physical response and a fixed duration.",
  ),
  'animated-counter': (
    '/docs/motion/transitions',
    "Keep a changing count readable while giving each update visible feedback.",
  ),
  'progress-choreography': (
    '/docs/motion/motion-values',
    "Coordinate task status, progress and completion feedback from one state.",
  ),
  'linked-objects': (
    '/docs/motion/motion-values',
    "Coordinate related objects while allowing their responses to differ.",
  ),
  'card-flip': (
    '/docs/motion/presets',
    "Show a second face without keeping both faces interactive.",
  ),
  'bounded-drag': (
    '/docs/motion/gestures',
    "Let users move an object without losing it outside its useful area.",
  ),
  'swipe-restore': (
    '/docs/motion/drag-and-drop',
    "Offer direct dismissal with a clear way to restore the item.",
  ),
  'hover-press': (
    '/docs/motion/gestures',
    "Confirm pointer, keyboard and touch interaction with visible feedback.",
  ),
  'drag-snap': (
    '/docs/motion/drag-and-drop',
    "Help a freely moved object land on a useful discrete choice.",
  ),
  'pivot-turn': (
    '/docs/motion/first-animation',
    "Make rotation read as a hinge instead of a turn around the center.",
  ),
  'keyed-reorder': (
    '/docs/motion/layout-animations',
    "Rearrange items while keeping their identity visible.",
  ),
  'presence-reflow': (
    '/docs/motion/presence',
    "Let a removed item finish its exit before releasing its space.",
  ),
  'expanding-card': (
    '/docs/motion/layout-animations',
    "Reveal detail in place so the user keeps their context.",
  ),
  'filtered-list': (
    '/docs/motion/presence',
    "Explain which results remain when a filter changes.",
  ),
  'selection-indicator': (
    '/docs/motion/layout-animations',
    "Make the selected option easy to follow when it changes.",
  ),
  'focus-overlay': (
    '/docs/motion/accessibility',
    "Open a contextual panel and return keyboard focus when it closes.",
  ),
  'stagger-list': (
    '/docs/motion/variants-stagger',
    "Introduce a short group in a readable order.",
  ),
  'variant-orchestration': (
    '/docs/motion/variants-stagger',
    "Coordinate child motion through one named parent state.",
  ),
  'onboarding-sequence': (
    '/docs/motion/animation-sequences',
    "Guide attention through ordered steps without losing the final content.",
  ),
  'loading-result': (
    '/docs/motion/presence',
    "Make a local busy-to-complete state change easy to follow.",
  ),
  'command-palette': (
    '/docs/motion/presence',
    "Keep a command panel responsive to rapid open and close input.",
  ),
  'viewport-reveal': (
    '/docs/motion/viewport-motion',
    "Introduce content when it becomes visible in its scroll area.",
  ),
  'local-parallax': (
    '/docs/motion/scroll-motion',
    "Give layers different scroll responses within a bounded scene.",
  ),
  'scroll-progress': (
    '/docs/motion/scroll-motion',
    "Show reading position inside a local scrollable article.",
  ),
  'page-transition': (
    '/docs/motion/navigation',
    "Keep the direction of a view change visible.",
  ),
  'form-validation': (
    '/docs/components/forms',
    "Put validation feedback beside the field that needs attention.",
  ),
  'tab-content': (
    '/docs/motion/navigation',
    "Connect a tab selection to the content it displays.",
  ),
  'accordion': (
    '/docs/components/catalog',
    "Reveal an answer while preserving the surrounding questions.",
  ),
};

/// Guided exercises reuse their exact documentation implementation. They do
/// not increase the count of distinct, qualified gallery animation recipes.
final allRecipes = <RecipeDefinition>[...verifiedRecipes, ..._guidedRecipes()];

List<RecipeDefinition> _guidedRecipes() {
  final byId = <String, RecipeDefinition>{};
  for (final article in SiteContent.articles) {
    for (final example in docExamplesFor(article.packageId, article.id)) {
      byId.putIfAbsent(
        example.playgroundId,
        () => RecipeDefinition(
          id: example.playgroundId,
          title: example.title,
          category: 'Guided exercises',
          summary: example.description,
          action: 'Use the labeled controls inside the preview',
          setting: '',
          minimum: 0,
          maximum: 1,
          initial: 0,
          sourceAsset: example.sourceAsset,
          documentationExample: example,
          guideRoute: article.route,
        ),
      );
    }
  }
  return byId.values.toList();
}

RecipeDefinition? recipeById(String id) {
  for (final recipe in allRecipes) {
    if (recipe.id == id) return recipe;
  }
  return null;
}
