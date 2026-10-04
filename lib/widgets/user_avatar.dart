import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/formatters.dart';

/// Round picture of a user, falling back to their initials on [color].
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.image,
    this.radius = 20,
    this.color,
  });

  final String name;
  final String? image;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final background = color ?? Theme.of(context).colorScheme.primary;
    final image = this.image;
    final hasImage = image != null && image.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      foregroundImage: hasImage ? NetworkImage(image) : null,
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
