import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class InputText extends StatelessWidget {
  const InputText({
    Key? key,
    this.hint,
    this.icon,
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
  }) : super(key: key);

  final String? hint;
  final IconData? icon;
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
                  child: Icon(
                    icon,
                    color: kRedColor,
                  ),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: suffixOnTap,
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 16, end: 24),
                    child: Icon(
                      suffixIcon,
                      color: kRedColor,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
