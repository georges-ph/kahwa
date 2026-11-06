import 'package:flutter/material.dart';
import 'package:kahwa/models/category.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/theme/palette.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/labels.dart';

/// How a page will look with the choices being made, before saving.
class PagePreview extends StatelessWidget {
  const PagePreview({
    super.key,
    required this.name,
    required this.color,
    required this.cover,
    required this.initials,
    this.emoji,
    this.tagline = '',
  });

  final String name;
  final Color color;
  final CoverPattern cover;
  final String initials;
  final String? emoji;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CoverBanner(color: color, pattern: cover, height: 92),
              PositionedDirectional(
                start: 18,
                bottom: -30,
                child: AvatarBox(
                  color: color,
                  emoji: emoji,
                  initials: initials,
                  size: 64,
                  ring: true,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 38, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? context.l10n.yourName : name,
                  style: context.text.titleLarge,
                ),
                if (tagline.isNotEmpty)
                  Text(
                    tagline,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.kahwa.muted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (i, color) in creatorColors.indexed)
          _Swatch(
            label: context.l10n.colorOption(i + 1),
            selected: color.toARGB32() == value,
            onTap: () => onChanged(color.toARGB32()),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: color.toARGB32() == value
                  ? Icon(Icons.check_rounded, color: foregroundOn(color))
                  : null,
            ),
          ),
      ],
    );
  }
}

class EmojiPicker extends StatelessWidget {
  const EmojiPicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.initials,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  /// Shown as the first choice: no emoji, the initials of the name.
  final String initials;

  @override
  Widget build(BuildContext context) {
    Widget cell(String? emoji) {
      return _Swatch(
        selected: emoji == value,
        onTap: () => onChanged(emoji),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.kahwa.subtle,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            emoji ?? (initials.isEmpty ? 'Aa' : initials),
            style: emoji == null
                ? context.text.titleSmall
                : const TextStyle(fontSize: 22),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [cell(null), for (final emoji in avatarEmojis) cell(emoji)],
    );
  }
}

class PatternPicker extends StatelessWidget {
  const PatternPicker({
    super.key,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final CoverPattern value;
  final Color color;
  final ValueChanged<CoverPattern> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final pattern in CoverPattern.values)
          _Swatch(
            label: context.l10n.patternOption(pattern.index + 1),
            selected: pattern == value,
            onTap: () => onChanged(pattern),
            child: SizedBox(
              width: 72,
              child: CoverBanner(
                color: color,
                pattern: pattern,
                height: 44,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }
}

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CreatorCategory? value;
  final ValueChanged<CreatorCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in CreatorCategory.values)
          ChoiceChip(
            selected: category == value,
            onSelected: (selected) => onChanged(selected ? category : null),
            avatar: Icon(
              category.icon,
              size: 18,
              color: category == value
                  ? context.colors.onPrimary
                  : context.colors.primary,
            ),
            label: Text(categoryLabel(context, category)),
          ),
      ],
    );
  }
}

/// A choice with a ring around it when selected.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.selected,
    required this.onTap,
    required this.child,
    this.label,
  });

  /// What a screen reader says, for a choice that has no text of its own.
  final String? label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final swatch = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? context.colors.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: child,
      ),
    );
    return Semantics(
      container: true,
      label: label,
      selected: selected,
      button: true,
      child: swatch,
    );
  }
}
