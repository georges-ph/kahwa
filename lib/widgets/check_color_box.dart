import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class CheckColorBox extends StatelessWidget {
  const CheckColorBox({
    Key? key,
    required this.color,
    required this.checkedValue,
    required this.checked,
  }) : super(key: key);

  final Color color;
  final bool checkedValue;
  final Function(bool) checked;

  @override
  Widget build(BuildContext context) {
    bool _checked = checkedValue;
    return GestureDetector(
      onTap: () {
        _checked = !_checked;
        checked(_checked);
      },
      child: ClipOval(
        child: SizedBox.square(
          dimension: 40,
          child: ColoredBox(
            color: color,
            child: Icon(
              Icons.check_rounded,
              color: _checked ? kWhiteColor : kTransparentColor,
            ),
          ),
        ),
      ),
    );
  }
}
