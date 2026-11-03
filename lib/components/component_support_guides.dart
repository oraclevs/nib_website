import '../content/site_content.dart';

/// Public symbols taught across families; these do not add live demo families.
const componentSupportSymbols = <String, List<String>>{
  'theming': ['NibTheme'],
  'state-and-controllers': [
    'NibSwitch',
    'NibFlipCard',
    'NibTabsController',
    'NibAccordionController',
    'NibNavMenuController',
    'NibOtpController',
    'NibInput',
    'NibTextarea',
  ],
  'motion-opt-in': [
    'NibButton',
    'NibFlipCard',
    'NibCircularLoader',
    'NibTabs',
    'NibBottomSheet',
    'NibToastDuplicateBehavior',
  ],
  'overlays': [
    'showNibDialog',
    'openNibDialog',
    'NibDialogScope',
    'NibDialogHandle',
    'showNibBottomSheet',
    'openNibBottomSheet',
    'NibBottomSheetHandle',
    'showNibContextMenu',
    'NibPopover',
    'NibHoverCard',
    'showNibToast',
    'dismissNibToast',
    'NibToaster',
  ],
  'accessibility': [
    'NibButton',
    'NibCheckbox',
    'NibSwitch',
    'NibRadioGroup',
    'NibSelect',
    'NibInput',
    'NibTextarea',
    'NibCircularLoader',
    'NibFlipCard',
  ],
  'validation': ['NibValidator', 'NibValidators', 'NibInput', 'NibTextarea'],
};

/// Cross-family guides for the selected local nib_components 0.2.2 candidate.
/// Family routes are the canonical IDs in the component source inventory.
const componentSupportArticles = <DocArticle>[
  DocArticle(
    packageId: 'components',
    id: 'theming',
    title: 'Theming',
    summary: 'Set shared colors and radii, override one control, and keep both brightness modes usable.',
    evidence: 'ComponetsNib/nib_components/lib/src/theme/nib_theme.dart; ComponetsNib/nib_components/lib/src/button/nib_button.dart; ComponetsNib/nib_components/lib/src/card/nib_card.dart; ComponetsNib/nib_components/lib/src/toast/nib_toast_types.dart',
    sections: [
      DocSection(
        id: 'start-with-brightness',
        heading: 'Start with Flutter brightness',
        paragraphs: [
          'NibTheme is a Flutter ThemeExtension. Every call to NibTheme.of(context) first checks the nearest ThemeData for that extension. If it is absent, the method chooses NibTheme.light or NibTheme.dark from the ambient brightness. You can put a Nib control in a MaterialApp before writing any theme configuration.',
          'This website uses a dark Ember palette. The package also supports light themes. Set ThemeData brightness and the Nib extension together: installing NibTheme.dark in a light ThemeData does not make Material widgets dark. ThemeMode.system chooses between the two ThemeData objects using the platform preference.',
        ],
        code: r'''MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      NibTheme.light.copyWith(
        primary: const Color(0xFF6D28D9),
        primaryForeground: Colors.white,
        ring: const Color(0xFF6D28D9),
      ),
    ],
  ),
  darkTheme: ThemeData.dark().copyWith(
    extensions: const [NibTheme.dark],
  ),
  themeMode: ThemeMode.system,
  home: const Scaffold(body: Center(child: Text('Your screen'))),
)''',
      ),
      DocSection(
        id: 'token-reference',
        heading: 'Know which token changes which surface',
        paragraphs: [
          'The public constructor has 16 color tokens and four radius tokens. copyWith preserves every field you omit. Change a fill and its foreground together, then inspect the result in normal, focused, disabled, and error states. A readable button label does not guarantee a visible focus ring around that button.',
        ],
        blocks: [
          DocTable(
            headers: ['Tokens', 'Purpose'],
            rows: [
              ['background / foreground', 'Page surfaces and their main text.'],
              [
                'card / cardForeground',
                'Card and raised surface fill and text.',
              ],
              [
                'primary / primaryForeground',
                'Primary actions and their foreground.',
              ],
              [
                'secondary / secondaryForeground',
                'Secondary surfaces and their foreground.',
              ],
              ['muted / mutedForeground', 'Quiet surfaces and secondary text.'],
              ['accent / accentForeground', 'Accent fill and its foreground.'],
              [
                'border',
                'Outlines and dividers where the component reads this token.',
              ],
              ['input', 'Default input border.'],
              ['ring', 'Focus and active input ring.'],
              ['destructive', 'Destructive and error color.'],
              ['radiusSm', 'Small radius; built-in value 4 logical pixels.'],
              [
                'radiusDefault',
                'Default radius; built-in value 8 logical pixels.',
              ],
              ['radiusLg', 'Large radius; built-in value 12 logical pixels.'],
              [
                'radiusPill',
                'Pill radius; built-in value 9999 logical pixels.',
              ],
            ],
          ),
        ],
        api: [
          DocApiEntry(
            name: 'NibTheme.of',
            type: 'NibTheme Function(BuildContext)',
            defaultValue: 'Registered extension, then brightness fallback',
            description:
                'Resolve tokens from a context below the intended Theme.',
          ),
          DocApiEntry(
            name: 'NibTheme.copyWith',
            type: 'NibTheme',
            defaultValue: 'Omitted fields retained',
            description:
                'Return a new token set; the original stays immutable.',
          ),
          DocApiEntry(
            name: 'NibTheme.lerp',
            type: 'NibTheme',
            defaultValue: 'ThemeExtension interpolation',
            description: 'Interpolate colors and radii when Flutter interpolates themes.',
          ),
        ],
      ),
      DocSection(
        id: 'component-overrides',
        heading: 'Theme one component without inventing another theme API',
        paragraphs: [
          'The current package exports one NibTheme class. There are no NibButtonTheme or NibCardTheme extensions. Per-component styling comes from constructor arguments. For example, NibButton exposes backgroundColor, foregroundColor, borderColor, and borderRadius. NibCard exposes backgroundColor, borderColor, and borderRadius. These explicit values take precedence over their token defaults.',
          'Use a shared token change when several controls should change together. Use an instance override for a deliberate exception. A button that keeps its old color after a theme change may simply have an explicit backgroundColor. Removing that override lets the variant resolve its fill again.',
        ],
        code: r'''NibButton(
  label: 'Secondary action',
  variant: NibButtonVariant.outline,
  borderRadius: BorderRadius.circular(4),
  onPressed: () {},
)''',
        blocks: [
          DocLink(
            'Button variants and instance styling',
            '/docs/components/button',
          ),
          DocLink('Card surfaces and flip faces', '/docs/components/card'),
        ],
      ),
      DocSection(
        id: 'scope-and-state',
        heading: 'Change the theme without replacing the draft',
        paragraphs: [
          'Wrap a section in Theme when it needs a local palette. Use Theme.of(context).copyWith to preserve unrelated Flutter settings. If you already have other ThemeExtension objects, keep them when replacing the extensions list. Read NibTheme.of from below the wrapper; a context above it still sees the outer theme.',
          'Keep controllers and keys outside build. Editing an accent or switching brightness should rebuild presentation, not create a new TextEditingController or reset a selected tab. Type a draft, place its cursor in the middle, then change the theme to check this separation in your own screen.',
          'NibTheme does not define typography, spacing, shadows, or every effect color. Use Flutter ThemeData and the documented instance arguments for those. Toast success and warning accents are fixed package colors, while error and info use destructive and accent. Liquid glass has its own tint, radius, and optical defaults; changing radiusDefault alone does not change its shape.',
        ],
        blocks: [
          DocLink(
            'Controller ownership',
            '/docs/components/state-and-controllers',
          ),
          DocLink(
            'Liquid glass styling and fallback',
            '/docs/components/liquid-glass',
          ),
          DocLink(
            'Overlay theme and placement rules',
            '/docs/components/overlays',
          ),
        ],
      ),
      DocSection(
        id: 'review-a-palette',
        heading: 'Review the states people will actually use',
        paragraphs: [
          'Check text, focus rings, selected rows, disabled controls, errors, and overlay content in each supported brightness mode. Open a dialog while changing the app theme and inspect its nested content as well as the outer surface. The dialog and sheet helpers recapture inherited themes on overlay rebuilds; explicit colors in your content still win.',
          'Color contrast and readable layouts depend on your chosen tokens and content. The dark website preview is not a light-theme or physical-device accessibility certification. Test your final palette at the text sizes and platforms you support.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'state-and-controllers',
    title: 'State and controllers',
    summary: 'Choose a state owner, connect callbacks, and dispose only the objects you create.',
    evidence: 'ComponetsNib/nib_components/lib/src/switch/nib_switch.dart; ComponetsNib/nib_components/lib/src/card/nib_flip_card.dart; ComponetsNib/nib_components/lib/src/tabs/nib_tabs_controller.dart; ComponetsNib/nib_components/lib/src/input/nib_input.dart; ComponetsNib/nib_components/lib/src/accordion/nib_accordion_controller.dart; ComponetsNib/nib_components/lib/src/navigation_menu/nib_navigation_menu_controller.dart',
    sections: [
      DocSection(
        id: 'choose-an-owner',
        heading: 'Choose the contract before adding a controller',
        paragraphs: [
          'A value and an event are different things. value describes the current state. onChanged asks your app to accept a new state. A controlled widget keeps showing the old value until its parent rebuilds with the new one. An optional controller instead stores widget-specific state and exposes operations that another part of the screen can call.',
        ],
        blocks: [
          DocTable(
            headers: ['Contract', 'Examples', 'Your responsibility'],
            rows: [
              [
                'Required value + callback',
                'NibCheckbox, NibSwitch, NibSlider, NibRadioGroup',
                'Store the value and rebuild after accepting a callback.',
              ],
              [
                'Optional controlled value',
                'NibFlipCard.isFlipped',
                'Omit it for local state; provide it and onFlippedChanged for parent-owned state.',
              ],
              [
                'Optional controller',
                'NibAccordion, NibTabs, NibSelect, NibNavigationMenu',
                'Let the widget own its default controller, or retain and dispose an external one.',
              ],
              [
                'Native text editing',
                'NibInput, NibTextarea',
                'Choose controller or initialValue; connect Form validation separately.',
              ],
              [
                'Imperative result',
                'showNibDialog, showNibBottomSheet',
                'Await the returned future; use an open helper handle for external close control.',
              ],
            ],
          ),
        ],
        code: r'''// Field and widget inside a State class.
bool enabled = false;

Widget buildSwitch() => NibSwitch(
  label: 'Sync drafts',
  value: enabled,
  onChanged: (next) => setState(() => enabled = next),
);''',
      ),
      DocSection(
        id: 'controller-lifetime',
        heading: 'Create once; dispose when the owner leaves',
        paragraphs: [
          'Create an external controller in State, not inside build or an onPressed callback. Pass the same instance to the component and dispose it in the owning State.dispose. Components detach from external controllers; they do not dispose them for you. When no controller is supplied, the component manages its internal controller.',
          'If you add your own controller listener, remove it before disposing the owner. When a parent replaces a supplied controller, detach from the old instance in didUpdateWidget and attach to the new one. Do not dispose the old external object unless your object created it and still owns it.',
        ],
        code: r'''class TabScreen extends StatefulWidget {
  const TabScreen({super.key});
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  final tabs = NibTabsController(initialIndex: 0);

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(children: [
      NibButton(label: 'Open notes', onPressed: () => tabs.animateTo(1)),
      Expanded(child: NibTabs(
        controller: tabs,
        tabs: [
          NibTab(label: 'Summary', builder: (_) => const Text('Summary')),
          NibTab(label: 'Notes', builder: (_) => const Text('Notes')),
        ],
      )),
    ]),
  );
}''',
        note: 'NibTabs owns its vertical scroll and needs bounded height. Expanded supplies it here; do not wrap the tab set in another vertical scroll view.',
        blocks: [DocLink('Tabs and scroll ownership', '/docs/components/tabs')],
      ),
      DocSection(
        id: 'controller-operations',
        heading: 'Use the operation that matches the state',
        paragraphs: [
          'Controllers are specific to a family. NibTabsController.animateTo requests an animated switch; jumpTo requests an immediate switch. NibAccordionController coordinates open indices, including single-open behavior. NibNavMenuController separates a horizontal flyout path from the set of expanded vertical items. None of these controllers performs application routing.',
        ],
        api: [
          DocApiEntry(
            name: 'NibTabsController.animateTo',
            type: 'void Function(int)',
            defaultValue: 'Explicit operation',
            description: 'Select an index and request animated pager movement.',
          ),
          DocApiEntry(
            name: 'NibTabsController.jumpTo',
            type: 'void Function(int)',
            defaultValue: 'Explicit operation',
            description:
                'Select an index without the programmatic pager animation.',
          ),
          DocApiEntry(
            name: 'NibAccordionController.open',
            type: 'void Function(int)',
            defaultValue: 'Single-open unless allowMultiple is true',
            description:
                'Open an index, closing other indices in single-open mode.',
          ),
          DocApiEntry(
            name: 'NibNavMenuController.openChainTo',
            type: 'void Function(List<String>)',
            defaultValue: 'Empty chain',
            description: 'Set the root-to-deepest horizontal submenu path.',
          ),
          DocApiEntry(
            name: 'NibOtpController.clear',
            type: 'void Function()',
            defaultValue: 'Explicit operation',
            description: 'Clear the entered code; it does not cancel your verification request.',
          ),
        ],
        blocks: [
          DocLink('Accordion state', '/docs/components/accordion'),
          DocLink(
            'Navigation selection and submenus',
            '/docs/components/navigation-menu',
          ),
          DocLink('OTP input and verification', '/docs/components/otp-input'),
        ],
      ),
      DocSection(
        id: 'editing-state',
        heading: 'Preserve selection as well as text',
        paragraphs: [
          'TextEditingController.value contains text, selection, and the composing range. Reassigning controller.text during every rebuild can discard the cursor and interrupt input methods. Change it only for an explicit edit or accepted external update. Use a complete TextEditingValue when your application must set both text and selection.',
          'For NibInput and NibTextarea, initialValue seeds internally owned text. It is not a live command to replace the draft on each rebuild. Passing both initialValue and controller is an assertion error. In the current candidate, switching from an external controller to internal ownership preserves the editing value; switching to a supplied controller adopts that controller’s value. Prefer stable ownership for an ordinary form.',
        ],
        blocks: [
          DocLink(
            'Fields, cursor behavior, and controls',
            '/docs/components/input',
          ),
        ],
      ),
      DocSection(
        id: 'async-state',
        heading: 'Keep request state in the application',
        paragraphs: [
          'NibSwitch.loading and NibButton.loading block repeated interaction and show busy feedback. They do not start, authorize, retry, or cancel a request. Set busy before awaiting work, keep the previous accepted value until success if that is your interaction policy, and clear busy on failure. Check mounted before calling setState after an await.',
          'When multiple requests can overlap, give each request an identity and ignore stale responses. Unmounting a widget does not cancel an HTTP request. Dispose controllers and cancel subscriptions or requests in their respective owners; keep those duties separate from a component’s presentation state.',
        ],
        blocks: [
          DocLink(
            'Switch value and loading behavior',
            '/docs/components/switch',
          ),
          DocLink('Validation and submission', '/docs/components/validation'),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'motion-opt-in',
    title: 'Motion and reduced motion',
    summary: 'Opt into component effects and account for the motion that lives outside that switch.',
    evidence: 'ComponetsNib/nib_components/lib/src/button/nib_button.dart; ComponetsNib/nib_components/lib/src/card/nib_flip_card.dart; ComponetsNib/nib_components/lib/src/loader/nib_circular_loader.dart; ComponetsNib/nib_components/lib/src/tabs/nib_tabs.dart; ComponetsNib/nib_components/lib/src/toast/show_nib_toast.dart; ComponetsNib/nib_components/lib/src/bottom_sheet/show_nib_bottom_sheet.dart; MotionNib/motion/lib/src/core/reduced_motion.dart',
    sections: [
      DocSection(
        id: 'opt-in',
        heading: 'Add motion after the interaction works',
        paragraphs: [
          'Most component constructors with an animated argument default it to false. Turning it on adds the documented NibMotion effect: a button press response, an input message transition, or an overlay entrance. The component still needs its ordinary callback and state when animation is disabled. Website playgrounds explicitly start their supported animations; that showcase configuration does not change the package constructor defaults.',
          'A transition argument configures that component’s documented motion path. It is not a global speed control for every descendant. Import nib_motion explicitly when writing NibTransition; nib_components uses it as a dependency but does not re-export the entire motion API.',
        ],
        code: r'''import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_motion/nib_motion.dart';

NibButton(
  label: 'Try the press response',
  animated: true,
  transition: const NibTransition(duration: Duration(milliseconds: 160)),
  onPressed: () {},
)''',
      ),
      DocSection(
        id: 'exceptions',
        heading: 'Understand what animated does not switch off',
        paragraphs: [
          'animated: false is not a promise that the entire subtree is still. Flutter interaction feedback, gesture settling, loading indicators, and some layout transitions use other paths. These exceptions matter when choosing a reduced-motion policy.',
        ],
        blocks: [
          DocTable(
            headers: ['Component or behavior', 'Current contract'],
            rows: [
              [
                'NibFlipCard',
                'No animated property. It always delegates face changes to NibFlip; duration defaults to 600 ms.',
              ],
              [
                'NibCircularLoader',
                'No animated property and no local reduced-motion check. Its AnimationController repeats while active.',
              ],
              [
                'NibTabs',
                'animated controls the optional panel fade. Indicator glide, pager slide, and height reflow have separate gesture/layout behavior.',
              ],
              [
                'Bottom-sheet dragging',
                'Snap settling uses an internal AnimationController and spring; animated controls the optional entrance/exit path.',
              ],
              [
                'Duplicate toast',
                'The default shake duplicate policy can move an existing toast even with animated: false. Choose ignore or replace when that motion is unwanted.',
              ],
            ],
          ),
          DocLink('Flip cards', '/docs/components/card'),
          DocLink('Loading indicators', '/docs/components/loader'),
          DocLink('Bottom-sheet snapping', '/docs/components/bottom-sheet'),
          DocLink('Toast duplicate behavior', '/docs/components/toast'),
        ],
      ),
      DocSection(
        id: 'respect-system-preference',
        heading: 'Respect the preference at the relevant layer',
        paragraphs: [
          'NibMotion and NibFlip use the motion package’s reduced-motion policy. With its default policy, the system MediaQuery.disableAnimations preference causes motion to settle at the target. The local candidate’s NibFlip also keeps only the actually visible face in focus traversal and semantics while a flip is running.',
          'A loader is a separate case. Replace a decorative spinning loader with readable static status when reduced motion is requested. TickerMode can silence tickers in an inactive preview, but it does not label the work, cancel a request, or establish a reduced-motion policy for arbitrary timers. Do not rely on it as the only accessibility control.',
        ],
        code: r'''Widget busyStatus(BuildContext context) {
  final reduce = MediaQuery.disableAnimationsOf(context);
  return Semantics(
    liveRegion: true,
    label: 'Saving changes',
    child: ExcludeSemantics(
      child: reduce
          ? const Text('Saving changes…')
          : const NibCircularLoader(size: 28),
    ),
  );
}''',
        note: 'This helper describes a busy state. It does not simulate a save or imply that any backend operation has completed.',
      ),
      DocSection(
        id: 'test-state-transitions',
        heading: 'Test interruptions and the final state',
        paragraphs: [
          'Trigger a change, reverse it before it finishes, then enable reduced motion. The final selected value, visible message, and available action should still match application state. Test disabling an interactive surface during a held press, removing an open overlay, and leaving a screen with a loader active.',
          'Use numeric state and semantics assertions where possible. A test that simply pumps without an exception does not prove a correct endpoint. Widget tests can check state and cleanup; physical-device frame pacing and GPU appearance require separate device evidence.',
        ],
        blocks: [
          DocLink(
            'Accessible interaction checks',
            '/docs/components/accessibility',
          ),
          DocLink(
            'Liquid glass press and fallback behavior',
            '/docs/components/liquid-glass',
          ),
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'overlays',
    title: 'Overlays and result lifecycles',
    summary: 'Choose a surface, control its lifetime, and understand which overlay receives it.',
    evidence: 'ComponetsNib/nib_components/lib/src/dialog/show_nib_dialog.dart; ComponetsNib/nib_components/lib/src/bottom_sheet/show_nib_bottom_sheet.dart; ComponetsNib/nib_components/lib/src/context_menu/show_nib_context_menu.dart; ComponetsNib/nib_components/lib/src/popover/nib_popover.dart; ComponetsNib/nib_components/lib/src/hover_card/nib_hover_card.dart; ComponetsNib/nib_components/lib/src/toast/show_nib_toast.dart',
    sections: [
      DocSection(
        id: 'choose-a-surface',
        heading: 'Choose by interaction, not appearance',
        paragraphs: [
          'Use a dialog for a focused task or decision, a bottom sheet for a task that benefits from draggable height, and a popover for content anchored to a trigger. A hover card provides supporting information on hover or focus. A context menu offers actions at a pointer position. A toast reports a brief status without becoming the only place essential information is available.',
        ],
        blocks: [
          DocLink('Dialogs', '/docs/components/dialog'),
          DocLink(
            'Confirmation and alert results',
            '/docs/components/alert-dialog',
          ),
          DocLink('Bottom sheets', '/docs/components/bottom-sheet'),
          DocLink('Popovers', '/docs/components/popover'),
          DocLink('Hover cards', '/docs/components/hover-card'),
          DocLink('Context menus', '/docs/components/context-menu'),
          DocLink('Toasts', '/docs/components/toast'),
        ],
      ),
      DocSection(
        id: 'return-a-result',
        heading: 'Close through the surface’s scope',
        paragraphs: [
          'showNibDialog<T> returns Future<T?>. Close it through NibDialogScope from a context inside the dialog. A Builder supplies that inner context when the content is created at the call site. Navigator.pop is not the close mechanism: these helpers insert OverlayEntry objects rather than Navigator routes.',
          'Keep the returned value compatible with T. The scope accepts Object?, but the helper casts a non-null result to T. Barrier, Escape, and close-button dismissal produce null. In a confirmation flow, act only on an explicit affirmative result. Check context.mounted before using the original context after awaiting the dialog.',
        ],
        code: r'''Future<bool?> askToContinue(BuildContext context) {
  return showNibDialog<bool>(
    context,
    title: 'Keep these changes?',
    content: Builder(
      builder: (dialogContext) => NibButton(
        label: 'Keep changes',
        onPressed: () => NibDialogScope.of(dialogContext).close(true),
      ),
    ),
  );
}''',
        api: [
          DocApiEntry(
            name: 'showNibDialog',
            type: 'Future<T?>',
            defaultValue: 'animated: false; barrierDismissible: true',
            description: 'Insert a dialog and return its result future.',
          ),
          DocApiEntry(
            name: 'NibDialogScope.of',
            type: 'NibDialogScope',
            defaultValue: 'Nearest scope',
            description: 'Requires a context under the dialog. Calling it outside asserts.',
          ),
          DocApiEntry(
            name: 'NibDialogHandle.closed',
            type: 'Future<T?>',
            defaultValue: 'Pending until close is requested',
            description: 'The result can complete before the animated exit has fully removed the surface.',
          ),
        ],
      ),
      DocSection(
        id: 'overlay-location',
        heading: 'Know where the helper inserts its content',
        paragraphs: [
          'The dialog, bottom-sheet, and context-menu helpers call Overlay.of(context, rootOverlay: true). Toasts also select a root overlay. NibPopover and NibHoverCard use the nearest overlay. A nested Navigator supplies an overlay, but nesting alone does not contain helpers that explicitly request the root.',
          'These Nib helpers expose no useRootNavigator argument. That parameter belongs to Flutter route helpers such as showDialog or showModalBottomSheet; their policies must not be copied onto a Nib call. Read the actual helper signature when selecting a local or application-wide presentation.',
          'This website uses the package’s page-modal root-overlay helpers for dialogs, alert dialogs, sheets, and context menus. Nearest-overlay controls use the preview’s local Navigator overlay. In your own application, choose that host policy explicitly and verify barrier bounds, dismissal, and focus for each helper. A local preview Navigator alone does not contain a helper that asks for the root overlay.',
        ],
        note: 'Do not add LookupBoundary around a same-view preview merely to force root helpers into it: it can also hide View lookups needed by editable text and break focus. A nested Navigator alone does not contain these root-overlay helpers. Test the helper’s actual scope, including text input and keyboard focus.',
      ),
      DocSection(
        id: 'own-open-surfaces',
        heading: 'Own an overlay that can outlive its caller',
        paragraphs: [
          'Use openNibDialog or openNibBottomSheet when another part of the screen must close the surface. Their handles expose closed, close, and isOpen; the sheet handle also exposes snapTo. Store the handle in the screen owner and close it when that owner no longer needs the surface. There is no handle.dispose method.',
          'The declarative NibDialog and NibBottomSheet widgets connect their own overlay handles to optional controllers and close them during their lifecycle. With an imperative helper, the caller owns the decision to close. A root overlay is not automatically tied to a nested route’s lifetime.',
          'Closing an animated surface has two stages: a result is reported, then the exit finishes and the entry is removed. Do not treat the result future as a screenshot-ready guarantee that every exit frame has completed. Dialog and sheet handles report whether the entry is still mounted through isOpen.',
        ],
        blocks: [
          DocLink(
            'External controller ownership',
            '/docs/components/state-and-controllers',
          ),
        ],
      ),
      DocSection(
        id: 'focus-theme-and-toast',
        heading: 'Account for focus, theme, and toast ownership',
        paragraphs: [
          'Dialogs create a focus scope, hide underlying semantics, and restore the previous focus when removed. barrierDismissible governs barrier and Escape dismissal. If you disable dismissal, keep an explicit reachable action inside the surface. Sheets have their own dismissible and drag-handle controls; test the specific exit paths you enable.',
          'Dialog and sheet entries recapture the caller’s inherited themes when rebuilding and depend on the root theme. Theme capture does not copy arbitrary application state objects into the overlay. Pass the data and callbacks the content needs, and avoid reading a disposed caller after an async operation.',
          'showNibToast returns an ID rather than a result future. Supply a context with an Overlay, or install NibToaster for context-free calls. Keep the ID if you must dismiss the toast using dismissNibToast. Duration.zero leaves it visible until dismissal. Reusing an ID follows onDuplicateTrigger; the default is shake, with ignore and replace alternatives.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'accessibility',
    title: 'Accessible component composition',
    summary: 'Name controls, preserve keyboard paths, and verify the final screen at useful text sizes.',
    evidence: 'ComponetsNib/nib_components/lib/src/button/nib_button.dart; ComponetsNib/nib_components/lib/src/checkbox/nib_checkbox.dart; ComponetsNib/nib_components/lib/src/radio_group/nib_radio_group.dart; ComponetsNib/nib_components/lib/src/select/nib_select.dart; ComponetsNib/nib_components/lib/src/dialog/show_nib_dialog.dart; ComponetsNib/nib_components/lib/src/card/nib_flip_card.dart; ComponetsNib/nib_components/lib/src/loader/nib_circular_loader.dart',
    sections: [
      DocSection(
        id: 'accessible-names',
        heading: 'Name the action, then expose its state',
        paragraphs: [
          'Prefer a visible label that describes the action. An icon-only NibButton needs semanticLabel, such as Add note. The button constructor requires a label, content, or semanticLabel; a custom content widget still needs a meaningful accessible name. When semanticLabel is supplied, the button replaces its descendant semantics with that name, so include all information needed to identify the action.',
          'NibCheckbox and NibSwitch can use their visible label as the semantic name, with semanticLabel as an override. NibRadioGroup has a group label and option labels. NibSelect uses its semanticLabel or placeholder. Choose labels that distinguish neighboring controls instead of announcing several identical Select buttons.',
        ],
        code: r'''NibButton(
  semanticLabel: 'Add note',
  leadingIcon: const Icon(Icons.add),
  onPressed: () {},
)''',
        blocks: [
          DocLink(
            'Button content and semantic labels',
            '/docs/components/button',
          ),
          DocLink('Selection controls', '/docs/components/checkbox'),
          DocLink('Select labels and options', '/docs/components/select'),
        ],
      ),
      DocSection(
        id: 'keyboard-path',
        heading: 'Walk the screen with the keyboard',
        paragraphs: [
          'Start before the component and move through it using Tab and Shift+Tab. Activate buttons with Enter or Space. In NibRadioGroup, one option is the tab stop; arrow keys move and select among enabled options. Test custom optionBuilder content with that same path, because custom visuals do not replace the group’s keyboard contract.',
          'Keep a visible focus ring after changing theme tokens. When you supply a FocusNode, retain it in State and dispose it yourself. Avoid setting autofocus on many competing controls. For a dialog, verify that focus enters the dialog, remains on available actions, and returns to its trigger when it closes.',
        ],
        blocks: [
          DocLink(
            'Radio group keyboard navigation',
            '/docs/components/radio-group',
          ),
          DocLink('Overlay focus and dismissal', '/docs/components/overlays'),
          DocLink(
            'Navigation menu interaction',
            '/docs/components/navigation-menu',
          ),
        ],
      ),
      DocSection(
        id: 'size-and-content',
        heading: 'Test the hit target and the actual text',
        paragraphs: [
          'A control’s visible height and interactive target are not always the same. NibButton has a package minimum tap-target mechanism around smaller visual sizes. Check the painted control and its surrounding hit region in the layout you ship, especially after adding clipping, transforms, or tightly constrained rows.',
          'Use realistic long labels and increased text scaling at narrow widths. Prefer wrapping action rows or vertical stacking when space is limited. Do not use a FittedBox to shrink essential text merely to avoid overflow. Include error messages, loading text, translated labels, and selected values in the review.',
          'Readability also depends on the backdrop. Glass content needs sufficient contrast over the backgrounds it can actually cover. Decorative grids and illustrations should not add unrelated semantic nodes. Essential instructions must remain readable when decorative motion or shader effects are unavailable.',
        ],
        blocks: [
          DocLink(
            'Theme tokens and contrast states',
            '/docs/components/theming',
          ),
          DocLink(
            'Glass content and rendering fallback',
            '/docs/components/liquid-glass',
          ),
        ],
      ),
      DocSection(
        id: 'status-and-errors',
        heading: 'Make errors and busy states understandable',
        paragraphs: [
          'Keep field labels visible while an error is shown. A validator should say what to fix, and a submission status should say what happened. Color alone is insufficient. NibInput and NibTextarea display error or helper text; your host decides whether to focus the first invalid field and where a summary belongs.',
          'A custom-painted NibCircularLoader does not provide a task name on its own. Add a semantic status such as Saving changes, and provide readable static feedback under reduced motion. Avoid announcing every animation frame or repeated polling update as a live region. Announce a meaningful status change.',
          'NibFlipCard accepts frontSemanticLabel and backSemanticLabel for tappable faces. Its visibility and focus behavior also depends on the resolved NibFlip implementation. The current local motion candidate gates focus and semantics by the actually visible face; do not infer that every older hosted dependency has that repair.',
        ],
        blocks: [
          DocLink(
            'Validation and error precedence',
            '/docs/components/validation',
          ),
          DocLink(
            'Motion exceptions and static busy feedback',
            '/docs/components/motion-opt-in',
          ),
        ],
      ),
      DocSection(
        id: 'verification-boundary',
        heading: 'Separate widget checks from assistive-technology runs',
        paragraphs: [
          'Widget tests can inspect semantic names, roles, checked state, keyboard callbacks, focus, and layout bounds. Use them to catch regressions in your composition. Test disabled and loading states too, so an unavailable action is not still exposed as actionable.',
          'A passing semantics test is not a screen-reader or physical touch pass. Run the finished screen with the assistive technologies and devices you support, record the package revisions and environment, and check reading order, announcements, focus restoration, and touch targets. The website preview does not certify those external checks.',
        ],
      ),
    ],
  ),
  DocArticle(
    packageId: 'components',
    id: 'validation',
    title: 'Validation and forms',
    summary: 'Build a local validation flow, understand each rule, and keep server errors distinct from drafts.',
    evidence: 'ComponetsNib/nib_components/lib/src/validation/nib_validators.dart; ComponetsNib/nib_components/lib/src/input/nib_input.dart; ComponetsNib/nib_components/lib/src/textarea/nib_textarea.dart; ComponetsNib/nib_components/lib/src/checkbox/nib_checkbox.dart; ComponetsNib/nib_components/lib/src/select/nib_select.dart',
    sections: [
      DocSection(
        id: 'form-contract',
        heading: 'Put participating fields inside Form',
        paragraphs: [
          'NibInput and NibTextarea extend FormField<String>. A parent Form can validate, save, and reset them. NibValidator is String? Function(String?): return null when valid and a useful error string when invalid. validate runs the rules; save invokes onSaved callbacks. Neither operation submits data to a backend.',
          'Keep the GlobalKey<FormState> in the screen’s State so it survives rebuilds. Validate before saving. For fields that must be present, place required before format rules so an empty field gets the most useful first message. AutovalidateMode.onUserInteraction is the default for both text widgets.',
        ],
        code: r'''// Fields and method inside a State class.
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
        NibValidators.required('Enter your email.'),
        NibValidators.email(),
      ]),
      onSaved: (value) => savedEmail = value?.trim() ?? '',
    ),
    NibButton(
      label: 'Check details',
      onPressed: () {
        if (formKey.currentState?.validate() != true) return;
        formKey.currentState!.save();
        setState(() => status = 'Details checked for $savedEmail');
      },
    ),
    Text(status),
  ]),
);''',
        note: 'This is a local validation example. The status means the local rules passed, not that an address was verified or saved on a server.',
      ),
      DocSection(
        id: 'validator-reference',
        heading: 'Choose and compose the actual rules',
        paragraphs: [
          'compose evaluates validators in order and returns the first error. Except for required, the supplied format and length rules accept a null or empty value. They do not trim or normalize all input uniformly. Decide whether trimming is appropriate for your field; never silently trim passwords.',
        ],
        blocks: [
          DocTable(
            headers: ['Rule', 'Behavior and limits'],
            rows: [
              [
                'required([message])',
                'Rejects null, empty, and whitespace-only values.',
              ],
              [
                'minLength(length, [message])',
                'Checks String.length for non-empty values.',
              ],
              [
                'maxLength(length, [message])',
                'Checks String.length for non-empty values.',
              ],
              [
                'email([message])',
                'Checks the package regex. It does not verify delivery or cover every valid international address.',
              ],
              [
                'pattern(RegExp, [message])',
                'Uses RegExp.hasMatch. Supply anchors when the whole value must match.',
              ],
              [
                'name([message])',
                'Trims first; requires a Unicode letter initially, then letters, spaces, apostrophes, or hyphens. This is a restricted policy, not a universal model of names.',
              ],
              [
                'phone([message])',
                'Trims first; accepts the package 7–20 character pattern with optional leading plus and digits, spaces, hyphens, parentheses, and periods. It does not verify a reachable number.',
              ],
              [
                'password(...)',
                'Checks length, then requested uppercase, lowercase, number, and special-character requirements in that order.',
              ],
            ],
          ),
        ],
        api: [
          DocApiEntry(
            name: 'NibValidators.compose',
            type: 'NibValidator Function(List<NibValidator>)',
            defaultValue: 'First error wins',
            description: 'Combine mandatory and format checks in the order the user should fix them.',
          ),
          DocApiEntry(
            name: 'NibValidators.password',
            type: 'NibValidator',
            defaultValue: 'minLength: 8; uppercase/lowercase/number: true; special character: false',
            description: 'Enforces the chosen character rules; it is not an account-security or password-strength service.',
          ),
        ],
      ),
      DocSection(
        id: 'length-and-custom-rules',
        heading: 'Keep input limits and validation distinct',
        paragraphs: [
          'A text field’s maxLength controls its input behavior. A validator still matters for values supplied programmatically or loaded from storage. NibValidators.minLength and maxLength use Dart String.length, which counts UTF-16 code units rather than user-perceived grapheme clusters. An emoji or combined character can therefore count differently from Flutter’s visible character counter.',
          'Write a custom NibValidator when the built-in policy does not fit. Keep it synchronous and deterministic. A rule can check a local relationship, such as a confirmation matching a password, but an async server check belongs in the host submission flow. Revalidate dependent fields when the value they depend on changes.',
        ],
        code: r'''NibValidator projectCode() => (value) {
  if (value == null || value.isEmpty) return null;
  return RegExp(r'^[A-Z]{3}-[0-9]{3}$').hasMatch(value)
      ? null
      : 'Use three capital letters, a dash, and three digits.';
};''',
      ),
      DocSection(
        id: 'server-errors',
        heading: 'Show server feedback without losing the draft',
        paragraphs: [
          'errorText is a host-supplied forced error. The current candidate forwards it to FormField.forceErrorText, so Form.validate fails while it is set and the validator is not evaluated. It takes precedence over the validator and helper text. Keep it in application state, associate it with the submitted value, and clear or replace it when that value changes.',
          'Disable repeated submission while a request is pending, retain the draft on failure, and ignore responses belonging to an older draft. After an await, check mounted before updating the screen. The backend must still validate and authorize the request; a passing local regex is only local feedback.',
        ],
        blocks: [
          DocLink(
            'Loading and asynchronous state ownership',
            '/docs/components/state-and-controllers',
          ),
        ],
      ),
      DocSection(
        id: 'reset-and-other-controls',
        heading: 'Decide what reset means for the whole form',
        paragraphs: [
          'Form.reset resets participating FormFields. NibInput and NibTextarea write their current FormField.initialValue into the effective controller. Without a controller, that baseline comes from initialValue. With a controller, the widget constructor seeds the baseline from controller.text. A parent rebuild can therefore update that baseline to the current draft. Keep an explicit saved draft in the host if Reset must always restore a particular saved value.',
          'NibCheckbox, NibSwitch, NibSelect, and other selection widgets are not automatically registered as text FormFields by placing them inside Form. Reset their owned values or controllers explicitly. For a required agreement or selection, use a host-owned FormField wrapper or a submission check with visible feedback. Avoid implying that Form.validate has checked values it never received.',
        ],
        blocks: [
          DocLink('Input and textarea controls', '/docs/components/input'),
          DocLink('Textarea options', '/docs/components/textarea'),
          DocLink('Select ownership', '/docs/components/select'),
          DocLink('Checkbox state', '/docs/components/checkbox'),
        ],
      ),
      DocSection(
        id: 'exercise-the-form',
        heading: 'Exercise the failure paths before submitting',
        paragraphs: [
          'Try empty input, whitespace, malformed values, valid values, and programmatic edits. Check which rule reports first and whether fixing a field clears its feedback. Test reset with and without an external controller. Then test a delayed server error arriving after the user has edited the field again.',
          'Use keyboard navigation and increased text scaling while error messages are visible. Keep focus and selection stable during style changes. These checks establish the form’s local interaction contract; they do not validate a production backend that is absent from this example.',
        ],
      ),
    ],
  ),
];
