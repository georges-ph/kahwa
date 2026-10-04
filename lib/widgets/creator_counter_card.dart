import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';

/// A number with a label below it, e.g. `12 Fans`. Tappable when [onTap] is
/// set.
class CreatorCounterCard extends StatelessWidget {
  const CreatorCounterCard({
    super.key,
    required this.counter,
    required this.title,
    this.onTap,
  });

  final int counter;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kFillColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                counter.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
