import 'package:flutter/material.dart';

class AppDrawerItem {
  const AppDrawerItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  /// Trailing text such as an unread count ("24").
  final String? badge;
}

class AppDrawerSection {
  const AppDrawerSection({this.title, required this.items});

  final String? title;
  final List<AppDrawerItem> items;
}

/// Material 3 navigation drawer. Indices passed to [onSelected] are flat
/// across all sections, in order.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
    this.header,
    this.footer,
  });

  final List<AppDrawerSection> sections;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Drawer width minus tile padding (12 * 2) and icon + gaps (16 + 24 + 12).
    final labelWidth = (DrawerTheme.of(context).width ?? 304) - 24 - 52;
    final children = <Widget>[];
    if (header != null) children.add(header!);

    for (var s = 0; s < sections.length; s++) {
      final section = sections[s];
      if (s > 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Divider(),
          ),
        );
      }
      if (section.title != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(section.title!, style: theme.textTheme.titleSmall),
          ),
        );
      }
      for (final item in section.items) {
        children.add(
          NavigationDrawerDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon ?? item.icon),
            // The destination lays out its label in an unbounded Row, so
            // bound it to the indicator width minus icon + gaps (16+24+12).
            label: SizedBox(
              width: labelWidth,
              child: Row(
                children: [
                  Expanded(
                    child: Text(item.label, overflow: TextOverflow.ellipsis),
                  ),
                  if (item.badge != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        item.badge!,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }
    if (footer != null) children.add(footer!);

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        onSelected(i);
        Navigator.maybePop(context);
      },
      children: children,
    );
  }
}
