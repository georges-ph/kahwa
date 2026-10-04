import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/models/creator_color.dart';

/// Row of round swatches to pick the accent color of a creator page.
class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CreatorColor selected;
  final ValueChanged<CreatorColor> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final option in CreatorColor.values)
          Tooltip(
            message: option.name,
            child: Material(
              color: option.color,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(option),
                child: SizedBox.square(
                  dimension: 44,
                  child: option == selected
                      ? Icon(
                          Icons.check_rounded,
                          color: foregroundOn(option.color),
                        )
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
