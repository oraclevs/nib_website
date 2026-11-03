import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const _demoFile = 'lib/components/examples/overlay_family_demos.dart';
const _animate = ComponentControl(
  'animated',
  'Animate opening and closing',
  ComponentControlKind.toggle,
);
const _title = ComponentControl(
  'text',
  'Surface title',
  ComponentControlKind.text,
);
const _outside = ComponentControl(
  'interactive',
  'Allow outside dismissal',
  ComponentControlKind.toggle,
);

const overlayComponentGuides = <ComponentGuide>[
  _alertGuide,
  _dialogGuide,
  _sheetGuide,
  _popoverGuide,
  _hoverGuide,
  _contextGuide,
  _commandGuide,
  _toastGuide,
];

const _alertGuide = ComponentGuide(
  id: 'alert-dialog',
  title: 'Alert dialog',
  category: 'Overlays',
  summary: 'Ask for a decision and distinguish confirmation, cancellation, and dismissal.',
  symbols: ['NibAlertSeverity', 'NibAlertSeverityX', 'showNibAlertDialog'],
  source:
      'ComponetsNib/nib_components/lib/src/alert/show_nib_alert_dialog.dart',
  demoClass: 'AlertDialogComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(text: 'Use this label?', variant: 'info'),
  previewHeight: 560,
  controls: [
    _title,
    ComponentControl(
      'variant',
      'Severity',
      ComponentControlKind.choice,
      choices: ['info', 'success', 'warning', 'error'],
    ),
    _outside,
    ComponentControl(
      'multiple',
      'Adaptive platform presentation',
      ComponentControlKind.toggle,
    ),
    _animate,
  ],
  minimalCode: '''final confirmed = await showNibAlertDialog(
  context,
  title: 'Use this label?',
  description: 'This changes the local preview only.',
  severity: NibAlertSeverity.info,
  confirmText: 'Apply locally',
  cancelText: 'Keep current',
);
if (!context.mounted) return;
if (confirmed == true) { /* Apply the confirmed change. */ }''',
  sections: [
    DocSection(
      id: 'decision',
      heading: 'Ask one clear question',
      paragraphs: [
        'Use showNibAlertDialog when the next step needs a yes-or-no answer: applying a preference, leaving a draft, or acknowledging a result. The helper supplies the dialog surface and action buttons. It is a function; there is no public NibAlert widget in this package.',
        'The example changes only its local result label. Apply locally returns true, Keep current returns false, and dismissal returns null. Your application decides what those answers authorize. An alert does not implement server permissions or undo.',
      ],
    ),
    DocSection(
      id: 'severity',
      heading: 'Choose severity and content',
      paragraphs: [
        'NibAlertSeverity offers info, success, warning, and error. NibAlertSeverityX.defaultIcon() and accent(NibTheme) resolve the visual cue. Error chooses a destructive confirm button unless confirmVariant overrides it. A red button does not make an operation safe.',
        'Supply title, description, or content. Custom content replaces the built-in body and must include its own heading and explanation. The live example uses that slot to show the severity icon and retain its scope for cleanup. icon, iconColor, titleTextStyle, and descriptionTextStyle customize the built-in body.',
      ],
    ),
    DocSection(
      id: 'actions',
      heading: 'Handle one result, once',
      paragraphs: [
        'cancelText: null creates a single-action acknowledgment. onConfirm and onCancel run for the default buttons; outside dismissal is a third outcome. Put a business action in either the awaited result handler or the callback to avoid executing it twice.',
        'actions replaces the default pair. Custom buttons own their result behavior and should close through NibDialogScope.of(aContextInsideTheDialog).close(true) or close(false). Use showNibDialog<T> for a result richer than a boolean.',
      ],
      code: '''await showNibAlertDialog(
  context,
  title: 'Changes saved',
  severity: NibAlertSeverity.success,
  confirmText: 'Continue',
  cancelText: null,
);''',
    ),
    DocSection(
      id: 'layout',
      heading: 'Fit the actions to the available space',
      paragraphs: [
        'buttonWidth, buttonPadding, cancelVariant, and confirmVariant shape the default buttons. actionsAlignment, actionsSpacing, actionsOverflowAlignment, actionsOverflowDirection, and cancelFirst control layout. The Material action OverflowBar can stack when labels do not fit. Test translations and text scaling.',
        'adaptive defaults to false. When true, iOS and macOS receive the helper’s Cupertino-style presentation; other platforms retain the Material-style presentation. This is Nib’s implementation. A target-platform override in a widget test is not a physical iPhone accessibility pass.',
      ],
    ),
    DocSection(
      id: 'ownership',
      heading: 'Keep lifetime and focus explicit',
      paragraphs: [
        'The helper inserts into the root overlay. In the website, this is a deliberate page-modal task: its barrier can cover the page, rather than only the preview card. The surface captures inherited themes, creates a focus scope, and restores previous focus when removed. The alert body uses an inert initial focus sink, so do not assume the first action is selected.',
        'Check mounted after awaiting. Dropping a Future does not cancel the surface. The complete example retains a close callback captured from the active scope and calls it on disposal. Never look up an ancestor from a deactivated context. Keep a visible action when outside dismissal is disabled.',
      ],
    ),
    DocSection(
      id: 'limits',
      heading: 'Read dismissal correctly',
      paragraphs: [
        'barrierDismissible controls outside dismissal. animated defaults to false; transition configures optional motion. A null result is neither acceptance nor rejection. Use Builder inside content or actions when the page context cannot find NibDialogScope.',
        'Validate the actual barrier area, Escape behavior, focus return, and action labels in your host. These local examples do not certify a production authorization flow, physical touch, or a screen reader.',
      ],
    ),
  ],
);

const _dialogGuide = ComponentGuide(
  id: 'dialog',
  title: 'Dialog',
  category: 'Overlays',
  summary: 'Open a focused task, return a typed result, and choose who owns its lifetime.',
  symbols: [
    'NibDialog',
    'NibDialogAnimation',
    'NibDialogSize',
    'nibDialogMaxWidth',
    'resolveNibDialogEnter',
    'NibDialogController',
    'NibDialogHandle',
    'NibDialogScope',
    'openNibDialog',
    'showNibDialog',
  ],
  source: 'ComponetsNib/nib_components/lib/src/dialog/show_nib_dialog.dart',
  demoClass: 'DialogComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(
    text: 'Choose a draft title',
    variant: 'fadeScale',
    backdrop: 'md',
  ),
  previewHeight: 560,
  controls: [
    _title,
    ComponentControl(
      'variant',
      'Entrance preset',
      ComponentControlKind.choice,
      choices: ['none', 'fade', 'scale', 'fadeScale', 'slideUp'],
    ),
    ComponentControl(
      'backdrop',
      'Surface size',
      ComponentControlKind.choice,
      choices: ['sm', 'md', 'lg', 'fullscreen'],
    ),
    _outside,
    _animate,
  ],
  minimalCode: '''final result = await showNibDialog<String>(
  context,
  title: 'Choose a title',
  content: Builder(builder: (dialogContext) => NibButton(
    label: 'Use this title',
    onPressed: () => NibDialogScope.of(dialogContext).close('Draft'),
  )),
);
if (!context.mounted) return;
// result is 'Draft', or null when dismissed.''',
  sections: [
    DocSection(
      id: 'entry-points',
      heading: 'Choose an ownership model',
      paragraphs: [
        'showNibDialog<T> returns Future<T?> when the caller only needs a result. openNibDialog<T> returns NibDialogHandle<T>, exposing closed, isOpen, and close(result). Keep that handle when an application event must close the task. NibDialog is the declarative wrapper, opened by a trigger or NibDialogController.',
        'The three buttons exercise all three entry points with the same content. The scoped action returns a string for imperative calls. The declarative wrapper reports closure through onClose, rather than returning a typed Future. Avoid using an unrelated imperative surface and a controller to represent the same task.',
      ],
    ),
    DocSection(
      id: 'content',
      heading: 'Build the task inside the surface',
      paragraphs: [
        'content is required. title and description create the standard heading; header replaces that heading. footer holds actions below the scrolling content. Keep form keys, validation, and editing controllers in a stateful content widget when the task is a form.',
        'NibDialogSize is a width ceiling: sm is 380, md is 512, and lg is 720 logical pixels. fullscreen fills the safe viewport and has no numeric ceiling. width overrides the ordinary ceiling; narrow screens still constrain it. nibDialogMaxWidth returns the preset ceiling, or null for fullscreen.',
      ],
      blocks: [
        DocTable(
          headers: ['Setting', 'Meaning'],
          rows: [
            ['content', 'Required scrolling task body'],
            ['header / footer', 'Custom heading / persistent actions'],
            ['barrierDismissible', 'Outside dismissal; true by default'],
            ['showCloseButton', 'Built-in close affordance; true by default'],
          ],
        ),
      ],
    ),
    DocSection(
      id: 'result',
      heading: 'Return a value from the right context',
      paragraphs: [
        'NibDialogScope.of(context) is available inside the surface. Its close accepts a result compatible with T; isOpen describes the surface. A page context captured before insertion is above this scope. Builder inside content gives the correct context.',
        'handle.closed completes after removal. Await it and check mounted before updating the caller. Treat null as dismissal. A repeated close is ignored by the surface. The handle is useful when cancellation comes from somewhere other than a dialog button.',
      ],
      code: '''final handle = openNibDialog<String>(
  context,
  title: 'Working draft',
  content: const Text('An application event can close this task.'),
);
if (handle.isOpen) handle.close('cancelled');
final result = await handle.closed;''',
    ),
    DocSection(
      id: 'motion',
      heading: 'Choose motion separately from timing',
      paragraphs: [
        'animated is false by default. NibDialogAnimation selects none, fade, scale, fadeScale, or slideUp; transition controls timing or spring response separately. resolveNibDialogEnter maps a preset to its NibAnim start: slideUp uses y: 16 and opacity zero; fadeScale uses scale .97 and opacity zero.',
        'The none preset removes the card transform; an animated scrim can still fade. The surface respects reduced motion. Reopening a task is a new entrance, not an automatic retarget from one dialog into a different task.',
      ],
    ),
    DocSection(
      id: 'controller',
      heading: 'Keep one controller and a clear focus path',
      paragraphs: [
        'Create NibDialogController once in State and dispose it there. open and close are idempotent; isOpen is observable through ChangeNotifier. Without an external controller the widget owns one. A trigger wrapper expects a non-interactive child; a nested NibButton should call controller.open itself.',
        'The root overlay receives the dialog, inherited theme, and focus scope. These website dialogs are page-modal. Escape closes the focused surface and prior focus is restored when it is still attached. Test nested tasks and focus return in your actual app.',
      ],
    ),
    DocSection(
      id: 'cleanup',
      heading: 'Close work when its owner leaves',
      paragraphs: [
        'An imperative dialog remains in its overlay until closed or that overlay is removed. The example captures the active scope object, retains a close callback, and calls it during disposal. It does not perform an ancestor lookup from dispose.',
        'If opening does nothing, inspect nested gestures. If the wrong task closes, inspect the scope context. Validate a form before returning success and cancel or ignore stale async work. This component supplies presentation and lifecycle, not backend submission or authorization.',
      ],
    ),
  ],
);

const _sheetGuide = ComponentGuide(
  id: 'bottom-sheet',
  title: 'Bottom sheet',
  category: 'Overlays',
  summary:
      'Let a local task expand between snap heights and return a typed result.',
  symbols: [
    'NibBottomSheet',
    'NibBottomSheetController',
    'NibBottomSheetHandle',
    'NibBottomSheetScope',
    'openNibBottomSheet',
    'showNibBottomSheet',
    'clampInitialSnapIndex',
    'kNibSheetFlingVelocity',
    'kNibSheetMinExtent',
    'normalizeSnapExtents',
    'resolveSnapTarget',
  ],
  source: 'ComponetsNib/nib_components/lib/src/bottom_sheet/show_nib_bottom_sheet.dart',
  demoClass: 'BottomSheetComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(text: 'Reading list', value: 45),
  previewHeight: 560,
  controls: [
    _title,
    ComponentControl(
      'value',
      'First snap: percent of available height',
      ComponentControlKind.number,
      minimum: 30,
      maximum: 60,
    ),
    ComponentControl(
      'showBorder',
      'Show drag handle',
      ComponentControlKind.toggle,
    ),
    _outside,
    _animate,
  ],
  minimalCode: '''final result = await showNibBottomSheet<String>(
  context,
  title: 'Reading list',
  snapPoints: const [.45, .85],
  initialSnap: 0,
  content: Builder(builder: (sheetContext) => NibButton(
    label: 'Use list',
    onPressed: () => NibBottomSheetScope.of(sheetContext).close('selected'),
  )),
);''',
  sections: [
    DocSection(
      id: 'task',
      heading: 'Reveal a task from the bottom',
      paragraphs: [
        'Use a sheet for a contextual task that benefits from more height: a reading list, filter summary, or item details. NibBottomSheet is an overlay surface, not bottom navigation. The example starts at the smaller snap, expands through an explicit action, and returns a string when the list is chosen.',
        'showNibBottomSheet<T> returns a Future. openNibBottomSheet<T> returns NibBottomSheetHandle<T> with closed, isOpen, close(result), and snapTo(index). The widget NibBottomSheet uses a trigger or NibBottomSheetController. The three preview buttons exercise each ownership model.',
      ],
    ),
    DocSection(
      id: 'snaps',
      heading: 'Understand fractions and normalized indexes',
      paragraphs: [
        'snapPoints are fractions of available height, not pixels. normalizeSnapExtents clamps them to .05 through 1, removes duplicates, and sorts ascending. Null or an empty list means a content-sized sheet with one implicit snap. kNibSheetMinExtent exposes the .05 minimum.',
        'initialSnap is an index into the normalized list. Null selects the last snap. clampInitialSnapIndex clamps negative indexes to zero and high indexes to the last index. An unsorted input list does not retain its original indexes. These details follow the implementation, including the negative-index case.',
      ],
      code:
          '''final snaps = normalizeSnapExtents([.85, .45, .85])!; // [.45, .85]
final index = clampInitialSnapIndex(snaps.length, 0); // 0
// Pass these same normalized values to the sheet.''',
    ),
    DocSection(
      id: 'release',
      heading: 'Know what a drag release means',
      paragraphs: [
        'resolveSnapTarget is the pure helper used to settle a drag. velocity is measured in extent-fractions per second, positive when opening upward. kNibSheetFlingVelocity defaults to 2. A fast release steps to the next snap; a downward release below the lowest snap can dismiss only if dismissible is true.',
        'A slow release chooses the nearest snap, or dismisses below half the lowest extent when permitted. Do not pass raw pointer pixels per second to this helper. The widget converts using available height. snapTo requests a snap index; onSnapChanged reports the selected index. The example asserts a real height change after expanding.',
      ],
    ),
    DocSection(
      id: 'scope',
      heading: 'Expand or finish from inside',
      paragraphs: [
        'NibBottomSheetScope.of(sheetContext) exposes snapTo, close, and isOpen inside content. Expand sheet requests index 1. Use reading list returns a string. A dismissal returns null. After awaiting, check mounted before updating the caller.',
        'Use Builder inside content to obtain the scope. For an external command retain a handle or controller rather than a BuildContext. The complete example captures a scope close callback while active, then closes its imperative surface during disposal.',
      ],
    ),
    DocSection(
      id: 'controller',
      heading: 'Own controllers and presentation',
      paragraphs: [
        'NibBottomSheetController exposes open, close, snapTo, isOpen, pendingSnap, and consumePendingSnap. The last two form the handoff used by the attached widget; let it consume requests. Dispose an external controller in its owner. The widget owns its internal controller when none is supplied.',
        'title, showDragHandle, dismissible, and barrierColor describe the surface. animated defaults to false; transition configures optional movement. The root overlay captures the inherited theme and supplies a focus scope. These website sheet tasks are page-modal; a visible completion action remains when outside dismissal is off.',
      ],
    ),
    DocSection(
      id: 'constraints',
      heading: 'Design for the smallest useful height',
      paragraphs: [
        'Scrolling content does not eliminate the space needed by headers and actions. Test the smallest snap with long labels, text scaling, and keyboard insets. The preview permits a first snap from 30 to 60 percent to keep its actions reachable; that range is an example choice, not a package limit.',
        'Close or cancel work when the workflow leaves the page. VM tests cover returned results and numeric expansion, but physical dragging, platform keyboard insets, and screen-reader behavior remain separate checks. A sheet is not an authorization or data-persistence layer.',
      ],
    ),
  ],
);

const _popoverGuide = ComponentGuide(
  id: 'popover',
  title: 'Popover',
  category: 'Overlays',
  summary: 'Anchor a small interactive task to its trigger and close it through a local scope.',
  symbols: [
    'NibPopover',
    'NibPopoverPlacement',
    'NibPopoverScope',
    'NibPopoverController',
  ],
  source: 'ComponetsNib/nib_components/lib/src/popover/nib_popover.dart',
  demoClass: 'PopoverComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(
    text: 'Choose a reading tag',
    variant: 'bottom',
    value: 260,
  ),
  previewHeight: 560,
  controls: [
    _title,
    ComponentControl(
      'variant',
      'Preferred side',
      ComponentControlKind.choice,
      choices: ['bottom', 'top', 'start', 'end'],
    ),
    ComponentControl(
      'value',
      'Maximum panel width',
      ComponentControlKind.number,
      minimum: 180,
      maximum: 360,
    ),
    ComponentControl('showBorder', 'Show arrow', ComponentControlKind.toggle),
    _outside,
    _animate,
  ],
  minimalCode: '''NibPopover(
  trigger: const Padding(
    padding: EdgeInsets.all(12), child: Text('Choose a tag'),
  ),
  content: Builder(builder: (popoverContext) => NibButton(
    label: 'Pick Flutter',
    onPressed: () => NibPopoverScope.of(popoverContext).close(),
  )),
)''',
  sections: [
    DocSection(
      id: 'task',
      heading: 'Keep the task next to its trigger',
      paragraphs: [
        'Use a popover for tags, a small toolbar, or a short explanation with a choice. The example records Flutter as the selected reading tag and closes from the panel. Use a dialog when the task needs modal focus containment.',
        'content is required. A trigger gives the panel a meaningful anchor. Its wrapper toggles on tap; if the trigger is an interactive button, connect that button to an explicit NibPopoverController instead of relying on a parent gesture. The complete example does this.',
      ],
    ),
    DocSection(
      id: 'placement',
      heading: 'Treat placement as a preference',
      paragraphs: [
        'NibPopoverPlacement offers bottom, top, start, and end. Positioning can flip and clamp to the available viewport. gap separates trigger and panel; maxWidth is a ceiling. showArrow defaults to false. Check edges and right-to-left layouts rather than assuming the preferred side always fits.',
        'This anchored family uses the nearest overlay, so its bounded website preview differs from page-modal root helpers. The candidate geometry repairs convert positions into the owning overlay coordinate space. A passing root-overlay example alone cannot prove local-overlay bounds.',
      ],
    ),
    DocSection(
      id: 'closing',
      heading: 'Keep an exit available',
      paragraphs: [
        'dismissOnOutsideTap defaults to true. When false, close with the controller or NibPopoverScope.of(popoverContext).close(). The scope also exposes isOpen. The selected tag is application state; onOpen and onClose only report presentation changes.',
        'Outside dismissal uses a pointer barrier. Non-modal does not mean every click passes through. barrierColor can tint that layer, but the popover does not trap focus like a dialog. Keep the trigger and an in-panel action reachable by keyboard.',
      ],
    ),
    DocSection(
      id: 'controller',
      heading: 'Keep one controller per surface',
      paragraphs: [
        'NibPopoverController exposes open, close, toggle, and isOpen. Create it once in State and dispose it in that owner. NibPopover removes its listeners and overlay on unmount. Without an external controller it owns one internally.',
        'The complete example keeps the controller across inspector changes. Do not recreate it inside build. Store selected values or asynchronous task state separately: the controller represents whether the surface is open, not whether a request succeeded.',
      ],
    ),
    DocSection(
      id: 'theme',
      heading: 'Use inherited tokens and optional motion',
      paragraphs: [
        'The panel uses NibTheme card, foreground, border, and radius values from its opening context. semanticLabel describes the trigger purpose. Keep it meaningful rather than repeating a generic widget name.',
        'animated defaults to false. transition controls optional timing or spring response; enterFrom supplies a NibAnim start state. Reduced motion must leave text and choices usable. The example uses the actual package transition, not a separate visual substitute.',
      ],
    ),
    DocSection(
      id: 'troubleshooting',
      heading: 'Check the trigger and scope context',
      paragraphs: [
        'If a nested button consumes the opening tap, connect its callback to controller.toggle. If closing cannot find NibPopoverScope, use Builder inside content. If the panel clips, inspect the actual overlay bounds, text scale, and longest label.',
        'This primitive supplies a surface and positioning, not form validation, selection storage, or authorization. The tag result is local state. Cancel or ignore stale async responses when the owner leaves or a different choice becomes active.',
      ],
    ),
  ],
);

const _hoverGuide = ComponentGuide(
  id: 'hover-card',
  title: 'Hover card',
  category: 'Overlays',
  summary: 'Reveal extra context after hover intent, with a path for touch and keyboard users.',
  symbols: ['NibHoverCard', 'NibHoverCardPlacement', 'NibHoverCardController'],
  source: 'ComponetsNib/nib_components/lib/src/hover_card/nib_hover_card.dart',
  demoClass: 'HoverCardComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(
    text: 'Ada, example author',
    variant: 'bottom',
    value: 500,
  ),
  previewHeight: 560,
  controls: [
    ComponentControl('text', 'Profile heading', ComponentControlKind.text),
    ComponentControl(
      'variant',
      'Preferred side',
      ComponentControlKind.choice,
      choices: ['bottom', 'top', 'start', 'end'],
    ),
    ComponentControl(
      'value',
      'Hover delay in milliseconds',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 1000,
    ),
    _animate,
  ],
  minimalCode: '''NibHoverCard(
  trigger: const Text('@ada'),
  content: const Text('Writes examples and reviews patches.'),
  showDelay: const Duration(milliseconds: 500),
  hideDelay: const Duration(milliseconds: 300),
  semanticLabel: 'Contributor profile',
)''',
  sections: [
    DocSection(
      id: 'purpose',
      heading: 'Show supplemental context',
      paragraphs: [
        'Use a hover card for a contributor summary or link preview. Keep essential instructions in the page: touch screens have no hover and users may never pause over a trigger. The example also opens from a button and provides a close action.',
        'NibHoverCard requires content and normally has a trigger. NibHoverCardController permits an external action to open, close, or toggle it. The complete example’s NibButton calls that controller, so keyboard activation does not depend on a mouse event.',
      ],
    ),
    DocSection(
      id: 'delays',
      heading: 'Separate intent from crossing the gap',
      paragraphs: [
        'showDelay defaults to 700 milliseconds; hideDelay defaults to 300. Showing after a delay avoids flicker during a quick pass-over. The hide delay gives the pointer time to cross gap onto the card. Moving onto its content keeps it open. The slider changes real showDelay, not decorative speed.',
        'openOnTap defaults to true and supplies the built-in touch-style toggle. Setting it false removes that fallback, so keep an explicit control if the content matters. The demo’s button drives the controller independently. Pending show/hide timers belong to the widget and are cancelled when it is disposed.',
      ],
    ),
    DocSection(
      id: 'placement',
      heading: 'Give the content enough room',
      paragraphs: [
        'NibHoverCardPlacement offers bottom, top, start, and end. The panel flips or clamps as needed; gap and maxWidth control separation and the width ceiling. Keep the content short enough to fit near an edge. A hover card is a poor home for a multi-step form.',
        'The card is anchored to its trigger and captures inherited theme across the overlay boundary. Test the host’s real coordinate space. A bounded local preview and a root application overlay need separate geometry checks.',
      ],
    ),
    DocSection(
      id: 'focus',
      heading: 'Keep hover separate from focus',
      paragraphs: [
        'Hovering does not steal focus from the trigger. The card is not a modal focus trap. semanticLabel describes its purpose; the demo’s explicit button and close action provide a path without hover. onOpen and onClose report visibility changes.',
        'Do not place a required confirmation behind a hover-only surface. Use a dialog for an explicit decision. Desktop pointer tests do not establish touch, mobile browser, or screen-reader behavior.',
      ],
    ),
    DocSection(
      id: 'ownership',
      heading: 'Keep a stable controller',
      paragraphs: [
        'Create NibHoverCardController in State and dispose it there. open, close, toggle, and isOpen describe visibility, not loading state. Without an external controller the widget owns one. The example preserves its controller across property edits.',
        'Load profile data separately. Cancel or ignore an async result if the hovered identity changes or its owner is disposed. This example uses local text and starts no network work or recurring task.',
      ],
    ),
    DocSection(
      id: 'motion',
      heading: 'Tune the delay before adding movement',
      paragraphs: [
        'animated is false by default; transition and enterFrom customize optional NibMotion entrance and exit. A longer hover delay and a slower entrance solve different problems. The information must remain usable with reduced motion.',
        'If the card never opens, check its hit area, elapsed showDelay, and whether the pointer left. If it closes while crossing to the panel, check gap and hideDelay together. The regression asserts absence before the deadline and presence after it, plus explicit button behavior and cleanup.',
      ],
    ),
  ],
);

const _contextGuide = ComponentGuide(
  id: 'context-menu',
  title: 'Context menu',
  category: 'Overlays',
  summary: 'Offer pointer and keyboard access to grouped actions, disabled entries, and nested choices.',
  symbols: [
    'NibContextMenu',
    'NibMenuDivider',
    'NibMenuEntry',
    'NibMenuItem',
    'NibMenuSection',
    'showNibContextMenu',
  ],
  source: 'ComponetsNib/nib_components/lib/src/context_menu/show_nib_context_menu.dart',
  demoClass: 'ContextMenuComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(text: 'A note worth keeping'),
  previewHeight: 560,
  controls: [
    ComponentControl('text', 'Target note', ComponentControlKind.text),
    ComponentControl(
      'disabled',
      'Disable Pin note',
      ComponentControlKind.toggle,
    ),
    _animate,
  ],
  minimalCode: '''NibContextMenu(
  items: const [
    NibMenuSection('Reading list'),
    NibMenuItem(label: 'Pin note'),
    NibMenuDivider(),
    NibMenuItem(label: 'Move to', submenu: [
      NibMenuItem(label: 'Later'),
      NibMenuItem(label: 'Today'),
    ]),
  ],
  onItemSelected: (item) { /* Apply one selected action. */ },
  child: const Padding(padding: EdgeInsets.all(20), child: Text('A note')),
)''',
  sections: [
    DocSection(
      id: 'entries',
      heading: 'Build a menu from entries',
      paragraphs: [
        'NibMenuEntry is the common model. NibMenuItem is selectable, NibMenuSection supplies a group label, and NibMenuDivider separates groups. They are models rather than standalone rendered buttons. Supply them to NibContextMenu or showNibContextMenu.',
        'The demo groups reading-list actions, can disable Pin note, and puts Later and Today inside Move to. A leaf selection changes the local status. A disabled entry remains visible but cannot be selected; hiding an unavailable action is a separate application choice.',
      ],
    ),
    DocSection(
      id: 'opening',
      heading: 'Expose more than a right-click',
      paragraphs: [
        'NibContextMenu opens at the pointer on secondary tap or long press. enableSecondaryTap and enableLongPress are independently configurable and default to true. Open menu calls the imperative helper at the note’s measured global edge, providing a keyboard-accessible path.',
        'showNibContextMenu requires globalPosition. Compute it with RenderBox.localToGlobal at opening time; do not pass local pointer coordinates. Its Future returns a selected NibMenuItem or null. The helper targets the root overlay, so the website menu and dismissal layer use the page’s overlay.',
      ],
    ),
    DocSection(
      id: 'selection',
      heading: 'Perform each action once',
      paragraphs: [
        'NibMenuItem.onSelected is the leaf callback. onItemSelected on the wrapper or helper also reports a selection, and the helper returns that item. Put the side effect in one of these paths to avoid duplicates.',
        'The demo uses the wrapper callback for right-click/long-press and the awaited helper result for its button. It does not attach a second business callback to each item. enabled, destructive, icon, and trailing describe availability or appearance; destructive styling is not a confirmation mechanism.',
      ],
    ),
    DocSection(
      id: 'keyboard',
      heading: 'Navigate nested entries',
      paragraphs: [
        'submenu is another list of entries; hasSubmenu reports whether it is non-empty. Sections and dividers are skipped by keyboard navigation. Up/down moves the active entry, right enters a submenu, left returns, Enter activates, and Escape closes or steps back.',
        'Keep nesting shallow and labels recognizable. trailing may show a shortcut hint, but the menu does not register that shortcut. Test a real app binding before displaying one. The example avoids fictitious shortcut labels.',
      ],
    ),
    DocSection(
      id: 'lifecycle',
      heading: 'Close before leaving the workflow',
      paragraphs: [
        'The menu captures NibTheme from the opening context. animated and transition opt into motion; the default is static. The root overlay contains its barrier and levels. Previous focus is restored on closure when still attached.',
        'The show helper returns a Future, not a cancellation handle. Check mounted before updating State after the wait. A root-overlay menu can outlive the widget that opened it, so dismiss or complete it before removing the workflow. It is not a navigation route or security boundary.',
      ],
    ),
    DocSection(
      id: 'bounds',
      heading: 'Check root and submenu bounds',
      paragraphs: [
        'Opening near an edge requires checking both the first level and its submenu. Overlay origins matter: a global position must be converted before local layout. The candidate geometry repair addresses that conversion rather than moving the target away from an edge.',
        'The tests exercise helper selection, a disabled item, a submenu, and the long-press wrapper. Physical touch latency, platform context-menu interception, and screen-reader discovery remain separate checks. Keep the explicit button available when pointer hardware is absent.',
      ],
    ),
  ],
);

const _commandGuide = ComponentGuide(
  id: 'command-palette',
  title: 'Command palette',
  category: 'Overlays',
  summary:
      'Search actions, drill into a group, and keep a bounded recent history.',
  symbols: [
    'NibCommandAction',
    'NibCommandActionFilter',
    'NibCommandPalette',
    'NibCommandPaletteController',
  ],
  source: 'ComponetsNib/nib_components/lib/src/command_palette/nib_command_palette.dart',
  demoClass: 'CommandPaletteComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(text: 'Search local commands', multiple: true),
  previewHeight: 560,
  controls: [
    ComponentControl('text', 'Search placeholder', ComponentControlKind.text),
    ComponentControl(
      'disabled',
      'Disable Create draft',
      ComponentControlKind.toggle,
    ),
    ComponentControl(
      'searchable',
      'Substring matching (off: prefix only)',
      ComponentControlKind.toggle,
    ),
    ComponentControl(
      'multiple',
      'Show recent commands',
      ComponentControlKind.toggle,
    ),
    _animate,
  ],
  minimalCode: '''NibCommandPalette(
  actions: [
    NibCommandAction(
      id: 'new-draft', label: 'Create draft', group: 'Notes',
      onSelected: () { /* Create one local draft. */ },
    ),
  ],
  child: const Text('Use the configured palette shortcut.'),
)''',
  sections: [
    DocSection(
      id: 'actions',
      heading: 'Give commands stable identities',
      paragraphs: [
        'NibCommandAction carries id, label, optional subtitle, icon, shortcutLabel, group, children, onSelected, and disabled. Use stable unique ids: recent history stores ids and resolves them against the current action tree. An action with children drills down; a leaf performs the action.',
        'Create draft increments one local counter. Choose folder opens a second level; Later folder changes a local label. No files or services are modified. Disabling Create draft leaves the other commands available.',
      ],
    ),
    DocSection(
      id: 'search',
      heading: 'Make matching predictable',
      paragraphs: [
        'The default filter matches a case-insensitive substring in label or subtitle. NibCommandActionFilter defines a custom predicate. The inspector switches between the default and case-insensitive label prefix matching: raft matches Create draft under substring matching but not prefix matching.',
        'The predicate checks the current action set; it does not load remote commands or authorize them. Keep expensive work outside it. The query filters the current drill-down level, not an invented global search service.',
      ],
    ),
    DocSection(
      id: 'shortcut',
      heading: 'Choose a shortcut that belongs to the host',
      paragraphs: [
        'The default opener is Cmd+K or Ctrl+K according to platform. openShortcut accepts a ShortcutActivator. The widget installs a global HardwareKeyboard handler while mounted, so focus does not have to be inside its child. Multiple mounted palettes with the same activator can conflict.',
        'This preview uses Alt+Shift+P to avoid the website search shortcut, and provides Open commands. Mount only one active example at a time. shortcutLabel on an action is a display hint; it does not register the action’s shortcut.',
      ],
      code: '''// Also import package:flutter/services.dart.
NibCommandPalette(
  openShortcut: const SingleActivator(
    LogicalKeyboardKey.keyP, alt: true, shift: true,
  ),
  actions: actions,
  child: page,
)''',
    ),
    DocSection(
      id: 'history',
      heading: 'Record one result and bounded history',
      paragraphs: [
        'A leaf’s onSelected and the palette’s onActionSelected both fire. Put a business effect in one of them; use the other for observation if needed. The example increments its counter in the leaf and reports the selected id through the palette callback.',
        'showRecent controls the Recent section; maxRecent bounds stored ids. NibCommandPaletteController.recentActionIds is unmodifiable and newest-first. recordUsed(id, maxRecent) supports explicit integration, but ordinary selections already record history. Use a non-negative limit.',
      ],
    ),
    DocSection(
      id: 'controller',
      heading: 'Keep a controller outside build',
      paragraphs: [
        'Create NibCommandPaletteController in State. open, close, toggle, and isOpen control the surface; dispose it with its owner. Without an external controller the widget owns an internal one. The widget removes its global keyboard handler and overlay on disposal.',
        'The search field takes focus when opened and previous focus is restored on closure. Arrows, Enter, Escape, and drill-down/back navigation are supported. placeholder and hintStyle affect the search hint; backgroundColor changes the card fill. This palette inserts into the nearest overlay; in the website it remains within the active preview. Its keyboard handler is still global while mounted.',
      ],
    ),
    DocSection(
      id: 'limits',
      heading: 'Keep execution policy in the application',
      paragraphs: [
        'The palette does not provide authorization, persistence, backend idempotency, or command cancellation. Recheck permissions at dispatch for an operation affecting real data. A displayed disabled state is not a security check.',
        'animated defaults to false; transition configures optional motion. Tests cover filtering, leaf selection, nested choices, history, and removal. Operating-system shortcut conflicts and screen-reader behavior still need platform checks. If an action runs twice, inspect duplicate callbacks and mounted global handlers.',
      ],
    ),
  ],
);

const _toastGuide = ComponentGuide(
  id: 'toast',
  title: 'Toast',
  category: 'Overlays',
  summary: 'Announce a local outcome, handle duplicate ids, and provide an undo action.',
  symbols: [
    'NibToastDuplicateBehavior',
    'NibToastPosition',
    'NibToastPositionX',
    'NibToastVariant',
    'NibToastVariantX',
    'NibToaster',
    'dismissAllNibToasts',
    'dismissNibToast',
    'showNibToast',
  ],
  source: 'ComponetsNib/nib_components/lib/src/toast/show_nib_toast.dart',
  demoClass: 'ToastComponentDemo',
  demoFile: _demoFile,
  initial: ComponentSettings(
    text: 'Saved locally',
    variant: 'success',
    backdrop: 'bottomCenter',
    value: 0,
    multiple: true,
  ),
  previewHeight: 560,
  controls: [
    _title,
    ComponentControl(
      'variant',
      'Outcome style',
      ComponentControlKind.choice,
      choices: ['normal', 'success', 'error', 'warning', 'info'],
    ),
    ComponentControl(
      'backdrop',
      'Stack position',
      ComponentControlKind.choice,
      choices: [
        'topLeft',
        'topCenter',
        'topRight',
        'bottomLeft',
        'bottomCenter',
        'bottomRight',
      ],
    ),
    ComponentControl(
      'value',
      'Auto-dismiss milliseconds (0: persistent)',
      ComponentControlKind.number,
      minimum: 0,
      maximum: 8000,
    ),
    ComponentControl(
      'multiple',
      'Replace duplicates (off: ignore)',
      ComponentControlKind.toggle,
    ),
    _animate,
  ],
  minimalCode: '''final id = showNibToast(
  context: context,
  id: 'draft-saved',
  title: 'Draft saved',
  variant: NibToastVariant.success,
  actionLabel: 'Undo',
  onAction: () { /* Restore the previous local state. */ },
);
// If the operation is cancelled elsewhere:
dismissNibToast(id);''',
  sections: [
    DocSection(
      id: 'host',
      heading: 'Choose where notifications live',
      paragraphs: [
        'showNibToast returns an id and accepts an optional context. With a context it resolves that context’s root Overlay. Without one, install NibToaster once above the application content. NibToaster supplies an Overlay itself, so it can sit above MaterialApp’s Navigator in builder.',
        'The preview mounts a bounded NibToaster and passes context explicitly. Context chooses the root overlay, which may be the page overlay above the preview. The manager is process-global, not a per-widget queue or tenant boundary. Prefer one app host and a consistent policy for ids. Concurrent hosts do not create isolated managers.',
      ],
      code: '''MaterialApp(
  builder: (context, child) => NibToaster(child: child!),
  home: const HomePage(),
);''',
    ),
    DocSection(
      id: 'appearance',
      heading: 'Describe the outcome and place its stack',
      paragraphs: [
        'NibToastVariant has normal, success, error, warning, and info. NibToastVariantX.defaultIcon() and accent(theme) resolve the icon and accent; normal has no default icon. Override icon, content, padding, borderRadius, or backgroundColor when appropriate. Custom content owns its semantics.',
        'NibToastPosition has six top/bottom and left/center/right positions. NibToastPositionX exposes alignment, isTop, and enterOffset. Left/right stacks enter horizontally; centered stacks enter vertically. Position is a stack anchor, not a per-item coordinate. The manager caps visible items per position.',
      ],
    ),
    DocSection(
      id: 'duplicates',
      heading: 'Make repeated operations deliberate',
      paragraphs: [
        'A repeated id uses onDuplicateTrigger: shake, ignore, or replace. Shake calls attention to the existing item; ignore keeps it unchanged; replace updates content and restarts its timer. The example uses one unique id per owner and compares replacement with ignoring a second save.',
        'Choose ids for the represented operation, not an unbounded new notification for each retry. The returned id can be passed to dismissNibToast. Different ids produce separate items. A visual duplicate policy does not make a backend operation idempotent.',
      ],
    ),
    DocSection(
      id: 'duration',
      heading: 'Separate undo from presentation',
      paragraphs: [
        'duration defaults to four seconds. Duration.zero makes a persistent notification; the demo starts there for inspection. A nonzero value schedules dismissal. actionLabel and onAction add an application action. Closing a toast does not undo anything by itself; the demo explicitly records the reversal and dismisses its id.',
        'showCloseButton controls the close affordance. dismissible controls swipe dismissal. onDismiss observes removal. Keep lasting error or operation state in the page instead of relying on a short-lived toast as the only place to read or resolve it.',
      ],
    ),
    DocSection(
      id: 'cleanup',
      heading: 'Dismiss only what you own',
      paragraphs: [
        'dismissNibToast(id) closes one item. dismissAllNibToasts() closes the global manager’s items, including notifications from other parts of the app. The explicit global button demonstrates that API; use it only when clearing all app notifications is intended.',
        'The example dismisses its own id during disposal and guards callbacks with mounted. NibToaster registers and unregisters its overlay, but does not create a separate manager. Account for route removal, timers, and context changes in the application. Keep event history bounded.',
      ],
    ),
    DocSection(
      id: 'theme',
      heading: 'Verify the real notification viewport',
      paragraphs: [
        'The toast captures inherited theme from its caller when available. animated defaults to false; transition controls optional entrance and removal. Success and warning accents are fixed semantic colors in this package; changing the primary accent does not recolor those outcomes.',
        'Widget tests cover duplicate policy, action callbacks, both dismiss helpers, and cleanup. Physical swipe feel, screen-reader announcements, and narrow stacking remain platform checks. A toast that says Saved reflects the application’s claim; this demo verifies no production storage service.',
      ],
    ),
  ],
);
