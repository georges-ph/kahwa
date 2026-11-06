import 'package:flutter/material.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/theme/palette.dart';

/// A user's picture: their emoji, or their initials, on their page color,
/// in a rounded square.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 48,
    this.ring = false,
  });

  final Profile? profile;
  final double size;

  /// Draws a border in the page color around it, to sit on a banner.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return AvatarBox(
      color: Color(p?.color ?? creatorColors.first.toARGB32()),
      emoji: p?.emoji,
      initials: p == null ? '' : initialsOf(p.name),
      size: size,
      ring: ring,
    );
  }
}

/// The drawing behind [ProfileAvatar], also used by pickers to preview a
/// choice that is not saved yet.
class AvatarBox extends StatelessWidget {
  const AvatarBox({
    super.key,
    required this.color,
    required this.initials,
    this.emoji,
    this.size = 48,
    this.ring = false,
  });

  final Color color;
  final String initials;
  final String? emoji;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.32);
    final hasEmoji = emoji != null;
    // An emoji sits on a soft tint of the color, initials on the color.
    final background = hasEmoji
        ? Color.alphaBlend(color.withValues(alpha: 0.18), Colors.white)
        : color;
    final box = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: hasEmoji
          ? Text(emoji!, style: TextStyle(fontSize: size * 0.5, height: 1.1))
          : Text(
              initials,
              style: TextStyle(
                color: foregroundOn(color),
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
    );
    if (!ring) return box;
    final ringWidth = (size * 0.06).clamp(2.0, 5.0);
    return Container(
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(size * 0.32 + ringWidth),
      ),
      child: box,
    );
  }
}
