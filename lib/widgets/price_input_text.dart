import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class PriceInputText extends StatelessWidget {
  const PriceInputText({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: ShapeDecoration(
          color: kGreyColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 0.toString(),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.all(4),
          ),
        ),
      ),
    );
  }
}
