import 'package:flutter/material.dart';

import '../atoms/app_button.dart';
import '../tokens/app_spacing.dart';

/// Vertical form with consistent field spacing and a full-width submit
/// button. [onSubmit] is only called when all validators pass.
class AppForm extends StatefulWidget {
  const AppForm({
    super.key,
    required this.children,
    required this.onSubmit,
    this.submitLabel = 'Tiếp tục',
    this.isLoading = false,
    this.spacing = AppSpacing.lg,
    this.formKey,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final List<Widget> children;
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool isLoading;
  final double spacing;

  /// Optional external key, e.g. to call `reset()` from outside.
  final GlobalKey<FormState>? formKey;
  final AutovalidateMode autovalidateMode;

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  late final GlobalKey<FormState> _key =
      widget.formKey ?? GlobalKey<FormState>();

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_key.currentState?.validate() ?? false) widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      autovalidateMode: widget.autovalidateMode,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: widget.spacing,
          children: [
            ...widget.children,
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: widget.submitLabel,
              onPressed: _submit,
              isLoading: widget.isLoading,
              size: AppButtonSize.large,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
