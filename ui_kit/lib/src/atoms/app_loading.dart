import 'package:flutter/material.dart';

/// Material 3 progress indicators. [value] null = indeterminate.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.value, this.size = 40, this.message})
    : _linear = false;

  const AppLoading.linear({super.key, this.value, this.message})
    : _linear = true,
      size = 0;

  final double? value;
  final double size;
  final String? message;
  final bool _linear;

  @override
  Widget build(BuildContext context) {
    final indicator = _linear
        ? LinearProgressIndicator(value: value)
        : SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(value: value),
          );
    if (message == null) return indicator;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(height: 16),
        Text(message!, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

/// Covers [child] with a scrim and spinner while [isLoading] is true,
/// blocking interaction underneath.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.scrim
                  .withValues(alpha: 0.32),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppLoading(message: message),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
