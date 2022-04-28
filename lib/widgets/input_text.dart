import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class InputText extends StatelessWidget {
  const InputText({
    Key? key,
    this.text = "",
    this.icon,
    this.hint,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.suffixOnTap,
    this.inverted = false,
    this.readOnly = false,
  }) : super(key: key);

  final String? text;
  final IconData? icon;
  final String? hint;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final Function(String)? onChanged;
  final Function()? suffixOnTap;
  final bool? inverted;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: ShapeDecoration(
        color: inverted == true
            ? kWhiteColor.withOpacity(0.2)
            : kGreyColor.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: TextField(
        controller: TextEditingController()..text = text!,
        minLines: 1,
        maxLines: obscureText == true ? 1 : 10,
        readOnly: readOnly!,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: textCapitalization!,
        cursorColor: inverted == true ? kWhiteColor : null,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              color: inverted == true ? kWhiteColor : null,
            ),
        decoration: InputDecoration(
          hintText: hint ?? "Hint text",
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: inverted == true ? kWhiteColor : kGreyColor,
              ),
          border: InputBorder.none,
          prefixIcon: icon != null
              ? Icon(
                  icon ?? Icons.question_mark_rounded,
                  color: inverted == true ? kWhiteColor : kRedColor,
                )
              : null,
          suffixIcon: GestureDetector(
            onTap: suffixOnTap,
            child: Icon(
              suffixIcon,
              color: kRedColor,
            ),
          ),
        ),
      ),
    );
  }
}
