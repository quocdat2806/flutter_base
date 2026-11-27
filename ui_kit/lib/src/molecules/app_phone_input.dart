import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../atoms/app_text_field.dart';

/// Phone number field with a fixed dial-code prefix (default +84).
/// [onChanged] receives the national number as typed (digits only).
class AppPhoneInput extends StatelessWidget {
  const AppPhoneInput({
    super.key,
    this.controller,
    this.label = 'Số điện thoại',
    this.hint,
    this.dialCode = '+84',
    this.maxDigits = 10,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String dialCode;
  final int maxDigits;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;

  /// Converts a national number (e.g. `0912345678`) to E.164 (`+84912345678`).
  static String toE164(String national, {String dialCode = '+84'}) {
    final digits = national.replaceAll(RegExp(r'\D'), '');
    return '$dialCode${digits.startsWith('0') ? digits.substring(1) : digits}';
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.phone_outlined,
      prefixText: '$dialCode ',
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxDigits),
      ],
      validator: validator,
      errorText: errorText,
      enabled: enabled,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
