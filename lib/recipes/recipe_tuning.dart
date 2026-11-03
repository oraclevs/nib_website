import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// These fields are intentionally explicit. A control is shown only when its
/// recipe passes the field into an actual Nib API or local behavior.
enum RecipeField {
  durationMs,
  stiffness,
  damping,
  mass,
  secondary,
  elasticity,
  opacity,
  scale,
}

enum RecipeEase { easeInOut, easeOut, linear }

enum RecipeDragRelease { springBack, inertia, stay }

@immutable
class RecipeTuning {
  const RecipeTuning({
    this.durationMs = 550,
    this.stiffness = 180,
    this.damping = 18,
    this.mass = 1,
    this.secondary,
    this.elasticity = .2,
    this.opacity = .6,
    this.scale = .7,
    this.option = false,
    this.ease = RecipeEase.easeInOut,
    this.release = RecipeDragRelease.springBack,
  });

  final double durationMs;
  final double stiffness;
  final double damping;
  final double mass;
  final double? secondary;
  final double elasticity;
  final double opacity;
  final double scale;
  final bool option;
  final RecipeEase ease;
  final RecipeDragRelease release;

  double getField(RecipeField field) => switch (field) {
    RecipeField.durationMs => durationMs,
    RecipeField.stiffness => stiffness,
    RecipeField.damping => damping,
    RecipeField.mass => mass,
    RecipeField.secondary => secondary ?? 0,
    RecipeField.elasticity => elasticity,
    RecipeField.opacity => opacity,
    RecipeField.scale => scale,
  };

  RecipeTuning withField(RecipeField field, double value) => switch (field) {
    RecipeField.durationMs => copyWith(durationMs: value),
    RecipeField.stiffness => copyWith(stiffness: value),
    RecipeField.damping => copyWith(damping: value),
    RecipeField.mass => copyWith(mass: value),
    RecipeField.secondary => copyWith(secondary: value),
    RecipeField.elasticity => copyWith(elasticity: value),
    RecipeField.opacity => copyWith(opacity: value),
    RecipeField.scale => copyWith(scale: value),
  };

  RecipeTuning copyWith({
    double? durationMs,
    double? stiffness,
    double? damping,
    double? mass,
    double? secondary,
    double? elasticity,
    double? opacity,
    double? scale,
    bool? option,
    RecipeEase? ease,
    RecipeDragRelease? release,
  }) => RecipeTuning(
    durationMs: durationMs ?? this.durationMs,
    stiffness: stiffness ?? this.stiffness,
    damping: damping ?? this.damping,
    mass: mass ?? this.mass,
    secondary: secondary ?? this.secondary,
    elasticity: elasticity ?? this.elasticity,
    opacity: opacity ?? this.opacity,
    scale: scale ?? this.scale,
    option: option ?? this.option,
    ease: ease ?? this.ease,
    release: release ?? this.release,
  );

  Curve get curve => switch (ease) {
    RecipeEase.easeInOut => Curves.easeInOut,
    RecipeEase.easeOut => Curves.easeOutCubic,
    RecipeEase.linear => Curves.linear,
  };
}
