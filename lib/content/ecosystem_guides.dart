import 'site_content.dart';

/// Source-checked guides for the Components and experimental GenUI layers.
/// These replace the brief entries in SiteContent.articles by matching route ID.
const detailedEcosystemGuides = <DocArticle>[
  DocArticle(
    packageId: 'components',
    id: 'getting-started',
    title: 'Start with components',
    summary:
        'Install the published widget library and wire a control to app state.',
    evidence: 'ComponetsNib/nib_components/README.md; ComponetsNib/nib_components/lib/nib_components.dart; ComponetsNib/nib_components/lib/src/button/nib_button.dart',
    sections: [
      DocSection(
        id: 'install',
        heading: 'Add the package',
        paragraphs: [
          'Run the package command in an existing Flutter app. nib_components declares nib_motion as a dependency, so pub resolves the animation layer with it.',
          'Import the public barrel. The widgets also work without a registered NibTheme; they choose the built-in light or dark palette from the surrounding Flutter Theme.',
        ],
        code: '''flutter pub add nib_components''',
      ),
      DocSection(
        id: 'working-screen',
        heading: "Build a complete first screen",
        paragraphs: [
          "You need a Flutter app that already runs with MaterialApp. Add the package with the command above, then replace lib/main.dart with this small screen. MaterialApp supplies Flutter theme and direction; Scaffold supplies the page surface. The example keeps one integer in State. Each press runs onPressed, increments the integer inside setState, and rebuilds the text. NibButton handles focus, tapping and appearance; the integer remains application state.",
          "Run the screen before adding animation. Press Add one twice and verify that the number is two. The live button demo follows the same flow and also has Reset. Try moving the integer declaration into build: it returns to zero on every rebuild. Move it back to State to restore persistence. This distinction applies to form keys, selected values and controllers throughout the library.",
        ],
        code: r'''import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

void main() => runApp(const MaterialApp(home: CountPage()));

class CountPage extends StatefulWidget {
  const CountPage({super.key});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Pressed $count times'),
        NibButton(
          label: 'Add one',
          onPressed: () => setState(() => count++),
        ),
      ]),
    ),
  );
}''',
      ),
      DocSection(
        id: 'first-control',
        heading: 'Let app state decide',
        paragraphs: [
          'NibButton calls onPressed; it does not own the state that the button changes. Store that state in your widget, controller, or application model and rebuild with the new value.',
          'A null onPressed, disabled: true, or loading: true blocks input. Keep a useful label or semanticLabel when the visible content is only an icon.',
        ],
        code: '''bool saved = false;

NibButton(
  label: saved ? 'Saved' : 'Save draft',
  variant: NibButtonVariant.primary,
  onPressed: () => setState(() => saved = true),
)''',
        api: [
          DocApiEntry(
            name: 'label',
            type: 'String?',
            defaultValue: 'null',
            description: 'Visible button text; content or an icon can supply the body instead.',
          ),
          DocApiEntry(
            name: 'onPressed',
            type: 'VoidCallback?',
            defaultValue: 'required',
            description: 'Host callback. Null disables the button.',
          ),
          DocApiEntry(
            name: 'variant',
            type: 'NibButtonVariant',
            defaultValue: 'primary',
            description:
                'Primary, secondary, outline, ghost, or destructive styling.',
          ),
          DocApiEntry(
            name: 'size',
            type: 'NibButtonSize',
            defaultValue: 'md',
            description:
                'Preset control metrics; md is about 44 logical pixels high.',
          ),
          DocApiEntry(
            name: 'animated',
            type: 'bool',
            defaultValue: 'false',
            description: 'Opts into the component motion path for supported state changes.',
          ),
        ],
      ),
      DocSection(
        id: 'busy-and-disabled',
        heading: "Add loading after the action works",
        paragraphs: [
          "For an asynchronous save, store a saving boolean beside the result. Set it before starting the request and pass it as loading. The button then blocks additional presses and shows its loader; loadingText can explain the work. On failure, keep the input, show a useful error and clear saving so the person can retry. After an await, check mounted before updating a State object that may have left the screen.",
          "Loading changes presentation and input handling; it does not start, cancel or retry a request. Likewise, the destructive variant changes styling but does not confirm a delete. Put confirmation and persistence in the host action. Once the behavior is correct, try animated: true for the small press effect. Leave it false if the screen does not need extra motion. Both settings still provide native button interaction.",
          "If nothing happens, first check whether onPressed is null, disabled is true, or loading is still true. Then put a breakpoint in the callback. A callback that runs without a visible update usually means the host changed a variable without rebuilding the widget that reads it.",
        ],
      ),
      DocSection(
        id: 'next-step',
        heading: 'Choose the state owner',
        paragraphs: [
          "The state owner is the object that keeps a value between builds. A simple button uses your State object; a checkbox receives value and onChanged; a select can keep selection in an internal controller. These are different contracts. Decide whether another part of your app needs to read or change the value before introducing an external controller.",
          "Create long-lived controllers once in State, not inside build. A widget disposes an internal controller that it created. You dispose a controller that you passed in. Rebuilding a widget is routine; disposing its controller ends that controller’s lifetime. Keep those operations separate so a theme change or validation message does not erase the user’s work.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'theming',
    title: 'Theme the controls',
    summary:
        'Use Flutter brightness or register one NibTheme per color scheme.',
    evidence: 'ComponetsNib/nib_components/lib/src/theme/nib_theme.dart; ComponetsNib/nib_components/README.md',
    sections: [
      DocSection(
        id: 'fallback',
        heading: 'Start with the built-in palettes',
        paragraphs: [
          'NibTheme.of(context) first reads a NibTheme extension from ThemeData. If none is registered, it picks NibTheme.light or NibTheme.dark from Theme.of(context).brightness. A separate theme setup is optional.',
          'The extension carries colors and four radius tokens. Radius values are logical pixels: 4 small, 8 default, 12 large, and 9999 pill in both built-in palettes.',
        ],
        api: [
          DocApiEntry(
            name: 'NibTheme.of(context)',
            type: 'NibTheme',
            defaultValue: 'ambient fallback',
            description: 'Returns the registered extension or built-in palette for current brightness.',
          ),
          DocApiEntry(
            name: 'radiusDefault',
            type: 'double',
            defaultValue: '8',
            description: 'Default corner radius in Flutter logical pixels.',
          ),
          DocApiEntry(
            name: 'primary',
            type: 'Color',
            defaultValue: 'palette token',
            description: 'Main action color; use copyWith to customize it in one scheme.',
          ),
          DocApiEntry(
            name: 'ring',
            type: 'Color',
            defaultValue: 'palette token',
            description: 'Focus and input ring color.',
          ),
        ],
      ),
      DocSection(
        id: 'register',
        heading: 'Register both schemes',
        paragraphs: [
          'Put the extension on each ThemeData supplied to MaterialApp. copyWith keeps all other tokens from the selected palette, so a small brand change does not require rebuilding the entire token set.',
          'Test open dialogs, sheets, and toasts while changing theme; they inherit the caller’s current theme. Check focus rings and error contrast with the colors you choose.',
        ],
        code: r'''MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      NibTheme.light.copyWith(
        primary: const Color(0xFF6D28D9),
        primaryForeground: Colors.white,
      ),
    ],
  ),
  darkTheme: ThemeData.dark().copyWith(
    extensions: const [NibTheme.dark],
  ),
  themeMode: ThemeMode.system,
  home: const MyScreen(),
)''',
        api: [
          DocApiEntry(
            name: 'NibTheme.light / dark',
            type: 'NibTheme',
            defaultValue: 'built-in',
            description: 'Ready-to-use light and dark token sets.',
          ),
          DocApiEntry(
            name: 'copyWith(...)',
            type: 'NibTheme',
            defaultValue: 'unchanged fields retained',
            description:
                'Returns a new theme with selected colors or radii replaced.',
          ),
          DocApiEntry(
            name: 'lerp(other, t)',
            type: 'NibTheme',
            defaultValue: 'ThemeExtension API',
            description:
                'Interpolates token values during Flutter theme changes.',
          ),
        ],
      ),
      DocSection(
        id: 'token-flow',
        heading: "Trace a color from the app to a control",
        paragraphs: [
          "Use this guide after the first component screen works. A theme is shared visual data. When NibButton builds, it calls NibTheme.of(context), chooses the colors for its variant, and applies any instance overrides. A primary button uses primary with primaryForeground. A card uses card with cardForeground. Changing primary therefore does not recolor every surface, which lets actions stay distinct from content.",
          "In the snippet above, MyScreen means your existing page widget. ThemeData.light and ThemeData.dark establish the correct Flutter brightness as well as Nib tokens. Merely putting NibTheme.dark into a default ThemeData leaves Flutter’s other controls with light brightness. Always configure both layers when your page mixes Material and Nib widgets.",
          "Treat foreground and background as a pair. A dark purple primary often needs light text, while a pale accent often needs dark text. Updating only the fill can make the label difficult to read. Apply the same review to muted text, borders, error feedback and the focus ring. The ring should remain visible against the surface around the control, not just its own fill.",
        ],
      ),
      DocSection(
        id: 'theme-experiment',
        heading: "Change the palette without resetting the screen",
        paragraphs: [
          "In the theme demo, press the button to increase its count, then use Change accent token. Watch amber change to sage while the count stays intact. To explore brightness, switch themeMode in the standalone app above. The demo creates a modified extension with copyWith; it does not replace the component. In your app, type into a field before changing theme. Its value and selection should survive because the field’s controller belongs to the screen, not the theme.",
          "For a preview panel with a different theme, wrap only that subtree in Theme and use Theme.of(context).copyWith to retain unrelated settings. Read NibTheme.of from a BuildContext below that Theme. Reading it above the wrapper returns the parent’s extension; the BuildContext position determines which values are visible. A Builder inside the wrapper gives you the inner context when you need one.",
          "When an override seems ignored, inspect the widget arguments next. A backgroundColor passed directly to one button takes precedence over the variant’s theme fill. Remove that override to make it follow shared tokens. When only dark mode looks wrong, check that darkTheme has its own extension rather than reusing a modified light palette.",
          "For dialogs and other overlays, open the overlay, change the theme and check its content, input borders and focus ring. The current implementation carries the caller’s theme into overlays, but custom content with explicit colors still overrides inherited defaults. ThemeExtension.lerp allows token transitions; it is not a reason to recreate application state during a visual change.",
        ],
      ),
      DocSection(
        id: 'local-overrides',
        heading: 'Use local overrides sparingly',
        paragraphs: [
          'A number of widgets also expose color and radius arguments for one instance. These override the theme only for that control. Prefer the extension when several controls should share the same look.',
          'The theme covers controls, not your app’s business state. Theme changes should not recreate external controllers or reset form values.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'forms',
    title: 'Forms and state',
    summary: 'Validate text, choose values, and keep input ownership clear.',
    evidence: 'ComponetsNib/nib_components/lib/src/input/nib_input.dart; ComponetsNib/nib_components/lib/src/textarea/nib_textarea.dart; ComponetsNib/nib_components/lib/src/validation/nib_validators.dart; ComponetsNib/nib_components/lib/src/select/nib_select.dart; ComponetsNib/nib_components/lib/src/checkbox/nib_checkbox.dart',
    sections: [
      DocSection(
        id: 'text-fields',
        heading: 'Put text fields inside Form',
        paragraphs: [
          'NibInput and NibTextarea extend FormField<String>. A parent Form can validate, save, and reset them. A validator returns null for a valid value or an error message for an invalid one. AutovalidateMode.onUserInteraction is the default.',
          'Use either controller or initialValue; passing both is an assertion error. When controller or focusNode is omitted, the field creates and disposes its own. Dispose the ones your state object creates.',
        ],
        code: r'''// Fields and method inside your State class.
final formKey = GlobalKey<FormState>();
String savedEmail = '';
String status = '';

Widget buildForm() => Form(
  key: formKey,
  child: Column(mainAxisSize: MainAxisSize.min, children: [
    NibInput(
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: NibValidators.compose([
        NibValidators.required(),
        NibValidators.email(),
      ]),
      onSaved: (value) => savedEmail = value?.trim() ?? '',
    ),
    NibButton(
      label: 'Check form',
      onPressed: () {
        if (formKey.currentState?.validate() != true) return;
        formKey.currentState!.save();
        setState(() => status = 'Ready for $savedEmail');
      },
    ),
    Text(status),
  ]),
);''',
        api: [
          DocApiEntry(
            name: 'controller',
            type: 'TextEditingController?',
            defaultValue: 'null',
            description:
                'External text owner; mutually exclusive with initialValue.',
          ),
          DocApiEntry(
            name: 'initialValue',
            type: 'String?',
            defaultValue: 'null',
            description: 'Seeds an internally owned controller.',
          ),
          DocApiEntry(
            name: 'validator',
            type: 'NibValidator?',
            defaultValue: 'null',
            description:
                'Returns an error string or null; Form.validate invokes it.',
          ),
          DocApiEntry(
            name: 'autovalidateMode',
            type: 'AutovalidateMode',
            defaultValue: 'onUserInteraction',
            description: 'Controls when the validator runs before explicit Form validation.',
          ),
          DocApiEntry(
            name: 'errorText',
            type: 'String?',
            defaultValue: 'null',
            description: 'Forced error that takes precedence over validator output and helper text.',
          ),
          DocApiEntry(
            name: 'minHeight',
            type: 'double?',
            defaultValue: 'null',
            description: 'Optional field floor in logical pixels.',
          ),
        ],
      ),
      DocSection(
        id: 'submit-flow',
        heading: "Follow a value through validation and saving",
        paragraphs: [
          "A useful form has three separate moments: typing, validation and submission. Typing updates the field’s text controller. validate asks every participating FormField for an error. save runs each onSaved callback, but it does not contact a server. Put the code above inside your screen’s State class and return buildForm from a padded page body. Keep the GlobalKey outside build so the Form remains identifiable across rebuilds.",
          "Press Check form with no email. required returns the first error, so email is not the message you see yet. Enter a malformed address and check again; now required succeeds and email reports the problem. Enter a valid address and the saved value appears below the button. The live form demo uses the same sequence with a required name. Inspect the feedback before and after editing to understand onUserInteraction validation.",
          "If you need to read text while the user is typing, create a TextEditingController in State and pass controller. Dispose it in dispose, and omit initialValue. If you need only the submitted value, onSaved avoids that extra ownership. initialValue is a seed, not a command to overwrite the current draft on every rebuild.",
        ],
      ),
      DocSection(
        id: 'helpers',
        heading: 'Compose validation rules',
        paragraphs: [
          'NibValidators.compose checks rules in order and returns the first error. Format rules such as email permit an empty value, so add required when a field is mandatory.',
          'NibTextarea adds minLines: 3 by default, optional maxLines, maxLength, and a showCounter switch. A server validation error belongs in errorText; clear or replace it when the server accepts a new value.',
        ],
        api: [
          DocApiEntry(
            name: 'NibValidators.required()',
            type: 'NibValidator',
            defaultValue: 'default message',
            description: 'Rejects null, empty, and whitespace-only text.',
          ),
          DocApiEntry(
            name: 'NibValidators.email()',
            type: 'NibValidator',
            defaultValue: 'default message',
            description: 'Checks a non-empty email-shaped value.',
          ),
          DocApiEntry(
            name: 'NibTextarea.minLines',
            type: 'int',
            defaultValue: '3',
            description: 'Initial minimum visible text lines.',
          ),
          DocApiEntry(
            name: 'NibTextarea.showCounter',
            type: 'bool',
            defaultValue: 'false',
            description: 'Shows the length counter when enabled.',
          ),
        ],
      ),
      DocSection(
        id: 'choices',
        heading: 'Keep choices controlled',
        paragraphs: [
          "NibCheckbox.value and NibSwitch.value are controlled: read the current boolean from State and assign the callback’s proposed value inside setState. A checkbox can represent an indeterminate value only when tristate is true. These controls do not automatically validate or save themselves through the text field’s Form contract.",
          "NibSelect uses a controller for selection. Its value or values arguments seed an internally created controller; an external controller takes precedence. Supply exactly one of options or groups. Single selection reports T? through onChanged; onSelectionChanged reports List<T> in either mode. Multi-selection is a list of selected values, not a Set. Use the controller when a reset button elsewhere must clear the selection.",
        ],
        api: [
          DocApiEntry(
            name: 'NibCheckbox.value',
            type: 'bool?',
            defaultValue: 'required',
            description:
                'Current value; null is indeterminate only with tristate.',
          ),
          DocApiEntry(
            name: 'NibSwitch.loading',
            type: 'bool',
            defaultValue: 'false',
            description: 'Shows thumb progress and blocks interaction during an async change.',
          ),
          DocApiEntry(
            name: 'NibSelect.multiSelect',
            type: 'bool',
            defaultValue: 'false',
            description: 'Selects one value or a list of values.',
          ),
          DocApiEntry(
            name: 'NibSelect.maxDropdownHeight',
            type: 'double',
            defaultValue: '280',
            description: 'Maximum menu height in logical pixels.',
          ),
        ],
      ),
      DocSection(
        id: 'server-errors',
        heading: "Keep drafts when submission fails",
        paragraphs: [
          "After local validation succeeds, mark the form busy and call your own save operation. Preserve the typed values until the operation succeeds. Display a field-specific server error through errorText and a general connection failure near the submit action. Clear an old server error when a relevant edit or a new response makes it obsolete; otherwise it continues to override a validator that now returns null.",
          "A validator should answer whether the current value is valid. Avoid starting a request or changing State inside it: Flutter can invoke it repeatedly. Async validation belongs in the host submission flow or a separately managed check. A loading button prevents accidental repeated taps, but the service still needs its own duplicate-request policy.",
          "Try adding a NibTextarea for a message. Its minimum is three lines; maxLength constrains length and showCounter controls whether the count is displayed. Use constraints that leave space for helper and error text. Test a long error at a narrow width before fixing the whole form to a short height. Reset only when the user asks or when successful submission clearly starts a fresh form.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'catalog',
    title: 'Component catalog',
    summary: 'Find every exported widget family by the task it handles.',
    evidence: 'ComponetsNib/nib_components/lib/nib_components.dart; ComponetsNib/nib_components/README.md; ComponetsNib/nib_components/lib/src/card/nib_card.dart; ComponetsNib/nib_components/lib/src/accordion/nib_accordion.dart; ComponetsNib/nib_components/lib/src/combobox/nib_combobox.dart; ComponetsNib/nib_components/lib/src/skeleton/nib_skeleton.dart',
    sections: [
      DocSection(
        id: 'choose-by-flow',
        heading: "Choose widgets around a concrete task",
        paragraphs: [
          "Start with the interaction you need to complete. A profile editor might use NibCard to group fields, NibInput for a name, NibTextarea for a biography and NibButton to save. A NibSwitch is suitable for an immediately applied setting; a NibCheckbox suits a choice that belongs to a later submission. The host decides whether changing the setting saves immediately or waits for the form.",
          "For a short visible set, NibRadioGroup communicates one choice and NibToggleGroup suits toolbar-like options. NibSelect puts a known list behind a trigger. NibCombobox adds a text field for filtering; allowFreeText is false by default, so typing an unmatched query does not create a new option. Turn it on only when your domain accepts new free text, and handle onFreeTextSubmitted separately from selecting an existing value.",
          "NibDatePicker handles calendar selection, while NibOtpInput collects a structured code. A number-looking field is not interchangeable with either: dates need range and locale decisions, and code entry needs completion handling. Choose the value model first, then pick the control that exposes that model. Keep labels in the user’s vocabulary rather than exposing your enum names.",
        ],
      ),
      DocSection(
        id: 'inputs',
        heading: 'Forms and input',
        paragraphs: [
          'Start with NibInput or NibTextarea for text that belongs to a Flutter Form. Use NibSelect for a known list, NibCombobox when users may filter or search, and NibDatePicker for calendar selection.',
          'The remaining input controls cover boolean, range, and structured entry. Their value and callback contracts differ; check each constructor rather than assuming one generic form API.',
        ],
        api: [
          DocApiEntry(
            name: 'NibButton',
            type: 'Widget',
            defaultValue: '—',
            description: 'Action control with variants, sizes, loading, and disabled states.',
          ),
          DocApiEntry(
            name: 'NibInput / NibTextarea',
            type: 'FormField<String>',
            defaultValue: '—',
            description:
                'Single-line and multiline text with Flutter Form validation.',
          ),
          DocApiEntry(
            name: 'NibCheckbox / NibSwitch',
            type: 'Widget',
            defaultValue: '—',
            description:
                'Controlled boolean input; checkbox also supports tristate.',
          ),
          DocApiEntry(
            name: 'NibRadioGroup / NibToggleGroup',
            type: 'Widget',
            defaultValue: '—',
            description: 'Choose from a small visible set.',
          ),
          DocApiEntry(
            name: 'NibSlider',
            type: 'Widget',
            defaultValue: '—',
            description: 'Single or range numeric input.',
          ),
          DocApiEntry(
            name: 'NibSelect / NibCombobox',
            type: 'Widget',
            defaultValue: '—',
            description:
                'Select from a list; combobox can load options asynchronously.',
          ),
          DocApiEntry(
            name: 'NibOtpInput / NibDatePicker',
            type: 'Widget',
            defaultValue: '—',
            description: 'Segmented code entry and calendar selection.',
          ),
        ],
      ),
      DocSection(
        id: 'compose-content',
        heading: "Compose a card and expandable details",
        paragraphs: [
          "Paste this subtree into a Scaffold body after importing nib_components. NibCard has header, child and footer slots. Its default is plain content; interactive: true opts the whole card into tapping, and onTap supplies the action. Do not turn a card into a large invisible button when its only action is already a clearly labeled button inside it.",
          "NibAccordion owns expansion state unless you provide a controller. With allowMultipleOpen false, opening one item closes the previous item. Add a second item, open both in turn, then enable allowMultipleOpen to compare the behavior. Its expansion callback reports the tapped index and new open state. That is useful for analytics or coordinating another panel; it is not needed merely to make the accordion expand.",
        ],
        code: r'''NibCard(
  header: const Text('Delivery details'),
  child: NibAccordion(
    items: const [
      NibAccordionItem(
        title: Text('When will it arrive?'),
        content: Text('Your confirmation includes the estimated date.'),
      ),
      NibAccordionItem(
        title: Text('Can I change the address?'),
        content: Text('Contact support before the order is dispatched.'),
      ),
    ],
  ),
)''',
      ),
      DocSection(
        id: 'overlays',
        heading: 'Overlays and popups',
        paragraphs: [
          'Overlays need a trigger or a host-owned controller. Close them from a deliberate result or cancellation path, and keep the calling widget mounted until an awaited result is handled.',
          'The package exports placed widgets and top-level show functions for several overlays. Those are different entry points to the same interaction family.',
        ],
        api: [
          DocApiEntry(
            name: 'NibDialog / showNibDialog',
            type: 'Widget / function',
            defaultValue: '—',
            description: 'Modal content and optional typed close result.',
          ),
          DocApiEntry(
            name: 'showNibAlertDialog',
            type: 'function',
            defaultValue: '—',
            description: 'Confirm or alert popup with severity and actions.',
          ),
          DocApiEntry(
            name: 'NibBottomSheet / showNibBottomSheet',
            type: 'Widget / function',
            defaultValue: '—',
            description:
                'Sheet interaction with declarative or imperative opening.',
          ),
          DocApiEntry(
            name: 'NibPopover / NibHoverCard',
            type: 'Widget',
            defaultValue: '—',
            description:
                'Anchored information and pointer-oriented hover content.',
          ),
          DocApiEntry(
            name: 'NibContextMenu / showNibContextMenu',
            type: 'Widget / function',
            defaultValue: '—',
            description: 'Contextual menu entries.',
          ),
          DocApiEntry(
            name: 'NibCommandPalette',
            type: 'Widget',
            defaultValue: '—',
            description: 'Keyboard-searchable command launcher.',
          ),
          DocApiEntry(
            name: 'showNibToast',
            type: 'function',
            defaultValue: '—',
            description: 'Transient status message.',
          ),
        ],
      ),
      DocSection(
        id: 'overlays-feedback',
        heading: "Choose how much attention an action needs",
        paragraphs: [
          "Use a dialog for a decision that interrupts the current task, a bottom sheet for a focused mobile interaction, and a popover for content anchored to a trigger. A hover card adds pointer detail, but essential instructions still need a touch and keyboard route. A context menu groups actions for an item; a command palette searches across host-registered commands. None of these decides your app’s permissions or routing.",
          "For feedback, a toast communicates a short outcome, a loader communicates ongoing work, and NibSkeleton shades the real content tree while loading. Skeleton children still exist, so they must be safe to build before data arrives. NibSkeletonBone and NibSkeletonIgnore refine detection without maintaining a second copy of the layout. NibFlipCard, NibCarousel and NibLiquidGlass provide more specialized presentation; introduce them after the content and navigation remain usable without their visual effects.",
          "The button demo below is a focused interaction sample, not a renderer for every catalog family. Use its Add one and Reset controls to practice host state, then apply that pattern to the family you chose. Tables, tabs and resizable panels have additional layout and controller contracts covered in the API guide.",
        ],
      ),
      DocSection(
        id: 'navigation',
        heading: 'Navigation',
        paragraphs: [
          'These widgets report the selected destination or index to the host. Route ownership stays with your app; a visual active item is not a router.',
        ],
        api: [
          DocApiEntry(
            name: 'NibTabs',
            type: 'Widget',
            defaultValue: '—',
            description: 'Pinned tab bar with one vertical scroll and optional controller.',
          ),
          DocApiEntry(
            name: 'NibBreadcrumb',
            type: 'Widget',
            defaultValue: '—',
            description: 'Path hierarchy.',
          ),
          DocApiEntry(
            name: 'NibPagination',
            type: 'Widget',
            defaultValue: '—',
            description: 'One-based page navigation.',
          ),
          DocApiEntry(
            name: 'NibNavigationMenu',
            type: 'Widget',
            defaultValue: '—',
            description: 'Horizontal flyout or vertical expandable menu.',
          ),
        ],
      ),
      DocSection(
        id: 'layout-feedback',
        heading: 'Layout, data, and feedback',
        paragraphs: [
          'NibDataTable is the data-heavy control; pass columns and rows, then choose local or host sorting. NibTabs and NibResizablePanels need a bounded layout, so test them at the widths your app supports.',
        ],
        api: [
          DocApiEntry(
            name: 'NibCard / NibFlipCard',
            type: 'Widget',
            defaultValue: '—',
            description: 'Content container and two-sided card.',
          ),
          DocApiEntry(
            name: 'NibDataTable',
            type: 'Widget',
            defaultValue: '—',
            description: 'Sortable and selectable rows.',
          ),
          DocApiEntry(
            name: 'NibAccordion / NibCarousel',
            type: 'Widget',
            defaultValue: '—',
            description: 'Expandable groups and horizontal content sequence.',
          ),
          DocApiEntry(
            name: 'NibResizablePanels',
            type: 'Widget',
            defaultValue: '—',
            description: 'User-adjustable panel sizes.',
          ),
          DocApiEntry(
            name: 'NibSkeleton / NibCircularLoader',
            type: 'Widget',
            defaultValue: '—',
            description: 'Loading placeholders and progress indicator.',
          ),
          DocApiEntry(
            name: 'NibLiquidGlass',
            type: 'Widget',
            defaultValue: '—',
            description: 'Visual surface effect.',
          ),
          DocApiEntry(
            name: 'NibTheme / NibValidators',
            type: 'ThemeExtension / helpers',
            defaultValue: '—',
            description: 'Design tokens and text validation helpers.',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'api',
    title: 'API reference',
    summary: 'Use the right state and overlay entry point for each control.',
    evidence: 'ComponetsNib/nib_components/lib/src/data_table/nib_data_table.dart; ComponetsNib/nib_components/lib/src/tabs/nib_tabs.dart; ComponetsNib/nib_components/lib/src/dialog/nib_dialog.dart; ComponetsNib/nib_components/lib/src/command_palette/nib_command_palette.dart',
    sections: [
      DocSection(
        id: 'controller-lifetime',
        heading: "Keep controllers alive for the whole interaction",
        paragraphs: [
          "The table snippet belongs inside a StatefulWidget. Declare tableController as a field on State, return the table from build, and call tableController.dispose before super.dispose. Creating it inside build loses selection whenever the parent rebuilds. With no external controller, the table creates its own; use that simpler mode when no other widget needs to command selection or sorting.",
          "A column’s cellBuilder controls how one cell looks. sortValue supplies the value used for local comparisons, so a formatted currency label can still sort numerically. Adding onSort changes responsibility: the table reports the request and expects the host to provide rows in the requested order. For a remote query, show loading, preserve the current rows until a response is accepted, and avoid letting an older response replace a newer sort request.",
          "Selection uses row values, while rowKey identifies Flutter rows for animation. In a real model, derive the key from a stable record ID, not the visible name or its current position. Two people can share a name, and positions change when sorting. Begin with selectionMode.none, then enable single or multi only when a selected-row action actually exists.",
        ],
      ),
      DocSection(
        id: 'table',
        heading: 'Sort and select table rows',
        paragraphs: [
          'NibDataTable<T> requires columns and rows. Without onSort it sorts locally. If onSort is set, the host supplies rows in the requested order, which is the right shape for server-side sorting.',
          'Use a stable rowKey when animated rows can reorder or be replaced. Create and dispose NibDataTableController<T> in the owner state if another widget needs to change sorting or selection.',
        ],
        code: '''final tableController = NibDataTableController<String>();

NibDataTable<String>(
  controller: tableController,
  columns: [
    NibDataColumn<String>(
      label: 'Name',
      cellBuilder: (context, name) => Text(name),
      sortValue: (name) => name,
    ),
  ],
  rows: const ['Ada', 'Lin'],
  rowKey: (name) => ValueKey(name),
  selectionMode: NibDataTableSelectionMode.single,
  onSelectionChanged: (selected) => debugPrint(selected.join(', ')),
)''',
        api: [
          DocApiEntry(
            name: 'columns / rows',
            type: 'List<NibDataColumn<T>> / List<T>',
            defaultValue: 'required',
            description: 'Column schema and current row values.',
          ),
          DocApiEntry(
            name: 'selectionMode',
            type: 'NibDataTableSelectionMode',
            defaultValue: 'none',
            description: 'None, single, or multi row selection.',
          ),
          DocApiEntry(
            name: 'rowHeight / headerHeight',
            type: 'double',
            defaultValue: '48 / 48',
            description: 'Table metrics in logical pixels.',
          ),
          DocApiEntry(
            name: 'stickyHeader',
            type: 'bool',
            defaultValue: 'true',
            description: 'Keeps column labels visible during table scrolling.',
          ),
          DocApiEntry(
            name: 'onSort',
            type: 'callback?',
            defaultValue: 'null',
            description: 'When supplied, host owns sorted row order.',
          ),
        ],
      ),
      DocSection(
        id: 'tabs',
        heading: 'Give tabs one vertical scroll',
        paragraphs: [
          'NibTabs expects bounded height. Put content above the tabs in header and content after the active panel in footer; do not wrap the entire widget in another vertical ScrollView. The widget has its own single vertical scroll and a pinned bar.',
          'An external NibTabsController lets a parent animateTo or jumpTo an index. Dispose it when the parent is removed. panelGap is 16 logical pixels by default.',
        ],
        api: [
          DocApiEntry(
            name: 'tabs',
            type: 'List<NibTab>',
            defaultValue: 'required nonempty',
            description: 'Each tab has a label and lazy panel builder.',
          ),
          DocApiEntry(
            name: 'controller',
            type: 'NibTabsController?',
            defaultValue: 'null',
            description:
                'External selection owner; otherwise internally owned.',
          ),
          DocApiEntry(
            name: 'panelGap',
            type: 'double',
            defaultValue: '16',
            description:
                'Space between panels and before footer in logical pixels.',
          ),
          DocApiEntry(
            name: 'barHeight',
            type: 'double',
            defaultValue: '44',
            description: 'Pinned tab bar height in logical pixels.',
          ),
          DocApiEntry(
            name: 'scrollable',
            type: 'bool',
            defaultValue: 'false',
            description: 'Intrinsic-width horizontal tab strip when true.',
          ),
        ],
      ),
      DocSection(
        id: 'overlays',
        heading: 'Pick a dialog entry point',
        paragraphs: [
          'NibDialog is a placed widget with trigger or NibDialogController. showNibDialog<T> opens one imperatively and returns Future<T?>. A dismissed dialog resolves to null; NibDialogScope.of(context).close(result) supplies a result.',
          'NibCommandPalette can use its platform-aware open shortcut: Command-K on Apple platforms or Control-K elsewhere. Scope command actions to the host and dispose an external palette controller.',
        ],
        api: [
          DocApiEntry(
            name: 'NibDialog.content',
            type: 'Widget',
            defaultValue: 'required',
            description: 'Modal body.',
          ),
          DocApiEntry(
            name: 'NibDialog.barrierDismissible',
            type: 'bool',
            defaultValue: 'true',
            description: 'Allows barrier dismissal.',
          ),
          DocApiEntry(
            name: 'NibDialog.animated',
            type: 'bool',
            defaultValue: 'false',
            description: 'Opt-in overlay transition.',
          ),
          DocApiEntry(
            name: 'showNibDialog<T>(...)',
            type: 'Future<T?>',
            defaultValue: 'null on dismiss',
            description: 'Opens modal content without a placed trigger widget.',
          ),
          DocApiEntry(
            name: 'NibCommandPalette.openShortcut',
            type: 'ShortcutActivator?',
            defaultValue: 'platform shortcut',
            description: 'Opens the palette from the keyboard.',
          ),
        ],
      ),
      DocSection(
        id: 'dialog-result',
        heading: "Wait for a dialog result before changing data",
        paragraphs: [
          "Put this function in your screen’s State and call it from a button. The Builder provides a context inside the dialog’s scope. Using the page context for NibDialogScope.of cannot find that scope. close(true) resolves the returned Future with true; dismissal through Escape, the barrier or the close control resolves with null.",
          "The example only reports a local confirmation. Replace that message with your host operation after you have defined its failure and retry behavior. Check mounted after awaiting the result because the original page may have been removed. Do not dispose a controller you did not create, and do not add an external dialog controller simply to obtain a return value: the imperative function already returns one.",
          "For tabs, return NibTabs from a bounded page region such as Scaffold.body or Expanded. Use its header and footer for surrounding scrollable content. A NibTab.builder builds the panel; it does not select a route. Try a short and long panel and watch the pinned bar. If the page traps scrolling, inspect the outer constraints and scroll ownership before adding another controller.",
        ],
        code: r'''Future<void> confirmArchive() async {
  final confirmed = await showNibDialog<bool>(
    context,
    title: 'Archive this draft?',
    content: Builder(
      builder: (dialogContext) => NibButton(
        label: 'Archive',
        onPressed: () => NibDialogScope.of(dialogContext).close(true),
      ),
    ),
  );
  if (!mounted || confirmed != true) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Archive confirmed locally')),
  );
}''',
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'accessibility',
    title: 'Accessible components',
    summary: 'Keep names, focus, input methods, and reduced motion in the host flow.',
    evidence: 'ComponetsNib/nib_components/lib/src/button/nib_button.dart; ComponetsNib/nib_components/lib/src/input/nib_input.dart; ComponetsNib/nib_components/lib/src/dialog/nib_dialog.dart; ComponetsNib/nib_components/lib/src/command_palette/nib_command_palette.dart',
    sections: [
      DocSection(
        id: 'names',
        heading: 'Give controls a useful name',
        paragraphs: [
          "A visible button label usually supplies its accessible name. An icon-only NibButton requires semanticLabel; tooltip alone does not satisfy that requirement. Use a verb describing the action, such as Add item, rather than describing the icon as Plus. With custom content, give the control a clear name even when the constructor does not require it.",
          "NibInput and NibTextarea expose label, helperText and errorText. A placeholder disappears while typing, so keep a persistent label when the field’s purpose would otherwise be unclear. Put an error beside the field and explain how to correct it. A red outline alone does not tell someone which value is expected.",
        ],
        api: [
          DocApiEntry(
            name: 'NibButton.semanticLabel',
            type: 'String?',
            defaultValue: 'null',
            description:
                'Explicit accessible name for custom or icon-only content.',
          ),
          DocApiEntry(
            name: 'NibButton.tooltip',
            type: 'String?',
            defaultValue: 'null',
            description: 'Short pointer and keyboard hint.',
          ),
          DocApiEntry(
            name: 'NibInput.label',
            type: 'String?',
            defaultValue: 'null',
            description: 'Field label shown with the input.',
          ),
          DocApiEntry(
            name: 'NibDataTable.semanticLabel',
            type: 'String?',
            defaultValue: 'null',
            description: 'Optional name for the data table.',
          ),
        ],
      ),
      DocSection(
        id: 'named-action',
        heading: "Build a named icon action",
        paragraphs: [
          "This widget can replace the icon-only action in a toolbar. The semantic label names the action for assistive technology, while the tooltip gives a short visible hint on hover or long press. The empty callback is a local teaching placeholder; connect it to the same host action that a text button would invoke. If the action is unavailable, pass null so the disabled state matches the missing behavior.",
          "NibButton keeps a minimum 48 logical-pixel hit region even when its visual size is smaller. That makes small-looking controls easier to activate, but the surrounding layout must still leave room. Crowding several controls into overlapping regions defeats the benefit. Keep meaningful spacing, then check the actual layout with a pointer, touch and keyboard.",
        ],
        code: r'''NibButton(
  leadingIcon: const Icon(Icons.add),
  semanticLabel: 'Add item',
  tooltip: 'Add item',
  onPressed: () {},
)''',
      ),
      DocSection(
        id: 'keyboard',
        heading: 'Follow the focus path',
        paragraphs: [
          'NibButton, NibCheckbox, NibSwitch, and NibInput expose focusNode and autofocus. If the host creates a FocusNode, the host disposes it. Confirm tab order when controls enter or leave an overlay.',
          'NibDialog includes a focus trap with Tab wrapping and Escape or barrier dismissal. NibCommandPalette handles Up, Down, Enter, and Escape. Test the full route with a keyboard rather than treating one focused widget as sufficient.',
        ],
      ),
      DocSection(
        id: 'walk-the-task',
        heading: "Test the whole task in order",
        paragraphs: [
          "Start at the first focusable control and press Tab until you have completed the form and reached its result. Check that the focus ring is visible and that Enter or Space activates the intended button. Shift-Tab should let you move backward. Open a dialog, move through its actions, dismiss it with Escape, and verify where focus returns. Correct individual labels do not compensate for a focus path that strands the user.",
          "In the live form demo, submit an empty value, read the error, enter a name and submit again. Repeat with a larger text setting and without a mouse. The error should remain visible near its field, the submit control should stay reachable, and success should have text. For an asynchronous flow, keep progress and failure understandable even if a loading animation is difficult to perceive.",
          "External FocusNode instances belong to the State that creates them. Create them once and dispose them when that state ends. Avoid autofocus on every newly appearing control; it can interrupt typing or move focus away from a pending decision. If you programmatically focus the first invalid field, do it after validation has identified that field and the widget is still mounted.",
          "Finally enable the platform’s reduced-motion preference and inspect the same task. animated defaults to false for many component transitions, but spinners and some gesture-driven effects have separate behavior. Do not use absence of NibMotion widgets as proof that the entire page is motion-free. Test with a real screen reader on the platforms you support; widget semantics checks establish structure, not the complete spoken experience.",
        ],
      ),
      DocSection(
        id: 'motion-and-scale',
        heading: 'Test the result without animation',
        paragraphs: [
          'Many component transitions are opt-in through animated: true; loading indicators still animate while active. Test the component at the platform’s reduced-motion setting and keep state changes understandable when movement is reduced.',
          'Run large-text and screen-reader checks on the actual host screens, especially menus, dialogs, tables, and validation errors. Source-level semantics do not replace a device check.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'platform-limits',
    title: 'Platform and performance notes',
    summary: 'Know which layout and measurement work belongs to the host app.',
    evidence: 'ComponetsNib/nib_components/lib/src/tabs/nib_tabs.dart; ComponetsNib/nib_components/lib/src/data_table/nib_data_table.dart; ComponetsNib/nib_components/lib/src/combobox/nib_combobox.dart; ComponetsNib/nib_components/README.md',
    sections: [
      DocSection(
        id: 'bounded-layout',
        heading: 'Give scrollable controls constraints',
        paragraphs: [
          'NibTabs fills a bounded parent and owns its vertical scroll. Nesting it in an unbounded vertical ListView or SingleChildScrollView can reintroduce stuck scroll behavior. Put page content in its header and footer slots instead.',
          'Test NibDataTable and NibResizablePanels at your actual window and text scales. The package does not choose responsive breakpoints for your application.',
        ],
        api: [
          DocApiEntry(
            name: 'NibTabs.header / footer',
            type: 'Widget?',
            defaultValue: 'null',
            description: 'Content around the pinned bar and active panel in one scroll view.',
          ),
          DocApiEntry(
            name: 'NibDataTable.stickyHeader',
            type: 'bool',
            defaultValue: 'true',
            description: 'Pinned column header within the table layout.',
          ),
          DocApiEntry(
            name: 'NibCombobox.debounceDuration',
            type: 'Duration',
            defaultValue: '300 ms',
            description:
                'Wait before loading async options after a query change.',
          ),
        ],
      ),
      DocSection(
        id: 'layout-recipe',
        heading: "Give a scrolling section a measurable height",
        paragraphs: [
          "Flutter parents give constraints to children, and children choose a size inside them. A vertical scroll view permits its contents to be taller than the viewport. NibTabs also owns a viewport, so putting it directly inside that unconstrained content leaves it without a finite height to fill. Fix the ownership of scrolling instead of trying progressively larger padding values.",
          "Place the snippet below in a Scaffold body. The SizedBox establishes a 420 logical-pixel viewport for the example. In a full screen, Expanded inside a bounded Column can provide the remaining height instead. Content before and after the tab panels belongs in header and footer so the same vertical scroll handles the whole region. Each NibTab builder should return ordinary content, not another unbounded full-page scroll view.",
          "Resize the window, enlarge text, and scroll from the header through the footer. The bar should pin while the content continues. Then try a long tab label; scrollable: true changes the bar to intrinsic-width items that can scroll horizontally. It does not fix a missing vertical constraint. NibResizablePanels needs finite bounds on both axes for the same basic reason: it divides available space.",
        ],
        code: r'''SizedBox(
  height: 420,
  child: NibTabs(
    header: const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Account'),
    ),
    tabs: [
      NibTab(label: 'Profile', builder: (_) => const Text('Profile details')),
      NibTab(label: 'Activity', builder: (_) => const Text('Recent activity')),
    ],
    footer: const Padding(
      padding: EdgeInsets.all(16),
      child: Text('End of account details'),
    ),
  ),
)''',
      ),
      DocSection(
        id: 'workload-budget',
        heading: "Separate data work from paint work",
        paragraphs: [
          "A slow screen can spend time fetching rows, sorting them, building cells, laying out text or drawing effects. Measure those stages separately. Replace remote data with a fixed list first; if the delay remains, the network was not the only cause. Keep expensive formatting out of repeated cell builds when the same values can be prepared once. Use stable record keys so replacing a row does not unnecessarily replace its interactive subtree.",
          "For a searchable remote list, NibCombobox waits 300 milliseconds by default before invoking asyncOptionsLoader after a query change. It guards against stale results, but it does not make your service inexpensive or remove the need to handle service errors. Test rapid query changes, an empty result and a failed request. Decide what the host should display and whether a retry is appropriate.",
          "The button, form and theme demos are deliberately small. They are useful for understanding behavior, not for predicting a large table’s frame time. Profile representative row counts and overlay combinations in profile or release mode on your target hardware. Include repeated opening, closing and route disposal when checking retained memory. Record the device, build mode and data size with a result so a later comparison measures the same workload.",
        ],
      ),
      DocSection(
        id: 'measure',
        heading: 'Measure the real workload',
        paragraphs: [
          'The examples and widget tests show behavior, but they do not give a frame-time guarantee for your row count, shader, or target GPU. Profile large tables, open overlays, and theme changes in the mode and device you intend to ship.',
          'When animated rows are enabled, stable rowKey values matter: the default ValueKey(row) relies on stable equality or identity across rebuilds.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'troubleshooting',
    title: 'Troubleshooting and migration',
    summary: 'Fix common state, validation, and layout mistakes.',
    evidence: 'ComponetsNib/nib_components/lib/src/input/nib_input.dart; ComponetsNib/nib_components/lib/src/select/nib_select.dart; ComponetsNib/nib_components/lib/src/tabs/nib_tabs.dart; ComponetsNib/nib_components/lib/src/data_table/nib_data_table.dart',
    sections: [
      DocSection(
        id: 'input',
        heading: 'A field does not update or validate',
        paragraphs: [
          'Do not pass controller and initialValue together to NibInput or NibTextarea. When you supply a controller, update or inspect that controller; when you do not, the widget owns it.',
          'Form.validate triggers the field validator even if autovalidateMode is disabled. A non-null errorText forces an error above validator output, so clear it after a successful server response.',
        ],
      ),
      DocSection(
        id: 'choices',
        heading: 'A choice snaps back',
        paragraphs: [
          "If a checkbox or switch snaps back, check whether its callback assigns the proposed value and rebuilds the widget. A non-null callback can run while value remains unchanged. Use the repair below to see the full loop. For NibSelect, do not apply this rule blindly: it keeps selection in its controller, value and values seed internal state, and an external controller takes precedence.",
          "NibSelect requires exactly one option source, options or groups. In multi-select mode, use onSelectionChanged for the complete List<T>. NibDataTable has a separate ownership switch: adding onSort asks your host to supply sorted rows. Without it the table sorts locally. A callback that only logs the request will not reorder server-owned data.",
        ],
      ),
      DocSection(
        id: 'repair-state',
        heading: "Repair the value-to-callback loop first",
        paragraphs: [
          "Put enabled on your State class and this switch in build. Tap it and verify both the switch and the text change. Temporarily remove setState from the callback: the variable changes, but the widget tree keeps its previous configuration until another rebuild. Restore setState. This small experiment distinguishes a callback problem from a rendering or theme problem.",
          "When a text field loses its draft, look for a new TextEditingController, a changing key, or a replacement form key created inside build. A rebuild should reuse the owner’s controller. A reset should be a deliberate action, such as FormState.reset or assigning controller.text. Do not use a key change to force a label update; that replaces widget state and can also discard focus.",
        ],
        code: r'''// On State:
bool enabled = false;

// In build:
Column(mainAxisSize: MainAxisSize.min, children: [
  NibSwitch(
    value: enabled,
    onChanged: (next) => setState(() => enabled = next),
  ),
  Text(enabled ? 'Notifications on' : 'Notifications off'),
])''',
      ),
      DocSection(
        id: 'diagnose-in-order',
        heading: "Reduce a failing screen to one interaction",
        paragraphs: [
          "Start with the first error in the console. An assertion about controller and initialValue means two owners were supplied; choose one before changing validation. An options/groups assertion means the select has zero or two sources; provide one. A layout error about unbounded height means a viewport cannot determine its size; place it in a finite region and remove competing vertical scroll owners. Later errors can be consequences of the first failure.",
          "For an overlay that opens but will not close from its content, check the BuildContext used to find its scope. The page context exists above the newly inserted dialog. Wrap dialog content in Builder and use its inner context for NibDialogScope.of. For a result that never updates the page, check the awaited result and mounted before calling setState. Barrier dismissal normally produces null; it is not the same as a confirmed action.",
          "Migrate one working interaction at a time. Keep the same host values, validation and save method while swapping the visual control. Verify typing, focus, submit, cancellation and failed submission before adding optional motion. The form demo gives a small reference flow; the theme demo helps isolate inherited colors from state. If a problem appears only with custom colors, remove instance overrides and test the built-in palette.",
          "For a useful bug report, include a small runnable widget, package versions, platform, viewport size, text scale, the action sequence and the first exception. Avoid copying private form values or a full production response. A reproduction that begins in a known state and ends with a specific incorrect result is much easier to verify than a screenshot of the final screen alone.",
        ],
      ),
      DocSection(
        id: 'migration',
        heading: 'Move one screen at a time',
        paragraphs: [
          'Replace a Flutter control with the corresponding Nib widget while leaving its state owner in place. Start with the public barrel import, confirm the callback and nullable value behavior, then register NibTheme if the default palette is not right for the screen.',
          'If tabs trap the page scroll, remove the outer vertical scroll and move surrounding content into NibTabs.header and footer. Dispose any external controllers or focus nodes that the old screen created.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'getting-started',
    title: 'Explore the local fixture',
    summary: 'Run a known A2UI subset through the core and Flutter renderer.',
    evidence: 'GenUINib/packages/nib_genui/README.md; GenUINib/packages/nib_genui_core/test/fixtures/spec-basic.jsonl; GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart',
    sections: [
      DocSection(
        id: 'status',
        heading: 'Use the local source',
        paragraphs: [
          'The three nib_genui 0.0.1 packages are local release candidates with publication disabled. The website fixture is scripted; it does not connect to an agent or a production backend. Do not copy an install command for a package that is not hosted.',
          'The path below runs a known surface through a pure Dart runtime and a Flutter renderer. Keep one runtime per session owner and dispose it when that owner ends.',
        ],
      ),
      DocSection(
        id: 'local-dependencies',
        heading: "Prepare a local Flutter consumer",
        paragraphs: [
          "Begin with an app that already runs and a local checkout containing all three NibGenUI packages. They are unpublished 0.0.1 packages, so a hosted install command cannot reproduce this setup. The renderer currently also uses staged Nib package constraints. The paths below assume your app folder sits alongside GenUINib, MotionNib and ComponetsNib; adjust them to your actual checkout.",
          "Put these entries in the app’s pubspec.yaml, merge them with its existing Flutter dependency, and run flutter pub get. The root app’s dependency_overrides selects the local core, motion and component packages. Overrides in a dependency’s own pubspec do not configure your consumer. This local resolution lets you explore the candidate APIs; it does not establish that a clean hosted install works.",
        ],
        code: r'''dependencies:
  flutter:
    sdk: flutter
  nib_genui:
    path: ../GenUINib/packages/nib_genui

dependency_overrides:
  nib_genui_core:
    path: ../GenUINib/packages/nib_genui_core
  nib_motion:
    path: ../MotionNib/motion
  nib_components:
    path: ../ComponetsNib/nib_components''',
      ),
      DocSection(
        id: 'runtime',
        heading: 'Create a bounded runtime',
        paragraphs: [
          "Create the runtime once when the host screen starts. It holds validated surface snapshots, data bindings and registered capabilities. NibCatalog.basic() describes four supported components: Text, Column, Button and TextField. The Flutter renderer supplies their builders. A catalog describes which data is legal; a builder turns accepted data into widgets.",
          "The complete example below creates a surface, adds a root Column with one Text child, and provides the bound title. Each operation returns a result. Stopping on a rejected result during fixture development makes the first mistake visible rather than letting later errors obscure it. In a streaming host, keep the last valid surface and show recoverable feedback instead of throwing away the whole session.",
        ],
        code: r'''import 'package:flutter/material.dart';
import 'package:nib_genui/nib_genui.dart';

void main() => runApp(const MaterialApp(home: FixturePage()));

class FixturePage extends StatefulWidget {
  const FixturePage({super.key});
  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  late final NibRuntime runtime;

  @override
  void initState() {
    super.initState();
    runtime = NibRuntime(
      catalogs: [NibCatalog.basic()],
      maxSurfaces: 1,
      maxNodes: 8,
      maxProtocolMessages: 20,
    );
    final frames = <Map<String, Object?>>[
      {'version': 'v0.9.1', 'createSurface': {
        'surfaceId': 'main', 'catalogId': NibCatalog.basicId,
      }},
      {'version': 'v0.9.1', 'updateComponents': {
        'surfaceId': 'main',
        'components': [
          {'id': 'root', 'component': 'Column', 'children': ['title']},
          {'id': 'title', 'component': 'Text', 'text': {'path': '/title'}},
        ],
      }},
      {'version': 'v0.9.1', 'updateDataModel': {
        'surfaceId': 'main', 'path': '/', 'value': {'title': 'Hello from Nib'},
      }},
    ];
    for (final frame in frames) {
      final result = runtime.apply(frame);
      if (!result.accepted) {
        throw StateError(result.diagnostics.first.code);
      }
    }
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: NibGeneratedSurface(runtime: runtime, surfaceId: 'main'),
    ),
  );
}''',
        api: [
          DocApiEntry(
            name: 'catalogs',
            type: 'Iterable<NibCatalog>',
            defaultValue: 'required',
            description: 'Exact catalog IDs accepted by the runtime.',
          ),
          DocApiEntry(
            name: 'actions',
            type: 'Map<String, NibActionHandler>',
            defaultValue: '{}',
            description: 'Host-owned event handlers; generated data cannot create callbacks.',
          ),
          DocApiEntry(
            name: 'actionContextPaths',
            type: 'Map<String, Map<String, String>>',
            defaultValue: '{}',
            description:
                'Allowed context key and JSON Pointer pairs per action.',
          ),
          DocApiEntry(
            name: 'dispose()',
            type: 'void',
            defaultValue: 'host call',
            description:
                'Releases retained surfaces and closes runtime streams.',
          ),
        ],
      ),
      DocSection(
        id: 'render',
        heading: 'Render only a committed surface',
        paragraphs: [
          'Apply component and data frames after createSurface. Inspect NibApplyResult.accepted and diagnostics on every frame. A rejected frame leaves the prior committed surface in place.',
          'Place NibGeneratedSurface in the widget tree with the same runtime and surfaceId. It subscribes to node changes and cancels its own subscription on disposal. The host still owns the runtime.',
        ],
        code: '''NibGeneratedSurface(
  runtime: runtime,
  surfaceId: 'main',
)''',
      ),
      DocSection(
        id: 'progressive-experiment',
        heading: "Replay before adding a transport",
        paragraphs: [
          "Copy the complete example into lib/main.dart. It uses no network and should display Hello from Nib. The website fixture is a larger version: press Next frame three times to create a surface, define a form, and populate its data. The form can exist before its bound data arrives. Press Say hello with an empty name to see the host guard reject it; type a name and press again to get local feedback.",
          "Replay fixture creates a fresh runtime because the demo deliberately budgets exactly three protocol messages. It also resets the message and the frame counter. A real screen should make the same ownership explicit: the renderer subscribes to the runtime but does not dispose that shared runtime for you. Dispose it when the session owner ends, after stopping any transport that could send more updates.",
          "Next change only the title data frame and leave the component definition unchanged. The binding updates the displayed text. Then change the binding path without supplying matching data and observe the unresolved state. Once these local transitions are predictable, study the protocol and binding guides before adding HTTP. No AI provider or production backend is needed to understand the client contract.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'protocol-scope',
    title: 'Protocol scope',
    summary: 'Separate the four wire envelopes from the four built-in widgets.',
    evidence: 'GenUINib/docs/PROTOCOL_COMPATIBILITY.md; GenUINib/packages/nib_genui_core/lib/src/a2ui_v091_adapter.dart; GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart',
    sections: [
      DocSection(
        id: 'envelopes',
        heading: 'Four v0.9.1 envelopes',
        paragraphs: [
          'The adapter accepts version: v0.9.1 with exactly one createSurface, updateComponents, updateDataModel, or deleteSurface body. Unknown envelope fields or versions are rejected. This is a tested subset of A2UI v0.9.1, not full conformance or v0.9/v1 compatibility.',
          'createSurface chooses an exact catalog ID. updateComponents adds or replaces IDs in one surface; it does not erase all old definitions. deleteSurface permits later reuse of an ID, but old packets after reuse cannot be identified because this protocol slice has no sequence number.',
        ],
        api: [
          DocApiEntry(
            name: 'createSurface',
            type: 'A2UI envelope',
            defaultValue: '—',
            description: 'Creates one surface with an exact catalog ID.',
          ),
          DocApiEntry(
            name: 'updateComponents',
            type: 'A2UI envelope',
            defaultValue: '—',
            description: 'Upserts node IDs; existing definitions not named in the frame remain.',
          ),
          DocApiEntry(
            name: 'updateDataModel',
            type: 'A2UI envelope',
            defaultValue: '—',
            description: 'Writes or removes a value at a JSON Pointer.',
          ),
          DocApiEntry(
            name: 'deleteSurface',
            type: 'A2UI envelope',
            defaultValue: '—',
            description: 'Clears the surface, nodes, and data model.',
          ),
        ],
      ),
      DocSection(
        id: 'read-a-frame',
        heading: "Read an envelope from outside to inside",
        paragraphs: [
          "Use this guide after replaying the local fixture. The outer version identifies the wire format. One envelope key identifies the operation. surfaceId selects the runtime surface, and the operation body contains only fields supported for that operation. A JSON object can be syntactically valid while its version, catalog, component or property is invalid for this runtime.",
          "The frame below changes the title in an already-created main surface. It does not define a Text widget. A previously accepted Text with text bound to /title reads the new string. Send the same frame before createSurface and it is rejected because there is no surface to update. This separation lets structure arrive once and data change repeatedly without retransmitting the whole tree.",
        ],
        code: r'''{
  "version": "v0.9.1",
  "updateDataModel": {
    "surfaceId": "main",
    "path": "/title",
    "value": "Your draft is ready"
  }
}''',
      ),
      DocSection(
        id: 'catalog',
        heading: 'Four Basic Catalog components',
        paragraphs: [
          'NibCatalog.basic() includes Text(text, optional variant), Column(static children IDs), Button(child ID and event action), and TextField(label, optional value and variant). A host can register its own schema and matching trusted Flutter builders; a schema alone does not render a widget.',
          'Forward child references and temporarily missing bound data are legal during incremental construction. The renderer shows a safe placeholder for a missing child. An unknown component, wrong property type, cycle, or shared child is rejected.',
        ],
        api: [
          DocApiEntry(
            name: 'Text',
            type: 'component',
            defaultValue: 'text required',
            description: 'Plain text; variant values are restricted by the Basic schema.',
          ),
          DocApiEntry(
            name: 'Column',
            type: 'component',
            defaultValue: 'children required',
            description: 'Static array of child IDs.',
          ),
          DocApiEntry(
            name: 'Button',
            type: 'component',
            defaultValue: 'child and action required',
            description: 'Registered event action with one child ID.',
          ),
          DocApiEntry(
            name: 'TextField',
            type: 'component',
            defaultValue: 'label required',
            description:
                'Local bound editing when value points to a data path.',
          ),
        ],
      ),
      DocSection(
        id: 'stream-order',
        heading: "Distinguish a missing reference from an invalid tree",
        paragraphs: [
          "A Column may list a child ID before that child’s definition arrives. The renderer shows a placeholder while waiting; a later updateComponents frame can supply the missing definition. Try this by splitting the fixture’s component frame into a root-only frame and a child-definition frame. Increase the fixture’s message budget when adding frames, or its limit will correctly reject your extra operation.",
          "A cycle is different: if a child eventually points back to its ancestor, the completed graph is invalid. This subset also requires one parent per child ID, so two Columns cannot share the same child definition as a reusable subtree. Give each visual instance its own ID. Keeping stable IDs for the same instance helps preserve field state and avoids unnecessary structural replacements.",
          "updateComponents upserts listed IDs. Omitting an old node from the next frame does not delete it. To remove it from view, update the parent’s children or child reference. Detached definitions remain in storage and can be attached later. Deleting the whole surface clears both definitions and data. This is why removing a visible branch and freeing all of its storage are separate operations.",
          "Keep protocol version, catalog ID and Dart package version separate in saved fixtures. The package being 0.0.1 does not change the frame’s v0.9.1 string. A custom catalog name does not grant support for every Basic component. The four accepted envelopes and four built-in components form a useful tested slice; the excluded fields below remain rejected even if another A2UI implementation supports them.",
        ],
      ),
      DocSection(
        id: 'excluded',
        heading: 'Know the excluded wire features',
        paragraphs: [
          'This catalog does not include resource widgets or URL loading. createSurface.theme, sendDataModel, dynamic child templates, protocol checks, functionCall actions, and Basic Catalog components beyond the four above are outside the supported slice.',
          'A root data replacement currently requires a JSON object, although the upstream envelope allows any JSON value. An omitted updateDataModel value removes a map key; an explicit null stores null. Array removal leaves a null slot because JSON has no undefined value.',
        ],
        note: 'Supported here: four envelopes and four Basic components. Broader protocol and resource features need separate implementation and compatibility tests.',
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'runtime',
    title: 'Runtime and state',
    summary: 'Apply atomic mutations, observe affected nodes, and end a session cleanly.',
    evidence: 'GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart; GenUINib/packages/nib_genui_core/lib/src/mutations.dart; GenUINib/packages/nib_genui_core/README.md',
    sections: [
      DocSection(
        id: 'commits',
        heading: 'Validate before commit',
        paragraphs: [
          'NibRuntime.applyJson parses a frame; apply takes a decoded envelope; applyMutation takes typed Nib mutations. Each route validates before replacing a surface. Check accepted and diagnostics. On rejection, the last committed surface remains available.',
          'NibSurface holds an ID map of NibNode definitions and a data model. root is the root node ID. A child can arrive in a later frame, so a temporary absent definition is not automatically a bad update.',
        ],
        code: '''final result = runtime.applyJson(frame);
if (!result.accepted) {
  for (final diagnostic in result.diagnostics) {
    print(diagnostic.code);
  }
}
final surface = runtime.surface('main');''',
        api: [
          DocApiEntry(
            name: 'applyJson(json)',
            type: 'NibApplyResult',
            defaultValue: '—',
            description:
                'Parses and applies one complete versioned JSON envelope.',
          ),
          DocApiEntry(
            name: 'apply(message)',
            type: 'NibApplyResult',
            defaultValue: '—',
            description: 'Applies one decoded envelope.',
          ),
          DocApiEntry(
            name: 'applyMutation(mutation)',
            type: 'NibApplyResult',
            defaultValue: '—',
            description: 'Applies a typed local mutation through the same validation path.',
          ),
          DocApiEntry(
            name: 'surface(id)',
            type: 'NibSurface?',
            defaultValue: 'null if absent',
            description: 'Reads the most recent committed immutable snapshot.',
          ),
        ],
      ),
      DocSection(
        id: 'snapshot-flow',
        heading: "Read a snapshot without owning a second model",
        paragraphs: [
          "The runtime is the state owner for a generated surface. A frame is parsed, checked against its catalog and limits, and applied to a candidate state. Only a valid candidate replaces the committed snapshot. Your renderer reads that snapshot. Avoid keeping a second mutable copy of the same data in widget State unless you have a specific draft or conflict policy; two owners make it unclear which value an action should use.",
          "After the getting-started fixture has created main and bound title to /title, run the function below from a local button callback. writeData uses the same value validation path as protocol data updates but needs no wire envelope. resolve reads through a NibValue such as NibBinding. The accepted write is visible immediately; it does not wait for a transport or a model response.",
        ],
        code: r'''void changeTitle(NibRuntime runtime) {
  final result = runtime.writeData('main', '/title', 'Edited locally');
  if (!result.accepted) {
    for (final diagnostic in result.diagnostics) {
      debugPrint(diagnostic.code);
    }
    return;
  }
  final title = runtime.resolve('main', const NibBinding('/title'));
  debugPrint(title is String ? 'Title updated' : 'Title unresolved');
}''',
      ),
      DocSection(
        id: 'change-streams',
        heading: 'Observe only what changed',
        paragraphs: [
          'nodeChanges reports affected node IDs for each accepted mutation. watchNode(surfaceId, nodeId) filters that stream for a widget; cancel the subscription when its owner leaves. actionDecisions reports dispatch outcomes without event context or data values.',
          'Detached node definitions stay available for later references. After a complete update, compactSurface removes definitions unreachable from root. Do not compact while prefetched children still need to be attached.',
        ],
        api: [
          DocApiEntry(
            name: 'nodeChanges',
            type: 'Stream<NibNodeChange>',
            defaultValue: 'broadcast stream',
            description: 'Affected node IDs and lifecycle flag.',
          ),
          DocApiEntry(
            name: 'watchNode(surfaceId, nodeId)',
            type: 'Stream<NibNodeChange>',
            defaultValue: 'filtered stream',
            description:
                'Updates for one rendered node; caller cancels subscription.',
          ),
          DocApiEntry(
            name: 'compactSurface(id)',
            type: 'NibApplyResult',
            defaultValue: 'host call',
            description: 'Drops detached definitions once root reachability is complete.',
          ),
          DocApiEntry(
            name: 'actionDecisions',
            type: 'Stream<NibActionDecision>',
            defaultValue: 'broadcast stream',
            description:
                'Action acceptance or rejection without context values.',
          ),
        ],
      ),
      DocSection(
        id: 'rollback-and-retention',
        heading: "Test rollback and retained definitions",
        paragraphs: [
          "Now try writing the number 42 to /title while a Text expects a string there. The result should be rejected and the last valid title should remain visible. Treat this as recoverable input failure: record the diagnostic code, ask the sender for a corrected frame, or stop the session if your policy requires it. Clearing the entire runtime would throw away valid content and make diagnosis harder.",
          "For subscriptions, use nodeChanges when several nodes matter, or watchNode when one view depends on a single node. The event identifies affected nodes; read their current values from the runtime. NibGeneratedSurface already manages its own subscriptions, so a normal host does not need to rebuild the entire page for every data change. Any extra subscription you create still needs cancellation when its owner ends.",
          "Node limits include detached definitions. If a session repeatedly replaces children, its visible tree may stay small while its retained node map grows. After the sender finishes attaching all prefetched definitions, compactSurface removes nodes unreachable from root. Calling it too early can remove data the next frame intended to reference; calling it before root exists returns root_missing.",
          "Protocol attempt limits belong to the runtime lifetime. Replacing an adapter during reconnect does not reset maxProtocolMessages, and rejected envelopes spend that budget too. Use a fresh runtime for a genuinely new session, not as an automatic way to evade an exhausted session budget. During shutdown, cancel incoming work, detach the view and dispose the runtime so late updates cannot target a closed owner.",
        ],
      ),
      DocSection(
        id: 'limits',
        heading: 'Keep the session bounded',
        paragraphs: [
          'Defaults are 64 KiB per message and retained data model, 256 nodes per surface, 16 live surfaces, depth 32, and 8192 characters per string. maxProtocolMessages allows 4096 protocol attempts over the runtime lifetime, including rejected frames; local writes and dispatches do not spend that budget.',
          'A new runtime starts a new budget. The host must still limit session duration, reconnections, and invalid physical frames across adapters. Dispose the runtime after cancelling its transport and removing the renderer.',
        ],
        api: [
          DocApiEntry(
            name: 'maxMessageBytes / maxDataModelBytes',
            type: 'int',
            defaultValue: '65536 each',
            description: 'Per-envelope bytes and retained data-model bytes.',
          ),
          DocApiEntry(
            name: 'maxNodes / maxSurfaces',
            type: 'int',
            defaultValue: '256 / 16',
            description: 'Node capacity per surface and total live surfaces.',
          ),
          DocApiEntry(
            name: 'maxDepth / maxStringLength',
            type: 'int',
            defaultValue: '32 / 8192',
            description: 'Nested value depth and string character limit.',
          ),
          DocApiEntry(
            name: 'maxProtocolMessages',
            type: 'int',
            defaultValue: '4096',
            description:
                'Lifetime envelope attempts, including rejected messages.',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'api',
    title: 'API reference',
    summary: 'Pick the core, Flutter renderer, or optional HTTP adapter deliberately.',
    evidence: 'GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart; GenUINib/packages/nib_genui/lib/nib_genui.dart; GenUINib/packages/nib_genui_http/lib/nib_genui_http.dart',
    sections: [
      DocSection(
        id: 'layer-choice',
        heading: "Choose the smallest layer that solves the task",
        paragraphs: [
          "Use nib_genui_core when you need to validate or replay data without Flutter. Add nib_genui when the accepted surface should become native widgets. Add nib_genui_http only when an existing host endpoint will deliver JSONL or receive approved action envelopes. Each layer has a separate owner: the runtime owns surface state, the renderer owns widget subscriptions, and your host owns the HTTP client and session.",
          "The custom Badge example below is an advanced extension, after the Basic fixture works. Give the custom catalog its own ID, create the surface with that same ID, then send Badge with a label. Register both the schema and the builder. A schema-only Badge is valid data but has no custom visual implementation; a builder-only Badge is rejected before rendering because the catalog never permitted it.",
          "The upper callback is a registered string function. The schema specifies its argument names and types, while functions supplies trusted executable code. A wire value can request that known function but cannot define new Dart. Keep callbacks deterministic and free of I/O: resolving a label may happen repeatedly, and a formatting operation must not trigger a payment, fetch or mutation.",
        ],
      ),
      DocSection(
        id: 'core',
        heading: 'Core: data and policy',
        paragraphs: [
          'nib_genui_core is pure Dart. NibCatalog defines allowed component and function schemas. NibRuntime validates envelopes, owns surfaces and bindings, and decides whether a registered action may dispatch. NibA2uiV091Adapter and NibJsonlAdapter sit at the untrusted input boundary.',
          'Use allowedSurfaceIds on adapters when a stream should control only particular surfaces. Calling runtime.applyJson directly does not add stream ownership policy for you.',
          'Local string computation also needs two registrations: a NibFunctionSchema in the catalog and a same-named pure callback in NibRuntime.functions. A dynamic-string field may request {"call":"upper","args":{"value":{"path":"/name"}},"returnType":"string"}; the wire cannot define the function itself.',
        ],
        code: '''final catalog = NibCatalog(
  'https://example.test/catalog/v1',
  [
    NibComponentSchema('Badge', {
      'label': const NibPropertySchema(
        NibPropertyKind.dynamicString,
        required: true,
      ),
    }),
  ],
  functions: [
    NibFunctionSchema('upper', {
      'value': NibFunctionArgumentKind.string,
    }),
  ],
);
final runtime = NibRuntime(
  catalogs: [catalog],
  functions: {
    'upper': (args) => (args['value'] as String).toUpperCase(),
  },
);''',
        api: [
          DocApiEntry(
            name: 'NibCatalog.basic()',
            type: 'NibCatalog',
            defaultValue: 'four components',
            description: 'Registered Basic subset with its exact catalog ID.',
          ),
          DocApiEntry(
            name: 'NibA2uiV091Adapter(..., allowedSurfaceIds: ...)',
            type: 'adapter',
            defaultValue: 'null',
            description:
                'Envelope parser with optional surface ownership allowlist.',
          ),
          DocApiEntry(
            name: 'NibJsonlAdapter.maxFrames',
            type: 'int',
            defaultValue: '1024',
            description: 'Physical JSONL lines per adapter, including blank or malformed lines.',
          ),
          DocApiEntry(
            name: 'NibRuntime.resolve(surfaceId, value)',
            type: 'Object?',
            defaultValue: 'null if unresolved',
            description:
                'Resolves literal, binding, or registered string function.',
          ),
        ],
      ),
      DocSection(
        id: 'renderer',
        heading: 'Renderer: trusted Flutter builders',
        paragraphs: [
          'nib_genui exports the core API and adds NibGeneratedSurface. It uses Nib components for controls and NibMotion for structural changes. The host may register a map of NibComponentBuilder callbacks, but untrusted JSON cannot provide Dart builders.',
          'A schema without a renderer builder shows an unsupported-component fallback. The host owns the runtime; the widget owns its node subscription. The surrounding Theme and Directionality apply to the rendered controls.',
        ],
        code: '''NibGeneratedSurface(
  runtime: runtime,
  surfaceId: 'main',
  builders: {
    'Badge': (context, node, runtime, surfaceId) {
      final value = runtime.resolve(
        surfaceId,
        node.properties['label']!,
      );
      return Text(value as String? ?? '');
    },
  },
)''',
        api: [
          DocApiEntry(
            name: 'runtime / surfaceId',
            type: 'NibRuntime / String',
            defaultValue: 'required',
            description: 'Runtime and surface selected for rendering.',
          ),
          DocApiEntry(
            name: 'motionEnabled',
            type: 'bool',
            defaultValue: 'true',
            description:
                'Allows structural motion unless reduced motion is active.',
          ),
          DocApiEntry(
            name: 'builders',
            type: 'Map<String, NibComponentBuilder>',
            defaultValue: '{}',
            description:
                'Host-registered renderers for custom catalog components.',
          ),
          DocApiEntry(
            name: 'labels',
            type: 'NibGeneratedSurfaceLabels',
            defaultValue: 'English fallbacks',
            description: 'Localized empty, loading, error, tree, component, action, and field text.',
          ),
          DocApiEntry(
            name: 'error',
            type: 'NibDiagnostic?',
            defaultValue: 'null',
            description: 'Initial error label when no valid surface exists.',
          ),
        ],
      ),
      DocSection(
        id: 'http',
        heading: 'HTTP: optional transport',
        paragraphs: [
          'nib_genui_http adds NibHttpTransport. The host supplies an http.Client, endpoint, headers, surface allowlist, and reconnect policy. connect consumes JSONL; sendAction posts one approved action envelope. It does not choose a backend or authorize an account.',
          'A successful action POST only means the endpoint returned a 2xx status. It is not a business-operation receipt. Handle failure and duplicate delivery in the host and backend.',
        ],
        code: '''import 'package:http/http.dart' as http;
import 'package:nib_genui_core/nib_genui_core.dart';
import 'package:nib_genui_http/nib_genui_http.dart';

Future<void> readUi(Uri endpoint, NibRuntime runtime) async {
  final client = http.Client();
  final transport = NibHttpTransport(client: client, runtime: runtime);
  try {
    await for (final result in transport.connect(
      endpoint,
      allowedSurfaceIds: {'main'},
    )) {
      if (!result.accepted) {
        for (final diagnostic in result.diagnostics) {
          print(diagnostic.code);
        }
      }
    }
  } finally {
    client.close();
  }
}''',
        api: [
          DocApiEntry(
            name: 'connect(endpoint, allowedSurfaceIds: ...)',
            type: 'Stream<NibApplyResult>',
            defaultValue: 'surface IDs required',
            description: 'GET JSONL stream into one runtime.',
          ),
          DocApiEntry(
            name: 'sendAction(endpoint, event)',
            type: 'Future<void>',
            defaultValue: 'host call',
            description: 'POST a versioned action envelope after local policy.',
          ),
          DocApiEntry(
            name: 'maxStreamBytes / maxFrames',
            type: 'int',
            defaultValue: '8 MiB / 1024',
            description: 'Per-connection byte and frame ceilings.',
          ),
        ],
      ),
      DocSection(
        id: 'transport-lifetime',
        heading: "Give a stream an explicit owner",
        paragraphs: [
          "The readUi function is a finite-stream example. Supply a real endpoint that your host already controls and a runtime whose allowed surface is main. connect performs GET and yields one NibApplyResult per processed frame. A malformed frame can produce a rejected result; connection failures are stream errors. Handle both paths. The allowedSurfaceIds set limits which surface this connection may mutate; it does not authenticate the caller or endpoint.",
          "For an interactive page that can close before the response ends, keep the StreamSubscription and cancel it when leaving. Cancellation aborts the request. Close the client only if that owner created it, and stop the stream before disposing the runtime. If several sessions share a client, one session must not close the client while the others still use it.",
          "The runtime action handler type is synchronous void. If it starts sendAction, catch that Future’s errors in host code and update a separate busy/result state. An accepted dispatch means local policy permitted the handler; it does not mean an asynchronous server operation succeeded. Start transport integration with a bounded fixture endpoint, verify cancellation and failures, then add authentication and your application’s action contract.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'bindings-and-forms',
    title: 'Bindings and forms',
    summary: 'Edit bound text locally and decide how remote updates resolve conflicts.',
    evidence: 'GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart; GenUINib/packages/nib_genui/lib/nib_genui.dart; GenUINib/packages/nib_genui/README.md',
    sections: [
      DocSection(
        id: 'bind',
        heading: 'Bind to a JSON Pointer',
        paragraphs: [
          'A dynamic string may be a literal or a path binding such as /user/name. A missing path resolves as null while a progressive surface is being built. A present value with the wrong type is rejected. TextField.value must be a binding for local editing; a literal value is read-only in this slice.',
          'The runtime keeps the surface data model. writeData validates a local value and commits it before the user sees a transport response. The renderer uses NibInput or NibTextarea and writes through the bound path on each edit.',
        ],
        code: '''final result = runtime.writeData('main', '/user/name', 'Ada');
if (!result.accepted) {
  for (final diagnostic in result.diagnostics) {
    print(diagnostic.code);
  }
}''',
        api: [
          DocApiEntry(
            name: 'NibBinding(path)',
            type: 'NibValue',
            defaultValue: '—',
            description: 'Points to a surface-local JSON Pointer.',
          ),
          DocApiEntry(
            name: 'writeData(surfaceId, path, value)',
            type: 'NibApplyResult',
            defaultValue: '—',
            description: 'Validates and commits a local data change without a protocol envelope.',
          ),
          DocApiEntry(
            name: 'resolve(surfaceId, value)',
            type: 'Object?',
            defaultValue: 'null if missing',
            description:
                'Reads a literal, binding, or registered function result.',
          ),
        ],
      ),
      DocSection(
        id: 'editable-field',
        heading: "Build a field that writes to one data path",
        paragraphs: [
          "First create main with the Basic catalog. The component frame below adds a root Column, a field and a preview Text. Both field and preview refer to /user/name. After applying it, seed that path with runtime.writeData. Typing in the field should update the preview without a request, because both widgets resolve the same surface-local value.",
          "A literal value such as \"Ada\" displays text but is read-only in this renderer. The object {\"path\":\"/user/name\"} makes the field editable. The path is a JSON Pointer, not Dart property syntax: use slash-separated segments rather than user.name. Missing map parents can be created by a write; an existing scalar or null parent cannot become a map implicitly, so that write is rejected.",
        ],
        code: r'''runtime.apply({
  'version': 'v0.9.1',
  'updateComponents': {
    'surfaceId': 'main',
    'components': [
      {'id': 'root', 'component': 'Column', 'children': ['name', 'preview']},
      {'id': 'name', 'component': 'TextField', 'label': 'Your name',
       'value': {'path': '/user/name'}},
      {'id': 'preview', 'component': 'Text',
       'text': {'path': '/user/name'}},
    ],
  },
});
final seeded = runtime.writeData('main', '/user/name', 'Ada');
if (!seeded.accepted) debugPrint(seeded.diagnostics.first.code);''',
      ),
      DocSection(
        id: 'conflict',
        heading: 'Choose a remote edit policy',
        paragraphs: [
          'Local typing does not wait for an agent. If a later committed remote frame writes the same path, the remote value takes precedence. The renderer retains the active selection where possible and clamps it when the replacement text is shorter.',
          'For a form that must keep the user’s draft uninterrupted, the host should avoid sending conflicting remote values while that field is active. This is a host policy decision, not an automatic merge.',
        ],
      ),
      DocSection(
        id: 'validation',
        heading: 'Gate form actions in the host',
        paragraphs: [
          'The supported TextField wire schema has label, optional value, and variant. It does not support A2UI checks or validationRegexp. The host must validate a consequential form before dispatch and validate again in the backend.',
          'An optional NibRuntime.actionGuards entry can reject an action using its allowed context. A registered action without a guard can dispatch; do not treat the guard as implicit.',
        ],
        api: [
          DocApiEntry(
            name: 'TextField.variant',
            type: 'String?',
            defaultValue: 'shortText behavior',
            description:
                'Accepted values: longText, number, shortText, obscured.',
          ),
          DocApiEntry(
            name: 'actionGuards',
            type: 'Map<String, NibActionGuard>',
            defaultValue: '{}',
            description: 'Optional host validation or permission check before a handler runs.',
          ),
        ],
      ),
      DocSection(
        id: 'edit-experiments',
        heading: "Compare missing data, wrong types and remote replacement",
        paragraphs: [
          "Remove the initial data write and replay. An unresolved binding is a normal temporary state during streaming. Now supply a number at /user/name: the present value conflicts with the dynamic string property, so validation rejects it. Missing and invalid are different outcomes. Do not convert every invalid value to a string in the renderer; that hides a producer contract error and changes what the action receives.",
          "Type a longer name, place the cursor in the middle, then apply a remote data frame with a shorter replacement. The committed remote value wins. The renderer preserves or clamps selection so it stays inside the replacement text; it does not merge two simultaneous edits. If your task needs uninterrupted drafts, coordinate the sender to avoid updating active draft paths, or design distinct draft and server-result paths in the host.",
          "In the live fixture, press Next frame until the form appears, leave Your name empty and press Say hello. The host action guard produces Enter a name first. Type Ada and press again; Hello, Ada is local host feedback. The fixture does not send the name to a service. Replay starts with fresh state, so do not expect that draft to survive a new runtime.",
          "Before using the same pattern for a consequential form, define which fields are required, normalize them deliberately, and validate the permitted action context. TextField’s number variant changes entry behavior but still belongs to the supported dynamic-string contract. It does not turn a string into a trusted numeric amount. Keep parsing and domain checks in the host and repeat authoritative validation in the service that performs the operation.",
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'actions-and-policy',
    title: 'Actions and host policy',
    summary: 'Register capabilities in the host and authorize side effects again on the server.',
    evidence: 'GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart; GenUINib/packages/nib_genui_http/lib/nib_genui_http.dart; GenUINib/docs/THREAT_MODEL.md',
    sections: [
      DocSection(
        id: 'register',
        heading: 'Register an action by name',
        paragraphs: [
          'Button actions use an event name. The runtime resolves that name against the host actions map. The wire cannot carry a callback or executable Dart code. actionContextPaths permits exact context key and data path pairs; an unresolved allowed path blocks dispatch.',
          'Buttons with an unresolved child also cannot dispatch. This prevents a partially built surface from sending an action before its visible label arrives.',
        ],
        code: r'''final runtime = NibRuntime(
  catalogs: [NibCatalog.basic()],
  actions: {
    'submit': (event) {
      final name = event.context['name'];
      if (name is String) debugPrint('Local submit accepted');
    },
  },
  actionContextPaths: {'submit': {'name': '/user/name'}},
  actionGuards: {
    'submit': (event) {
      final name = event.context['name'];
      return name is String && name.trim().isNotEmpty;
    },
  },
);''',
        api: [
          DocApiEntry(
            name: 'actions',
            type: 'Map<String, NibActionHandler>',
            defaultValue: '{}',
            description: 'Host callback allowlist by exact event name.',
          ),
          DocApiEntry(
            name: 'actionContextPaths',
            type: 'Map<String, Map<String, String>>',
            defaultValue: '{}',
            description: 'Permitted context keys and paths per action.',
          ),
          DocApiEntry(
            name: 'actionGuards',
            type: 'Map<String, NibActionGuard>',
            defaultValue: '{}',
            description:
                'Optional check at dispatch time; false blocks the handler.',
          ),
          DocApiEntry(
            name: 'dispatch(surfaceId, nodeId)',
            type: 'NibApplyResult',
            defaultValue: '—',
            description:
                'Validates the current node and context before host callback.',
          ),
        ],
      ),
      DocSection(
        id: 'button-event',
        heading: "Connect one visible button to one host capability",
        paragraphs: [
          "Build the form and data binding before adding an action. The runtime registration above belongs in the session owner’s initialization. Use the array below as updateComponents.components for the same surface and include submit in the root’s children. Button.child names a node, not a caption string. That child must resolve before dispatch so an incomplete button cannot trigger a hidden capability.",
          "Pressing the button resolves its registered event, checks the context bindings and calls the guard. The name key is permitted to read exactly /user/name. A request to read another path under the same key is not equivalent and is rejected. When the name is absent, dispatch reports missing data; when it is an empty string, the guard rejects it. Only a complete permitted event reaches the callback.",
        ],
        code: r'''[
  {
    "id": "submit",
    "component": "Button",
    "child": "submit_label",
    "action": {
      "event": {
        "name": "submit",
        "context": {"name": {"path": "/user/name"}}
      }
    }
  },
  {"id":"submit_label","component":"Text","text":"Say hello"}
]''',
      ),
      DocSection(
        id: 'policy-experiment',
        heading: "Observe rejection before adding side effects",
        paragraphs: [
          "Use the local demo to compare the two outcomes: Say hello rejects an empty name and accepts a nonempty name. The actionDecisions stream tells the host that validation failed without copying the name into the diagnostic. Subscribe once, turn relevant codes into useful feedback, and cancel the subscription with the session. Avoid reporting every streamed update as a new notification.",
          "For a confirmation flow, keep a pending request in host state. After the user confirms, re-read the live surface and current permissions before executing. The surface may have been deleted, its button replaced or the form edited while the dialog was open. A decision based solely on the original snapshot can act on stale data. The package exposes the pieces for these checks; it does not infer which business actions require them.",
          "Suppress repeated activation while one operation is pending and design retry semantics before wiring a network handler. A timeout can occur after a server accepted work, so retrying the same operation may require a server-issued or host-managed idempotency key. The experimental client has no production backend or built-in exactly-once guarantee. A synthetic confirmation demo can verify client transitions only.",
          "Finally distinguish three outcomes in your UI: the runtime allowed dispatch, the HTTP endpoint accepted the request, and the business operation completed. sendAction returns after a 2xx response and does not parse a completion receipt. Preserve an honest pending or failed state until your application protocol provides the result the person actually cares about.",
        ],
      ),
      DocSection(
        id: 'consequential',
        heading: 'Treat confirmation as host state',
        paragraphs: [
          'The package does not infer which actions need confirmation. The host must configure that policy, recheck current permissions and form validity when confirmation is accepted, and cancel a pending confirmation if the surface or component changes.',
          'The backend must authorize the user and tenant, reject stale or repeated requests where necessary, and make consequential operations idempotent. A client-side guard or successful HTTP status does not prove those backend obligations were met.',
        ],
      ),
      DocSection(
        id: 'privacy',
        heading: 'Send the minimum context',
        paragraphs: [
          'NibHttpTransport.sendAction serializes the approved NibActionEvent context rather than the entire surface data model. actionDecisions omits context values. Identifiers and binding paths can still contain private words if the source puts them there, so apply a host logging policy before recording diagnostics.',
          'A fake backend can test request shape and client failure handling. Authorization and idempotency must also be tested against the service that will perform the real operation.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'accessibility',
    title: 'Accessibility and motion',
    summary: 'Use trusted labels and test real input, focus, and reduced-motion behavior.',
    evidence: 'GenUINib/packages/nib_genui/lib/nib_genui.dart; GenUINib/packages/nib_genui/README.md; GenUINib/packages/nib_genui/test/accessibility_test.dart',
    sections: [
      DocSection(
        id: 'labels',
        heading: 'Own fallback text in the host',
        paragraphs: [
          'NibGeneratedSurfaceLabels supplies fallback text for empty, loading, error, invalid-tree, unsupported-component, action, and text-field states. Translate these in the host. The renderer cannot derive trustworthy accessible instructions from an unregistered wire component.',
          'Only initial loading and error fallbacks are live regions. Bound text changes are not announced on every stream update.',
        ],
        api: [
          DocApiEntry(
            name: 'NibGeneratedSurfaceLabels.empty',
            type: 'String',
            defaultValue: 'No generated content',
            description: 'Shown before a surface exists.',
          ),
          DocApiEntry(
            name: 'NibGeneratedSurfaceLabels.error',
            type: 'String',
            defaultValue: 'Unable to load content',
            description: 'Initial load failure label when error is supplied.',
          ),
          DocApiEntry(
            name: 'NibGeneratedSurfaceLabels.unsupportedComponent',
            type: 'String',
            defaultValue: 'Unsupported component',
            description:
                'Safe fallback when the schema has no renderer builder.',
          ),
          DocApiEntry(
            name: 'NibGeneratedSurfaceLabels.textField',
            type: 'String',
            defaultValue: 'Text field',
            description: 'Fallback field name.',
          ),
        ],
      ),
      DocSection(
        id: 'host-labels',
        heading: "Provide language and layout around the surface",
        paragraphs: [
          "Start with the fixture rendering inside MaterialApp and a normally constrained page. The host supplies Flutter theme, text direction and text scaling. The generated data describes only the supported component fields; this Basic slice does not accept arbitrary accessibility attributes from a sender. Trusted builders and host fallback labels therefore carry the accessible behavior.",
          "Place this widget where the generated surface belongs and replace each fallback string with your app’s translation. Empty means the surface does not exist yet. Loading covers incomplete content. Error is used for initial failure when the error argument is supplied and there is no valid surface. A later rejected frame should leave valid content visible and report its problem through host feedback rather than replacing the form with a generic error.",
        ],
        code: r'''NibGeneratedSurface(
  runtime: runtime,
  surfaceId: 'main',
  motionEnabled: false,
  labels: const NibGeneratedSurfaceLabels(
    empty: 'Your form will appear here',
    loading: 'Preparing your form',
    error: 'The form could not load',
    invalidTree: 'The form structure could not be shown',
    unsupportedComponent: 'This control is unavailable',
    action: 'Continue',
    textField: 'Response',
  ),
)''',
      ),
      DocSection(
        id: 'focus',
        heading: 'Check focus after updates',
        paragraphs: [
          'The renderer keys nodes by runtime, surface, generation, and node ID. A bound TextField keeps its selection through local updates and clamps it after a shorter remote value. Surface deletion or replacement changes generation and should be treated as a new focus context.',
          'Test keyboard traversal, screen readers, large text, and right-to-left direction in the host. Widget tests show part of the contract; physical assistive-technology behavior remains a separate release check.',
        ],
      ),
      DocSection(
        id: 'progressive-focus',
        heading: "Walk a progressively built form with the keyboard",
        paragraphs: [
          "Replay the website fixture one frame at a time. Before the root and data arrive, observe the fallback instead of expecting an editable completed form. After the third frame, reach Your name with Tab, type a value and activate Say hello from the keyboard. Confirm that the feedback is visible and that focus remains useful. Replay creates a new runtime, so treating it as a new focus context is appropriate.",
          "Stable node IDs allow the renderer to preserve a field’s widget state across ordinary updates. Replacing IDs for every keystroke discards that continuity. Deleting and recreating a surface represents a new generation even when its external name is reused. Decide where focus should go after such a replacement; do not assume a stale focused node still exists.",
          "Only initial loading and error fallbacks are live regions. Streaming text is not announced after every update, which avoids a constantly speaking interface, but it means important host results need deliberate accessible feedback. Do not hide submission success in color or movement alone. Give validation feedback a readable message and a route back to the field that needs correction.",
          "Compare the surface with motionEnabled false and with the platform’s reduced-motion preference enabled. Both should keep the final content and actions usable without structural animation. Then test large text, a narrow viewport and right-to-left direction. Inspect custom builders too: a trusted builder can still have a fixed-size label or poor semantics. Widget tests cover important structure, but an actual screen reader and keyboard on each supported platform are needed to assess the complete task.",
        ],
      ),
      DocSection(
        id: 'motion',
        heading: 'Turn off structural motion when needed',
        paragraphs: [
          'motionEnabled defaults to true, but the renderer also watches NibMotionConfig reduced motion and skips structural animation when it is active. A host can set motionEnabled: false for a surface that should update without movement.',
          'Keep action outcomes and form errors visible without relying on animation. Theme and text direction come from the surrounding Flutter app.',
        ],
        api: [
          DocApiEntry(
            name: 'motionEnabled',
            type: 'bool',
            defaultValue: 'true',
            description:
                'Structural transitions when reduced motion is not active.',
          ),
          DocApiEntry(
            name: 'labels',
            type: 'NibGeneratedSurfaceLabels',
            defaultValue: 'English defaults',
            description: 'Host-provided fallback copy.',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'platform-limits',
    title: 'Limits and performance',
    summary: 'Bound each stream and distinguish local tests from target-device evidence.',
    evidence: 'GenUINib/packages/nib_genui_http/lib/nib_genui_http.dart; GenUINib/packages/nib_genui_core/README.md; GenUINib/docs/THREAT_MODEL.md; GenUINib/docs/PLATFORMS.md',
    sections: [
      DocSection(
        id: 'budget-plan',
        heading: "Budget a session before opening its stream",
        paragraphs: [
          "Choose limits from the task you intend to show. A short profile form may need one surface, a handful of nodes and a small data model. A dashboard may need more. Give the runtime enough room for valid intermediate frames, including detached definitions, but do not raise every limit just to make malformed input pass. Per-message bytes, retained model bytes and total protocol attempts constrain different resources.",
          "The constructor below is an example for a small local session. It does not represent a universal safe setting. Eight kilobytes bounds one envelope, while four kilobytes bounds the retained data model after updates. Twenty-four nodes permits temporary definitions around a small form. A hundred protocol attempts counts rejected messages too. Local typing through writeData does not consume those protocol attempts.",
        ],
        code: r'''final runtime = NibRuntime(
  catalogs: [NibCatalog.basic()],
  maxMessageBytes: 8192,
  maxDataModelBytes: 4096,
  maxNodes: 24,
  maxSurfaces: 1,
  maxDepth: 8,
  maxStringLength: 512,
  maxProtocolMessages: 100,
);''',
      ),
      DocSection(
        id: 'transport',
        heading: 'Set a complete-stream deadline',
        paragraphs: [
          'NibHttpTransport.connect needs an explicit allowedSurfaceIds set. It defaults to 8 MiB and 1024 frames per connection. Its 30-second timeout covers connection setup and the entire response body; active frames do not reset it. The adapter has no independent inactivity timer.',
          'Cancel the stream subscription to abort the request. The host owns reconnect and backoff, total session time, authentication headers, and endpoint selection. Browser use requires the server’s CORS policy.',
        ],
        api: [
          DocApiEntry(
            name: 'allowedSurfaceIds',
            type: 'Set<String>',
            defaultValue: 'required',
            description: 'Surface ownership allowlist for one HTTP stream.',
          ),
          DocApiEntry(
            name: 'maxStreamBytes',
            type: 'int',
            defaultValue: '8 × 1024 × 1024',
            description: 'Maximum complete response bytes per connection.',
          ),
          DocApiEntry(
            name: 'maxFrames',
            type: 'int',
            defaultValue: '1024',
            description: 'Maximum response frames per connection.',
          ),
          DocApiEntry(
            name: 'timeout',
            type: 'Duration',
            defaultValue: '30 seconds',
            description:
                'Hard connection-plus-body deadline, not idle timeout.',
          ),
        ],
      ),
      DocSection(
        id: 'bounded-http',
        heading: "Separate connection, inactivity and session limits",
        paragraphs: [
          "Add nib_genui_http from the same local checkout only after the fixture works. Supply an http.Client and a host-selected endpoint; neither is generated by the UI stream. The transport’s default 30-second timeout is a hard connection-plus-body deadline. A stream that keeps delivering frames still ends at that deadline. An inactivity timer would instead reset on progress, and the adapter does not provide one independently.",
          "If your host needs inactivity detection, define what counts as progress. A completed valid frame is different from a peer sending one byte forever. Also cap total session time and reconnection attempts. Making a new adapter resets its frame counter, while the same runtime retains its protocol-attempt budget. Automatically recreating both on every failure would defeat the session boundary you intended.",
          "Test a finite successful response, a stalled connection, malformed JSONL, a frame beyond the byte limit, and a response for a disallowed surface. Confirm that rejection preserves the previous valid surface and that cancellation stops further updates. On the web, test the actual origin and CORS response; a passing fake-client test cannot establish browser permission to read a server response.",
          "The local demo has no network and deliberately permits three frames. Use it to learn bounded replay, not to infer transport throughput. Measure decode, validation, widget build and raster work separately with representative bursts on target hardware. Resource fetches, a broad widget catalog and production authorization remain outside this built-in slice; adding a custom builder means designing and testing those responsibilities yourself.",
        ],
      ),
      DocSection(
        id: 'resource',
        heading: 'No resource widget yet',
        paragraphs: [
          'The Basic subset has no URL or media resource component. There is therefore no production resource fetch policy to rely on. If a trusted custom builder fetches URLs, the host owns scheme, origin, redirect, size, and permission checks before it is used.',
          'This package slice does not run generated code. Registered host functions should be deterministic, side-effect-free string functions; they are not a way to smuggle a network call into the data model.',
        ],
      ),
      DocSection(
        id: 'measurement',
        heading: 'Measure the host and device separately',
        paragraphs: [
          'Pure Dart reduction tests and Flutter widget tests do not establish device frame time, raster cost, memory retention, or screen-reader behavior. Measure large surface updates, stream bursts, and repeated disposal in the host and renderer you plan to support.',
          'A successful build shows that a target compiled. It does not show that text input, scrolling, focus and memory behave correctly on a physical device. Record those checks separately, and describe the platforms you actually exercised when sharing an integration.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'genui',
    id: 'troubleshooting',
    title: 'Troubleshooting and migration',
    summary:
        'Read safe diagnostics before changing catalogs, bindings, or hosts.',
    evidence: 'GenUINib/packages/nib_genui_core/lib/nib_genui_core.dart; GenUINib/packages/nib_genui_core/README.md; GenUINib/packages/nib_genui_http/README.md; GenUINib/docs/PROTOCOL_COMPATIBILITY.md',
    sections: [
      DocSection(
        id: 'first-failure',
        heading: "Keep the first rejected frame and its last good state",
        paragraphs: [
          "Start diagnosis with a deterministic fixture. Replay from a fresh runtime in order and stop at the first rejected result. Later failures often follow from that missing creation or data update. Keep the frame number, diagnostic code and a sanitized description of the operation. Do not dump a whole response or action context into shared logs; identifiers and paths can also contain private information.",
          "The helper below accepts one complete JSON envelope, not an arbitrary network chunk. Call it after framing, using the same runtime and surface IDs as your view. On rejection, inspect the code and leave the current surface visible. If the view is empty, first confirm that createSurface succeeded and that the renderer’s surfaceId exactly matches it. Then check that root and its referenced children are defined.",
        ],
        code: r'''bool applyCompleteFrame(NibRuntime runtime, String frame) {
  final result = runtime.applyJson(frame);
  if (result.accepted) return true;
  for (final diagnostic in result.diagnostics) {
    debugPrint('${diagnostic.stage}: ${diagnostic.code}');
  }
  return false;
}''',
      ),
      DocSection(
        id: 'diagnostics',
        heading: 'Inspect the rejected frame',
        paragraphs: [
          'NibApplyResult.diagnostics contains a code, safe message, stage, and optional surface, node, path, expected type, and actual type. The runtime does not include raw untrusted values in a diagnostic. The previous valid surface stays visible after a rejected mutation.',
          'An unknown_catalog means the exact catalog ID is missing from the runtime. unknown_component means the schema has no component of that name. invalid_pointer or binding_type points to a data path or value mismatch. Check these before changing the renderer.',
        ],
        api: [
          DocApiEntry(
            name: 'NibApplyResult.accepted',
            type: 'bool',
            defaultValue: 'per operation',
            description: 'Whether a mutation was committed.',
          ),
          DocApiEntry(
            name: 'NibDiagnostic.stage',
            type: 'String',
            defaultValue: 'derived from code',
            description: 'Broad decode, protocol, catalog, binding, graph, capability, or lifecycle category.',
          ),
          DocApiEntry(
            name: 'NibDiagnostic.suggestedFix',
            type: 'String?',
            defaultValue: 'null',
            description: 'Hint for selected known rejection codes.',
          ),
        ],
      ),
      DocSection(
        id: 'symptom-path',
        heading: "Follow the symptom to its layer",
        paragraphs: [
          "For unknown_catalog, compare the exact catalog ID in createSurface with the runtime registration. For unknown_component, compare the component name and schema. For a builder fallback after an accepted custom component, register its matching trusted Flutter builder. These are three different failures: catalog selection, schema validation and visual implementation. Adding a renderer cannot repair a frame that the runtime rejected.",
          "For an unresolved label, inspect the binding path and whether the data frame arrived. For binding_type, a value exists but has the wrong type. For an uneditable field, check whether value is a literal instead of a path binding. For an inactive action, verify the Button is reachable from root, its child is complete, its event is registered, its context paths are allowed and its guard accepts current data.",
          "For streaming problems, distinguish JSON framing from protocol validation and HTTP failure. JSONL needs complete newline-delimited objects; SSE data: prefixes are not supported. NibJsonlAdapter handles split bytes and a final line without a newline. HTTP status errors and the hard response deadline are transport failures, while a well-delivered invalid frame yields a rejected NibApplyResult.",
          "Replay fixture on the website is a deliberate reset, not a reconnect strategy. A real reconnect must preserve generation order and surface ownership. The protocol slice has no sequence number to reject an old frame after an ID is reused, so use a fresh session or distinct IDs at that boundary. Before changing a saved format or catalog, replay known fixtures through both versions and compare accepted state and action decisions. Do not relabel an unsupported frame to a newer version and assume compatibility.",
        ],
      ),
      DocSection(
        id: 'ordering',
        heading: 'Keep generation order',
        paragraphs: [
          'Updates before createSurface and duplicate active creates are rejected. A valid update can be applied twice and emits another change event. The protocol slice has no sequence field, so a stale update after an ID is deleted and reused cannot be recognized from that ID alone.',
          'Use a fresh runtime or distinct IDs for a new session, and keep delivery ordered across reconnects. Do not retry consequential actions without backend deduplication.',
        ],
      ),
      DocSection(
        id: 'migration',
        heading: 'Integrate in layers',
        paragraphs: [
          'Start with a saved v0.9.1 fixture in nib_genui_core, then render the same surface through nib_genui. Add nib_genui_http only when the host has endpoint, authorization, deadlines, and reconnect policy. The website’s scripted fixture is a local demonstration, not a live provider integration.',
          'Do not interpret a passing three-frame smoke test as complete protocol compatibility. Keep unsupported fields and Basic components outside the advertised catalog until they have schemas, trusted builders, and tests.',
        ],
      ),
    ],
  ),
];
