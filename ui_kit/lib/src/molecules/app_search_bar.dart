import 'package:flutter/material.dart';

/// Material 3 search bar with a leading search icon and a clear button
/// that appears once there is text.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Tìm kiếm',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.trailing,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<Widget>? trailing;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      hintText: widget.hint,
      autoFocus: widget.autofocus,
      leading: const Icon(Icons.search),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textInputAction: TextInputAction.search,
      trailing: [
        if (_controller.text.isNotEmpty)
          IconButton(
            tooltip: 'Xoá',
            icon: const Icon(Icons.close),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          ),
        ...?widget.trailing,
      ],
    );
  }
}
