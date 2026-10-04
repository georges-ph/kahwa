import 'package:flutter/material.dart';

/// Round shortcut that sets the number of kahwas to [value].
class KahwaCounter extends StatelessWidget {
  const KahwaCounter({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primary : colorScheme.surface,
      shape: CircleBorder(side: BorderSide(color: colorScheme.primary)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 40,
          child: Center(
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
