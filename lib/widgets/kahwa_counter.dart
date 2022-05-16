import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class KahwaCounter extends StatelessWidget {
  const KahwaCounter({
    Key? key,
    required this.text,
    required this.kahwas,
    required this.onTap,
  }) : super(key: key);

  final int text;
  final String kahwas;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: kahwas == text.toString() ? kBrownColor : kWhiteColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: kBrownColor,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text.toString(),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: kahwas == text.toString() ? kWhiteColor : kBrownColor,
                ),
          ),
        ),
      ),
    );
  }
}
