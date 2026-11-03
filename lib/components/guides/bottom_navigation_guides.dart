import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const bottomNavigationGuides = <ComponentGuide>[
  ComponentGuide(
    id: 'glass-bottom-navigation',
    title: 'Glass bottom navigation',
    category: 'Compositions',
    summary: 'Keep a floating glass bar above scrolling content while each destination retains its local state.',
    symbols: _navSymbols,
    source: 'MotionNib/motion/lib/src/nav/nib_nav_bar.dart; ComponetsNib/nib_components/example/lib/examples/liquid_glass_showcase.dart',
    composition: true,
    apiPackageId: 'motion',
    demoClass: 'GlassBottomNavigationDemo',
    demoFile: 'lib/components/examples/bottom_navigation_compositions.dart',
    initial: ComponentSettings(
      text: 'Overview',
      value: 3,
      animated: true,
      blurSigma: 5,
      highlight: .7,
      radius: 20,
    ),
    previewHeight: 560,
    controls: [
      ..._navControls,
      ComponentControl(
        'blurSigma',
        'Glass blur',
        ComponentControlKind.number,
        minimum: 0,
        maximum: 16,
        help: 'Changes NibNavBarStyle.glassBlur on the background surface.',
      ),
      ComponentControl(
        'highlight',
        'Glass highlight',
        ComponentControlKind.number,
        minimum: 0,
        maximum: 1,
      ),
    ],
    minimalCode: '''import 'package:nib_motion/nib_motion.dart' as motion;

// Inside a bounded Stack with content behind the bar.
motion.NibNavBar(
  currentIndex: selectedIndex,
  onIndexChanged: (index) => setState(() => selectedIndex = index),
  style: const motion.NibNavBarStyle(glass: true, glassBlur: 5),
  items: const [
    motion.NibNavItem(icon: Icon(Icons.home), label: 'Home'),
    motion.NibNavItem(icon: Icon(Icons.inbox), label: 'Inbox'),
  ],
)''',
    sections: [
      DocSection(
        id: 'ownership',
        heading: 'Use the actual navigation API',
        paragraphs: [
          'This is an example composition built from NibMotion’s NibNavBar. The Components package exports NibLiquidGlass and NibNavigationMenu, but neither is a bottom navigation bar. The existing package glass showcase supplies the styling pattern; this example adds related destination content and retained draft state.',
          'Both packages export a class called NibNavItem. Import nib_motion with a prefix, as the complete example does. A Motion item describes an icon, label and badge; a Components navigation-menu item describes a recursive menu tree.',
        ],
      ),
      DocSection(
        id: 'backdrop',
        heading: 'Give the glass something to filter',
        paragraphs: [
          'Place the scrolling page and floating bar in the same Stack. The bar must paint after the content so its backdrop filter can sample that content. The list has bottom padding equal to the bar height plus spacing, which lets the last row scroll clear of the bar.',
          'NibNavBarStyle.glass enables NibMotion’s NibGlass surface. glassTint, glassBlur and glassHighlight control that background. The pill selection indicator is a separate layer; changing the background blur does not change the pill’s spring.',
          'The guide uses Ember tokens for foreground, inactive icons, border and tint. A local SafeArea protects the bottom edge. A production Scaffold still needs an explicit keyboard policy; this bounded example does not demonstrate a native keyboard or system gesture area.',
        ],
      ),
      ..._navSections,
    ],
    limitations: _navLimits,
  ),
  ComponentGuide(
    id: 'liquid-bottom-navigation',
    title: 'Liquid bottom navigation',
    category: 'Compositions',
    summary: 'Move a water-like selection indicator between real destinations, with badge counts and keyboard activation.',
    symbols: _navSymbols,
    source: 'MotionNib/motion/lib/src/nav/nib_nav_bar.dart; lib/src/nav/nib_nav_bar_painter.dart; lib/shaders/nav_water.frag',
    composition: true,
    apiPackageId: 'motion',
    demoClass: 'LiquidBottomNavigationDemo',
    demoFile: 'lib/components/examples/bottom_navigation_compositions.dart',
    initial: ComponentSettings(
      text: 'Overview',
      value: 3,
      animated: true,
      radius: 20,
    ),
    previewHeight: 560,
    controls: _navControls,
    minimalCode: '''import 'package:nib_motion/nib_motion.dart' as motion;

motion.NibNavBar(
  currentIndex: selectedIndex,
  onIndexChanged: (index) => setState(() => selectedIndex = index),
  indicator: const motion.NibNavIndicatorStyle(
    type: motion.NibNavIndicatorType.liquid,
  ),
  items: const [
    motion.NibNavItem(icon: Icon(Icons.home), label: 'Home'),
    motion.NibNavItem(icon: Icon(Icons.inbox), label: 'Inbox'),
  ],
)''',
    sections: [
      DocSection(
        id: 'ownership',
        heading: 'Select the liquid indicator',
        paragraphs: [
          'The water effect belongs to NibMotion’s NibNavIndicatorType.liquid. There is no separate NibWater or NibBottomNav constructor in the selected Components package. This composition keeps the bar background opaque so the moving indicator is easy to inspect.',
          'Set indicator.type to liquid. NibNavBar loads packages/nib_motion/lib/shaders/nav_water.frag and drives its phase, tail and position from the library’s motion values. If loading fails, the painter retains a gradient lens. A successful selection callback does not prove the fragment shader executed.',
          'The liquid phase runs after selection and stops at rest. The Motion control below is a host choice: it uses NibMotionConfig.reducedMotion to make changes immediate. The library’s standard navigation configuration animates by default, unlike most Components widgets.',
        ],
      ),
      DocSection(
        id: 'indicator-options',
        heading: 'Separate indicator, icons and background',
        paragraphs: [
          'NibNavIndicatorStyle accepts type, color, dimensions, borderRadius and a spring. Its other types are pill, dot, line, highlight and none. Width and height apply to the indicator shapes documented by those properties; they are not a general layout constraint for every effect.',
          'NibNavItemAnimation controls the press and active icon poses independently. Its default press scale is 0.85 and active scale is 1.1. Use NibNavItemAnimation.none to remove those icon poses; the indicator still follows its own transition and reduced-motion policy.',
          'The bar itself is styled with NibNavBarStyle. Glass is an independent background option, so a glass surface and a liquid indicator can be combined in application code. The two guides keep them separate so each visual mechanism is understandable.',
        ],
      ),
      ..._navSections,
    ],
    limitations: _navLimits,
  ),
];
const _navSymbols = [
  'NibNavBar',
  'NibNavItem',
  'NibNavBadge',
  'NibNavBarStyle',
  'NibNavIndicatorStyle',
  'NibNavIndicatorType',
  'NibNavItemAnimation',
];
const _navControls = [
  ComponentControl(
    'text',
    'First destination label',
    ComponentControlKind.text,
    help: 'Long labels are ellipsized visually; the semantic label retains the full text.',
  ),
  ComponentControl(
    'value',
    'Inbox badge count',
    ComponentControlKind.number,
    minimum: 0,
    maximum: 120,
    help: 'Zero hides the badge. Counts above 99 display 99+.',
  ),
  ComponentControl(
    'animated',
    'Motion',
    ComponentControlKind.toggle,
    help: 'On is the NibNavBar default. Off applies a local reduced-motion scope; system preference takes priority.',
  ),
  ComponentControl('showBorder', 'Bar border', ComponentControlKind.toggle),
];
const _navSections = [
  DocSection(
    id: 'state',
    heading: 'Change the destination as well as the indicator',
    paragraphs: [
      'NibNavBar is controlled: currentIndex is the selected destination, and onIndexChanged reports activation. The host updates both currentIndex and an IndexedStack. An IndexedStack keeps each child mounted, so the Inbox draft remains when you visit Settings and return.',
      'The “Next destination from host” button exercises external state changes through the same selection function. This example owns its TextEditingController and FocusNode, disposes both, and releases the draft field’s focus before changing destinations. Tuning radius, badge count or glass style leaves the draft intact.',
      'Selection stays inside the example. Browser history is not changed, repeated activation can report the same index, and there is no automatic back-stack policy. An application can instead use NibScaffold and NibScreenStack for the library’s screen-transition and keepAlive options.',
    ],
  ),
  DocSection(
    id: 'items',
    heading: 'Configure labels, icons and badges',
    paragraphs: [
      'Every NibNavItem requires icon. activeIcon falls back to icon; label is optional. tooltip supplies the accessible target label in this implementation. Keep the item count and currentIndex valid when changing the list.',
      'NibNavBadge.count null means a dot, zero means hidden, and positive counts cap the displayed text at 99+. The example lets you change a numeric count and uses explicit Ember foreground/background colors. Badge copyWith uses null as “keep the old value,” so construct a new badge to switch an existing numeric badge to a dot.',
      'The painter bounds labels to one line with ellipsis. It does not automatically read the ambient TextScaler; this host applies that scale to labelStyle.fontSize and enlarges the bar height. Test very long translations with the number of tabs you actually ship.',
    ],
  ),
  DocSection(
    id: 'keyboard',
    heading: 'Know when selection occurs',
    paragraphs: [
      'Each native target is focusable and exposes selected/button semantics. Tab reaches destinations; Enter and Space activate the focused destination. The package does not provide arrow-key roving between these tabs, and this example does not claim that convention.',
      'Pointer selection is reported on tap-down. Cancellation releases the pressed pose but does not roll back a destination already selected on pointer-down. A horizontal drag is not a supported tab-scrubbing API. The guide tests that cancellation leaves a coherent selected screen rather than inventing a drag gesture.',
      'Reduced motion settles the spring and liquid phase. Physical touch, screen-reader announcements and GPU rendering still require device checks; widget semantics and deterministic input tests establish a narrower contract.',
    ],
  ),
  DocSection(
    id: 'debugging',
    heading: 'Diagnose the common integration mistakes',
    paragraphs: [
      'If the indicator moves but content does not change, wire onIndexChanged to your own screen state. If a draft disappears, check whether the selected body replaces the entire screen instead of retaining it. Do not create a new controller inside build.',
      'A bar needs a finite width. Put it inside a bounded Stack, Scaffold slot or constrained container; do not place it directly in an unconstrained horizontal Row. Leave enough bottom content padding so the last row remains reachable.',
      'For flat-looking glass, put structured content behind it and check renderer support. For a liquid indicator that looks different on another backend, distinguish the shader path from the painted lens fallback. The guide does not infer backend identity from the selected effect name.',
    ],
  ),
];
const _navLimits = [
  'Composition using nib_motion 0.3.4 and nib_components 0.2.2 local candidates. It is not an additional public Components widget.',
  'Physical Android/iOS touch, native safe areas, screen readers and GPU paths are not certified by the bounded Flutter preview.',
  'Pointer-down commits selection; cancelling a pointer does not restore the previous destination. Drag-to-select is not implemented.',
];
