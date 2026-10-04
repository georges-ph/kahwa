import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/widgets/page_body.dart';

/// Rounded text field with an optional [title] and [subtitle] above it.
class InputText extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
        child: Text(prefixText!, style: TextStyle(color: primary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionTitle(title!),
        if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!)],
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
