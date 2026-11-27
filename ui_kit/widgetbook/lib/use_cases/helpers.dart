import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// One component with its use cases.
WidgetbookComponent component(
  String name,
  Map<String, WidgetBuilder> useCases,
) => WidgetbookComponent(
  name: name,
  useCases: [
    for (final e in useCases.entries)
      WidgetbookUseCase(name: e.key, builder: e.value),
  ],
);

/// Scrollable padded frame for a use case.
class Showcase extends StatelessWidget {
  const Showcase({super.key, required this.children, this.spacing = 16});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing,
          children: children,
        ),
      ),
    );
  }
}

/// Holds a value locally so interactive widgets (checkbox, switch…)
/// respond to taps inside Widgetbook.
class Stateful<T> extends StatefulWidget {
  const Stateful({super.key, required this.initial, required this.builder});

  final T initial;
  final Widget Function(BuildContext context, T value, ValueChanged<T> set)
  builder;

  @override
  State<Stateful<T>> createState() => _StatefulState<T>();
}

class _StatefulState<T> extends State<Stateful<T>> {
  late T _value = widget.initial;

  @override
  void didUpdateWidget(covariant Stateful<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, (v) => setState(() => _value = v));
}

/// Shorthand for "print the callback" handlers in use cases.
void log(String message) => debugPrint('[widgetbook] $message');

const sampleImage = 'https://picsum.photos/seed/vietlife/400/400';
