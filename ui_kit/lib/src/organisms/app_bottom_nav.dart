import 'package:flutter/material.dart';

import '../atoms/app_badge.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
    this.showDot = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  /// Number badge; takes precedence over [showDot].
  final int? badgeCount;
  final bool showDot;
}

/// Material 3 navigation bar (3–5 destinations).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.labelBehavior = NavigationDestinationLabelBehavior.alwaysShow,
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final NavigationDestinationLabelBehavior labelBehavior;

  @override
  Widget build(BuildContext context) {
    Widget withBadge(AppNavItem item, IconData icon) {
      final iconWidget = Icon(icon);
      if (item.badgeCount != null) {
        return AppBadge(count: item.badgeCount, child: iconWidget);
      }
      return item.showDot ? AppBadge(child: iconWidget) : iconWidget;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelBehavior: labelBehavior,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: withBadge(item, item.icon),
            selectedIcon: withBadge(item, item.selectedIcon ?? item.icon),
            label: item.label,
          ),
      ],
    );
  }
}
