import 'package:flutter/widgets.dart';

import 'component_model.dart';
import 'guides/selection_family_guides.dart';
import 'examples/selection_family_demos.dart';
import 'guides/overlay_family_guides.dart';
import 'examples/overlay_family_demos.dart';
import 'guides/layout_family_guides.dart';
import 'examples/layout_family_demos.dart';
import 'component_settings.dart';
import 'examples/glass_component_demo.dart';
import 'examples/bottom_navigation_compositions.dart';
import 'guides/bottom_navigation_guides.dart';
import 'examples/input_component_demo.dart';
import 'examples/navigation_component_demo.dart';
import 'guides/glass_component_guide.dart';
import 'guides/input_component_guide.dart';
import 'guides/navigation_component_guide.dart';

/// One identity connects discovery, public symbols, live behavior and source.
const componentGuides = <ComponentGuide>[
  glassComponentGuide,
  navigationComponentGuide,
  inputComponentGuide,
  ...bottomNavigationGuides,
  ...layoutComponentGuides,
  ...overlayComponentGuides,
  ...selectionComponentGuides,
];

ComponentGuide? componentById(String id) => componentGuides
    .where((guide) => guide.id == (id == 'textarea' ? 'input' : id))
    .firstOrNull;

Widget buildComponentDemo(
  ComponentGuide guide,
  ComponentSettings settings,
  ValueChanged<ComponentSettings> onChanged,
  ValueChanged<String> onEvent,
) => switch (guide.id) {
  'liquid-glass' => GlassComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'navigation-menu' => NavigationComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'input' => InputComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'glass-bottom-navigation' => GlassBottomNavigationDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'liquid-bottom-navigation' => LiquidBottomNavigationDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'accordion' => AccordionComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'card' => CardComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'carousel' => CarouselComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'tabs' => TabsComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'data-table' => DataTableComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'resizable-panels' => ResizablePanelsComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'loader' => LoaderComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'skeleton' => SkeletonComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'breadcrumb' => BreadcrumbComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'pagination' => PaginationComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'alert-dialog' => AlertDialogComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'bottom-sheet' => BottomSheetComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'dialog' => DialogComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'popover' => PopoverComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'hover-card' => HoverCardComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'context-menu' => ContextMenuComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'command-palette' => CommandPaletteComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'toast' => ToastComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'button' => ButtonComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'checkbox' => CheckboxComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'switch' => SwitchComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'radio-group' => RadioGroupComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'toggle-group' => ToggleGroupComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'slider' => SliderComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'select' => SelectComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'combobox' => ComboboxComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'date-picker' => DatePickerComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  'otp-input' => OtpInputComponentDemo(
    settings: settings,
    onChanged: onChanged,
    onEvent: onEvent,
  ),
  _ => throw StateError('No demo registered for ${guide.id}'),
};
