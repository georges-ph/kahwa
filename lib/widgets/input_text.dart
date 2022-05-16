import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class InputText extends StatelessWidget {
  const InputText({
    Key? key,
    this.hint,
    this.icon,
    this.iconColor = kBrownColor,
    this.suffixIcon,
    this.suffixOnTap,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.readOnly = false,
    this.minLines,
    this.maxLines = 1,
    this.enableInteractiveSelection = true,
    this.title,
    this.subtitle,
    this.prefixText,
  }) : super(key: key);

  final String? hint;
  final IconData? icon;
  final Color? iconColor;
  final IconData? suffixIcon;
  final Function()? suffixOnTap;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final bool? obscureText;
  final bool? readOnly;
  final int? minLines;
  final int? maxLines;
  final bool? enableInteractiveSelection;
  final String? title;
  final String? subtitle;
  final String? prefixText;

  // TODO: try to use a TextField in a ListTile instead of all this

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == null
            ? Container()
            : Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: kSemiBoldFontWeight,
                    ),
              ),
        subtitle == null ? Container() : verticalSpace(height: 8),
        subtitle == null ? Container() : Text(subtitle!),
        title == null ? Container() : verticalSpace(height: 16),
        Container(
          padding: EdgeInsets.only(
            left: icon == null ? 24 : 0,
            right: suffixIcon == null ? 24 : 0,
          ),
          decoration: ShapeDecoration(
            color: kGreyColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: TextField(
            enableInteractiveSelection: enableInteractiveSelection!,
            minLines: minLines,
            maxLines: maxLines,
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization!,
            obscureText: obscureText!,
            readOnly: readOnly!,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint ?? "Hint text",
              prefixIcon: icon != null
                  ? Padding(
                      padding:
                          const EdgeInsetsDirectional.only(start: 24, end: 16),
                      child: Icon(
                        icon,
                        color: iconColor,
                      ),
                    )
                  : prefixText != null
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: Text(
                            prefixText!,
                            style: const TextStyle(
                              color: kBrownColor,
                            ),
                          ),
                        )
                      : null,
              prefixIconConstraints: prefixText != null
                  ? const BoxConstraints(minWidth: 0, minHeight: 0)
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: suffixOnTap,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 16, end: 24),
                        child: Icon(
                          suffixIcon,
                          color: kBrownColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
