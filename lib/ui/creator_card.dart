import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/labels.dart';

/// A creator on Explore and the welcome page: their banner, avatar, name
/// and what they make.
class CreatorCard extends StatelessWidget {
  const CreatorCard({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final category = profile.category;
    return Card(
      child: InkWell(
        onTap: () => context.push(Routes.page(profile)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CoverBanner(
                  color: Color(profile.color),
                  pattern: CoverPattern.of(profile.cover),
                  height: 70,
                ),
                PositionedDirectional(
                  start: 14,
                  bottom: -26,
                  child: ProfileAvatar(profile: profile, size: 54, ring: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: context.text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Kept as an empty line without a username, so every card
                  // lines up with the next one.
                  Text(
                    profile.username == null ? ' ' : '@${profile.username}',
                    style: context.text.bodySmall?.copyWith(
                      color: context.kahwa.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 40,
                    child: Text(
                      profile.tagline.isEmpty
                          ? context.l10n.noTagline
                          : profile.tagline,
                      style: context.text.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (category != null) ...[
                        Icon(
                          category.icon,
                          size: 16,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            categoryLabel(context, category),
                            style: context.text.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Icon(
                        Icons.favorite_rounded,
                        size: 15,
                        color: context.kahwa.muted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${profile.fans}',
                        style: context.text.labelMedium?.copyWith(
                          color: context.kahwa.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A creator as one row: avatar, name, tagline.
class CreatorRow extends StatelessWidget {
  const CreatorRow({super.key, required this.profile, this.trailing});

  final Profile profile;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push(Routes.page(profile)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: ProfileAvatar(profile: profile, size: 44),
      title: Text(
        profile.name,
        style: context.text.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        profile.tagline.isNotEmpty
            ? profile.tagline
            : profile.username != null
            ? '@${profile.username}'
            : '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
      ),
      trailing: trailing,
    );
  }
}
