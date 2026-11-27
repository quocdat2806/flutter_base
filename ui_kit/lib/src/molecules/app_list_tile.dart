import 'package:flutter/material.dart';

/// Material 3 list item. Pass [leadingIcon] or a custom [leading] widget.
/// [showChevron] adds a trailing arrow for navigation rows.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.showChevron = false,
    this.onTap,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool enabled;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: leading ?? (leadingIcon == null ? null : Icon(leadingIcon)),
      trailing:
          trailing ?? (showChevron ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      enabled: enabled,
      selected: selected,
      dense: dense,
    );
  }
}
