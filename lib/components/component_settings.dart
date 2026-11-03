import 'dart:convert';

import 'package:flutter/material.dart';

/// Inspector state. Each guide exposes only settings supported by its demo.
@immutable
class ComponentSettings {
  const ComponentSettings({
    this.animated = false,
    this.disabled = false,
    this.text = 'Hello, Nib',
    this.variant = 'default',
    this.value = 50,
    this.multiple = false,
    this.searchable = true,
    this.vertical = false,
    this.blurSigma = 1,
    this.thickness = 24,
    this.refractiveIndex = 1.2,
    this.chromaticAberration = .03,
    this.saturation = 1.3,
    this.highlight = .5,
    this.showBorder = true,
    this.interactive = true,
    this.backdrop = 'grid',
    this.accent = 0xFFFFB51B,
    this.radius = 8,
    this.waterMaterial = 'legacy',
    this.waterScene = 'droplets',
    this.waterInteraction = 'drag',
    this.waterBackdrop = 'grid',
    this.waterWaveSpeed = 180,
    this.waterDamping = 2.4,
    this.waterImpulse = 5,
    this.waterWavelength = 46,
    this.waterRecovery = 14,
    this.waterRefraction = 16,
    this.waterHighlight = .6,
    this.waterCaptureScale = 1,
    this.waterSampling = 'live',
    this.waterOptics = 'clear',
    this.waterQuality = 1,
    this.waterBlur = 0,
  });

  final bool animated, disabled, multiple, searchable, vertical;
  final String text, variant, backdrop;
  final double value, blurSigma, thickness, refractiveIndex;
  final double chromaticAberration, saturation, highlight, radius;
  final bool showBorder, interactive;
  final int accent;
  final String waterMaterial, waterScene, waterInteraction, waterBackdrop;
  final String waterSampling, waterOptics;
  final double waterQuality, waterBlur;
  final double waterWaveSpeed, waterDamping, waterImpulse, waterWavelength;
  final double waterRecovery,
      waterRefraction,
      waterHighlight,
      waterCaptureScale;

  Map<String, Object> get values => {
    'animated': animated,
    'disabled': disabled,
    'text': text,
    'variant': variant,
    'value': value,
    'multiple': multiple,
    'searchable': searchable,
    'vertical': vertical,
    'blurSigma': blurSigma,
    'thickness': thickness,
    'refractiveIndex': refractiveIndex,
    'chromaticAberration': chromaticAberration,
    'saturation': saturation,
    'highlight': highlight,
    'showBorder': showBorder,
    'interactive': interactive,
    'backdrop': backdrop,
    'accent': accent,
    'radius': radius,
    'waterMaterial': waterMaterial,
    'waterScene': waterScene,
    'waterInteraction': waterInteraction,
    'waterBackdrop': waterBackdrop,
    'waterWaveSpeed': waterWaveSpeed,
    'waterDamping': waterDamping,
    'waterImpulse': waterImpulse,
    'waterWavelength': waterWavelength,
    'waterRecovery': waterRecovery,
    'waterRefraction': waterRefraction,
    'waterHighlight': waterHighlight,
    'waterCaptureScale': waterCaptureScale,
    'waterSampling': waterSampling,
    'waterOptics': waterOptics,
    'waterQuality': waterQuality,
    'waterBlur': waterBlur,
  };

  ComponentSettings change(String key, Object value) {
    if (!values.containsKey(key)) throw ArgumentError.value(key, 'key');
    final next = {...values, key: value};
    return ComponentSettings(
      animated: next['animated'] as bool,
      disabled: next['disabled'] as bool,
      text: next['text'] as String,
      variant: next['variant'] as String,
      value: (next['value'] as num).toDouble(),
      multiple: next['multiple'] as bool,
      searchable: next['searchable'] as bool,
      vertical: next['vertical'] as bool,
      blurSigma: (next['blurSigma'] as num).toDouble(),
      thickness: (next['thickness'] as num).toDouble(),
      refractiveIndex: (next['refractiveIndex'] as num).toDouble(),
      chromaticAberration: (next['chromaticAberration'] as num).toDouble(),
      saturation: (next['saturation'] as num).toDouble(),
      highlight: (next['highlight'] as num).toDouble(),
      showBorder: next['showBorder'] as bool,
      interactive: next['interactive'] as bool,
      backdrop: next['backdrop'] as String,
      accent: next['accent'] as int,
      radius: (next['radius'] as num).toDouble(),
      waterMaterial: next['waterMaterial'] as String,
      waterScene: next['waterScene'] as String,
      waterInteraction: next['waterInteraction'] as String,
      waterBackdrop: next['waterBackdrop'] as String,
      waterWaveSpeed: (next['waterWaveSpeed'] as num).toDouble(),
      waterDamping: (next['waterDamping'] as num).toDouble(),
      waterImpulse: (next['waterImpulse'] as num).toDouble(),
      waterWavelength: (next['waterWavelength'] as num).toDouble(),
      waterRecovery: (next['waterRecovery'] as num).toDouble(),
      waterRefraction: (next['waterRefraction'] as num).toDouble(),
      waterHighlight: (next['waterHighlight'] as num).toDouble(),
      waterCaptureScale: (next['waterCaptureScale'] as num).toDouble(),
      waterSampling: next['waterSampling'] as String,
      waterOptics: next['waterOptics'] as String,
      waterQuality: (next['waterQuality'] as num).toDouble(),
      waterBlur: (next['waterBlur'] as num).toDouble(),
    );
  }

  String get dartSource =>
      'ComponentSettings(\n${values.entries.map((entry) => '  ${entry.key}: ${componentDartLiteral(entry.value)},').join('\n')}\n)';
}

/// JSON quotes plus escaped interpolation produce a Dart string literal.
String componentDartLiteral(Object value) => value is String
    ? jsonEncode(value).replaceAll(r'$', r'\$')
    : value.toString();
