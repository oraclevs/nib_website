import '../../content/site_content.dart';
import '../component_model.dart';
import '../component_settings.dart';

const navigationComponentGuide = ComponentGuide(
  id: 'navigation-menu',
  title: 'Navigation menu',
  category: 'Navigation',
  summary: 'Build a destination tree with flyout or inline submenus, then keep the selected destination tied to your content.',
  symbols: [
    'NibNavigationMenu',
    'NibNavItem',
    'NibNavMenuController',
    'NibNavMenuOrientation',
  ],
  source: 'ComponetsNib/nib_components/lib/src/navigation_menu/',
  demoClass: 'NavigationComponentDemo',
  demoFile: 'lib/components/examples/navigation_component_demo.dart',
  initial: ComponentSettings(text: 'Overview'),
  previewHeight: 430,
  controls: [
    ComponentControl('text', 'Overview label', ComponentControlKind.text),
    ComponentControl(
      'vertical',
      'Vertical inline menus',
      ComponentControlKind.toggle,
    ),
    ComponentControl(
      'disabled',
      'Disable Monthly destination',
      ComponentControlKind.toggle,
    ),
    ComponentControl(
      'multiple',
      'Allow multiple open (vertical)',
      ComponentControlKind.toggle,
    ),
    ComponentControl(
      'animated',
      'Animate opened submenus',
      ComponentControlKind.toggle,
    ),
  ],
  minimalCode: '''String selected = 'home';

NibNavigationMenu(
  activeItemId: selected,
  items: const [
    NibNavItem(id: 'home', label: 'Home'),
    NibNavItem(id: 'settings', label: 'Settings'),
  ],
  onItemSelected: (id) => setState(() => selected = id),
)''',
  limitations: [
    'This menu does not own a browser router or page history.',
    'This is not the NibMotion bottom navigation widget.',
    'Changing the preview orientation remounts the menu to dismiss its old overlay; destination content remains selected.',
  ],
  sections: [
    DocSection(
      id: 'use',
      heading: 'Tie a destination to real content',
      paragraphs: [
        'Use NibNavigationMenu for a tree of application destinations. Each NibNavItem supplies a unique id and label. Children form nested destinations; icons and badges are optional widgets. IDs must be unique across the whole tree because they key overlay, focus and open-state bookkeeping.',
        'The menu reports onItemSelected and highlights activeItemId. It does not change your content or URL. Store the selected ID in your host state and render the matching content, as the preview does. For peer panels inside one view, use NibTabs; for a bottom bar with a liquid indicator, see the separately labelled NibMotion composition.',
      ],
    ),
    DocSection(
      id: 'directions',
      heading: 'Choose flyouts or inline expansion',
      paragraphs: [
        'orientation defaults to NibNavMenuOrientation.horizontal. Top-level items form a row and branch items open cascading flyouts. At narrow widths, the menu can place overflowing entries under More instead of compressing every label. Test with your longest translated label.',
        'Vertical orientation renders a column with nested inline children. allowMultipleOpen defaults to false and closes open siblings at the same depth when another branch opens. The setting applies to vertical mode; it does not turn horizontal flyouts into unrelated floating windows.',
        'A disabled NibNavItem cannot be selected. The preview disables only Monthly so you can compare enabled and disabled destinations in the same tree. Repeated selection calls the same callback; the host decides whether that resets content or preserves it.',
      ],
    ),
    DocSection(
      id: 'state',
      heading: 'Selection and open state are different',
      paragraphs: [
        'activeItemId is the visual selection supplied by the host. NibNavMenuController manages open submenus, not selection. Without an external controller, the widget creates and disposes its own controller. When you supply one, the host must dispose it.',
        'openChain is an unmodifiable list of horizontal flyout IDs from root to deepest submenu. openChainTo replaces that chain, closeFromDepth truncates it, and closeAll clears it. openIds is the separate set of vertically expanded IDs; toggleOpenId can close exclusiveSiblings while opening another branch. closeAll does not clear openIds.',
        'The example keeps the controller in State and disposes it with the example. Its vertical controller button uses toggleOpenId; the event readout records the resulting real openIds. Switching to code leaves the example mounted and keeps the destination selected.',
      ],
      code: '''final menu = NibNavMenuController();

// In a vertical menu:
menu.toggleOpenId('reports');

@override
void dispose() {
  menu.dispose();
  super.dispose();
}''',
    ),
    DocSection(
      id: 'motion',
      heading: 'Opt in to submenu motion',
      paragraphs: [
        'animated defaults to false. Set it to true to animate submenu entrance and exit through NibMotion. transition is optional; null uses the component default. This changes submenu motion, not the host page transition.',
        'NibTheme controls the menu colors and radii. Register the extension in ThemeData so the main row and captured submenu theme agree. The exported example includes the Ember extension. Keep contrast and disabled-state legibility when changing the preview accent.',
      ],
    ),
    DocSection(
      id: 'keyboard',
      heading: 'Keep menu focus local',
      paragraphs: [
        'Use Tab to reach a destination and activate it from the keyboard. Escape closes a horizontal flyout; pointer dismissal and selection remove its overlay. Test branch expansion separately from selecting a leaf. semanticLabel names the whole menu for assistive technology.',
        'The example does not bind global navigation shortcuts. When adding a router, keep menu activation local and use the reported ID in your routing callback. Do not put the menu inside a gallery link: clicking a submenu must not navigate away from the demonstration.',
      ],
    ),
    DocSection(
      id: 'troubleshooting',
      heading: 'When the selection does not change',
      paragraphs: [
        'If a click opens content but no entry looks selected, check that activeItemId matches the selected item ID exactly. If the highlight changes but the content does not, implement the host content update in onItemSelected. Neither result is automatic.',
        'Duplicate IDs can attach focus or overlays to the wrong item. Generate stable IDs from your data, not list positions. For a narrow preview, allow the component to measure a bounded width; an unbounded horizontal parent prevents meaningful overflow decisions.',
        'A phone-shaped preview is a layout fixture. It is not evidence of physical touch behavior or a native-device pass. Current execution evidence is listed with the catalog coverage record.',
      ],
    ),
  ],
);
