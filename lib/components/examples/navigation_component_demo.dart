import 'package:flutter/material.dart';
import 'package:nib_components/nib_components.dart';

import '../component_settings.dart';

/// Local application navigation: selection changes content, never the site URL.
class NavigationComponentDemo extends StatefulWidget {
  const NavigationComponentDemo({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onEvent,
  });
  final ComponentSettings settings;
  final ValueChanged<ComponentSettings> onChanged;
  final ValueChanged<String> onEvent;
  @override
  State<NavigationComponentDemo> createState() =>
      _NavigationComponentDemoState();
}

class _NavigationComponentDemoState extends State<NavigationComponentDemo> {
  final _controller = NibNavMenuController();
  String _selected = 'overview';
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NibTheme.of(context);
    final settings = widget.settings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NibNavigationMenu(
          key: ValueKey(settings.vertical),
          semanticLabel: 'Example workspace destinations',
          controller: _controller,
          orientation: settings.vertical
              ? NibNavMenuOrientation.vertical
              : NibNavMenuOrientation.horizontal,
          activeItemId: _selected,
          allowMultipleOpen: settings.multiple,
          animated: settings.animated,
          items: [
            NibNavItem(
              id: 'overview',
              label: settings.text,
              icon: const Icon(Icons.home_outlined, size: 17),
            ),
            NibNavItem(
              id: 'reports',
              label: 'Reports',
              children: [
                const NibNavItem(id: 'weekly', label: 'Weekly'),
                NibNavItem(
                  id: 'monthly',
                  label: 'Monthly',
                  disabled: settings.disabled,
                ),
              ],
            ),
            const NibNavItem(
              id: 'settings',
              label: 'Settings',
              icon: Icon(Icons.tune, size: 17),
            ),
          ],
          onItemSelected: (id) {
            setState(() => _selected = id);
            widget.onEvent('onItemSelected: $id');
          },
        ),
        const SizedBox(height: 20),
        Container(
          key: const ValueKey('navigation-local-content'),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tokens.secondary,
            borderRadius: BorderRadius.circular(tokens.radiusDefault),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (_selected) {
                  'weekly' => 'This week',
                  'monthly' => 'This month',
                  'settings' => 'Workspace settings',
                  'reports' => 'Reports',
                  _ => 'Workspace overview',
                },
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(switch (_selected) {
                'weekly' =>
                  '3 draft notes are ready for review. Local fixture data.',
                'monthly' =>
                  '12 notes were filed this month. Local fixture data.',
                'settings' =>
                  'Change the example orientation or label in Customize.',
                'reports' =>
                  'Choose a weekly or monthly report from the submenu.',
                _ =>
                  'Select a destination. The menu and this panel stay in sync.',
              }),
              const SizedBox(height: 8),
              Text(
                'Selected destination: $_selected',
                semanticsLabel: 'Selected destination: $_selected',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (settings.vertical)
          NibButton(
            label: 'Toggle Reports from controller',
            onPressed: () {
              _controller.toggleOpenId('reports');
              widget.onEvent(
                'controller.openIds: ${_controller.openIds.join(', ')}',
              );
            },
          ),
      ],
    );
  }
}
