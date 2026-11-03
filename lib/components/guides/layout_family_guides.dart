import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const layoutComponentGuides = <ComponentGuide>[
  ComponentGuide(
    id: "accordion",
    title: "Accordion",
    category: "Data and layout",
    summary: "Coordinate expandable sections, then decide whether several can remain open.",
    symbols: ['NibAccordion', 'NibAccordionController', 'NibAccordionItem'],
    source: "ComponetsNib/nib_components/lib/src/accordion/nib_accordion.dart; ComponetsNib/nib_components/lib/src/accordion/nib_accordion_controller.dart",
    demoClass: "AccordionComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(text: 'How does this section open?'),
    previewHeight: 440,
    minimalCode: "NibAccordion(\n  items: const [\n    NibAccordionItem(title: Text('How does it work?'), content: Text('Tap the header to reveal the answer.')),\n    NibAccordionItem(title: Text('Can several stay open?'), content: Text('Set allowMultipleOpen to true.')),\n  ],\n)",
    controls: [
      ComponentControl(
        "multiple",
        "Allow multiple sections",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "disabled",
        "Disable the second section",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "animated",
        "Animate expansion",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "text",
        "First section title",
        ComponentControlKind.text,
      ),
    ],
    sections: [
      DocSection(
        id: "open-a-section",
        heading: "Open a section and observe coordination",
        paragraphs: [
          "Tap a header in the preview. Its content becomes available, and the callback records the section index and whether it opened. Open a different section: the default single-open policy closes the previous one. Switch Allow multiple sections on to keep several answers visible.",
          "Each NibAccordionItem has a Widget title and content, optional leading widget, and an enabled flag. Use real headings and concise content rather than placing another scroll view inside each answer. The disabled second section demonstrates unavailable interaction without removing the section from the page.",
        ],
      ),
      DocSection(
        id: "controller",
        heading: "Choose internal or external expansion state",
        paragraphs: [
          "The widget creates a controller if controller is omitted. This demo supplies one so Open first and Close all can operate from outside a header. NibAccordionController.openIndices is an unmodifiable snapshot; use open, close, toggle, openAll, or closeAll to change it. openAll is ignored in single-open mode.",
          "Create the external controller once and dispose it when the owning screen leaves. allowMultipleOpen is synchronized with the controller. defaultOpenIndex seeds the internally created controller; it is not a command to reopen a section on every build.",
        ],
      ),
      DocSection(
        id: "motion",
        heading: "Keep expansion useful without motion",
        paragraphs: [
          "animated defaults to false. Enable it to animate the height reveal and chevron response; transition configures the requested timing. An expanded section must remain readable with animation off. The preview preserves open state while appearance controls change.",
          "Try opening the second section and then disabling it. Disabled controls should not become a workaround for hiding important information. If your application needs to close a section when permission changes, update the controller explicitly.",
        ],
      ),
      DocSection(
        id: "composition",
        heading: "Compose readable sections",
        paragraphs: [
          "The accordion grows with its content. Put the whole article in the screen’s scroll container; do not give it an arbitrary short height that clips revealed text. Test long titles and large text scaling at narrow widths.",
          "The demo is local UI state. Expanding a section does not fetch content or change routes. Add asynchronous loading and access checks in the host if a real section needs them.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "card",
    title: "Cards and flip cards",
    category: "Data and layout",
    summary: "Group content in a surface or reveal a second face with an explicit flip contract.",
    symbols: ['NibCard', 'NibFlipCard'],
    source: "ComponetsNib/nib_components/lib/src/card/nib_card.dart; ComponetsNib/nib_components/lib/src/card/nib_flip_card.dart",
    demoClass: "CardComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(
      text: 'A small project worth finishing',
      variant: 'plain',
      value: 600,
    ),
    previewHeight: 360,
    minimalCode: "NibCard(\n  header: const Text('Project notes'),\n  footer: const Text('Updated today'),\n  child: const Text('Keep related content together.'),\n)",
    controls: [
      ComponentControl(
        "variant",
        "Card type",
        ComponentControlKind.choice,
        choices: ['plain', 'flip'],
      ),
      ComponentControl(
        "interactive",
        "Allow card interaction",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "disabled",
        "Disable interaction",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "animated",
        "Animate plain-card interaction",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "vertical",
        "Flip around the horizontal axis",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "Flip duration (ms)",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 1200,
      ),
      ComponentControl(
        "radius",
        "Corner radius",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 32,
      ),
      ComponentControl("text", "Card heading", ComponentControlKind.text),
    ],
    sections: [
      DocSection(
        id: "plain-card",
        heading: "Start with a surface",
        paragraphs: [
          "NibCard has header, child, and footer slots. Padding, backgroundColor, borderColor, and borderRadius override its NibTheme defaults. A plain card groups content without implying that it can be pressed.",
          "Turn on interactive and supply onTap when the entire surface opens something. The preview increments an activation count so the callback outcome is observable. disabled blocks the action. animated opts into the hover and press treatment for an interactive card.",
        ],
      ),
      DocSection(
        id: "two-faces",
        heading: "Use NibFlipCard for a two-face interaction",
        paragraphs: [
          "Choose Flip to render the actual NibFlipCard. Tap the visible face to request the other one. front and back are independent widget subtrees; isFlipped and onFlippedChanged make the host the state owner. Omit isFlipped to use the widget’s local flip state.",
          "NibFlipCard has no animated parameter. Its duration defaults to 600 milliseconds, and flipAxis selects the rotation: Axis.horizontal rotates around Y, while Axis.vertical rotates around X. The duration control changes that real duration. A zero duration settles immediately in the selected motion candidate.",
        ],
      ),
      DocSection(
        id: "focus-and-motion",
        heading: "Keep the visible face meaningful",
        paragraphs: [
          "Give tappable faces useful frontSemanticLabel and backSemanticLabel values. tappable: false removes the built-in face action; the host can still change a controlled isFlipped value. The demo’s Disabled switch disables tapping without discarding the requested face.",
          "The selected local NibFlip dependency respects reduced motion and gates focus and semantics by the face actually visible during a flip. Test interruption and keyboard activation with your resolved dependency version. Those repaired behaviors are not an assertion about every older hosted release.",
        ],
      ),
      DocSection(
        id: "bounds",
        heading: "Give both faces useful bounds",
        paragraphs: [
          "Both faces need a stable, bounded layout. This preview gives the flip 180 logical pixels of height and lets the surrounding column set the width. Test the larger of your two content states, long text, and text scaling.",
          "Switching between the plain-card and flip-card examples changes the demonstrated widget. They have different APIs; the plain-card animated control does not secretly change the flip duration. The copied source contains both branches and the exact selected settings.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "carousel",
    title: "Carousel",
    category: "Data and layout",
    summary: "Swipe a real PageView, navigate through its controller, and choose an indicator.",
    symbols: [
      'NibCarousel',
      'NibCarouselController',
      'NibCarouselDot',
      'NibCarouselIndicatorStyle',
    ],
    source: "ComponetsNib/nib_components/lib/src/carousel/nib_carousel.dart; ComponetsNib/nib_components/lib/src/carousel/nib_carousel_controller.dart",
    demoClass: "CarouselComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(
      variant: 'dots',
      value: 12,
      multiple: true,
      animated: true,
    ),
    previewHeight: 380,
    minimalCode: "NibCarousel(\n  height: 180,\n  items: const [Center(child: Text('Sketch')), Center(child: Text('Build')), Center(child: Text('Review'))],\n)",
    controls: [
      ComponentControl(
        "variant",
        "Indicator",
        ComponentControlKind.choice,
        choices: ['dots', 'line', 'none'],
      ),
      ComponentControl("multiple", "Loop slides", ComponentControlKind.toggle),
      ComponentControl(
        "animated",
        "Autoplay and indicator motion",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "Adjacent-slide peek",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 40,
      ),
    ],
    sections: [
      DocSection(
        id: "navigate",
        heading: "Swipe, then use the controller",
        paragraphs: [
          "Three original illustrations introduce Motion, Components, and the local pre-release GenUI workspace. The website starts autoplay and looping; press Pause carousel to read at your own pace. Drag sideways or use Previous slide and Next slide. NibCarousel.onPageChanged updates the visible slide count. With Loop slides off, navigation stops at either end.",
          "NibCarousel uses Flutter PageView. NibCarouselController offers nextPage, previousPage, animateToPage, and jumpToPage. Its page property is the logical index even when looping changes the underlying physical page. Retain an external controller once and dispose it in the owner.",
        ],
      ),
      DocSection(
        id: "geometry",
        heading: "Choose height and neighboring visibility",
        paragraphs: [
          "height gives every slide a bounded vertical extent. peekExtent exposes an edge of adjacent slides; viewportFraction is the explicit alternative when you need a fraction of the viewport. This preview preserves the complete artwork with BoxFit.contain. Changing the peek or loop setting rebuilds PageView and returns to slide one because the package fixes its viewport fraction at controller construction.",
          "indicatorStyle chooses dots, line, or none. NibCarouselDot is also exported for a custom indicator arrangement. It receives active, color, and inactiveColor along with style options. It is a visual mark without an onTap callback; changing the indicator style does not change the slide model.",
        ],
      ),
      DocSection(
        id: "autoplay",
        heading: "Make automatic movement a deliberate policy",
        paragraphs: [
          "NibCarousel itself defaults autoPlay, loop, and animated to false. This website explicitly enables them, with a four-second interval. The Autoplay and indicator motion setting changes both autoplay and the active-indicator effect. Those are separate package parameters: animated alone does not turn on autoplay or control PageView scrolling.",
          "The example disables autoPlay when its Pause carousel button is active, when the containing TickerMode is disabled, or when MediaQuery.disableAnimations is true. The website motion pause and view-only gallery use TickerMode. Reduced-motion and paused manual navigation use jumpToPage, so the destination remains accessible without a sliding transition. Disposing the widget cancels the package timer and the example disposes its external controller. Hosts must supply their own visibility signal for a carousel merely scrolled off screen.",
        ],
      ),
      DocSection(
        id: "content",
        heading: "Preserve logical identity",
        paragraphs: [
          "The artwork is original SVG, rasterized to PNG without a Flutter dependency. The full example embeds those PNG bytes and their semantic descriptions, so copying the code does not depend on website assets or remote image availability. Keep item order stable when only style changes; if the slide count changes, reconcile the selected index and controller.",
          "A carousel is useful for a short ordered sequence. Essential navigation and text should remain accessible without waiting for a timer. Device swipe behavior and frame pacing require device checks beyond this preview.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "tabs",
    title: "Tabs",
    category: "Navigation",
    summary: "Switch panels while keeping the header, selected content, and footer in one vertical scroll.",
    symbols: [
      'NibTab',
      'NibTabs',
      'NibTabsController',
      'NibTabsIndicatorStyle',
    ],
    source: "ComponetsNib/nib_components/lib/src/tabs/nib_tabs.dart; ComponetsNib/nib_components/lib/src/tabs/nib_tabs_controller.dart",
    demoClass: "TabsComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(variant: 'underline', value: 16),
    previewHeight: 450,
    minimalCode: "SizedBox(\n  height: 320,\n  child: NibTabs(tabs: [\n    NibTab(label: 'Overview', builder: (_) => const Text('Overview content')),\n    NibTab(label: 'Notes', builder: (_) => const Text('Notes content')),\n  ]),\n)",
    controls: [
      ComponentControl(
        "variant",
        "Indicator",
        ComponentControlKind.choice,
        choices: ['underline', 'pill', 'none'],
      ),
      ComponentControl(
        "searchable",
        "Scrollable tab bar",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "interactive",
        "Allow swipe between panels",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "animated",
        "Animate panel fade",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "Panel gap",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 40,
      ),
    ],
    sections: [
      DocSection(
        id: "scroll-contract",
        heading: "Give the tab set one bounded viewport",
        paragraphs: [
          "NibTabs owns one vertical CustomScrollView. Its header scrolls away, the bar pins, the active panel participates in that same vertical scroll, and the footer follows it. Put content above and below in the header and footer arguments.",
          "The preview supplies a 290-pixel bounded height. In a full screen, Expanded can supply the remaining height. Do not wrap NibTabs in another vertical ListView or SingleChildScrollView: that recreates competing scroll ownership.",
        ],
      ),
      DocSection(
        id: "selection",
        heading: "Select by tap, swipe, or controller",
        paragraphs: [
          "Tap Notes or press Animate to notes. NibTabsController.index reports the selection; animateTo asks for movement and jumpTo switches immediately. This demo uses an external controller for those two buttons and disposes it with the demo.",
          "NibTab contains a label, optional icon, and lazy panel builder. initialIndex applies when no external controller supplies its own index. Keep tab identities and order meaningful when rebuilding; selecting index 1 only has meaning relative to the current list.",
        ],
      ),
      DocSection(
        id: "bar-and-gap",
        heading: "Tune the tab bar and panel separation",
        paragraphs: [
          "scrollable gives tabs their intrinsic widths in a horizontal bar; otherwise tabs share the available width. indicatorStyle chooses underline, pill, or none. panelGap separates outgoing and incoming panels and adds space before the footer.",
          "swipeable controls horizontal page gestures; tapping the tab bar still works. The preview’s controls map to these actual properties. Test long labels, different panel heights, and a narrow width rather than assuming equal-sized sample text covers your content.",
        ],
      ),
      DocSection(
        id: "motion-exception",
        heading: "Distinguish fade from layout movement",
        paragraphs: [
          "animated opts into the new panel’s NibMotion fade. The indicator glide, pager slide, and height reflow use their own layout or gesture animation paths and can move when animated is false. transition configures programmatic and settle timing.",
          "Use jumpTo when the host explicitly requests an immediate page switch. Review your full reduced-motion policy instead of presenting animated: false as a universal motion disable switch. Panel data and request cancellation remain owned by the host.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "data-table",
    title: "Data table",
    category: "Data and layout",
    summary: "Sort task counts, select real rows, and inspect loading or empty states.",
    symbols: [
      'NibCellBuilder',
      'NibDataColumn',
      'NibDataTable',
      'NibDataTableController',
      'NibDataTableSelectionMode',
      'NibDataTableSort',
      'NibSortDirection',
      'NibSortValueGetter',
    ],
    source: "ComponetsNib/nib_components/lib/src/data_table/nib_data_column.dart; ComponetsNib/nib_components/lib/src/data_table/nib_data_table.dart; ComponetsNib/nib_components/lib/src/data_table/nib_data_table_controller.dart; ComponetsNib/nib_components/lib/src/data_table/nib_data_table_types.dart",
    demoClass: "DataTableComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(variant: 'single', value: 48, text: ''),
    previewHeight: 430,
    minimalCode: "SizedBox(height: 280, child: NibDataTable<String>(\n  rows: const ['Atlas', 'Birch', 'Cedar'],\n  columns: [NibDataColumn(label: 'Project', cellBuilder: (_, row) => Text(row), sortValue: (row) => row)],\n  selectionMode: NibDataTableSelectionMode.single,\n))",
    controls: [
      ComponentControl(
        "variant",
        "Selection mode",
        ComponentControlKind.choice,
        choices: ['none', 'single', 'multi'],
      ),
      ComponentControl(
        "value",
        "Row height",
        ComponentControlKind.number,
        minimum: 44,
        maximum: 72,
      ),
      ComponentControl(
        "text",
        "Filter project names",
        ComponentControlKind.text,
      ),
      ComponentControl(
        "animated",
        "Animate row entrance",
        ComponentControlKind.toggle,
      ),
    ],
    sections: [
      DocSection(
        id: "sorting",
        heading: "Let the table sort local data",
        paragraphs: [
          "Tap Tasks to sort the numeric count, then tap it again to change direction. NibDataColumn.sortValue supplies a comparable value; cellBuilder decides what appears in the cell. The preview omits onSort so NibDataTable performs local sorting.",
          "Providing onSort changes that contract: the host becomes responsible for supplying rows in the requested order, for example after a server query. A logging callback is enough to disable built-in sorting, so do not add onSort merely to observe it without also handling the order.",
        ],
      ),
      DocSection(
        id: "selection",
        heading: "Choose a selection model",
        paragraphs: [
          "Selection mode none omits selection behavior, single selects one row when tapped, and multi adds row checkboxes and a header select-all checkbox. The readout observes the actual NibDataTableController.selected set. Clear selection calls the controller.",
          "The controller stores NibDataTableSort and selected rows. setSort, setSelected, toggleSelected, and clearSelection support external actions. NibSortDirection includes none, ascending, and descending. Use stable row identity or rowKey across rebuilds; rebuilding equivalent objects with different identity can break selection expectations.",
        ],
      ),
      DocSection(
        id: "data-states",
        heading: "Show loading and empty results honestly",
        paragraphs: [
          "Show loading replaces rows with the package’s loading presentation. It is a local state toggle, not a network request. Filtering project names changes the real rows supplied to the table; an unmatched query shows the configured emptyState.",
          "Selection is controller state, so a row filtered out of view can remain selected. Decide whether to retain or clear hidden selections in your application. The table does not implement backend pagination, authorization, or request cancellation.",
        ],
      ),
      DocSection(
        id: "layout",
        heading: "Bound the viewport and preserve readable cells",
        paragraphs: [
          "The table needs bounded height for its virtualized body. headerHeight defaults to 48, and stickyHeader keeps headings visible while rows scroll. Column widths or minWidth determine when horizontal scrolling is needed. This demo leaves room for two columns and the optional selection column.",
          "NibCellBuilder and NibSortValueGetter are the public callback types. Use compact cell content at a fixed rowHeight; wrapping a large paragraph into a short row can clip it. Test keyboard interaction, long values, larger text, and horizontal scroll with your actual data.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "resizable-panels",
    title: "Resizable panels",
    category: "Data and layout",
    summary: "Drag or nudge a real divider while respecting panel fractions and narrow-layout fallback.",
    symbols: [
      'NibResizablePanel',
      'NibResizablePanels',
      'NibResizablePanelsController',
      'NibResizablePanelsHandle',
      'kNibResizablePanelsKeyboardStep',
      'kNibResizablePanelsNarrowFallbackPanelExtent',
    ],
    source: "ComponetsNib/nib_components/lib/src/resizable_panels/nib_resizable_panel.dart; ComponetsNib/nib_components/lib/src/resizable_panels/nib_resizable_panels.dart; ComponetsNib/nib_components/lib/src/resizable_panels/nib_resizable_panels_controller.dart; ComponetsNib/nib_components/lib/src/resizable_panels/nib_resizable_panels_handle.dart",
    demoClass: "ResizablePanelsComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(value: 50),
    previewHeight: 510,
    minimalCode: "SizedBox(height: 340, child: NibResizablePanels(\n  direction: Axis.horizontal,\n  panels: const [\n    NibResizablePanel(minSize: .2, maxSize: .8, child: Center(child: Text('Outline'))),\n    NibResizablePanel(minSize: .2, maxSize: .8, child: Center(child: Text('Notes'))),\n  ],\n))",
    controls: [
      ComponentControl(
        "vertical",
        "Stack vertically",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "animated",
        "Animate handle feedback",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "First panel share (%)",
        ComponentControlKind.number,
        minimum: 20,
        maximum: 80,
      ),
    ],
    sections: [
      DocSection(
        id: "resize",
        heading: "Move the boundary, not the content",
        paragraphs: [
          "Drag the divider to change the pair of panel fractions. Focus the handle and use the axis-appropriate arrow keys for small nudges; Home and End request the available extremes. Double-tap the handle or press Reset split to restore the original proportions.",
          "onLayoutChanged reports a committed drag or keyboard interaction. The live percentage readout also listens to NibResizablePanelsController so it updates during a drag. No file or user preference is saved by this example.",
        ],
      ),
      DocSection(
        id: "constraints",
        heading: "Use fractions and validate external layouts",
        paragraphs: [
          "NibResizablePanel.minSize, maxSize, and initialSize are fractions between 0 and 1. This demo gives each panel a 20% minimum and 80% maximum. The controller starts from the configured first-panel share and its complement.",
          "setSizes normalizes the supplied values but does not re-clamp them to every panel’s min/max. External callers must supply a sane layout. applyDelta applies the pair’s constraints; resetPanelPair and resetAll restore captured initial proportions. Dispose the controller in its owner.",
        ],
      ),
      DocSection(
        id: "handle-api",
        heading: "Understand the exported handle",
        paragraphs: [
          "NibResizablePanelsHandle is publicly exported even though a stale source comment describes it as internal. The group normally creates it for you. Its direction, groupMainExtent, handleThickness, and sizeFraction describe geometry; onDeltaFraction, onDragEnd, and onReset connect interaction to your model.",
          "kNibResizablePanelsKeyboardStep is the exported 0.02 fraction used by arrow nudges. The visual divider can be thinner than its interactive slot. animated controls its feedback, not whether resizing works. You do not need to construct a handle manually for an ordinary split layout.",
        ],
      ),
      DocSection(
        id: "narrow",
        heading: "Allow the narrow fallback to change the layout",
        paragraphs: [
          "When the main-axis extent is below panel count multiplied by kNibResizablePanelsNarrowFallbackPanelExtent, the package renders a vertical scrolling stack without handles. A narrow horizontal preview will therefore look different from the wide split.",
          "Give fallback content useful intrinsic heights and give the group bounded width and height. This example uses 150-pixel content surfaces, so a fallback panel remains readable. A missing divider at narrow width is this documented fallback, not a disabled resize callback.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "loader",
    title: "Circular loader",
    category: "Effects",
    summary: "Show indeterminate activity with explicit pause and static reduced-motion feedback.",
    symbols: ['NibCircularLoader'],
    source:
        "ComponetsNib/nib_components/lib/src/loader/nib_circular_loader.dart",
    demoClass: "LoaderComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(value: 64, radius: 5, animated: false),
    previewHeight: 340,
    minimalCode: "Semantics(\n  label: 'Loading project details',\n  child: const ExcludeSemantics(child: NibCircularLoader(size: 48)),\n)",
    controls: [
      ComponentControl(
        "animated",
        "Run indicator",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "value",
        "Diameter",
        ComponentControlKind.number,
        minimum: 32,
        maximum: 96,
      ),
      ComponentControl(
        "radius",
        "Stroke width",
        ComponentControlKind.number,
        minimum: 2,
        maximum: 12,
      ),
    ],
    sections: [
      DocSection(
        id: "meaning",
        heading: "Use a loader for unknown duration",
        paragraphs: [
          "NibCircularLoader paints a rotating gradient sweep over a track. It communicates indeterminate activity; it does not show a completion percentage. The preview explicitly says that no upload or background task is running. The website starts the actual package loader rotating; press Pause indicator to stop it.",
          "The demo wraps the loader in TickerMode for a user-controlled pause. This is host composition: NibCircularLoader has no animated or paused constructor argument. The Run control changes that wrapper, and the copied source includes it.",
        ],
      ),
      DocSection(
        id: "appearance",
        heading: "Configure the painted ring",
        paragraphs: [
          "size is the overall diameter, strokeWidth sets ring thickness, and color defaults to NibTheme.primary. trackColor defaults to a low-opacity form of the resolved color. child places a small widget in the center.",
          "duration controls one full rotation and defaults to 1100 milliseconds. sweep is a fraction strictly between 0 and 1 and defaults to 0.72. Keep strokeWidth sensible relative to size. Changing duration resets and restarts the current rotation in this implementation.",
        ],
      ),
      DocSection(
        id: "accessibility",
        heading: "Name the activity and respect reduced motion",
        paragraphs: [
          "The loader does not supply an accessible task name on its own. This preview labels the decorative indicator and replaces it with static Working text when MediaQuery.disableAnimations is true. In an application, name the actual activity and announce only meaningful status changes.",
          "The package loader does not itself check reduced motion. TickerMode can silence its ticker in a hidden or paused host, but it does not cancel a request or complete work. Remove the loader when the host operation finishes and keep failure feedback visible.",
        ],
      ),
      DocSection(
        id: "lifecycle",
        heading: "Keep the lifetime bounded",
        paragraphs: [
          "The package owns and disposes its AnimationController. The demo has no timer or backend subscription. The website starts it running and provides both the local Pause indicator control and the shared motion pause. Disposing the example ends its ticker lifetime.",
          "A widget test can check the pause and reduced-motion branches. Physical-device frame pacing remains a separate check; this preview makes no GPU or performance certification claim.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "skeleton",
    title: "Skeleton",
    category: "Effects",
    summary: "Turn one authored content tree into a loading placeholder, then reveal that same content.",
    symbols: [
      'NibSkeleton',
      'NibSkeletonBone',
      'NibSkeletonIgnore',
      'NibSkeletonShape',
    ],
    source: "ComponetsNib/nib_components/lib/src/skeleton/nib_skeleton.dart; ComponetsNib/nib_components/lib/src/skeleton/nib_skeleton_types.dart",
    demoClass: "SkeletonComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(text: 'Notes worth keeping', variant: 'circle'),
    previewHeight: 400,
    minimalCode: "NibSkeleton(\n  loading: true,\n  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [\n    Text('Project notes'),\n    SizedBox(height: 8),\n    Text('Content appears here when loading is false.'),\n  ]),\n)",
    controls: [
      ComponentControl(
        "animated",
        "Shimmer and dissolve",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "variant",
        "Explicit bone shape",
        ComponentControlKind.choice,
        choices: ['circle', 'rectangle'],
      ),
      ComponentControl(
        "radius",
        "Box-bone radius",
        ComponentControlKind.number,
        minimum: 0,
        maximum: 24,
      ),
      ComponentControl("text", "Content heading", ComponentControlKind.text),
    ],
    sections: [
      DocSection(
        id: "one-tree",
        heading: "Author the content once",
        paragraphs: [
          "NibSkeleton takes loading and the real child tree. While loading, the package converts supported nodes to bone shapes; otherwise it shows the content. Press Reveal content to switch the real loading property and inspect the result. The local example does not fetch data.",
          "Automatic detection works best with the supported layout and text widgets. A custom StatefulWidget or painter may become a generic fallback box. Check the placeholder instead of assuming every arbitrary subtree can be inferred correctly.",
        ],
      ),
      DocSection(
        id: "markers",
        heading: "Mark the cases the detector cannot infer",
        paragraphs: [
          "NibSkeletonBone provides explicit width, height, and a NibSkeletonShape for custom content. The preview marks the icon area and lets you choose a circle or rectangle. The real child remains the same when loading ends.",
          "NibSkeletonIgnore keeps its child unchanged and prevents the shade traversal from recursing into it. FIELD NOTES stays visible here to demonstrate a stable label. Do not ignore private data just to make a placeholder prettier; decide which content may be visible while loading.",
        ],
      ),
      DocSection(
        id: "motion-and-colors",
        heading: "Choose static bones or an animated transition",
        paragraphs: [
          "animated defaults to false and swaps the shaded and real trees immediately. Turning it on adds per-bone shimmer and a NibPresence opacity dissolve. This website starts that opt-in effect, then disables it for reduced motion or a disabled host TickerMode. transition controls the dissolve, while baseColor and shimmerColor customize the palette.",
          "borderRadius affects generic box bones; text-line bones stay fully rounded and circular avatar bones stay circular. fallbackWidth and fallbackHeight size unidentified nodes. boneSpacing adds to existing Row or Column spacing rather than replacing it.",
        ],
      ),
      DocSection(
        id: "state-and-a11y",
        heading: "Keep status and interaction outside the placeholder",
        paragraphs: [
          "The loading skeleton ignores pointer input. Keep a readable loading status or host action outside the shaded subtree, as this demo does. Do not make a skeleton the only way to understand why content is unavailable.",
          "Preserve the host data state when changing the palette or motion setting. If loading fails, show the actual error and retry action instead of leaving an infinite placeholder. The preview toggle is a bounded local state exercise.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "breadcrumb",
    title: "Breadcrumb",
    category: "Navigation",
    summary: "Navigate a local path and reveal collapsed ancestors without treating the current location as a link.",
    symbols: ['NibBreadcrumb', 'NibBreadcrumbItem', 'breadcrumbVisibleIndices'],
    source: "ComponetsNib/nib_components/lib/src/breadcrumb/nib_breadcrumb.dart; ComponetsNib/nib_components/lib/src/breadcrumb/nib_breadcrumb_types.dart",
    demoClass: "BreadcrumbComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(value: 3),
    previewHeight: 350,
    minimalCode: "NibBreadcrumb(items: [\n  NibBreadcrumbItem(label: 'Workspace', onTap: () {}),\n  const NibBreadcrumbItem(label: 'Current project'),\n])",
    controls: [
      ComponentControl(
        "value",
        "Maximum visible items",
        ComponentControlKind.number,
        minimum: 2,
        maximum: 4,
      ),
      ComponentControl(
        "disabled",
        "Disable breadcrumb links",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "animated",
        "Animate overflow content",
        ComponentControlKind.toggle,
      ),
    ],
    sections: [
      DocSection(
        id: "path",
        heading: "Make the final crumb the current location",
        paragraphs: [
          "The preview starts at Workspace / Projects / Atlas / Design notes. Activate an earlier crumb to shorten the local path; Restore full path restores the starting trail. This demonstrates onTap without navigating away from the documentation.",
          "NibBreadcrumbItem contains a label, optional icon, and callback. The last item is always current and non-interactive, even when it has an onTap. An earlier item without a callback is also plain text. Application routing remains your callback’s responsibility.",
        ],
      ),
      DocSection(
        id: "collapse",
        heading: "Keep ancestors reachable when space runs out",
        paragraphs: [
          "maxVisibleItems limits the visible trail. itemsBeforeCollapse and itemsAfterCollapse select how many ancestors remain around the overflow control. Activate the overflow to reach hidden ancestors through the package’s popover.",
          "breadcrumbVisibleIndices is the public pure helper for the same index model: integers represent visible items and null represents the overflow slot. It does not render or perform routing. The example’s first and last labels remain meaningful when middle items are collapsed.",
        ],
      ),
      DocSection(
        id: "style-and-state",
        heading: "Style links without losing location",
        paragraphs: [
          "linkColor, currentColor, separatorColor, fontSize, itemPadding, and gap are instance overrides. separator can replace the default divider widget. semanticLabel names the path as a whole. disabled prevents the breadcrumb links from activating.",
          "The current local path is separate from appearance controls. Changing the maximum visible count or theme does not reset the selected location. Test translated labels and large text; shortening a label is a content decision, not a substitute for a functional overflow menu.",
        ],
      ),
      DocSection(
        id: "overlay",
        heading: "Check the overflow in its real host",
        paragraphs: [
          "overflowPlacement selects the preferred NibPopoverPlacement. The overflow uses the real popover machinery, so theme inheritance, overlay containment, and edge placement must be checked in the host where the breadcrumb appears.",
          "The public helper computes which indices appear; it cannot prove that a popup fits every embedded viewport. Test narrow layouts and keyboard access to hidden items. Keep a direct route or another navigation path available when a user does not use breadcrumbs.",
        ],
      ),
    ],
  ),
  ComponentGuide(
    id: "pagination",
    title: "Pagination",
    category: "Navigation",
    summary: "Change a controlled page and make the displayed data follow it.",
    symbols: ['NibPagination', 'NibPaginationVariant', 'paginationRange'],
    source: "ComponetsNib/nib_components/lib/src/pagination/nib_pagination.dart; ComponetsNib/nib_components/lib/src/pagination/nib_pagination_types.dart",
    demoClass: "PaginationComponentDemo",
    demoFile: 'lib/components/examples/layout_family_demos.dart',
    initial: ComponentSettings(value: 12, variant: 'numbered'),
    previewHeight: 390,
    minimalCode: "// Inside State; update the rows alongside currentPage in a real screen.\nNibPagination(\n  currentPage: page,\n  totalPages: 12,\n  onPageChanged: (next) => setState(() => page = next),\n)",
    controls: [
      ComponentControl(
        "value",
        "Total pages",
        ComponentControlKind.number,
        minimum: 1,
        maximum: 30,
      ),
      ComponentControl(
        "variant",
        "Layout",
        ComponentControlKind.choice,
        choices: ['numbered', 'compact'],
      ),
      ComponentControl(
        "multiple",
        "Show first and last buttons",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "disabled",
        "Disable page changes",
        ComponentControlKind.toggle,
      ),
      ComponentControl(
        "animated",
        "Animate active page",
        ComponentControlKind.toggle,
      ),
    ],
    sections: [
      DocSection(
        id: "controlled-page",
        heading: "Accept a page change and rebuild the content",
        paragraphs: [
          "currentPage is controlled and one-based. onPageChanged reports the requested page; the host updates the value and the data shown above it. The preview changes three numbered local notes so the control’s effect is visible. It does not perform a network query.",
          "When Total pages becomes smaller than the current page, this host clamps the current page to the valid range. Decide how your application handles an empty dataset, a failed fetch, or a filter that removes pages. The paginator itself is not a data-loading controller.",
        ],
      ),
      DocSection(
        id: "layouts",
        heading: "Choose numbered or compact controls",
        paragraphs: [
          "The numbered variant shows boundary pages, siblings around the current page, and ellipses. siblingCount and boundaryCount configure that range. The compact variant shows previous/next navigation and a label, with compactLabelBuilder available for custom text.",
          "showPrevNext and showFirstLast control the surrounding navigation actions. disabled blocks page changes; a first-page previous action is unavailable at its boundary. This demo keeps labels and notes synchronized after either layout is selected.",
        ],
      ),
      DocSection(
        id: "range-helper",
        heading: "Use the range helper when building another presentation",
        paragraphs: [
          "paginationRange returns a List<int?>. Page numbers are integers; null is an ellipsis slot. It returns an empty list when totalPages is zero or below. A single missing page is shown as that page rather than an unnecessary ellipsis.",
          "The widget and helper use the same one-based page model. Do not pass a zero-based database offset as currentPage; convert it in your host. The public NibPaginationVariant enum has numbered and compact values.",
        ],
      ),
      DocSection(
        id: "feedback",
        heading: "Keep loading and selection policies explicit",
        paragraphs: [
          "animated opts into active-page feedback. itemSize, gap, activeColor, and itemBorderRadius adjust the control appearance. At narrow width, inspect the numbered layout and consider compact presentation rather than shrinking labels.",
          "For a server-backed table, retain the previous rows or show a loading state while fetching, prevent stale responses from replacing newer pages, and show failures without lying about the current data. A callback firing proves only that a page was requested.",
        ],
      ),
    ],
  ),
];
