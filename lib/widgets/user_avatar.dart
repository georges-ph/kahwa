import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/formatters.dart';

/// Round badge with the initials of a user on [color].
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.color,
  });

  final String name;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final background = color ?? Theme.of(context).colorScheme.primary;

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: Text(
        getInitials(name),
        style: TextStyle(
          color: foregroundOn(background),
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
