import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kahwa/utils/colors.dart';

class PriceInputText extends StatelessWidget {
  const PriceInputText({
    Key? key,
    required this.price,
    this.formatLbp = false,
    required this.onChanged,
  }) : super(key: key);

  final int price;
  final bool? formatLbp;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat();

    return Expanded(
      child: Container(
        decoration: ShapeDecoration(
          color: kGreyColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: TextField(
          controller: TextEditingController()
            ..text =
                formatLbp == true ? formatter.format(price) : price.toString(),
          onChanged: (value) => onChanged(value),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 0.toString(),
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(4),
          ),
        ),
      ),
    );
  }
}
