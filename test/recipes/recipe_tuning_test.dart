import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_export.dart';
import 'package:nib_ember_living/recipes/recipe_tuning.dart';

void main() {
  test('every exposed control round trips through a share URL', () {
    for (final recipe in verifiedRecipes) {
      var tuning = defaultRecipeTuning(recipe);
      final primary = recipe.minimum + (recipe.maximum - recipe.minimum) * .37;
      for (final control in recipeControls(recipe)) {
        if (control.field == null) continue;
        tuning = tuning.withField(
          control.field!,
          control.minimum + (control.maximum - control.minimum) * .61,
        );
      }
      if (recipeHasOption(recipe)) {
        tuning = tuning.copyWith(option: !tuning.option);
      }
      if (recipeHasEase(recipe)) {
        tuning = tuning.copyWith(ease: RecipeEase.linear);
      }
      if (recipeHasRelease(recipe)) {
        tuning = tuning.copyWith(release: RecipeDragRelease.inertia);
      }
      final link = recipeShareUri(
        recipe,
        primary,
        tuning,
        Uri.parse('https://nib.example/playground/${recipe.id}'),
      );
      final restored = recipeConfigurationFromUri(recipe, link);
      expect(restored.value, primary, reason: recipe.id);
      for (final control in recipeControls(recipe)) {
        if (control.field == null) continue;
        expect(
          restored.tuning.getField(control.field!),
          tuning.getField(control.field!),
          reason: '${recipe.id}: ${control.label}',
        );
      }
      if (recipeHasOption(recipe)) {
        expect(restored.tuning.option, tuning.option);
      }
      if (recipeHasEase(recipe)) expect(restored.tuning.ease, tuning.ease);
      if (recipeHasRelease(recipe)) {
        expect(restored.tuning.release, tuning.release);
      }
      final launcher = recipeLauncher(recipe, restored.value, restored.tuning);
      expect(launcher, contains(primary.toString()), reason: recipe.id);
      if (recipe.id == 'spring-retarget') {
        expect(launcher, contains('mass: ${tuning.mass}'));
      } else {
        expect(launcher, contains('durationMs: ${tuning.durationMs}'));
        expect(launcher, contains('stiffness: ${tuning.stiffness}'));
        expect(launcher, contains('damping: ${tuning.damping}'));
        expect(launcher, contains('mass: ${tuning.mass}'));
        expect(launcher, contains('elasticity: ${tuning.elasticity}'));
        expect(launcher, contains('opacity: ${tuning.opacity}'));
        expect(launcher, contains('scale: ${tuning.scale}'));
        expect(launcher, contains('option: ${tuning.option}'));
        expect(launcher, contains('ease: RecipeEase.${tuning.ease.name}'));
        expect(
          launcher,
          contains('release: RecipeDragRelease.${tuning.release.name}'),
        );
        expect(launcher, contains('secondary: ${tuning.secondary}'));
      }
    }
  });

  test('malformed links and values are bounded to the selected recipe', () {
    final recipe = recipeById('spring-retarget')!;
    final bad = Uri.parse(
      'https://nib.example/playground/spring-retarget?value=Infinity&stiffness=-10&damping=foo&mass=90',
    );
    final restored = recipeConfigurationFromUri(recipe, bad);
    expect(restored.value, recipe.initial);
    expect(restored.tuning.stiffness, 80);
    expect(restored.tuning.damping, 18);
    expect(restored.tuning.mass, 2.5);
    final other = recipeConfigurationFromUri(
      recipe,
      Uri.parse('https://nib.example/playground/card-flip?value=170'),
    );
    expect(other.value, recipe.initial);
  });
}
