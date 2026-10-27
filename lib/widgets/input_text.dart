import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/widgets/page_body.dart';

/// Rounded text field with an optional [title] and [subtitle] above it.
///
/// When an error appears on it, the page scrolls to it, so an error above a
/// button at the bottom of a long form is not missed.
class InputText extends StatefulWidget {
  const InputText({
    super.key,
    this.controller,
    this.title,
    this.subtitle,
    this.hint,
    this.icon,
    this.prefixText,
    this.suffixIcon,
    this.suffixOnTap,
    this.suffixTooltip,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.obscureText = false,
    this.readOnly = false,
    this.digitsOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? title;
  final String? subtitle;
  final String? hint;
  final IconData? icon;
  final String? prefixText;
  final IconData? suffixIcon;
  final VoidCallback? suffixOnTap;
  final String? suffixTooltip;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool readOnly;
  final bool digitsOnly;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  /// Set while a scroll is waiting for the next frame. Fields update from
  /// the top of the page down, so the first error of a form scrolls and the
  /// ones below it do not.
  static bool _isScrollScheduled = false;

  @override
  void didUpdateWidget(InputText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText == null ||
        widget.errorText == oldWidget.errorText ||
        _isScrollScheduled) {
      return;
    }
    _isScrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isScrollScheduled = false;
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final InputText(
      :controller,
      :title,
      :subtitle,
      :hint,
      :icon,
      :prefixText,
      :suffixIcon,
      :suffixOnTap,
      :suffixTooltip,
      :errorText,
      :keyboardType,
      :textInputAction,
      :textCapitalization,
      :autofillHints,
      :obscureText,
      :readOnly,
      :digitsOnly,
      :maxLines,
      :onChanged,
      :onSubmitted,
    ) = widget;
    final primary = Theme.of(context).colorScheme.primary;

    Widget? prefix;
    if (icon != null) {
      prefix = Padding(
        padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
        child: Icon(icon, color: primary),
      );
    } else if (prefixText != null) {
      prefix = Padding(
        padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
        child: Text(prefixText, style: TextStyle(color: primary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionTitle(title),
        if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle)],
        if (title != null || subtitle != null) const SizedBox(height: 16),
        TextField(
          controller: controller,
          keyboardType: digitsOnly ? TextInputType.number : keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          obscureText: obscureText,
          readOnly: readOnly,
          minLines: 1,
          maxLines: maxLines,
          inputFormatters: [
            if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: suffixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: IconButton(
                      onPressed: suffixOnTap,
                      tooltip: suffixTooltip,
                      icon: Icon(suffixIcon, color: primary),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
