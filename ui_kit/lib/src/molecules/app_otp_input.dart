import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_radius.dart';

/// OTP / PIN input drawn as [length] boxes. Backed by a single hidden text
/// field, so paste and SMS autofill (`AutofillHints.oneTimeCode`) work.
class AppOtpInput extends StatefulWidget {
  const AppOtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.controller,
    this.autofocus = true,
    this.obscure = false,
    this.hasError = false,
    this.boxSize = 48,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final TextEditingController? controller;
  final bool autofocus;
  final bool obscure;
  final bool hasError;
  final double boxSize;

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _focusNode.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final text = _controller.text;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    return Semantics(
      label: 'Mã OTP ${widget.length} số',
      textField: true,
      child: Stack(
        children: [
          // Real input; transparent and stretched under the boxes.
          Positioned.fill(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
              ),
              onChanged: _handleChanged,
            ),
          ),
          IgnorePointer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _box(
                    context,
                    char: i < text.length ? text[i] : '',
                    active: _focusNode.hasFocus && i == activeIndex,
                    borderColor: widget.hasError
                        ? c.error
                        : (_focusNode.hasFocus && i == activeIndex)
                        ? c.primary
                        : c.outline,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(
    BuildContext context, {
    required String char,
    required bool active,
    required Color borderColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.boxSize,
      height: widget.boxSize + 8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: AppRadius.smAll,
        border: Border.all(color: borderColor, width: active ? 2 : 1),
      ),
      child: Text(
        widget.obscure && char.isNotEmpty ? '•' : char,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
